import { router } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';

// console.log('测试');
// 1.变量：let 变量名:类型=数值
//  string,number,boolean
// let isLogin:boolean=false
// console.log('',isLogin);
// 2.常量: const 常量名:类型=数值（不可变
// 3.数组：let 数组名:类型[]=[...,...,]
// 4.函数：function ...(n1:type,){ return ...}
//    let a:string=f1()
// 5.对象：
// interface Person{
//  name:string
//  age:number
//  weight:number
//  sing:(song:string)=>void//对象中的方法
// }
// 6.联合类型：let judge:number|string=100
//    let gender:'man'|'woman'|'unknown'='unknown'
// 7.枚举：
// enum themecolor{
//   red='',
//   orange=''
// }
// let color:themecolor=themecolor.red
//    比如页面颜色限定



//1.组件
//容器组件 Row(){...}
//基础组件 基础组件(参数)

//2.弹窗
// AlertDialog.show({
//   message:'弹窗'
// })

//3.页面状态管理
//state(状态变量)--render-->UI(界面)
//state(状态变量)<--event-handlers--UI(界面)
//状态变量--装饰器修饰-->设置类型和初始值-->改变引起UI渲染

//4.foreach渲染控制

//5.Stack()层叠容器.zIndex

//6.切换动画animation

//7.路由--创建页面-跳转和后退-页面栈-路由模式-跳转传参
@Entry //程序入口组件
@Component //声明 Index 是一个 UI 组件。框架会根据它生成必要的视图和逻辑代码。
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