import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
const context = getContext(this) as common.UIAbilityContext;
@Entry
@Component
struct GetFrontCameraImage {
  private xComponentController: XComponentController = new XComponentController();
  async getCameraImage() {
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
    Row() {
      Column({ space: 20 }) {
        XComponent({ id: 'xComponentId1', type: 'surface', controller: this.xComponentController })
          .height(300)
        Button('打开摄像头')
          .onClick(() => {
            // 在调用前确保已经获得相机权限 
            this.getCameraImage();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
