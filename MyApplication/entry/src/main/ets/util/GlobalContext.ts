import common from '@ohos.app.ability.common';

export class GlobalContext {
  private constructor() {
  }

  private static instance: GlobalContext;
  private cameraAbilityContext: common.UIAbilityContext;

  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  public getCameraAbilityContext(): common.UIAbilityContext {

    return this.cameraAbilityContext;
  }

  public setCameraAbilityContext(context: common.UIAbilityContext): void {
    this.cameraAbilityContext = context;
  }
}