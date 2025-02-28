import { ErrorMsg } from "../../model/ErrorMsg";
import { Room as RoomBean } from "../../model/Live";
import { AVPlayerController } from "../../utils/AVPlayerController";
import { AVSessionManager } from "../../utils/AVSessionManager";
import { RoomViewModel as rvm } from "../../viewmodel/RoomViewModel";
import { promptAction } from "@kit.ArkUI";
import { webSocket } from "@kit.NetworkKit";
import { BusinessError } from "@kit.BasicServicesKit";
import Logger from "../../utils/Logger";
import { buffer, HashSet } from "@kit.ArkTS";
import { parseBiliDm } from "brotli";

const TAG = '[Room]';

@Builder
export function entryBuilder(_: string, params: RoomBean) {
  Room({ data: params })
}

@Component
struct Room {

  @State data?: RoomBean = undefined;

  @StorageProp("deviceHeight") deviceHeight: number = 0;
  @StorageProp("navHeight") navHeight: number = 0;
  @StorageProp("uid") uid: number = 0;

  private playerCtrl?: AVPlayerController;
  private componentCtrl = new XComponentController();
  private surfaceSize?: SizeOptions;
  private ws = webSocket.createWebSocket();
  private intervalID?: number;
  private sequence: number = 0;
  private dmData = new DMDataSource();
  private scroller = new Scroller();

  aboutToAppear(): void {
    this.connectDM();

  }

