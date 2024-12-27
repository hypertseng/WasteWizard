from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import shutil
from pathlib import Path
import subprocess
import threading
import queue
import os

app = FastAPI()

# 图片保存目录
UPLOAD_DIR = Path("./onnx_mobilenetv2_c++")
UPLOAD_DIR.mkdir(exist_ok=True)

# llama-cli 路径和命令
LLAMA_CLI_COMMAND = [
    "../llama.cpp/build/bin/llama-cli",
    "-m", "../qwen2.5-0.5b-instruct-q4_k_m.gguf",
    "-t", "4",
    "-cnv",
    "-p", "你是一个垃圾分类助手，请根据我提供的物体类别给出建议",
]

# MobileNet 二进制文件路径
MOBILENET_PATH = Path("./onnx_mobilenetv2_c++")

# llama-cli 进程和线程通信队列
llama_process = None
llama_queue = queue.Queue()

def start_llama_cli():
    """
    启动 llama-cli 进程并启动后台线程监听其输出。
    """
    global llama_process
    try:
        llama_process = subprocess.Popen(
            LLAMA_CLI_COMMAND,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            # universal_newlines=True
        )

        # 启动监听输出的线程
        threading.Thread(target=read_llama_output, daemon=True).start()
    except Exception as e:
        print(f"Failed to start llama-cli: {e}")
        raise

def stop_llama_cli():
    """
    停止 llama-cli 进程。
    """
    global llama_process
    if llama_process:
        llama_process.terminate()
        llama_process.wait()

def read_llama_output():
    """
    持续读取 llama-cli 的输出，并存入队列。
    """
    global llama_process
    while llama_process and llama_process.stdout:
        try:
            line = llama_process.stdout.readline()
            if line:
                print("llama-cli:", line, end="")
                llama_queue.put(line)
        except Exception as e:
            print(f"Error reading llama-cli output: {e}")
            break

def send_prompt_to_llama(prompt: str) -> str:
    """
    发送 prompt 到 llama-cli，并读取其响应。
    """
    global llama_process
    try:
        # 发送 prompt
        print("send prompt to qwen2.5")
        llama_process.stdin.write(prompt + "\n")
        llama_process.stdin.flush()
        
        # 从队列中读取响应
        response_lines = []
        flag = False
        while True:
            try:
                # 阻塞读取队列中的输出，设置超时时间防止死锁
                line = llama_queue.get(timeout=180)
                if line[0] == ">" : flag = True
                if line.strip() == "" and flag:
                    break
                response_lines.append(line.strip())
            except queue.Empty:
                break
        return "\n".join(response_lines)
    except Exception as e:
        return f"Error interacting with llama-cli: {e}"

def classify_image_with_mobilenet(image_path: str) -> str:
    """
    使用二进制文件 mobilenet_example 对图片进行推理，并返回置信率最高的类别。
    """
    try:
        # 调用 mobilenet_example 二进制文件进行推理
        result = subprocess.run(
            ["./mobilenetv2_example"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            raise RuntimeError(f"MobileNet inference failed: {result.stderr.strip()}")

        # 提取推理结果中最高置信率的类别
        output_lines = result.stdout.splitlines()
        top1_category = None

        # 找到 '********** probability top5: **********' 行
        for i, line in enumerate(output_lines):
            if "********** probability top5:" in line:
                # 下一行是置信率最高的类别
                top1_line = output_lines[i + 1].strip()
                # 提取类别名称（去掉类别编号和置信度）
                top1_category = " ".join(top1_line.split()[1:])
                break

        if top1_category:
            print("category:", top1_category)
            return top1_category
        else:
            raise ValueError("Failed to parse top1 category from MobileNet output.")

    except Exception as e:
        return f"Error during MobileNet inference: {e}"

def generate_prompt(image_class: str) -> str:
    """
    构造用于垃圾分类建议的 prompt。
    """
    return (
        f"你是一个垃圾分类助手，专注于根据输入的垃圾名称或者类别，提供垃圾的具体分类（如可回收垃圾、不可回收垃圾、厨余垃圾、有害垃圾等）以及处理建议，请尽可能简洁、准确地回答，并按以下规则进行回复：\\1. 该垃圾的具体类型。\\2. 对应的处理建议，如果垃圾属于特殊类别，请标明具体处理方式（如电池、有毒化学品等的处理建议。）\\这是识别出的垃圾类别：{image_class}。\\请回答并给出建议："
    )

# FastAPI 生命周期事件
@app.on_event("startup")
def on_startup():
    """
    FastAPI 启动时启动 llama-cli。
    """
    start_llama_cli()

@app.on_event("shutdown")
def on_shutdown():
    """
    FastAPI 关闭时停止 llama-cli。
    """
    stop_llama_cli()

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 保存上传的图片
        file_path = UPLOAD_DIR / "persian_cat.jpg"
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        cwd = os.getcwd()
        os.chdir(MOBILENET_PATH)

        # 使用 MobileNet 二进制文件进行推理
        image_class = classify_image_with_mobilenet(str(file_path))

        os.chdir(cwd)

        # 构造 prompt 并调用 llama-cli 生成分类建议
        prompt = generate_prompt(image_class)
        suggestion = send_prompt_to_llama(prompt)
        print("llm output:", suggestion)

        # 返回响应
        return {
            "message": "File uploaded and processed successfully!",
            "classification": image_class,
            "suggestion": suggestion
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": f"Error: {e}"})


@app.get("/")
def read_root():
    return {"Hello": "World"}
