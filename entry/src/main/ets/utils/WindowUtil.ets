/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

const TAG: string = '[WindowUtil]';

export class WindowUtil {
  private static instance: WindowUtil;
  private windowStage?: window.WindowStage;
  private mainWindowClass?: window.Window;

  public static getInstance() {
    if (!WindowUtil.instance) {
      WindowUtil.instance = new WindowUtil();
    }
    return WindowUtil.instance;
  }

  public setWindowStage(windowStage: window.WindowStage): void {

    this.windowStage = windowStage;
    this.windowStage.getMainWindow((err, windows: window.Window) => {
      if (err.code) {
        Logger.error(TAG, `Failed to obtain the main window. Code:${err.code}, message:${err.message}`);
        return;
      }
      this.mainWindowClass = windows;

      windows.setWindowLayoutFullScreen(true).then(() => {
        Logger.info(TAG, "设置全屏成功");
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `设置全屏失败 ${JSON.stringify(err)}`);
      })

      const properties = windows.getWindowProperties();
      AppStorage.setOrCreate('deviceWidth', px2vp(properties.windowRect.width));
      AppStorage.setOrCreate('deviceHeight', px2vp(properties.windowRect.height));

      let avoidArea = windows.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let navHeight = avoidArea.bottomRect.height;
      AppStorage.setOrCreate("navHeight", px2vp(navHeight));

      avoidArea = windows.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let statusHeight = avoidArea.topRect.height;
      AppStorage.setOrCreate("statusHeight", px2vp(statusHeight));

      windows.on("avoidAreaChange", (data) => {
        if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let navHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate("navHeight", px2vp(navHeight));
        } else if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let statusHeight = data.area.topRect.height;
          AppStorage.setOrCreate("statusHeight", px2vp(statusHeight));
        } else if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          let statusHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate("keyboardHeight", px2vp(statusHeight));
        }
      })
    });
  }

  setMainWindowOrientation(orientation: window.Orientation, callback?: Function): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    // Setting orientation.
    this.mainWindowClass.setPreferredOrientation(orientation).then(() => {
      callback?.();
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to set the ${orientation} of main window. Code:${err.code}, message:${err.message}`);
    });
  }

  disableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    // Set the status bar and navigation bar to be invisible in full-screen mode.
    this.mainWindowClass.setWindowSystemBarEnable([]);
  }

  enableWindowSystemBar(): void {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable(['status', 'navigation']);
  }

  setLandscapeMultiWindow(enable: boolean) {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    if (enable) {
      this.mainWindowClass?.enableLandscapeMultiWindow();
    } else {
      this.mainWindowClass?.disableLandscapeMultiWindow();
    }
  }

  registerOnWindowSizeChange(callback?: (size: window.Size) => void) {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    this.mainWindowClass.on('windowSizeChange', (size) => {
      // AppStorage.setOrCreate('deviceHeight', size.height);
      callback?.(size);
    });
  }

  registerOffWindowSizeChange() {
    if (this.mainWindowClass === undefined) {
      Logger.error(`MainWindowClass is undefined`);
      return;
    }
    this.mainWindowClass.off('windowSizeChange');
  }
}