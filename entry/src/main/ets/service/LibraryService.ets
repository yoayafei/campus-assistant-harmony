// service/LibraryService.ts
import http from '@ohos.net.http';
import {
  Book,
  BookSearchRequest,
  PageResponse,
  BorrowBookRequest,
  ReturnBookRequest,
  RenewBookRequest,
  BorrowStatusResponse,
  BorrowLimitInfo,
  LibraryQueryRequest,
  LibraryAgentResponse
} from '../model/Book';
import { BorrowRecordResponse } from '../model/BorrowRecord';

// ========== 核心类型定义 ==========
/**
 * HTTP请求选项（扩展鸿蒙原生接口，强类型约束）
 */
interface HttpRequestOptions extends http.HttpRequestOptions {
  method: http.RequestMethod;
  header: Record<string, string>;
  readTimeout?: number;
  connectTimeout?: number;
  extraData?: string | ArrayBuffer;
}

/**
 * SSE流式响应的回调类型
 */
export interface SseCallback {
  onContent: (content: string) => void; // 接收内容片段的回调
  onEnd: () => void; // 流结束的回调
  onError: (error: string) => void; // 错误回调
}

/**
 * 将ArrayBuffer转换为字符串
 * @param buffer 待转换的ArrayBuffer
 * @param encoding 编码方式
 * @returns 转换后的字符串
 */
function bufferToString(buffer: ArrayBuffer, encoding: string = 'utf-8'): string {
  // 鸿蒙环境下使用Uint8Array转换
  const uint8Array = new Uint8Array(buffer);
  let str = '';

  // 根据编码方式处理
  if (encoding.toLowerCase() === 'utf-8' || encoding.toLowerCase() === 'utf8') {
    // UTF-8编码处理
    let i = 0;
    while (i < uint8Array.length) {
      const byte1 = uint8Array[i++];
      if (byte1 < 0x80) {
        // 1字节字符
        str += String.fromCharCode(byte1);
      } else if (byte1 < 0xE0) {
        // 2字节字符
        const byte2 = uint8Array[i++];
        const code = ((byte1 & 0x1F) << 6) | (byte2 & 0x3F);
        str += String.fromCharCode(code);
      } else if (byte1 < 0xF0) {
        // 3字节字符
        const byte2 = uint8Array[i++];
        const byte3 = uint8Array[i++];
        const code = ((byte1 & 0x0F) << 12) | ((byte2 & 0x3F) << 6) | (byte3 & 0x3F);
        str += String.fromCharCode(code);
      } else {
        // 4字节字符
        const byte2 = uint8Array[i++];
        const byte3 = uint8Array[i++];
        const byte4 = uint8Array[i++];
        const code = ((byte1 & 0x07) << 18) | ((byte2 & 0x3F) << 12) | ((byte3 & 0x3F) << 6) | (byte4 & 0x3F);
        str += String.fromCharCode(code);
      }
    }
  } else {
    // 默认处理方式（ASCII兼容）
    for (let j = 0; j < uint8Array.length; j++) {
      str += String.fromCharCode(uint8Array[j]);
    }
  }

  return str;
}

/**
 * 解析SSE消息行
 * @param line 消息行
 * @returns 解析后的数据
 */
interface SseParsedLine {
  field: string;
  value: string;
}

function parseSseLine(line: string): SseParsedLine | null {
  if (!line) return null;

  const colonIndex = line.indexOf(':');
  if (colonIndex === -1) return null;

  const field = line.substring(0, colonIndex);
  const value = line.substring(colonIndex + 1).replace(/^ /, ''); // 移除冒号后的空格

  return { field, value };
}

/**
 * 解析完整的SSE响应
 * @param text 完整的SSE响应文本
 * @returns 解析后的消息数组
 */
function parseSseResponse(text: string): string[] {
  const messages: string[] = [];

  // 按双换行符分割SSE消息
  const sseBlocks = text.split('\n\n');

  for (const block of sseBlocks) {
    if (!block.trim()) continue;

    // 按行处理每个SSE块
    const lines = block.split('\n');
    for (const line of lines) {
      if (line.startsWith('data:')) {
        let content = line.substring(5).trim(); // 移除 "data:" 前缀

        // 检查是否是特殊消息
        if (content === '[END]') {
          messages.push('[END]');
        } else if (content.startsWith('[ERROR]')) {
          messages.push(content);
        } else {
          messages.push(content);
        }
      }
    }
  }

  return messages;
}

