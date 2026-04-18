/**
 * 对话消息数据模型
 */
export interface ChatMessage {
  id: string
  type: 'user' | 'system'
  content: string
  timestamp: string
}