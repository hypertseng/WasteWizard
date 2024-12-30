import picker from '@ohos.file.picker';
import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import call from '@ohos.telephony.call';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import request from '@ohos.request';
//
// async function checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
//   let atManager = abilityAccessCtrl.createAtManager();
//   let grantStatus: abilityAccessCtrl.GrantStatus;
//   // 获取应用程序的accessTokenID
//   let tokenId: number;
//   try {
//     let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
//     let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
//     tokenId = appInfo.accessTokenId;
//   } catch (err) {
//     console.error(`getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
//   }
//   // 校验应用是否被授予权限
//   try {
//     grantStatus = await atManager.checkAccessToken(tokenId, permission);
//   } catch (err) {
//     console.error(`checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
//   }
//   return grantStatus;
// }

// async function checkPermissions(permissions: Array<Permissions>): Promise<boolean> {
//   for (let i = 0; i < permissions.length; i++) {
//     let grantStatus: abilityAccessCtrl.GrantStatus = await checkAccessToken(permissions[i]);
//     if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
//       return false;
//     }
//   }
//   return true;
// }

@Entry
@Component
struct Index {
  @State message: string = '';
  @State selectVideoUrl: string = '';
  @State selectImageUrl: string = '';
  async checkAndGetPermissions(permissions: Array<Permissions>) {
    // const checkRes = await checkPermissions(permissions);
    // console.log(`checkRes: ${checkRes}`);
    // return new Promise((resolve) => {
    //   let context = getContext(this);
    //   let atManager = abilityAccessCtrl.createAtManager();
    //   // requestPermissionsFromUser 会判断权限的授权状态来决定是否唤起弹窗
    //   atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    //     let grantStatus: Array<number> = data.authResults;
    //     let length: number = grantStatus.length;
    //     for (let i = 0; i < length; i++) {
    //       if (grantStatus[i] !== 0) {
    //         console.log(`PhotoViewPicker grantStatus: ${JSON.stringify(grantStatus)}`);
    //         resolve(false);
    //       }
    //     }
    //     resolve(true);
    //   }).catch(() => {
    //     resolve(false);
    //   })
    // });
    return true;
  }

  async callPhone() {
    const callRes = await call.makeCall("10086");
    console.log(`callRes: ${callRes}`);
  }

  async openAmap() {
    // const lon = '116'; // 经度
    // const lat = '39'; // 纬度
    // let context = getContext(this) as common.UIAbilityContext;
    // let wantInfo = {
    //   action: "ohos.want.action.viewData",
    //   uri: `androidamap://navi?sourceApplication=liondemo&poiname=匹诺康尼&lat=${lat}&lon=${lon}&dev=1&style=2`,
    // };
    // // androidamap://navi?sourceApplication=liondemo&poiname=匹诺康尼&lat=36.547901&lon=104.258354&dev=1&style=2
    // try {
    //   context.startAbility(wantInfo).then(() => {
    //     console.log('打开成功');
    //   }).catch(() => {
    //     console.log('打开失败');
    //   });
    // }catch(err){
    //   console.log(`err: ${JSON.stringify(err)}`);
    // }
  }

  async openMarket() {
    let context = getContext(this) as common.UIAbilityContext;
    try {
      context.startAbility({
        action: "ohos.want.action.viewData",
        uri: `market://details?id=com.tencent.mobileqq`
      }).then(() => {
        console.log('打开成功');
      }).catch(() => {
        console.log('打开失败');
      });
    }catch(err){
      console.log(`err: ${JSON.stringify(err)}`);
    }
  }

  // 调起相册选择图片
  async selectPhoto() {
    try {
      let PhotoSelectOptions = new picker.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((photoSelectResult) => {
        // 不能在picker的回调里直接使用此URI进行打开文件操作，需要定义一个全局变量保存URI，使用类似一个按钮去触发打开文件
        this.message = JSON.stringify(photoSelectResult);
        this.selectImageUrl = photoSelectResult.photoUris[0];
      })
    } catch (err) {
      this.message = 'PhotoViewPicker failed with err: ';
    }
  }

  // 调起相机拍照
  async takePhoto(){
    const checkResult = await this.checkAndGetPermissions(['ohos.permission.CAMERA', 'ohos.permission.READ_MEDIA']);
    if(!checkResult) {
      console.log('需要授权');
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    const chaptureResult = await context.startAbilityForResult({
      action: 'ohos.want.action.imageCapture',
      parameters: {} // 参数
    });
    this.message = JSON.stringify(chaptureResult.want);
    this.selectImageUrl = chaptureResult.want.uri;
  }

  async uploadImage() {
    const context = getContext(this);
    const imgName = Date.now();
    const imgData = fs.openSync(this.selectImageUrl, fs.OpenMode.READ_ONLY); // 以只读的方式打开
    const newDir = `${context.cacheDir}/${imgName}.jpg`;
    fs.copyFileSync(imgData.fd, newDir); // 图片复制到此目录下
    // 操作上传到服务器
    const uploadURI = `internal://cache/${newDir.split('cache/')[1]}`;
    request.uploadFile(context, {
      url: "https://graph.baidu.com/upload",
      header: {
        "Accept": "*/*",
        "Content-type": "multipart/form-data"
      },
      method: "POST",
      files: [{ filename: "test", name: "test", uri: uploadURI, type: "jpg"}],
      data: [{ name: "a", value: "b" }],
    }).then((uploadTask) => {
      uploadTask.on('complete', () => {
        this.message = 'complete';
      });
      uploadTask.on('fail', () => {
        this.message = 'fail';
      });
    })
    // this.message = JSON.stringify(uploadResult);
  }
  build() {
    Column() {
      Text(`${this.message}`).fontSize(16)
      Button('从相册选择一张图片').onClick(() => {
        this.selectPhoto();
      }).margin({top: 20})
      Button('使用相机拍照').onClick(() => {
        this.takePhoto();
      }).margin({top: 20})
      // Button('使用相机录像').onClick(() => {
      //   this.takeVideo();
      // }).margin({top: 20})
      Button('将图片上传到服务器').onClick(() => {
        this.uploadImage();
      }).margin({top: 20})
      Image(this.selectImageUrl).width(200)


      // Video({
      //   src: this.selectVideoUrl
      // }).width('100%').height(300)
      // Button('打电话').onClick(() => {
      //   this.callPhone();
      // }).margin({top: 20})
      // Button('打开高德').onClick(() => {
      //   this.openAmap();
      // }).margin({top: 20})
      // Button('打开应用商店').onClick(() => {
      //   this.openMarket();
      // }).margin({top: 20})
    }.width('100%')
  }
}

