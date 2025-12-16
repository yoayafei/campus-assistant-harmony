// model/BorrowRecord.ets
export interface BorrowRecord {
  id: number;
  userId?: number;
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

export interface BorrowRecordResponse {
  id: number;
  userId?: number;
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
  days?: number;
}

export interface ReturnBookRequest {
  recordId: number;
}

export interface RenewBookRequest {
  recordId: number;
  additionalDays?: number;
}

export interface BorrowStatusResponse {
  userId: number;
  borrowingCount: number;
  overdueCount: number;
  returnedCount: number;
  borrowingRecords: BorrowRecordResponse[];
  recentlyReturned: BorrowRecordResponse[];
}

export interface BorrowLimitInfo {
  currentBorrowCount: number;
  remainingBorrowCount: number;
  reachLimit: boolean;
}

// model/Book.ts
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
  current: number;
  size: number;
  total: number;
  records: T[];
}