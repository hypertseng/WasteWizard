from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import shutil
from pathlib import Path

app = FastAPI()

# 创建一个保存图片的目录
UPLOAD_DIR = Path("uploaded_images")
UPLOAD_DIR.mkdir(exist_ok=True)

@app.post("/upload/")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 将上传的图片保存到本地
        file_path = UPLOAD_DIR / file.filename
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 返回上传成功的响应
        return {"filename": file.filename, "message": "File uploaded successfully!"}
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": f"Error: {e}"})