/**
 * 发送图书馆智能查询的流式请求（专门处理SSE）
 * @param request 查询参数
 * @param callback 回调函数
 */
export function sendChatQueryStream(
  request: LibraryQueryRequest,
  callback: SseCallback
): void {
  // 创建HTTP请求
  const httpRequest = http.createHttp();

  // 确保使用完整的URL（包含协议、主机和端口）
  const baseUrl = 'http://192.168.50.244:8080';
  // const baseUrl = 'http://10.35.153.236:8080'; // 基础URL，不含/api
  const url = `${baseUrl}/api/library/agent/query/stream`;

  // 发送请求（使用Promise回调处理响应，避免不支持的事件）
  httpRequest.request(
    url,
    {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'text/event-stream' // 明确要求SSE响应
      },
      extraData: JSON.stringify(request),
      readTimeout: 30000 // 超时时间30秒
    }
  ).then((response) => {
    // 处理响应成功
    if (response.responseCode !== http.ResponseCode.OK) {
      callback.onError(`请求失败，状态码：${response.responseCode}`);
      return;
    }

    // 转换响应体为字符串（使用鸿蒙原生方法，避免util）
    let text = '';
    if (typeof response.result === 'string') {
      text = response.result;
    } else {
      text = bufferToString(response.result as ArrayBuffer, 'utf-8');
    }

    console.info(`SSE响应内容: ${JSON.stringify(text)}`);

    // 解析SSE消息
    const messages = parseSseResponse(text);

    for (const msg of messages) {
      if (msg === '[END]') {
        console.info('SSE流结束');
        callback.onEnd();
      } else if (msg.startsWith('[ERROR]')) {
        console.error(`SSE错误: ${msg}`);
        callback.onError(msg.replace('[ERROR]', '').trim());
      } else {
        console.info(`SSE内容: ${msg}`);
        callback.onContent(msg);
      }
    }
  }).catch((error: Error) => {
    // 处理请求异常
    console.error(`SSE请求失败: ${error.message}`);
    callback.onError(`请求失败：${error.message}`);
  }).finally(() => {
    // 销毁请求实例
    httpRequest.destroy();
  });
}

/**
 * 获取热门图书的参数类型
 */
interface PopularBooksParams {
  limit: number;
}

/**
 * 获取借阅记录的参数类型
 */
interface BorrowRecordsParams {
  pageNum: number;
  pageSize: number;
}

/**
 * 业务请求选项（约束接口请求的URL、方法、参数）
 */
interface RequestOptions {
  url: string;
  method: http.RequestMethod;
  data?:
    | BookSearchRequest
    | BorrowBookRequest
    | ReturnBookRequest
    | RenewBookRequest
    | LibraryQueryRequest;
  // 严格的联合类型，避免 Record 导致的歧义
  params?: PopularBooksParams | BorrowRecordsParams;
}

/**
 * API响应通用结构
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  success?: boolean;
}

/**
 * 图书馆服务类（单例模式+静态方法，强类型约束）
 */
export class LibraryService {
  // 基础配置
  private static readonly baseUrl: string = 'http://192.168.50.244:8080/api';   //热点
  // private static readonly baseUrl: string = 'http://10.35.153.236:8080/api';  //网线
  private static tokenValue: string = '';

  // 设置Token（静态方法）
  public static setToken(token: string): void {
    LibraryService.tokenValue = token;
  }

  // ========== 通用请求核心方法 ==========
  private static async request<T>(options: RequestOptions): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      // 1. 构建完整URL（含查询参数）
      const fullUrl = LibraryService.buildFullUrl(options.url, options.params);

      // 2. 构建请求头（强类型）
      const headers: Record<string, string> = LibraryService.buildHeaders();

      // 3. 构建鸿蒙HTTP请求选项（严格匹配接口）
      const requestOptions: HttpRequestOptions = {
        method: options.method,
        header: headers,
        readTimeout: 30000,
        connectTimeout: 30000
      };

      // 4. 添加请求体（仅POST/PUT等方法）
      if (options.data) {
        requestOptions.extraData = JSON.stringify(options.data);
      }

      // 5. 发送请求
      const response: http.HttpResponse = await httpRequest.request(fullUrl, requestOptions);

