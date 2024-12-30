//
// import photoAccessHelper from '@ohos.file.photoAccessHelper';
// import DateTimeUtil from '../utils/DateTimeUtil';
// import Logger from '../utils/Logger';
// // import { Constants, SettingDataObj } from '';
// import common from '@ohos.app.ability.common';
//
// let context = getContext(this) as common.Context;
//
// export default class MediaUtils {
//   private tag: string = 'MediaUtils';
//   private mediaTest: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
//   private static instance: MediaUtils = new MediaUtils();
//   private num: number = 0;
//   private settingDataObj: SettingDataObj = {
//     mirrorBol: false,
//     videoStabilizationMode: 0,
//     exposureMode: 1,
//     focusMode: 2,
//     photoQuality: 1,
//     locationBol: false,
//     photoFormat: 1,
//     photoOrientation: 0,
//     photoResolution: 0,
//     videoResolution: 0,
//     videoFrame: 0,
//     referenceLineBol: false
//   };
//
//   public static getInstance() {
//     if (this.instance === undefined) {
//       this.instance = new MediaUtils();
//     }
//     return this.instance;
//   }
//
//   async createAndGetUri(mediaType: number) {
//     let info = this.getInfoFromType(mediaType);
//     let dateTimeUtil = new DateTimeUtil();
//     let name = `${dateTimeUtil.getDate()}_${dateTimeUtil.getTime()}`;
//     let displayName = `${info.prefix}${name}${info.suffix}`;
//     Logger.info(this.tag, `createAndGetUri displayName = ${displayName},mediaType = ${mediaType}`);
//     try {
//       return await this.mediaTest.createAsset(displayName);
//     } catch {
//       this.num++;
//       displayName = `${info.prefix}${name}_${this.num}${info.suffix}`;
//       return await this.mediaTest.createAsset(displayName);
//     }
//   }
//
//   async getFdPath(fileAsset: photoAccessHelper.PhotoAsset) {
//     let fd = await fileAsset.open('rw');
//     Logger.info(this.tag, `fd = ${fd}`);
//     return fd;
//   }
//
//   // Photo Format
//   onChangePhotoFormat() {
//     if (this.settingDataObj.photoFormat === 0) {
//       return 'png';
//     }
//     if (this.settingDataObj.photoFormat === 1) {
//       return 'jpg';
//     }
//     if (this.settingDataObj.photoFormat === 2) { // 2:photoFormat
//       return 'bmp';
//     }
//     if (this.settingDataObj.photoFormat === 3) { // 3:photoFormat
//       return 'webp';
//     }
//     if (this.settingDataObj.photoFormat === 4) { // 4:photoFormat
//       return 'jpeg';
//     }
//   }
//
//   getInfoFromType(mediaType: number) {
//     let result = {
//       prefix: '', suffix: ''
//     };
//     switch (mediaType) {
//       case Constants.IMAGE:
//         result.prefix = 'IMG_';
//         result.suffix = `.${this.onChangePhotoFormat()}`;
//         break;
//       case Constants.VIDEO:
//         result.prefix = 'VID_';
//         result.suffix = '.mp4';
//         break;
//       default:
//         break;
//     }
//     return result;
//   }
// }