  aboutToDisappear(): void {
    this.playerCtrl?.release();
    AVSessionManager.getInstance().release();
    this.ws.off("open");
    this.ws.off("message");
    this.ws.off("error");
    this.ws.close();
    clearInterval(this.intervalID)
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        XComponent({
          type: XComponentType.SURFACE,
          controller: this.componentCtrl
        }).onLoad(() => {
          this.playerCtrl = new AVPlayerController();
          this.playerCtrl.init(this.componentCtrl.getXComponentSurfaceId());
          this.playerCtrl.registerOnMediaSizeChange((w, h) => {
            if (this.surfaceSize) {
              let sw = vp2px(this.surfaceSize.width as number);
              let sh = vp2px(this.surfaceSize.height as number);
              let sAspectRatio = sw / sh;
              let vAspectRatio = w / h;
              if (sAspectRatio > vAspectRatio) {
                sw = sh * vAspectRatio;
              } else {
                sh = sw / vAspectRatio;
              }
              this.componentCtrl.setXComponentSurfaceRect({
                offsetY: Math.min(400, (vp2px(this.deviceHeight) - sh) / 2),
                surfaceWidth: sw,
                surfaceHeight: sh
              });
            }
          })
          if (this.data) {
            this.playerCtrl.setLiveRoom(this.data);
          }
          this.playerCtrl.onCurrChange(true);
        }).onSizeChange((_, newValue) => {
          this.surfaceSize = newValue;
        }).backgroundColor(Color.Transparent)
        List({ scroller: this.scroller }) {
          LazyForEach(this.dmData, (item: [string, string]) => {
            ListItem() {
              Text(){
                Span(`${item[0]}: `).fontColor(Color.Yellow)
                Span(item[1]).fontColor(Color.White)
              }.padding({ left: 10, top: 8, right: 10, bottom: 8 })
              .margin({ left: 16, top: 4, right:16, bottom: 4 })
              .backgroundColor("#80000000")
              .borderRadius(16)
            }
          }, () => {
            return `key_${Date.now()}`;
          })
        }.width('100%').height(this.deviceHeight * 2 / 5)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        }).margin({ bottom: this.navHeight })
      }.backgroundImage($r('app.media.room_bg'))
      .backgroundImageSize({ width: '100%', height: '100%' })
    }.hideTitleBar(true)
  }

  async connectDM() {
    if (!this.data) {
      return;
    }
    let dminfo = await rvm.getDMInfo(this.data.roomid);
    if (dminfo instanceof ErrorMsg) {
      promptAction.showToast({ message: dminfo.message, duration: 2000 })
      return;
    }
    let key = dminfo.token;
    this.ws.on("open", (err: BusinessError, value: Object) => {
      if (err) {
        Logger.error(TAG, `websocket open failed: ${err.message}`);
        return;
      }
    });
    this.ws.on("message", (err: BusinessError, value: string | ArrayBuffer) => {
      if (err) {
        Logger.error(TAG, `websocket on message failed: ${err.message}`);
        return;
      }

      if (value instanceof String) {
        Logger.info(TAG, `websocket reciver string message: ${value}`);
      } else {
        let d = value as ArrayBuffer;

        let buf = buffer.from(d);
        let prot = buf.readUInt16BE(6);

        switch (prot) {
          case 0:
          case 1:
            this.parsePacket(buf.toString('utf8', 16));
            break;
          case 2:
            break;
          case 3:
            parseBiliDm(d.slice(16)).then((dms) => {
              dms.forEach((item) => {
                this.parsePacket(item);
              })
            }, (error:Error) => {
              Logger.info(TAG, `parse dm failed: ${error.message}`);
            })
            break;
        }
      }
    });
    this.ws.on("error", (err: BusinessError) => {
      Logger.error(TAG, `dm connect error: ${err.message}`);
    });
    let host = dminfo.host_list[dminfo.host_list.length - 1];
    this.ws.connect(`wss://${host.host}:${host.wss_port}/sub`,
      (err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `dm connect failed: ${err.code}`);
        return;
      }
      Logger.info(TAG, `dm connect succeed`);
      let rz = `{"uid":${this.uid},"roomid":${this.data?.roomid},"protover":3,"platform":"web","type":2,"key":"${key}"}`;
      this.sendData(rz, 1, 7);
      this.sendHeartbeat();
    });
  }

  parsePacket(packet: string) {
    try {
      let p = JSON.parse(packet.trim()) as object;
      let cmd: string = p["cmd"];
      switch (cmd) {
        case "DANMU_MSG":
          let extra = p["info"][0][15]["extra"] as string;
          let ej = JSON.parse(extra) as object;
          this.dmData.pushData([p["info"][0][15]["user"]["base"]["name"], ej["content"]]);
          setTimeout(() => {
            let allss = this.dmData.totalCount() * 40;
            let needScrollSize = allss - this.scroller.currentOffset().yOffset - this.deviceHeight * 2 / 5;
            this.scroller.scrollEdge(Edge.Bottom, { velocity: Math.max(100, needScrollSize) });
          }, 100)
          Logger.info(TAG, `${p["info"][0][15]["user"]["base"]["name"]}: ${ej["content"]}`);
          break;
      }
    }catch (e) {
      Logger.error(TAG, `${(e as BusinessError).message}`);
      Logger.error(TAG, `${packet}`);
    }
  }

  sendData(data: string, prot: number, op: number) {
    let dataLength = buffer.byteLength(data, 'utf8');
    let arrayBuf = new ArrayBuffer(dataLength + 16);
    let buf = buffer.from(arrayBuf, 0);
    buf.writeUInt32BE(dataLength + 16);
    buf.writeUInt16BE(16, 4);
    buf.writeUInt16BE(prot, 6);
    buf.writeUInt32BE(op, 8);
    buf.writeUInt32BE(this.sequence, 12);
    buf.write(data, 16, dataLength);
    this.ws.send(arrayBuf).then((result) => {
      if (result) {
        Logger.info(TAG, `send data succeed: ${buf.toString('utf8', 16)} bit`);
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `send data failed: ${err.message}`);
    });
    this.sequence++;
  }

  sendHeartbeat() {
    this.intervalID = setInterval(() => {
      this.sendData("heartbeat", 1, 2);
    }, 30000)
  }
}

class DMDataSource implements IDataSource {
  protected data: [string, string][] = [];
  private listeners: HashSet<DataChangeListener> = new HashSet();
  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): [string, string] {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.remove(listener);
  }

  pushData(data: [string, string]) {
    let operation: Array<DataOperation>;
    this.data.push(data);
    if (this.data.length === 120) {
      operation = new Array(2);
      operation[1] = { type: DataOperationType.DELETE, index: 0, count: 40 };
      this.data.splice(0, 40);
    } else {
      operation = new Array(1);
    }
    operation[0] = { type: DataOperationType.ADD, index: this.data.length, count: 1, key: `key_${Date.now()}` };

    this.listeners.forEach((item) => {
      item?.onDatasetChange(operation);
    })
  }
}