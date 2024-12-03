import { HashSet } from "@kit.ArkTS";

export abstract class BaseDataSource<T> implements IDataSource {

  protected data: T[] = [];
  private listeners: HashSet<DataChangeListener> = new HashSet();

  abstract generateKey(index: number): string;

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): T {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.remove(listener);
  }

  reloadData(...data: T[]) {
    this.data.splice(0, this.data.length, ...data);
    this.notifyDataReload();
  }

  notifyDataReload() {
    this.listeners.forEach((listener) => {
      listener?.onDatasetChange([{ type: DataOperationType.RELOAD }]);
    })
  }

  moveData(from: number, to: number) {
    let temp = this.data[from];
    this.data[from] = this.data[to];
    this.data[to] = temp;
    this.notifyDataMove(from, to);
  }

  notifyDataMove(from: number, to: number) {
    this.listeners.forEach((listener) => {
      listener?.onDatasetChange([{
        type: DataOperationType.EXCHANGE,
        index: { start: from, end: to },
        key: {
          start: this.generateKey(from),
          end: this.generateKey(to)
        }
      }])
    })
  }

  changeData(index: number, d: T) {
    this.data[index] = d;
    this.notifyDataChange(index);
  }

  notifyDataChange(index: number) {
    this.listeners.forEach((listener) => {
      listener?.onDatasetChange([{
        type: DataOperationType.CHANGE,
        index: index, key: this.generateKey(index) }])
    })
  }

  insertData(index: number, ...d: T[]) {
    this.data.splice(index, 0, ...d);
    let size = d.length;
    this.notifyDataAdd(index, size);
  }

  addData(...d: T[]) {
    let index = this.data.length;
    this.data.push(...d);
    let size = d.length;
    this.notifyDataAdd(index, size);
  }

  notifyDataAdd(index: number, size: number) {
    this.listeners.forEach((listener) => {
      listener?.onDatasetChange([{ type: DataOperationType.ADD, index: index, count: size }]);
    })
  }

  delete(index: number, size: number = 1) {
    this.data.splice(index, size);
    this.notifyDataDelete(index, size);
  }

  notifyDataDelete(index: number, size: number) {
    this.listeners.forEach((listener) => {
      listener?.onDatasetChange([{ type: DataOperationType.DELETE, index: index, count: size }]);
    })
  }
}