      // 6. 解析响应
      return LibraryService.parseResponse<T>(response);
    } catch (error) {
      console.error(`API请求失败: ${options.url}`, error);
      throw error instanceof Error ? error : new Error('网络请求异常');
    } finally {
      // 销毁请求实例，避免内存泄漏
      httpRequest.destroy();
    }
  }

  // ========== 工具方法（抽离通用逻辑，减少重复） ==========
  /**
   * 构建完整URL（拼接基础URL和查询参数）
   * 适配ArkTS语法：避免扩展运算符、解构赋值，使用类型安全的属性遍历
   */
  private static buildFullUrl(path: string, params?: PopularBooksParams | BorrowRecordsParams | Record<string, string | number | boolean>): string {
    let url = `${LibraryService.baseUrl}${path}`;
    if (!params) {
      return url;
    }

    const paramArray: string[] = [];

    // 1. 针对不同的参数类型，显式遍历属性（避免索引访问和扩展运算符）
    if ((params as PopularBooksParams).limit !== undefined) {
      // 处理 PopularBooksParams 类型
      const limit = (params as PopularBooksParams).limit;
      if (limit !== undefined && limit !== null) {
        paramArray.push(`limit=${encodeURIComponent(limit.toString())}`);
      }
    } else if ((params as BorrowRecordsParams).pageNum !== undefined) {
      // 处理 BorrowRecordsParams 类型
      const pageNum = (params as BorrowRecordsParams).pageNum;
      const pageSize = (params as BorrowRecordsParams).pageSize;
      if (pageNum !== undefined && pageNum !== null) {
        paramArray.push(`pageNum=${encodeURIComponent(pageNum.toString())}`);
      }
      if (pageSize !== undefined && pageSize !== null) {
        paramArray.push(`pageSize=${encodeURIComponent(pageSize.toString())}`);
      }
    } else {
      // 处理通用 Record 类型（使用 Object.keys + 类型断言避免 any）
      const recordParams = params as Record<string, string | number | boolean>;
      const keys = Object.keys(recordParams);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value = recordParams[key];
        if (value !== undefined && value !== null) {
          paramArray.push(`${key}=${encodeURIComponent(value.toString())}`);
        }
      }
    }

    return paramArray.length > 0 ? `${url}?${paramArray.join('&')}` : url;
  }

  /**
   * 构建请求头（含Token和Content-Type）
   */
  private static buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json; charset=utf-8'
    };

    if (LibraryService.tokenValue) {
      headers['Authorization'] = `Bearer ${LibraryService.tokenValue}`;
    }

    return headers;
  }

  /**
   * 解析响应数据（统一处理响应码和数据格式）
   */
  private static parseResponse<T>(response: http.HttpResponse): T {
    if (response.responseCode !== 200) {
      throw new Error(`HTTP请求失败: 状态码${response.responseCode}`);
    }

    const responseText = response.result?.toString() || '{}';
    const result: ApiResponse<T> = JSON.parse(responseText) as ApiResponse<T>;

    if (result.code === 200 || result.success) {
      return result.data;
    } else {
      throw new Error(result.message || '业务请求失败');
    }
  }

  // ========== 图书相关接口 ==========
  /**
   * 获取所有图书
   */
  public static async getBooks(): Promise<Book[]> {
    const options: RequestOptions = {
      url: '/library/books/all',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<Book[]>(options);
  }

  /**
   * 搜索图书
   */
  static async searchBooks(request: BookSearchRequest): Promise<PageResponse<Book>> {
    const options: RequestOptions = {
      url: '/library/books/search',
      method: http.RequestMethod.POST,
      data: request
    };
    return LibraryService.request<PageResponse<Book>>(options);
  }

  /**
   * 获取图书详情
   */
  public static async getBookDetail(bookId: number): Promise<Book> {
    const options: RequestOptions = {
      url: `/library/books/${bookId}`,
      method: http.RequestMethod.GET
    };
    return LibraryService.request<Book>(options);
  }

  /**
   * 获取热门图书
   */
  public static async getPopularBooks(limit: number = 5): Promise<Book[]> {
    // 显式声明为 PopularBooksParams 类型，避免直接字面量
    const params: PopularBooksParams = { limit: limit };
    const options: RequestOptions = {
      url: '/library/books/popular',
      method: http.RequestMethod.GET,
      params: params
    };
    return LibraryService.request<Book[]>(options);
  }

  /**
   * 按分类获取图书
   */
  public static async getBooksByCategory(category: string): Promise<Book[]> {
    const options: RequestOptions = {
      url: `/library/books/category/${category}`,
      method: http.RequestMethod.GET
    };
    return LibraryService.request<Book[]>(options);
  }

  /**
   * 检查图书是否可借
   */
  public static async checkBookAvailable(bookId: number): Promise<boolean> {
    const options: RequestOptions = {
      url: `/library/books/available/${bookId}`,
      method: http.RequestMethod.GET
    };
    return LibraryService.request<boolean>(options);
  }

  // ========== 借阅相关接口 ==========
  /**
   * 借阅图书
   */
  public static async borrowBook(request: BorrowBookRequest): Promise<BorrowRecordResponse> {
    const options: RequestOptions = {
      url: '/library/borrow/borrow',
      method: http.RequestMethod.POST,
      data: request
    };
    return LibraryService.request<BorrowRecordResponse>(options);
  }

  /**
   * 归还图书
   */
  public static async returnBook(request: ReturnBookRequest): Promise<BorrowRecordResponse> {
    const options: RequestOptions = {
      url: '/library/borrow/return',
      method: http.RequestMethod.POST,
      data: request
    };
    return LibraryService.request<BorrowRecordResponse>(options);
  }

  /**
   * 续借图书
   */
  public static async renewBook(request: RenewBookRequest): Promise<BorrowRecordResponse> {
    const options: RequestOptions = {
      url: '/library/borrow/renew',
      method: http.RequestMethod.POST,
      data: request
    };
    return LibraryService.request<BorrowRecordResponse>(options);
  }

  /**
   * 获取借阅状态
   */
  public static async getBorrowStatus(): Promise<BorrowStatusResponse> {
    const options: RequestOptions = {
      url: '/library/borrow/status',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<BorrowStatusResponse>(options);
  }

  /**
   * 获取借阅记录（分页）
   */
  public static async getBorrowRecords(
    pageNum: number = 1,
    pageSize: number = 10
  ): Promise<PageResponse<BorrowRecordResponse>> {
    // 显式声明为 BorrowRecordsParams 类型，避免直接字面量
    const params: BorrowRecordsParams = {
      pageNum: pageNum,
      pageSize: pageSize
    };
    const options: RequestOptions = {
      url: '/library/borrow/records',
      method: http.RequestMethod.GET,
      params: params
    };
    return LibraryService.request<PageResponse<BorrowRecordResponse>>(options);
  }

  /**
   * 获取借阅记录详情
   */
  public static async getBorrowRecordDetail(recordId: number): Promise<BorrowRecordResponse> {
    const options: RequestOptions = {
      url: `/library/borrow/records/${recordId}`,
      method: http.RequestMethod.GET
    };
    return LibraryService.request<BorrowRecordResponse>(options);
  }

  /**
   * 获取借阅限制信息
   */
  public static async getBorrowLimitInfo(): Promise<BorrowLimitInfo> {
    const options: RequestOptions = {
      url: '/library/borrow/limit',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<BorrowLimitInfo>(options);
  }

  /**
   * 检查用户是否可借
   */
  public static async checkUserCanBorrow(): Promise<boolean> {
    const options: RequestOptions = {
      url: '/library/borrow/check',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<boolean>(options);
  }

  // ========== 智能对话接口 ==========
  /**
   * 发送智能查询（流式）
   */
  public static async sendChatQueryStream(request: LibraryQueryRequest, callback: SseCallback): Promise<void> {
    sendChatQueryStream(request, callback);
  }

  /**
   * 获取图书馆开放时间
   */
  public static async getLibraryHours(): Promise<string> {
    const options: RequestOptions = {
      url: '/library/agent/hours',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<string>(options);
  }

  /**
   * 获取图书馆规则
   */
  public static async getLibraryRules(): Promise<string> {
    const options: RequestOptions = {
      url: '/library/agent/rules',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<string>(options);
  }

  /**
   * 获取聊天历史摘要
   */
  public static async getChatHistorySummary(): Promise<string> {
    const options: RequestOptions = {
      url: '/library/agent/history/summary',
      method: http.RequestMethod.GET
    };
    return LibraryService.request<string>(options);
  }
}
