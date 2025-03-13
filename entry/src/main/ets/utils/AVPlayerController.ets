import { media } from "@kit.MediaKit";
import { BVideo } from "../model/BVideo";
import { PlayerViewModel as pvm } from "../viewmodel/PlayerViewModel";
import { RoomViewModel as rvm } from "../viewmodel/RoomViewModel";
import { BusinessError } from "@kit.BasicServicesKit";
import Logger from "./Logger";
import { ErrorMsg } from "../model/ErrorMsg";
import { parseTimeS } from "./ParseUtil";
import { AVSessionManager } from "./AVSessionManager";
import { avSession } from "@kit.AVSessionKit";
import { Room } from "../model/Live";
import { Cookies } from "../model/Cookies";

const TAG = '[AvPlayerController]';

@Observed
export class AVPlayerController{
  
  @Track isPlaying = false;
  @Track startRenderFrame = false;
  @Track currentTime: number = 0;
  @Track duration: number = 0;
  @Track durationTime: number = 0;
  @Track durationTimeString: string = "";

  private mPlayer?: media.AVPlayer;
  private surfaceId: string = "";
  private playWhenReady = false;
  private isSeeking = false;
  private lastSeekTime: number = 0;
  private sessionManager?: AVSessionManager;
  private video?: BVideo;
  private room?: Room;
  private onSizeChange?: (width: number, height: number) => void;

  constructor() {
  }

  init(surfaceId: string) {
    this.surfaceId = surfaceId;
    this.sessionManager = AVSessionManager.getInstance();
    media.createAVPlayer().then((player) => {
      this.mPlayer = player;
      this.setAVPlayerCallback(player);
      this.setAVPlayerCallback(player);
      this.registerSessionCallback();
    })
  }

  async setDataSource(data: BVideo) {
    this.video = data;
    this.startRenderFrame = false;
    this.playWhenReady = false;

    let videoUrl = await pvm.getUrl(data.cid, data.bvid)
    if (videoUrl instanceof ErrorMsg) {
      Logger.error(TAG, `加载视频URL失败 error: ${videoUrl.message}`)

    } else {
      Logger.info(TAG, `打开URL: ${videoUrl.durl?.[0]?.url}`)
      let ms = media.createMediaSourceWithUrl(
        videoUrl.durl?.[0]?.url,
        // "http://10.168.1.103/test.mp4",
        {
          "Content-Type": "application/json",
          "Cookie": AppStorage.get<Cookies>("cookies")?.cookies,
          "Referer": "https://m.bilibili.com/",
          "User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36 Edg/130.0.0.0"
        }
      );
      this.mPlayer?.setMediaSource(ms, {
        preferredWidth: data.dimension.width,
        preferredHeight: data.dimension.height,
        preferredBufferDuration: 5
      })
    }
  }
  async setLiveRoom(room: Room) {
    this.room = room;
    this.startRenderFrame = false;
    this.playWhenReady = false;

    let url = await rvm.getUrl(room.roomid);
    if (url instanceof ErrorMsg) {
      Logger.error(TAG, `加载视频URL失败 error: ${url.message}`)

    } else {
      Logger.info(TAG, `打开URL: ${url}`)
      // let ms = media.createMediaSourceWithUrl(
      //   roomUrl.durl?.[0]?.url,
      //   // "http://10.168.1.103/test.mp4",
      //   {
      //     "Content-Type": "application/json",
      //     "Cookie": AppStorage.get<Cookies>("cookies")?.cookies,
      //     "Referer": "https://m.bilibili.com/",
      //     "User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36 Edg/130.0.0.0"
      //   }
      // );
      // this.mPlayer?.setMediaSource(ms)

      if (this.mPlayer) {
        this.mPlayer.url = url;
      }
    }
  }

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', (time: number) => {
      if (this.isSeeking) {
        return;
      }

