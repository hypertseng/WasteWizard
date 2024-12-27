import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { BusinessError } from '@ohos.base';
import { common, Want } from '@kit.AbilityKit';

// 需要检测（申请）的权限
const permissions: Array<Permissions> = ['ohos.permission.CAMERA'];

// 1.1具体权限检测
async function checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

  // 获取应用程序的accessTokenID
  let tokenId: number = 0;
  try {
    let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    tokenId = appInfo.accessTokenId;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
  }

  // 校验应用是否被授予权限
  try {
    grantStatus = await atManager.checkAccessToken(tokenId, permission);//核心代码
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
  }

  return grantStatus;
}

// 1.2检测权限
export async function checkPermissions(context: common.UIAbilityContext): Promise<boolean> {
  let grantStatus: abilityAccessCtrl.GrantStatus = await checkAccessToken(permissions[0]);
  let hasPermission:boolean=false

  if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
    // 已经授权，可以继续访问目标操作
    hasPermission=true
  } else {
    // 申请相机权限
    reqPermissionsFromUser(permissions,context)
  }

  return hasPermission
}

// 2.动态申请权限
export async function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext) {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗[核心函数]
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        console.log('用户选择授权')
      } else {
        // 3. 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        console.log('用户选择不授权')
        openPermissionsInSystemSettings(context)
        console.log('用户选择不授权')
        return;
      }
    }
    // 授权成功
  }).catch((err: BusinessError) => {
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}

//3.授权结果处理：用户拒绝授权
function openPermissionsInSystemSettings(context: common.UIAbilityContext): void {
  //启动一个设置页（应用）
  //因openharmony和harmonyOS API不同，导致用户拒绝权限获取后，设置页调换不出来。
  const  bundleInfo =  bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  context.startAbility({
    bundleName:'com.huawei.hmos.settings',
    abilityName:'com.huawei.hmos.settings.MainAbility',
    uri:'application_info_entry',
    parameters:{
      //按照包名，打开对应设置页
      pushParams:bundleInfo.name
    }
  })

}
