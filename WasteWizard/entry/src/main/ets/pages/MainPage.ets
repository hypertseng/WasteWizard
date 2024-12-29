import { camera } from '@kit.CameraKit';
import { common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { checkPermissions,reqPermissionsFromUser } from '../utils/UserPerm';
const context = getContext(this) as common.UIAbilityContext;

const permissions: Array<Permissions> = ['ohos.permission.CAMERA'];

//拍摄照片
// async function takeImage(){
//   checkPermissions(context).then((res:boolean)=>{
//     console.log("相机权限:"+res)
//     if(res){
//       //获取照片
//       try{
//
//       }catch (e) {
//         console.log("相机权限"+res)
//       }
//     }
//   })
// }

@Entry
@Component
struct MainPage {
  @State isCameraAuthorized: boolean = false; // 权限状态
  @State isPreviewActive: boolean = false; // 是否显示相机预览
  xComponentController: XComponentController = new XComponentController();

  async PreviewCamera() {
    const hasPermission = await checkPermissions(context);
    console.log('PreviewCamera相机权限: ' + hasPermission);
    if (hasPermission) {
      this.getCameraImage(); // 权限已授予，开启相机预览
    } else {
      console.log('PreviewCamera权限未授予' + hasPermission);
    }
  }

  //摄像头预览
  async getCameraImage() {
    console.log('getCameraImage摄像头预览');
    // 1、使用系统相机框架camera模块获取物理摄像头信息。
    let cameraManager = camera.getCameraManager(context);
    let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    let cameraDevice: camera.CameraDevice = camerasInfo[0];
    // 检测相机状态
    cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      console.log(`camera : ${cameraStatusInfo.camera.cameraId}`);
      console.log(`status : : ${cameraStatusInfo.status}`);
    });
    // 2、创建并启动物理摄像头输入流通道
    // 设置为前置摄像头 camera.CameraPosition.CAMERA_POSITION_FRONT
    let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraType.CAMERA_TYPE_DEFAULT);
    await cameraInput.open();
    // 3、拿到物理摄像头信息查询摄像头支持预览流支持的输出格式，结合XComponent提供的surfaceId创建预览输出通道
    let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let previewProfile = outputCapability.previewProfiles[0];
    let surfaceId = this.xComponentController.getXComponentSurfaceId();
    let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
    // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。
    let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
    captureSession.beginConfig();
    captureSession.addInput(cameraInput);
    captureSession.addOutput(previewOutput);
    captureSession.commitConfig()
    captureSession.start();
  }

  build() {
    Column({ space: 20 }) {
      Blank().layoutWeight(1)
      //this.isPreviewActive

      XComponent({
        id: 'cameraPreview',
        type: 'surface',
        controller: this.xComponentController,
      })
        .width('100%')
        .height(300)
        .backgroundColor('#000') // 黑色背景表示加载中

      Button()
        .onClick(async () => {
          let hasPermission = await checkPermissions(context);
          console.log('权限测试', hasPermission); // 打印解析后的布尔值
        });
      
      // XComponent：动态显示图标或相机预览
      // if (this.isPreviewActive) {
      //   // 显示相机预览
      //   XComponent({
      //     id: 'cameraPreview',
      //     type: 'surface',
      //     controller: this.xComponentController,
      //   })
      //     .width('100%')
      //     .height(300)
      //     .backgroundColor('#000'); // 黑色背景表示加载中
      // } else {
      //   // 显示默认图标
      //   Image($r('app.media.cameraIcon')) // 替换为实际的图标路径
      //     .width(100)
      //     .height(100)
      //     .onClick(() => {
      //       this.isPreviewActive=true
      //       // this.PreviewCamera(); // 点击图标切换为预览
      //       console.log('切换为Xcomponent')
      //     });
      // }

      Blank().layoutWeight(1)

      Row(){
        //从相册上传
        Button('上传')
          .onClick(() => {
            // this.takeImage();
          })
          .fontSize(20)
          .width(200)
          .height(50)
          .backgroundColor('#006400')
          .fontColor(Color.White)
          .margin({ top: 20 })
          .layoutWeight(1)
          .onClick(()=>{
            console.log('点击上传按钮')
          })
        Blank().layoutWeight(1)
        // 拍照按钮
        Button('拍照')
          .onClick(() => {
            console.log('点击拍照按钮')
          })
          .fontSize(20)
          .width(200)
          .height(50)
          .backgroundColor('#006400')
          .fontColor(Color.White)
          .margin({ top: 20 })
          .layoutWeight(1)

      }
      .width('80%')

      Blank().layoutWeight(1)

    }
    .height('100%')//设置 RelativeContainer 的高度和宽度为父容器的 100%，即覆盖整个屏幕
    .width('100%')
    .linearGradient({
      angle: 180,
      colors: [['#ffe8ffe8', 0.1], ["#ffc7ffd3", 0.8]]
    })
  }
}



