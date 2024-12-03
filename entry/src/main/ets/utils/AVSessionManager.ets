import { avSession } from "@kit.AVSessionKit"
// import { BVideo } from "../model/BVideo";
import Logger from "./Logger";
import { BusinessError } from "@kit.BasicServicesKit";
import { common, wantAgent } from "@kit.AbilityKit";
import { BUNDLE_NAME } from "BuildProfile";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";

const TAG = "AVSessionManager";

export class AVSessionManager{

  private session?: avSession.AVSession;
  private static instance?: AVSessionManager;
  private sessionPromise?: Promise<void>;
  private context: common.Context;

  private constructor() {
    this.context = AppStorage.get("context") ?? getContext();
    this.createSession();
  }

  public static getInstance(): AVSessionManager {
    if (!AVSessionManager.instance) {
      AVSessionManager.instance = new AVSessionManager();
    }
    return AVSessionManager.instance;
  }

  private createSession() {
    this.sessionPromise = avSession.createAVSession(this.context,
      "bilibili", "video").then((session) => {
      Logger.info(TAG, "create session succeed");
      this.session = session;
      this.startBackRunning();
      this.setLaunchAbility();
      return session.activate();
    }).then(() => {
      Logger.info(TAG, "active session succeed");
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `active session failed: ${error.message}`);
    })
  }

  async setMetadata(id: string, pic?: string | null, title?: string | null, owner?: string | null, duration?: number | null) {
    await this.sessionPromise;
    let metadata: avSession.AVMetadata = {
      assetId: id,
      title: title ?? "bilibili",
      artist: owner ?? "",
      author: owner ?? "",
      mediaImage: pic ?? "",
      duration: (duration ?? 0) * 1000
    }
    this.session?.setAVMetadata(metadata).then(() => {
      Logger.info(TAG, `set metadata succeed: ${title}`);
    }).catch((error: BusinessError) => {
      Logger.info(TAG, `set metadata error: ${error.message}}`);
    })
  }

  async setPlaybackState(state: avSession.AVPlaybackState) {
    await this.sessionPromise;
    this.session?.setAVPlaybackState(state).then(() => {
      Logger.info(TAG, "set playback state succeed");
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `set playback state failed: ${error.message}`);
    });
  }

  setLaunchAbility() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: (this.context as common.UIAbilityContext).abilityInfo.bundleName,
          abilityName: (this.context as common.UIAbilityContext).abilityInfo.name
        }
      ],
      // OperationType.START_ABILITIES
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      this.session?.setLaunchAbility(agent);
      Logger.info(TAG, "set launch ability succeed");
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `set launch ability failed: ${error.message}`);
    })
  }



  startBackRunning() {
    let wantInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: BUNDLE_NAME,
          abilityName: "EntryAbility",
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    wantAgent.getWantAgent(wantInfo).then((wantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        wantAgent).then(() => {
        Logger.info(TAG, "start background running succeed");
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `start background running failed: ${error.message}`);
      })
    })
  }

  stopBackRunning() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      Logger.info(TAG, "stop background running succeed");
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `stop background running failed: ${error.message}`);
    })
  }

  async register(reg: (session: avSession.AVSession) => void) {
    await this.sessionPromise;
    if (this.session) {
      reg(this.session);
      Logger.info(TAG, "register session succeed");
    }
  }

  release() {
    this.session?.off('play');
    this.session?.off('pause');
    // this.session?.off('playNext');
    // this.session?.off('playPrevious');
    // this.session?.off('setLoopMode');
    this.session?.off('seek');
    // this.session?.off('toggleFavorite');
    this.session?.destroy().then(() => {
      Logger.info(TAG, "destroy session succeed");
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `destroy session failed: ${error.message}`);
    });
    this.stopBackRunning();
    AVSessionManager.instance = undefined;
  }
}