import { Emote } from "../model/Reply";


export function parseTimeMs(timeMs: number): string {
  return parseTimeS(timeMs / 1000)
}

export function parseTimeS(timeS: number): string {
  const h = timeS / 3600;
  const m = (timeS % 3600) / 60;
  const s = timeS % 60;

  return `${h > 1 ? Math.floor(h) + ":" : ""}${String(Math.floor(m)).padStart(2, "0")}:${String(Math.floor(s)).padStart(2, "0")}`;
}

export function parseView(view?: number): string {
  if (view) {
    if (view < 10000) {
      return String(Math.floor(view));
    } else {
      return `${(view / 10000).toFixed(1)}万`;
    }
  }
  return "0";
}

export function formatData(timestamp: number, hasTime: boolean = false): string {
  const now = new Date();
  const timeDiffSec = (now.getTime() / 1000 - timestamp);
  const minute = 60;
  const hour = minute * 60;
  const day = hour * 24;
  const day3 = day * 3;
  if (timeDiffSec < minute) {
    return "刚刚";
  } else if (timeDiffSec < hour) {
    return `${Math.floor(timeDiffSec / minute)}分钟前`;
  }  else if (timeDiffSec < day) {
    return `${Math.floor(timeDiffSec / hour)}小时前`;
  } else if (timeDiffSec < day3) {
    return `${Math.floor(timeDiffSec / day)}天前`;
  } else {
    const date = new Date(timestamp * 1000);
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDay()).padStart(2, "0");
    let time = "";
    if (hasTime) {
      time = ` ${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`;
    }
    return `${(y < now.getFullYear()) ? y + "年" : ""}${m}月${d}日${time}`
  }
}

export function parseUpLevel(level: number): Resource {
  switch (level) {
    case 0: return $r('app.media.user_level_0');
    case 1: return $r('app.media.user_level_1');
    case 2: return $r('app.media.user_level_2');
    case 3: return $r('app.media.user_level_3');
    case 4: return $r('app.media.user_level_4');
    case 5: return $r('app.media.user_level_5');
    case 6: return $r('app.media.user_level_6');
    default : return $r('app.media.user_level_0');
  }
}

export function parseReply(reply: string = "", emote?: Record<string, Emote>): string[] {
  let parseReply: string[] = [];
  if (emote) {
    let indexEmotes: [number, Emote][] = [];
    let entry = Object.entries(emote);
    entry.forEach((value) => {
      let index = 0;
      while ((index = reply.indexOf(value[0], index)) !== -1) {
        indexEmotes.push([index, value[1]]);
        index += value[0].length;
      }
    })
    indexEmotes.sort((a, b) => a[0] - b[0]);
    if (indexEmotes.length === 0) {
      parseReply.push(reply);
    } else {
      let index = 0;
      indexEmotes.forEach((value) => {
        if (value[0] === index) {
          parseReply.push(value[1].url);
        } else {
          parseReply.push(reply.substring(index, value[0]));
          parseReply.push(value[1].url);
        }
        index = value[0] + value[1].text.length;
      })
      if (index < reply.length - 1) {
        parseReply.push(reply.substring(index));
      }
    }
  } else {
    parseReply.push(reply);
  }
  return parseReply;
}
