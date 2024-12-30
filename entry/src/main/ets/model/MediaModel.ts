
import photoAccessHelper from '@ohos.file.photoAccessHelper';
// import DateTimeUtil from '../utils/DateTimeUtil';
import { GlobalContext } from '../utils/GlobalContext';
import common from '@ohos.app.ability.common';
// import Logger from '../utils/Logger';

const TAG = '[MediaModel]';

type FileInfo = {
  prefix: string;
  suffix: string;
};

export default class MediaModel {
  private accessHelper: photoAccessHelper.PhotoAccessHelper = undefined;
  private static mediaInstance: MediaModel = undefined;

  constructor() {
    let cameraContext: common.UIAbilityContext = GlobalContext.getContext().getCameraAbilityContext();
    this.accessHelper = photoAccessHelper.getPhotoAccessHelper(cameraContext);
  }

  public static getMediaInstance(): MediaModel {
    if (this.mediaInstance === undefined) {
      this.mediaInstance = new MediaModel();
    }
    return this.mediaInstance;
  }

  // async createAndGetUri(mediaType: photoAccessHelper.PhotoType): Promise<photoAccessHelper.PhotoAsset> {
  //   let dateTimeUtil: DateTimeUtil = new DateTimeUtil();
  //   let info: FileInfo = this.getInfoFromMediaType(mediaType);
  //   let name: string = `${dateTimeUtil.getDate()}_${dateTimeUtil.getTime()}`;
  //   let displayName: string = `${info.prefix}${name}${info.suffix}`;
  //   Logger.info(TAG, `displayName = ${displayName},mediaType = ${mediaType}`);
  //   let fileAsset: photoAccessHelper.PhotoAsset = await this.accessHelper.createAsset(displayName);
  //   return fileAsset;
  // }
  //
  // async getFdPath(fileAsset: photoAccessHelper.PhotoAsset): Promise<number> {
  //   let fd: number = await fileAsset.open('rw');
  //   Logger.info(TAG, `fd = ${fd}`);
  //   return fd;
  // }

  getInfoFromMediaType(mediaType: photoAccessHelper.PhotoType): FileInfo {
    let fileInfo: FileInfo = {
      prefix: '',
      suffix: ''
    };
    switch (mediaType) {
      case photoAccessHelper.PhotoType.IMAGE:
        fileInfo.prefix = 'IMG_';
        fileInfo.suffix = '.jpg';
        break;
      case photoAccessHelper.PhotoType.VIDEO:
        fileInfo.prefix = 'VID_';
        fileInfo.suffix = '.mp4';
        break;
      default:
        break;
    }
    return fileInfo;
  }
}