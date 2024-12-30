import ImageUploadDialog from './Upload'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct Index {
  @State dialogController: CustomDialogController | null = null //选择上传类型弹窗控制器
  @State result:string=""
  @State message:string="WasteWizard";
  @State classification:string="";
  @State suggestion:string="";
  @Provide onImageSelected:string="";

  aboutToAppear(): void {
    this.dialogController= new CustomDialogController({
      //回调函数，动态生成弹窗内容
      builder: ImageUploadDialog({
        uploadURL: 'http://192.168.64.189:8080/upload/',//上传地址 uploadURL: 'http://172.20.10.6:8080/upload/',
        //onImageSelected: onImageSelected,
        success:e=>{//上传成功回调，e上传成功接口返回数据
          let res= JSON.parse(e.body) as object //接口上传成功返回数据
          console.log(JSON.stringify(e.headers))
          console.log(JSON.stringify(res),'上传成功')
          this.result=JSON.stringify(res)
          console.log(JSON.stringify(res['message']),'上传成功')
          console.log(JSON.stringify(res['classification']),'上传成功')
          console.log(JSON.stringify(res['suggestion']),'上传成功')
          //根据实际接口返回字段获取图片url
          //url=res['data']
          this.classification=res['classification']
          this.suggestion=res['suggestion']
        },
        fail:e=>{//上传失败回调
          console.log(JSON.stringify(e))
          promptAction.showToast({message:'上传失败'})
        },
        complete:e=>{//上传完成回调
          console.log(JSON.stringify(e),'complete')
        }
      }),
      alignment: DialogAlignment.Bottom,//弹窗居于底部
      backgroundColor:'#ffe3ffe3',
      customStyle: true,//自定义样式
    })
  }
  build() {
    Column(){
      Blank().height('5%')

      Row() {
        Button('上传')
          .onClick(() => {
            this.message="WasteWizard 垃圾分类小助手"
            this.classification="图中垃圾类别正在分析......"
            this.suggestion="垃圾处理建议正在分析......"
            this.dialogController?.open()
          })
          .backgroundColor('#ff034503')
          .height('20%')
        Image($r('app.media.rightback'))
          .width(180)
          .height('60%')
      }
      .height('30%')

      Row(){
        Column() {
          Text(this.message)
            .width('100%')
            .maxLines(1)
            .fontSize(26)
            .backgroundColor('#ff9eec9e')
          Blank().height('10%').backgroundColor('#ff9eec9e')
          Text(this.classification)
            .width('100%')
            .maxLines(1)
            .fontSize(32)
            .padding(10)
            .backgroundColor('#ff9eec9e')
          Text(this.suggestion)
            .width('100%')
            .maxLines(2)
            .fontSize(32)
            .padding(10)
            .backgroundColor('#ff9eec9e')
        }
        .width('50%')

        if(this.onImageSelected===""){
          Image($r('app.media.rightback'))
            .width('50%')
        }
        else{
          Image(this.onImageSelected)
            .width('50%')
        }
      }
      .height('70%')
      .backgroundColor('#ff9eec9e')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffd0ffd0')
  }

}
