from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import shutil
from pathlib import Path
import requests

app = FastAPI()

# 图片保存目录
UPLOAD_DIR = Path("uploaded_images")
UPLOAD_DIR.mkdir(exist_ok=True)

# llama-cli 服务的地址
LLAMA_CLI_API_URL = "http://127.0.0.1:8000/generate"  # 假设 llama-cli 服务监听此地址

def generate_prompt(filename: str) -> str:
    """
    构造用于垃圾分类的 prompt。
    """
    return (
        f"以下是一张垃圾图片的描述，文件名为 {filename}。"
        "请根据垃圾分类的规则，提供以下两项内容：\n"
        "1. 该垃圾的具体类型。\n"
        "2. 对应的处理建议。\n"
        "注意：垃圾分类规则参考通用标准（如可回收垃圾、厨余垃圾、有害垃圾等）。"
    )

def classify_garbage_with_llama(prompt: str) -> str:
    """
    通过 llama-cli 服务生成垃圾分类建议。
    """
    try:
        response = requests.post(LLAMA_CLI_API_URL, json={"prompt": prompt, "max_tokens": 200})
        response.raise_for_status()
        result = response.json()
        return result.get("text", "").strip()  # 获取生成的文本
    except requests.exceptions.RequestException as e:
        return f"Error calling llama-cli: {e}"

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 保存上传的图片
        file_path = UPLOAD_DIR / file.filename
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 构造 prompt
        prompt = generate_prompt(file.filename)

        # 调用 llama-cli 服务生成分类建议
        suggestion = classify_garbage_with_llama(prompt)

        # 返回响应
        return {
            "filename": file.filename,
            "message": "File uploaded successfully!",
            "suggestion": suggestion
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": f"Error: {e}"})


@app.get("/")
def read_root():
    return {"Hello": "World"}
