
export function isEmpty(text?: string): boolean {
  if (text === undefined || text === null) return true;
  if (text.length === 0) return true;
  return false;
}