      if (time > this.currentTime * 1000) {
        animateTo({ duration: 1000, curve: Curve.Linear }, () => {
          this.currentTime = Math.floor(time / 1000);
        });
      } else {
        this.currentTime = Math.floor(time / 1000);
      }
    });
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      if (this.lastSeekTime === seekDoneTime) {
        this.isSeeking = false;
      }
      this.sessionManager?.setPlaybackState({
        position: {
          elapsedTime: avPlayer.currentTime,
          updateTime: new Date().getTime()
        },
        duration: avPlayer.duration
      })
      Logger.info(TAG, `AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // seek操作结果回调函数
    avPlayer.on('startRenderFrame', () => {
      Logger.info(TAG, `AVPlayer start render frame`);
      this.startRenderFrame = true;
    })
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      Logger.info(TAG, `source size change`);
      if (this.onSizeChange) {
        this.onSizeChange(width, height);
      }
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      // avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, _: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state idle called.');
          avPlayer.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          Logger.info(TAG, 'AVPlayer state initialized called.');
          avPlayer.surfaceId = this.surfaceId;
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          Logger.info(TAG, 'AVPlayer state prepared called.');
          this.duration = avPlayer.duration;
          this.durationTime = avPlayer.duration / 1000;
          this.durationTimeString = parseTimeS(this.durationTime);
          if (this.playWhenReady) {
            avPlayer.play(); // 调用播放接口开始播放
          }
          break;
        case 'playing': // play成功调用后触发该状态机上报
          this.isPlaying  = true;
          this.sessionManager?.setPlaybackState({
            state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
            position: {
              elapsedTime: avPlayer.currentTime,
              updateTime: new Date().getTime()
            },
            duration: avPlayer.duration
          })
          Logger.info(TAG, 'AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          this.sessionManager?.setPlaybackState({
            state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
            position: {
              elapsedTime: avPlayer.currentTime,
              updateTime: new Date().getTime()
            },
            duration: avPlayer.duration
          })
          this.isPlaying = false;
          Logger.info(TAG, 'AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state completed called.');
          this.isPlaying = false;
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          Logger.info(TAG, 'AVPlayer state stopped called.');
          break;
        case 'released':
          Logger.info(TAG, 'AVPlayer state released called.');
          break;
        default:
          Logger.info(TAG, 'AVPlayer state unknown called.');
          break;
      }
    })
  }

  registerSessionCallback(){
    this.sessionManager?.register((session) => {
      session.on("play", () => {
        this.play();
      });
      session.on("pause", () => {
        this.pause();
      });
      // session.on("playNext", () => {
      //
      // });
      // session.on("playPrevious", () => {
      //
      // });
      session.on("seek", (seekTime: number) => {
        this.seekTo(seekTime);
      });
    })
  }

  registerOnMediaSizeChange(cb: (width: number, height: number) => void) {
    this.onSizeChange = cb;
  }

  play() {
    this.playWhenReady = true;
    this.mPlayer?.play();
  }

  pause() {
    this.playWhenReady = false;
    this.mPlayer?.pause()
  }

  seekTo(time: number) {
    this.lastSeekTime = time;
    this.mPlayer?.seek(time, media.SeekMode.SEEK_PREV_SYNC);
    this.sessionManager?.setPlaybackState({
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      },
      duration: this.mPlayer?.duration ?? this.duration
    })
  }

  onCurrChange(isCurr: boolean) {
    if (isCurr) {
      this.play();
      if (this.video) {
        this.sessionManager?.setMetadata(
          this.video.bvid, this.video.pic, this.video.title,
          this.video.owner?.name, this.video.duration
        );
      } else if (this.room) {
        this.sessionManager?.setMetadata(
          this.room.roomid.toString(), this.room.face,
          this.room.title, this.room.uname
        );
      }
    } else {
      this.pause();
    }
  }

  release() {
    if (this.mPlayer) {
      this.mPlayer.off("stateChange");
      this.mPlayer.off("seekDone");
      this.mPlayer.off("error");
      this.mPlayer.off("startRenderFrame");
      this.mPlayer.off("timeUpdate");
      this.mPlayer.off("videoSizeChange");
      this.mPlayer.release();
    }
  }
}