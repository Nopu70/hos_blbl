
export interface LiveUrl{
  current_quality: number;
  accept_quality: number[];
  current_qn: 10000,
  quality_description: QualityDescription[],
  durl: Durl[]
}

export interface QualityDescription {
  qn: number;
  desc: string;
}

export interface Durl {
  url: string;
  length: number;
  order: number;
  stream_type: number;
  p2p_type: number;
}

export interface DMInfo {
  group: string;
  business_id: number;
  refresh_row_factor: number;
  refresh_rate: number;
  max_delay: number;
  token: string;
  host_list: DMHost[];
}

export interface DMHost {
  host: string;
  port: number;
  wss_port: number;
  ws_port: number;
}