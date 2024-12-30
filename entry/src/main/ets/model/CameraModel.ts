import { checkPermissions, applyPermission, copyFileToCache } from '../utils/tool';
import camera from '@ohos.multimedia.camera';
import deviceInfo from '@ohos.deviceInfo';
import fileIo from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import media from '@ohos.multimedia.media';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import Logger from '../utils/Logger';
import MediaModel from './MediaModel';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import picker from '@ohos.multimedia.cameraPicker';
import camerapicker from '@ohos.multimedia.cameraPicker';

const FOUR = 4; // format
const EIGHT = 8; // capacity
const FOUR_THOUSAND_AND_SIXTY_NINE = 4096; // buffer大小

const cameraMode = {
  modePhoto: 0, // 拍照模式
  // modeVideo: 1, // 录像模式
};

const cameraWH = {
  width: 480,
  height: 360,
};

/**
 * 分辨率
 */
export enum VideoFrame {
  VIDEOFRAME_1920_1080,
  VIDEOFRAME_1280_720,
  VIDEOFRAME_800_600,
};

// type VideoFrameWH = {
//   width: number;
//   height: number;
// };

const TAG = '[CameraModel]';

export default class CameraService {
  private mediaModel: MediaModel = undefined;
  private fileAsset: photoAccessHelper.PhotoAsset | undefined = undefined;
  private cameraMgr: camera.CameraManager = undefined;
  private camerasArray: Array<camera.CameraDevice> = undefined;
  private cameraInput: camera.CameraInput = undefined;
  private previewOutput: camera.PreviewOutput = undefined;
  private photoOutPut: camera.PhotoOutput = undefined;
  private capSession: camera.CaptureSession = undefined;
  private videoOutput: camera.VideoOutput = undefined;
  private capability: camera.CameraOutputCapability = undefined;

  private avRecorder: media.AVRecorder = undefined;
  private receiver: image.ImageReceiver = undefined;
  private photoPath: string = '';
  private fd: number = -1;
  private takePictureHandle: (photoUri: string) => void = undefined;
  private currentMode:number = cameraMode.modePhoto;
  private  message: string = '';
  private  selectImageUrl: string = '';
  // private videoFrameWH: VideoFrameWH = {
  //   width: 480,
  //   height: 360,
  // }; // 视频分辨率
  private imageRotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0; // 图片旋转角度

  private videoSourceType: number = 0;

  constructor() {
    this.mediaModel = MediaModel.getMediaInstance();
    this.receiver = image.createImageReceiver(
      cameraWH.width,
      cameraWH.height,
      FOUR,
      EIGHT
    );
    Logger.info(TAG, 'createImageReceiver');
    this.receiver.on('imageArrival', () => {
      Logger.info(TAG, 'imageArrival');
      this.receiver.readNextImage((err, image) => {
        Logger.info(TAG, 'readNextImage');
        if (err || image === undefined) {
          Logger.error(TAG, 'failed to get valid image');
          return;
        }
        image.getComponent(FOUR, (errMsg, img) => {
          Logger.info(TAG, 'getComponent');
          if (errMsg || img === undefined) {
            Logger.info(TAG, 'failed to get valid buffer');
            return;
          }
          let buffer = new ArrayBuffer(FOUR_THOUSAND_AND_SIXTY_NINE);
          if (img.byteBuffer) {
            buffer = img.byteBuffer;
          } else {
            Logger.error(TAG, 'img.byteBuffer is undefined');
          }
          // this.saveImage(buffer, image);
        });
      });
    });
  }


  /**
   * 设置图片旋转角度
   * @param imageRotation
   */
  setImageRotation(imageRotation: camera.ImageRotation): void {
    this.imageRotation = imageRotation;
  }

