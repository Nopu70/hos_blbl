import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { webview } from '@kit.ArkWeb';
import { WindowUtil } from '../utils/WindowUtil';
import { Cookies } from '../model/Cookies';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AppStorage.setOrCreate("context", this.context);
    webview.WebCookieManager.fetchCookie("api.bilibili.com").then((cookies) => {
      AppStorage.setOrCreate("cookies", new Cookies(cookies));
    }).catch(() => {
      console.log(`load cookie failed`);
    })
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    const currentColorMode: ConfigurationConstant.ColorMode | undefined = AppStorage.get('color_mode');
    if (currentColorMode != newConfig.colorMode) {
      AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('color_mode', newConfig.colorMode);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    WindowUtil.getInstance().setWindowStage(windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      PersistentStorage.persistProp("color_mode", ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      let colorMode = AppStorage.get<ConfigurationConstant.ColorMode>("color_mode");
      this.context.getApplicationContext().setColorMode(colorMode)

      PersistentStorage.persistProp("uid", 0);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
