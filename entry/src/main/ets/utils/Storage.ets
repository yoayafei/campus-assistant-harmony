// utils/Storage.ts - 使用PersistentStorage
// import { PersistentStorage } from '@ohos.app.storage';

export class Storage {
  // 初始化持久化存储
  static initStorage(): void {
    // PersistentStorage会自动处理持久化
  }

  // 设置存储项
  static setItem(key: string, value: string): void {
    PersistentStorage.PersistProp<string>(key, value);
  }

  // 获取存储项，支持默认值
  static getItemWithDefault(key: string, defaultValue: string): string {
    const value = AppStorage.Get<string>(key);
    return value !== undefined ? value : defaultValue;
  }

  // 删除存储项
  static removeItem(key: string): void {
    // PersistentStorage没有直接删除的方法
    // 可以设置为空字符串或使用其他方式
    PersistentStorage.PersistProp<string>(key, '');
  }
}

// config/Constants.ts - 配置常量
export class Constants {
  static readonly API_BASE_URL = 'http://your-api-domain/api';
  static readonly TOKEN_KEY = 'auth_token';
  static readonly USER_INFO_KEY = 'user_info';
  static readonly LIBRARY_CATEGORIES = [
    '全部', '计算机', '文学', '经济', '历史',
    '科学', '艺术', '哲学', '教育', '医学'
  ];
}