  /**
   * 初始化相机
   * @param surfaceId
   */
  async initCamera(surfaceId: string): Promise<void> {
    Logger.info(TAG, `initCamera surfaceId:${surfaceId}`);
    await this.cameraRelease();
    Logger.info(TAG, `deviceInfo.deviceType = ${deviceInfo.deviceType}`);
    if (deviceInfo.deviceType === 'default') {
      Logger.info(TAG, `deviceInfo.deviceType default 1 = ${deviceInfo.deviceType}`);
      this.videoSourceType = 1;
      Logger.info(TAG, `deviceInfo.deviceType default 2 = ${deviceInfo.deviceType}`);
    } else {
      Logger.info(TAG, `deviceInfo.deviceType other 1 = ${deviceInfo.deviceType}`);
      this.videoSourceType = 0;
      Logger.info(TAG, `deviceInfo.deviceType other 2 = ${deviceInfo.deviceType}`);
    }
    Logger.info(TAG, 'getCameraManager begin');
    try {
      Logger.info(TAG, 'getCameraManager try begin');
      this.cameraMgr = camera.getCameraManager(globalThis.cameraContext);
      Logger.info(TAG, 'getCameraManager try end');
    } catch (e) {
      Logger.info(TAG, `getCameraManager catch e:${JSON.stringify(e)}`);
      Logger.info(TAG, `getCameraManager catch code:${JSON.stringify(e.code)}`);
      Logger.info(TAG, `getCameraManager catch message:${JSON.stringify(e.message)}`);
    }
    Logger.info(TAG, 'getCameraManager end');
    Logger.info(TAG, `getCameraManager ${JSON.stringify(this.cameraMgr)}`);
    this.camerasArray = this.cameraMgr.getSupportedCameras();
    Logger.info(TAG, `get cameras ${this.camerasArray.length}`);
    if (this.camerasArray.length === 0) {
      Logger.info(TAG, 'cannot get cameras');
      return;
    }

    let mCamera = this.camerasArray[0];
    this.cameraInput = this.cameraMgr.createCameraInput(mCamera);
    this.cameraInput.open();
    Logger.info(TAG, 'createCameraInput');
    this.capability = this.cameraMgr.getSupportedOutputCapability(mCamera);
    let previewProfile = this.capability.previewProfiles[0];
    this.previewOutput = this.cameraMgr.createPreviewOutput(
      previewProfile,
      surfaceId
    );
    Logger.info(TAG, 'createPreviewOutput');
    let rSurfaceId = await this.receiver.getReceivingSurfaceId();
    let photoProfile = this.capability.photoProfiles[0];
    this.photoOutPut = this.cameraMgr.createPhotoOutput(
      photoProfile,
      rSurfaceId
    );
    this.capSession = this.cameraMgr.createCaptureSession();
    Logger.info(TAG, 'createCaptureSession');
    this.capSession.beginConfig();
    Logger.info(TAG, 'beginConfig');
    this.capSession.addInput(this.cameraInput);
    this.capSession.addOutput(this.previewOutput);
    this.capSession.addOutput(this.photoOutPut);
    await this.capSession.commitConfig();
    await this.capSession.start();
    Logger.info(TAG, 'captureSession start');
  }

  setTakePictureHandleCallback(callback): void {
    this.takePictureHandle = callback;
  }

  /**
   * 拍照和保存
   */

  async takePhoto(saveUri,abilityContext){
    try {
      let pickerProfile: camerapicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: camerapicker.PickerResult = await camerapicker.pick(abilityContext,
        [camerapicker.PickerMediaType.PHOTO, camerapicker.PickerMediaType.PHOTO], pickerProfile);
      Logger.info(JSON.stringify(pickerResult))
      if(pickerResult?.resultUri){
        //复制图片到缓存目录（缓存目录才有读写权限）
        let filePath = await copyFileToCache(pickerResult.resultUri, abilityContext)
        if (filePath) {
          Logger.info(filePath)
          //上传头像并设置
          // this.uploadImage(filePath)
        }
      }
    } catch (error) {
      let err = error as BusinessError;
      console.error(`the pick call failed. error code: ${err.code}`);
    }

  }


  /**
   * 资源释放
   */
  async cameraRelease(): Promise<void> {
    Logger.info(TAG, 'releaseCamera');
    if (this.cameraInput) {
      await this.cameraInput.close();
    }
    if (this.previewOutput) {
      await this.previewOutput.release();
    }
    if (this.photoOutPut) {
      await this.photoOutPut.release();
    }
    if (this.videoOutput) {
      await this.videoOutput.release();
    }
    if (this.capSession) {
      await this.capSession.release();
    }
  }
}