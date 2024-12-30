
// import common from '@ohos.app.ability.common';
// import { Permissions } from '@ohos.abilityAccessCtrl';
// import camera from '@ohos.multimedia.camera';
// import { BusinessError } from '@ohos.base';
//
// import image from '@ohos.multimedia.image';
// import fileio from '@ohos.fileio';
// import mediaLibrary from '@ohos.multimedia.mediaLibrary'
// import { checkPermissions,reqPermissionsFromUser } from '../utils/UserPerm';
// import DateTimeUtil from '../utils/DateTimeUtil';
//
// const context = getContext(this) as common.UIAbilityContext;
// const permissions: Array<Permissions> = ['ohos.permission.CAMERA'];
//
// @Component
// struct XComponentPage {
//   // 创建XComponentController
//   mXComponentController: XComponentController = new XComponentController;
//   surfaceId: string = '';
//
//   //1. 获取预览输出流
//   getPreviewOutput(cameraManager: camera.CameraManager, cameraOutputCapability: camera.CameraOutputCapability, surfaceId: string): camera.PreviewOutput | undefined {
//     let previewProfilesArray: Array<camera.Profile> = cameraOutputCapability.previewProfiles;
//     let previewOutput: camera.PreviewOutput | undefined = undefined;
//     try {
//       //[关键函数]
//       previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], surfaceId);
//     } catch (error) {
//       let err = error as BusinessError;
//       console.error("Failed to create the PreviewOutput instance. error code: " + err.code);
//     }
//     return previewOutput;
//   }
//
//   //2. 使能-调用预览输出流
//   async  startPreviewOutput(cameraManager: camera.CameraManager, previewOutput: camera.PreviewOutput): Promise<void> {
//     let cameraArray: Array<camera.CameraDevice> = [];
//     // 获取支持的设备
//     cameraArray = cameraManager.getSupportedCameras();
//     if (cameraArray.length == 0) {
//       console.error('no camera.');
//       return;
//     }
//     // 获取支持的模式类型
//     let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraArray[0]);
//     let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
//     if (!isSupportPhotoMode) {
//       console.error('photo mode not support');
//       return;
//     }
//
//     //相机输入
//     let cameraInput: camera.CameraInput | undefined = undefined;
//     cameraInput = cameraManager.createCameraInput(cameraArray[0]);
//     if (cameraInput === undefined) {
//       console.error('cameraInput is undefined');
//       return;
//     }
//
//     // 打开相机
//     await cameraInput.open();
//     let session: camera.PhotoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
//     session.beginConfig();
//     session.addInput(cameraInput);
//     session.addOutput(previewOutput);
//     await session.commitConfig();
//     await session.start();
//   }
//
//
//
//   build() {
//     Flex() {
//       // 创建XComponent
//       XComponent({
//         id: '',
//         type: 'surface',
//         libraryname: '',
//         controller: this.mXComponentController
//       })
//         .onLoad(() => {
//           // 设置Surface宽高（1920*1080），预览尺寸设置参考前面 previewProfilesArray 获取的当前设备所支持的预览分辨率大小去设置
//           // 预览流与录像输出流的分辨率的宽高比要保持一致
//           this.mXComponentController.setXComponentSurfaceSize({surfaceWidth:1920,surfaceHeight:1080});
//           // 获取Surface ID
//           this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
//         })
//         .width('1920px')
//         .height('1080px')
//     }
//   }
// }
//
// // @Entry
// // @Component
// // struct MainPage {
// //
// //
// // }
//   // @State isCameraAuthorized: boolean = false; // 权限状态
//   // @State isPreviewActive: boolean = false; // 是否显示相机预览
//   //
//   // private mXComponentController = new XComponentController()
//   // private cameraManager: camera.CameraManager = undefined
//   // private cameras: Array<camera.CameraDevice> = undefined
//   // private cameraId: string = undefined
//   // private mReceiver: image.ImageReceiver = undefined
//   // private cameraInput: camera.CameraInput = undefined
//   // private previewOutput: camera.PreviewOutput = undefined
//   // private mSurfaceId: string = undefined
//   // private photoOutput: camera.PhotoOutput = undefined
//   // private captureSession: camera.CaptureSession = undefined
//   // //private mediaUtil: MediaUtil = undefined//
//   // @State desStr: string = ""
//   // private fileAsset: mediaLibrary.FileAsset
//   // private surfaceId: string
//   // @State photoUriMedia: string = ""
//   // private photoFlag: boolean = true
//   // @State  imgUrl: string = ""
//   //
//   // //文件保存相关
//   // @State isMediaUrl:boolean=true
//   //判断保存路径为是沙箱路径或者媒体路径，默认媒体路径
//   // private mediaTest: mediaLibrary.MediaLibrary | undefined;//mediaTest
//   // aboutToAppear(){
//   //   this.mediaTest = mediaLibrary.getMediaLibrary(context)
//   // }
//   // async createAndGetUri(mediaType: number) {
//   //   let info = this.getInfoFromType(mediaType)
//   //   let dateTimeUtil = new DateTimeUtil()
//   //   let name = `${dateTimeUtil.getDate()}_${dateTimeUtil.getTime()}`
//   //   let displayName = `${info.prefix}${name}${info.suffix}`
//   //   let publicPath = await this.mediaTest.getPublicDirectory(info.directory)
//   //   let dataUri = await this.mediaTest.createAsset(mediaType, displayName, publicPath)
//   //   return dataUri
//   // }
//   // async getFdPath(fileAsset: any) {
//   //   let fd = await fileAsset.open('Rw')
//   //   return fd
//   // }
//   // getInfoFromType(mediaType: number) {
//   //   let result = {
//   //     prefix: '', suffix: '', directory: 0
//   //   }
//   //   switch (mediaType) {
//   //     case mediaLibrary.MediaType.FILE:
//   //       result.prefix = 'FILE_'
//   //       result.suffix = '.txt'
//   //       result.directory = mediaLibrary.DirectoryType.DIR_DOCUMENTS
//   //       break
//   //     case mediaLibrary.MediaType.IMAGE:
//   //       result.prefix = 'IMG_'
//   //       result.suffix = '.jpg'
//   //       result.directory = mediaLibrary.DirectoryType.DIR_IMAGE
//   //       break
//   //     case mediaLibrary.MediaType.VIDEO:
//   //       result.prefix = 'VID_'
//   //       result.suffix = '.mp4'
//   //       result.directory = mediaLibrary.DirectoryType.DIR_VIDEO
//   //       break
//   //     case mediaLibrary.MediaType.AUDIO:
//   //       result.prefix = 'AUD_'
//   //       result.suffix = '.wav'
//   //       result.directory = mediaLibrary.DirectoryType.DIR_AUDIO
//   //       break
//   //   }
//   //   return result
//   // }
//
//   // async PreviewCamera() {
//   //   const hasPermission = await checkPermissions(context);
//   //   console.log('PreviewCamera相机权限: ' + hasPermission);
//   //   if (hasPermission) {
//   //     this.getCameraImage(); // 权限已授予，开启相机预览
//   //   } else {
//   //     console.log('PreviewCamera权限未授予' + hasPermission);
//   //   }
//   // }
//
//   // //摄像头预览
//   // async getCameraImage() {
//   //   console.log('getCameraImage摄像头预览');
//   //   // 1、使用系统相机框架camera模块获取物理摄像头信息。
//   //   let cameraManager = camera.getCameraManager(context);
//   //   let camerasInfo: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
//   //   let cameraDevice: camera.CameraDevice = camerasInfo[0];
//   //   // 检测相机状态
//   //   cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
//   //     console.log(`camera : ${cameraStatusInfo.camera.cameraId}`);
//   //     console.log(`status : : ${cameraStatusInfo.status}`);
//   //   });
//   //   // 2、创建并启动物理摄像头输入流通道
//   //   // 设置为前置摄像头 camera.CameraPosition.CAMERA_POSITION_FRONT
//   //   let cameraInput = cameraManager.createCameraInput(camera.CameraPosition.CAMERA_POSITION_FRONT, camera.CameraType.CAMERA_TYPE_DEFAULT);
//   //   await cameraInput.open();
//   //   // 3、拿到物理摄像头信息查询摄像头支持预览流支持的输出格式，结合XComponent提供的surfaceId创建预览输出通道
//   //   let outputCapability = cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
//   //   let previewProfile = outputCapability.previewProfiles[0];
//   //   let surfaceId = this.xComponentController.getXComponentSurfaceId();
//   //   let previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
//   //   // 4、创建相机会话，在会话中添加摄像头输入流和预览输出流，然后启动会话，预览画面就会在XComponent组件上送显。
//   //   let captureSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO);
//   //   captureSession.beginConfig();
//   //   captureSession.addInput(cameraInput);
//   //   captureSession.addOutput(previewOutput);
//   //   captureSession.commitConfig()
//   //   captureSession.start();
//   // }
//   //
//
//   //1.初始化相机和会话管理
//   // async initCamera(surfaceId: number) {
//   //   this.cameraManager = await camera.getCameraManager(context)//需要在Ability中定义globalThis.context=this.context
//   //   this.cameras = await this.cameraManager.getSupportedCameras()//获取支持的相机设备
//   //   this.cameraId = this.cameras[0].cameraId//0？OR？1
//   //   await this.photoReceiver() //创建图片接收器并进行订阅
//   //   this.mSurfaceId = await this.mReceiver.getReceivingSurfaceId()
//   //
//   //   //设置相机输入---当前选择this.cameras[0]
//   //
//   //   this.cameraInput = await this.cameraManager.createCameraInput(this.cameras[0])
//   //   this.previewOutput = await this.cameraManager.createPreviewOutput(camera.Profile,surfaceId.toString())
//   //   this.photoOutput = await camera.createPhotoOutput(this.mSurfaceId)
//   //
//   //
//   //   this.captureSession = await camera.createCaptureSession(globalThis.context)
//   //   await this.captureSession.beginConfig()
//   //   await this.captureSession.addInput(this.cameraInput)
//   //   await this.captureSession.addOutput(this.previewOutput)
//   //   await this.captureSession.addOutput(this.photoOutput)
//   //   await this.captureSession.commitConfig()
//   //   await this.captureSession.start().then(() => {
//   //     console.log('zmw1--Promise returned to indicate the session start success.');
//   //   })
//   // }
//   //
//   // //创建图片接收器并进行订阅
//   // async photoReceiver() {
//   //   this.mReceiver = image.createImageReceiver(CameraSize.WIDTH, CameraSize.HEIGHT, 4, 8)
//   //   let buffer = new ArrayBuffer(4096)
//   //   this.mReceiver.on('imageArrival', () => {
//   //     console.log("zmw -service-imageArrival")
//   //     this.mReceiver.readNextImage((err, image) => {
//   //       if (err || image === undefined) {
//   //         return
//   //       }
//   //       image.getComponent(4, (errMsg, img) => {
//   //         if (errMsg || img === undefined) {
//   //           return
//   //         }
//   //         if (img.byteBuffer) {
//   //           buffer = img.byteBuffer
//   //         }
//   //         if(this.isMediaUrl){
//   //           this.savePictureMedia(buffer, image)
//   //         }else{
//   //           this.savePictureSand(buffer, image)
//   //         }
//   //       })
//   //     })
//   //     return buffer
//   //   })
//   // }
//   //
//   //
//   //
//   // build() {
//   //   Flex() {
//   //     Flex() {
//   //       Stack() {
//   //         Flex() {
//   //           //相机显示的组件
//   //           XComponent({
//   //             id: 'componentId',
//   //             type: 'surface',
//   //             controller: this.mXComponentController
//   //           }).onLoad(() => {
//   //             this.mXComponentController.setXComponentSurfaceSize({ surfaceWidth: 640, surfaceHeight: 480 })
//   //             this.surfaceId = this.mXComponentController.getXComponentSurfaceId()
//   //             this.initCamera(this.surfaceId)
//   //           })
//   //         }.width(800).height(800)
//   //         //显示在相机上面的组件：拍照和摄像的图标，摄像的时间
//   //         Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
//   //           if (this.photoFlag) { //拍照
//   //             Image($r("app.media.app_icon")).width(50).height(50).onClick(() => {
//   //               this.desStr = "拍照完成"
//   //               this.takePicture()
//   //             })
//   //           }
//   //           Text(this.desStr).fontColor("red").height(30).fontSize(20)
//   //         }.width(480).height(480)
//   //       }.border({ width: 1, style: BorderStyle.Solid, color: "#000000" })
//   //       //右边的控制button和图片显示区域
//   //       Flex({
//   //         direction: FlexDirection.Column,
//   //         justifyContent: FlexAlign.SpaceBetween,
//   //         alignItems: ItemAlign.Center,
//   //       }) {
//   //         Button("选择沙箱路径存储").onClick(()=>{
//   //           this.isMediaUrl=false
//   //         }) .stateStyles({
//   //           normal: { // 设置默认情况下的显示样式
//   //             .backgroundColor(Color.Blue)
//   //           },
//   //           pressed: { // 设置手指摁下时的显示样式
//   //             .backgroundColor(Color.Pink)
//   //           }
//   //         })
//   //         Image(decodeURI("file://"+this.imgUrl)).width(480).height(350)//显示沙箱图片
//   //         Button("选择媒体路径存储").onClick(()=>{
//   //           this.isMediaUrl=true
//   //         }) .stateStyles({
//   //           normal: { // 设置默认情况下的显示样式
//   //             .backgroundColor(Color.Blue)
//   //           },
//   //           pressed: { // 设置手指摁下时的显示样式
//   //             .backgroundColor(Color.Pink)
//   //           }
//   //         })
//   //         Image(decodeURI(this.imgUrl)).width(480).height(350)   //显示媒体图片
//   //       }.width(480).height("100%").border({ width: 1, style: BorderStyle.Solid, color: "#000000" })
//   //
//   //     }.border({ width: 1, style: BorderStyle.Solid, color: "red" })
//   //     .width("100%").height("100%")
//   //   }
//   //   .height('100%').width("100%")
//   // }
//
//
//   // build() {
//   //   Column({ space: 20 }) {
//   //     Blank().layoutWeight(1)
//   //     //this.isPreviewActive
//   //
//   //     XComponent({
//   //       id: 'cameraPreview',
//   //       type: 'surface',
//   //       controller: this.xComponentController,
//   //     })
//   //       .width('100%')
//   //       .height(300)
//   //       .backgroundColor('#000') // 黑色背景表示加载中
//   //
//   //     Button()
//   //       .onClick(async () => {
//   //         let hasPermission = await checkPermissions(context);
//   //         console.log('权限测试', hasPermission); // 打印解析后的布尔值
//   //       });
//   //
//   //     Blank().layoutWeight(1)
//   //
//   //     Row(){
//   //       //从相册上传
//   //       Button('上传')
//   //         .onClick(() => {
//   //           // this.takeImage();
//   //         })
//   //         .fontSize(20)
//   //         .width(200)
//   //         .height(50)
//   //         .backgroundColor('#006400')
//   //         .fontColor(Color.White)
//   //         .margin({ top: 20 })
//   //         .layoutWeight(1)
//   //         .onClick(()=>{
//   //           console.log('点击上传按钮')
//   //         })
//   //       Blank().layoutWeight(1)
//   //       // 拍照按钮
//   //       Button('拍照')
//   //         .onClick(() => {
//   //           console.log('点击拍照按钮')
//   //         })
//   //         .fontSize(20)
//   //         .width(200)
//   //         .height(50)
//   //         .backgroundColor('#006400')
//   //         .fontColor(Color.White)
//   //         .margin({ top: 20 })
//   //         .layoutWeight(1)
//   //
//   //     }
//   //     .width('80%')
//   //
//   //     Blank().layoutWeight(1)
//   //
//   //   }
//   //   .height('100%')//设置 RelativeContainer 的高度和宽度为父容器的 100%，即覆盖整个屏幕
//   //   .width('100%')
//   //   .linearGradient({
//   //     angle: 180,
//   //     colors: [['#ffe8ffe8', 0.1], ["#ffc7ffd3", 0.8]]
//   //   })
//   // }
//
//
