import picker from '@ohos.file.picker';
import {copyFileToCache } from '../util/tool'
import request from '@ohos.request';
import common from '@ohos.app.ability.common';


//上传回调数据类型
interface ReceiveRes {
  body: string
  headers: object
}


@Extend(Text)
function custText() {
  .width('100%')
  .height('48')
  .fontColor('#39364D')
  .textAlign(TextAlign.Center)
}

let context = getContext(this) as common.UIAbilityContext; //UIAbilityContext

//@Component
@CustomDialog
export default struct ImageUploadDialog {
  dialogController: CustomDialogController//MainPage.ets
  @Prop uploadURL:string=''//父组件->子组件
  @Consume onImageSelected:string//子组件<->父组件

  private success: (res: ReceiveRes) => void = () => {} //上传成功回调
  private fail: (res: request.TaskState[]) => void = () => {} //上传失败回调
  private complete: (res: request.TaskState[]) => void = () => {} //上传完成回调

  //开始上传图片 path：图片路径后缀（图片名称）
  async uploadImage(path: string) {
    console.log(path, 'path')
    let uri=`internal://cache/${path}` //上传图片全路径
    let uploadConfig: request.UploadConfig = {
      url:this.uploadURL,
      header: {'Content-Type': 'multipart/form-data'},
      method: "POST",
      files: [{ filename: path, name: "file", uri, type: 'image/jpeg' }],
      data: [],
    };
    try {
      console.log('uploading:'+JSON.stringify(uploadConfig))
      let uploadTask:request.UploadTask=await request.uploadFile(context, uploadConfig)
      //上传中回调
      uploadTask.on('progress', (size,total) => {
        console.log(size.toString(),total.toString(),'上传进度')
      })
      //每上传一张图片成功回调
      uploadTask.on('headerReceive', (data: object) => {
        let res = data as ReceiveRes
        this.success && this.success(res)
      })
      //所有上传完成回调
      uploadTask.on('complete', (taskStates: request.TaskState[]) => {
        console.info("upOnComplete complete taskState:" + JSON.stringify(taskStates));
        this.complete && this.complete(taskStates)
      })
      //上传失败回调
      uploadTask.on('fail', (taskStates: request.TaskState[]) => {
        console.info("upOnComplete fail taskState:" + JSON.stringify(taskStates));
        this.fail&&this.fail(taskStates)
      })
    }catch (e){
      console.log( JSON.stringify(e),'e')
    }

  }

  //1.权限相关暂时注释了
  build() {
    Column() {
      Divider().color('#F7F9FA').width('100%').strokeWidth(1)
      //从手机相册选择
      Text('从相册选择').custText().onClick(async () => {

        this.dialogController.close()
        //从相册选择
        let PhotoSelectOptions = new picker.PhotoSelectOptions();
        PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
        PhotoSelectOptions.maxSelectNumber = 1;
        let photoPicker = new picker.PhotoViewPicker();
        photoPicker.select(PhotoSelectOptions).then(async (PhotoSelectResult) => {
          if (PhotoSelectResult.photoUris.length) {

            //复制图片到缓存目录（缓存目录才有读写权限）
            let filePath = await copyFileToCache(PhotoSelectResult.photoUris[0],context)

            //同步传递给父组件
            this.onImageSelected=PhotoSelectResult.photoUris[0]
            console.log("upload  "+this.onImageSelected)

            //上传到服务器
            if (filePath) {
              this.uploadImage(filePath)
            }

          }
        })
      })
      Button('取消', { type: ButtonType.Capsule })
        .backgroundColor('#b7e0fcd7')
        .fontSize('16fp')
        .fontColor('#ff042807')
        .width('100%')
        .margin({ top: '30' })
        .onClick(() => {
          this.dialogController.close()
        })
    }
    .width('100%')
    .padding({ left: '16', top: '11', right: '16', bottom: '16' })
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: '24',
      topRight: '24'
    })
  }
}
