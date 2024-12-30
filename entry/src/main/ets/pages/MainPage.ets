import ImageUploadDialog from './Upload'
import promptAction from '@ohos.promptAction'

@Entry
@Component
struct Index {
  @State dialogController: CustomDialogController | null = null //选择上传类型弹窗控制器
  @State result:string=""
  @State message:string="WasteWizard分析结果：";
  @State classification:string="";
  @State suggestion:string="";
  @Provide onImageSelected:string="";

  aboutToAppear(): void {
    this.dialogController= new CustomDialogController({
      //回调函数，动态生成弹窗内容
      builder: ImageUploadDialog({
        uploadURL: 'http://192.168.64.189:8080/upload/',//上传地址
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
          this.classification='物体类别：'+res['classification']
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
      //标题栏
      Row() {
        Row(){
          Text('Waste Wizard')
            .height(40) // 设置高度
            .margin({ left: 10,top:10}) // 外边距
            .fontSize(18) // 字体大小
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffffff') // 设置字体颜色
            .textAlign(TextAlign.Center) // 文本水平居中
            .alignSelf(ItemAlign.Center); // 在父容器中居中

          Text('-日常生活垃圾分类小助手')
            .height(40) // 设置高度
            .margin({ left: 10,top:10}) // 外边距
            .fontSize(15) // 字体大小
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffeafdea') // 设置字体颜色
            .textAlign(TextAlign.Center) // 文本水平居中
            .alignSelf(ItemAlign.Center); // 在父容器中居中
        }
        .justifyContent(FlexAlign.Center) // 主轴方向靠左排列

        Image($r('app.media.appIcon'))
          .width(30) // 图像宽度
          .height(30) // 图像高度
          .margin({ left: 10,top:15}) // 外边距
          .objectFit(ImageFit.Cover) // 图像填充方式
          .alignSelf(ItemAlign.Start) // 图像居中对齐

      }
      .width('100%')
      .height('8%')
      .backgroundColor('#c1405f40')

      //用户输入相册照片
      Row() {
        Row() {
          Row() {
            Image($r('app.media.yonghu'))
              .height(50)// 图像高度
              .margin({ left: 15, top: 20, right: 15, bottom: 15 })// 外边距
              .objectFit(ImageFit.Cover)// 图像填充方式
              .alignSelf(ItemAlign.Start) // 图像居中对齐
          }.justifyContent(FlexAlign.Center) // 主轴方向居中
          Button('上传照片')
            .onClick(() => {
              this.message = "WasteWizard 垃圾分类小助手"
              this.classification = "图中垃圾类别正在分析......"
              this.suggestion = "垃圾处理建议正在分析......"
              this.dialogController?.open()
            })
            .margin({ left: 10, top: 25, right: 15, bottom: 15 })// 外边距
            .alignSelf(ItemAlign.End)
            .backgroundColor('#ff034503')
          }.justifyContent(FlexAlign.End) // 主轴方向居中
          .width('40%')

          Row(){
            Image($r('app.media.trash'))
              .margin({ left: 10,top:15,right:15,bottom:15}) // 外边距
              .height('60%') // 图像高度
              .objectFit(ImageFit.Cover) // 图像填充方式
              .alignSelf(ItemAlign.Center) // 图像居中对齐
          }
          .width('60%')
      }
      .width('100%')
      .height('20%')

      //结果显示
      Row(){
        if(this.onImageSelected===""){
          Text('图片待上传')
            .width('40%')
            .height('80%')
            .fontColor('#ff2c412c')
            .backgroundColor('#ffdcfadc')
            .margin({ left: 30,top:30,right:30,bottom:30}) // 外边距
            .padding({ left: 10,top:15,right:15,bottom:15}) // 内边距
        }
        else{
          Image(this.onImageSelected)
            .height('80%')
            .width('40%')
            .margin({ left: 30,top:30,right:30,bottom:30}) // 外边距
            .padding({ left: 10,top:15,right:15,bottom:15}) // 内边距
        }


        Column() {
          Text(this.message)
            .alignSelf(ItemAlign.Start)
            .width('100%')
            .maxLines(1)
            .fontSize(20)
            .backgroundColor('#ff9eec9e')
          Blank().height('10%').backgroundColor('#ff9eec9e')
          Text(this.classification)
            .alignSelf(ItemAlign.Center)
            .width('100%')
            .maxLines(1)
            .fontSize(32)
            .padding(10)
            .backgroundColor('#ff9eec9e')
          Text(this.suggestion)
            .alignSelf(ItemAlign.Center)
            .width('100%')
            .maxLines(4)
            .fontSize(32)
            .padding(10)
            .backgroundColor('#ff9eec9e')
        }
        .width('60%')
        .height('100%')
        .padding({ left: 30,top:30,right:30,bottom:30}) // 外边距

      }
      .height('67%')
      .backgroundColor('#ff9eec9e')

      //底栏
      Row() {
        Text('从日常照片开始，开启环保分类之旅吧～')
          .width('100%')
          .height(40) // 设置高度
          .margin({ left: 10,top:10}) // 外边距
          .fontSize(10) // 字体大小
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffcbdbcb') // 设置字体颜色
          .textAlign(TextAlign.Center) // 文本水平居中
          .alignSelf(ItemAlign.Center); // 在父容器中居中
      }
      .width('100%')
      .height('5%')
      .backgroundColor('#c1405f40')

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffd0ffd0')


  }

}
