import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'WasteWizard';
  //构建界面
  build() {
    Column() {//RelativeContainer 是一个容器组件
      // 插入图片组件作为图标
      Blank().layoutWeight(2.5).height('100%')
      Image($r('app.media.appIcon')) // 假设图标文件名为 appIcon.png
        .id('AppIcon') // 图片组件的唯一标识符
          // .width(60) // 设置图标的宽
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        }) // 图标水平居中，位于顶部
        .layoutWeight(3)
      // .height('100%')
      Text(this.message)//基础组件（参数）
        .id('WasteWizard')//基础组件的属性方法
        .fontSize(46)
        .fontColor(Color.White)
        .fontStyle(FontStyle.Italic)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .layoutWeight(2)

      // .height('100%')
      Button('Start')
        .id('entry')
        .backgroundColor('#006400')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Normal)
        .layoutWeight(1) // 修改权重，使按钮在横屏时显示完整
        .height('10%') // 动态高度，占父容器高度的 10%
        .width('30%') // 动态宽度，占父容器宽度的 30%
        .onClick(()=>{
          console.log('跳转到主界面')
          router.pushUrl({
            url:'pages/MainPage'
          })

        }
        )
      Blank().layoutWeight(2)
    }
    .height('100%')//设置 RelativeContainer 的高度和宽度为父容器的 100%，即覆盖整个屏幕
    .width('100%')
    .linearGradient({
      angle: 180,
      colors: [['#98FB98', 0.1], ["#32CD32", 0.8]]
    })

  }
}