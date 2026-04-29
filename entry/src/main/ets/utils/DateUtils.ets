/**
 * 日期格式化工具类
 */
export class DateUtils {
  /**
   * 格式化日期时间为字符串
   * @param date 日期对象
   * @returns 格式化后的日期时间字符串，格式：yyyy/M/d HH:mm:ss
   */
  static formatDateTime(date: Date): string {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hours = date.getHours();
    const minutes = date.getMinutes();
    const seconds = date.getSeconds();

    return `${year}/${month}/${day} ${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  /**
   * 获取当前时间的格式化字符串
   * @returns 当前时间的格式化字符串
   */
  static getCurrentDateTime(): string {
    return DateUtils.formatDateTime(new Date());
  }
}