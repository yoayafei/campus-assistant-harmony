// entry/src/main/ets/model/ChatModels.ets

// 单个会话的数据模型
export interface ChatSession {
  id: string;                     // 会话唯一ID
  title: string;                  // 会话标题（可自动生成）
  preview: string;                // 最后一条消息预览
  timestamp: number;              // 最后活动时间戳
  unreadCount: number;            // 未读消息数
  isPinned: boolean;              // 是否置顶
  avatar: string;                 // 头像资源路径或图标
}

// 单条消息的数据模型
export interface ChatMessage {
  id: string;
  sessionId: string;              // 关联的会话ID
  content: string;
  isFromUser: boolean;            // true为用户消息，false为AI回复
  timestamp: number;
}

// 模拟数据源
export class ChatDataService {
  // 模拟的会话列表数据
  static getSessions(): ChatSession[] {
    return [
      {
        id: '1',
        title: '数学问题咨询',
        preview: '上次我们讲到微积分的基本定理...',
        timestamp: Date.now() - 3600000, // 1小时前
        unreadCount: 0,
        isPinned: true,
        avatar: '\ue610'
      },
      {
        id: '2',
        title: '论文写作助手',
        preview: '关于文献综述的结构，我建议...',
        timestamp: Date.now() - 86400000, // 1天前
        unreadCount: 2,
        isPinned: true,
        avatar: '\ue611'
      },
      {
        id: '3',
        title: '课程安排查询',
        preview: '下周的课程时间已经排好了',
        timestamp: Date.now() - 172800000, // 2天前
        unreadCount: 0,
        isPinned: false,
        avatar: '\ue60e'
      },
      {
        id: '4',
        title: '校园导航帮助',
        preview: '去图书馆的最快路径是...',
        timestamp: Date.now() - 259200000, // 3天前
        unreadCount: 0,
        isPinned: false,
        avatar: '\ue612'
      }
    ];
  }

  // 根据会话ID获取消息列表
  static getMessagesBySessionId(sessionId: string): ChatMessage[] {
    const messages: ChatMessage[] = [];

    // 根据不同的sessionId返回不同的模拟消息
    if (sessionId === '1') {
      messages.push(
        { id: '1-1', sessionId: '1', content: '你好，我想问一下关于微积分的问题。', isFromUser: true, timestamp: Date.now() - 7200000 },
        { id: '1-2', sessionId: '1', content: '当然可以，请问您具体想了解微积分的哪个部分？', isFromUser: false, timestamp: Date.now() - 7100000 },
        { id: '1-3', sessionId: '1', content: '我想了解微分中值定理的应用。', isFromUser: true, timestamp: Date.now() - 7000000 },
        { id: '1-4', sessionId: '1', content: '微分中值定理是微积分中的重要定理，它描述了函数在某区间内的平均变化率与瞬时变化率的关系...', isFromUser: false, timestamp: Date.now() - 6900000 }
      );
    } else if (sessionId === '2') {
      messages.push(
        { id: '2-1', sessionId: '2', content: '你能帮我看看论文结构吗？', isFromUser: true, timestamp: Date.now() - 87000000 },
        { id: '2-2', sessionId: '2', content: '可以的，请把你的论文大纲发给我看看。', isFromUser: false, timestamp: Date.now() - 86900000 },
        { id: '2-3', sessionId: '2', content: '我还没开始写，不知道怎么下手。', isFromUser: true, timestamp: Date.now() - 86800000 },
        { id: '2-4', sessionId: '2', content: '那我建议你先确定研究问题，然后查找相关文献...', isFromUser: false, timestamp: Date.now() - 86700000 }
      );
    }

    // 按时间排序
    return messages.sort((a, b) => a.timestamp - b.timestamp);
  }

  // 创建新会话
  static createNewSession(): ChatSession {
    const newId = `session_${Date.now()}`;
    return {
      id: newId,
      title: '新会话',
      preview: '开始新的对话吧...',
      timestamp: Date.now(),
      unreadCount: 0,
      isPinned: false,
      avatar: '\ue608'
    };
  }
}