// import { camera } from '@kit.CameraKit';
// import { BusinessError } from '@kit.BasicServicesKit';
// import { common } from '@kit.AbilityKit';
//
// // 获取cameraManager对象 获取对象失败，说明相机可能被占用或无法使用
// function getCameraManager(context: common.BaseContext): camera.CameraManager {
//   let cameraManager: camera.CameraManager = camera.getCameraManager(context);
//   return cameraManager;
// }
//
// //获取当前设备支持的相机列表，列表中存储了设备支持的所有相机ID
// function getCameraDevices(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
//   let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
//   if (cameraArray != undefined && cameraArray.length > 0) {
//     for (let index = 0; index < cameraArray.length; index++) {
//       console.info('cameraId : ' + cameraArray[index].cameraId);  // 获取相机ID
//       console.info('cameraPosition : ' + cameraArray[index].cameraPosition);  // 获取相机位置
//       console.info('cameraType : ' + cameraArray[index].cameraType);  // 获取相机类型
//       console.info('connectionType : ' + cameraArray[index].connectionType);  // 获取相机连接类型
//     }
//     return cameraArray;
//   } else {
//     console.error("cameraManager.getSupportedCameras error");
//     return [];
//   }
// }
//
//
// @Entry
// @Component
// struct MainPage {
//   @State message: string = 'Hello World';
//
//   build() {
//     RelativeContainer() {
//       Text(this.message)
//         .id('VisualPageHelloWorld')
//         .fontSize(50)
//         .fontWeight(FontWeight.Bold)
//         .alignRules({
//           center: { anchor: '__container__', align: VerticalAlign.Center },
//           middle: { anchor: '__container__', align: HorizontalAlign.Center }
//         })
//     }
//     .height('100%')
//     .width('100%')
//   }
// }


// struct GetFrontCameraImage {
//   private xComponentController: XComponentController = new XComponentController();
//   async getCameraImage() {
//     // 1、使用系统相机框架camera模块获取物理摄像头信息。
//     let cameraManager = camera.getCameraManager(context);
//     let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
//     let cameraDevice: camera.CameraDevice = camerasInfo[0];
//     // 检测相机状态
//     cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
//       console.log(`camera : ${cameraStatusInfo.camera.cameraId}`);
//       console.log(`status : : ${cameraStatusInfo.status}`);
//     });
//     // 2、创建并启动物理摄像头输入流通道
//     // 设置为前置摄像头 camera.CameraPosition.CAMERA_POSITION_FRONT
//     let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraType.CAMERA_TYPE_DEFAULT);
//     await cameraInput.open();
//     // 3、拿到物理摄像头信息查询摄像头支持预览流支持的输出格式，结合XComponent提供的surfaceId创建预览输出通道
//     let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
//     let previewProfile = outputCapability.previewProfiles[0];
//     let surfaceId = this.xComponentController.getXComponentSurfaceId();
//     let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
//     // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。
//     let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
//     captureSession.beginConfig();
//     captureSession.addInput(cameraInput);
//     captureSession.addOutput(previewOutput);
//     captureSession.commitConfig()
//     captureSession.start();
//   }
//   build() {
//     Row() {
//       Column({ space: 20 }) {
//         XComponent({ id: 'xComponentId1', type: 'surface', controller: this.xComponentController })
//           .height(300)
//         Button('打开摄像头')
//           .onClick(() => {
//             // 在调用前确保已经获得相机权限
//             this.getCameraImage();
//           })
//       }
//       .width('100%')
//     }
//     .height('100%')
//   }
// }