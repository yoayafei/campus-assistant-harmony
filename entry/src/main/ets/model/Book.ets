// model/Book.ets
export interface Book {
  id: number; // 后端Long类型，鸿蒙number可兼容
  title: string;
  author: string;
  publisher: string;
  publishDate: string; // 匹配后端的publishDate（LocalDate序列化后为字符串，如"2020-01-01"）
  category: string;
  totalCopies: number;
  availableCopies: number;
  description?: string;
  coverUrl?: string;
  borrowRate?: number; // 后端计算属性
  canBorrow?: boolean; // 后端计算属性
  // 新增后端存在的字段（可选，若需要）
  isbn?: string;
  location?: string;
}


export interface BookSearchRequest {
  keyword: string;
  category?: string;
  author?: string;
  pageNum: number;
  pageSize: number;
}

export interface PageResponse<T> {
  current: number; // 对应后端的current（当前页）
  size: number;    // 对应后端的size（每页大小）
  total: number;   // 对应后端的total（总记录数）
  records: T[];    // 对应后端的records（数据列表）
  // 可选：添加后端返回的其他分页字段
  pages?: number;  // 总页数
}

// model/Borrow.ts
export interface BorrowRecord {
  id: number;
  bookId: number;
  bookTitle: string;
  borrowDate: string;
  dueDate: string;
  returnDate?: string;
  status: number; // 0:借阅中, 1:已归还, 2:逾期
  renewCount: number;
  statusDesc?: string;
  isOverdue?: boolean;
  remainingDays?: number;
  book?: Book;
}

export interface BorrowBookRequest {
  bookId: number;
  days?: number; // 借阅天数，默认30
}

export interface ReturnBookRequest {
  recordId: number;
}

export interface RenewBookRequest {
  recordId: number;
  additionalDays?: number; // 续借天数，默认15
}

export interface BorrowStatusResponse {
  userId: number;
  borrowingCount: number;
  overdueCount: number;
  returnedCount: number;
  borrowingRecords: BorrowRecord[];
  recentlyReturned: BorrowRecord[];
}

export interface BorrowLimitInfo {
  currentBorrowCount: number;
  remainingBorrowCount: number;
  reachLimit: boolean;
}

// model/LibraryChat.ts
export interface BookData {
  id: number;
  title: string;
  author: string;
  category: string;
  availableCopies: number;
  totalCopies: number;
  coverUrl?: string;
  borrowRate?: number;
  canBorrow?: boolean;
}

export interface ChatMessageData {
  books?: Book[];
  recommendations?: Book[];
  searchResults?: Book[];
  borrowStatus?: BorrowStatusResponse;
  hours?: string;
  rules?: string;
  popularBooks?: Book[];
  borrowLimit?: BorrowLimitInfo;
}

export interface QuickAction {
  text: string;
  action: string;
}


export interface ChatMessage {
  id: number;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
  type?: string;
  suggestion?: string;
  data?: ChatMessageData;
  quickActions?: QuickAction[];
  needsFurtherHelp?: boolean;
  displayBooks?: Book[];  // 添加这个字段用于显示
}

export interface LibraryQueryRequest {
  query: string;
  sessionId?: number | string;
}

export interface LibraryAgentResponse {
  userId: number;
  sessionId?: number;
  answer: string;
  suggestion: string;
  type: string;
  data: ChatMessageData;
  quickActions: QuickAction[];
  needsFurtherHelp: boolean;
}

export interface LibraryChat {
  id: number;
  sessionId: number;
  userId: number;
  userQuery: string;
  agentIntent: string;
  agentResponse: string;
  extractedData?: string;
  createTime: string;
  intentDesc?: string;
}