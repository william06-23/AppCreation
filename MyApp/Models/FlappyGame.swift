import Foundation

// MARK: - Flappy Bird 游戏模型
// 纯数据结构，不包含游戏逻辑

enum GameState {
    case waiting   // 等待开始
    case playing   // 游戏中
    case gameOver  // 游戏结束
}

struct PipeModel: Identifiable {
    let id = UUID()
    var x: CGFloat          // 管道中心 x 坐标
    let gapY: CGFloat       // 管道间隙中心 y 坐标
    let gapHeight: CGFloat  // 上下管道之间的间隙高度
    var hasScored = false   // 是否已经计分
}


