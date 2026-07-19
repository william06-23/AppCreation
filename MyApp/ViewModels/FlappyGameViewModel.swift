import SwiftUI
import Combine

// MARK: - Flappy Bird ViewModel
// 职责：管理游戏循环、物理计算、碰撞检测、计分
// View 只负责渲染，不包含游戏逻辑

@MainActor
final class FlappyGameViewModel: ObservableObject {

    @Published var birdY: CGFloat = 0
    @Published var birdRotation: Double = 0
    @Published var pipes: [PipeModel] = []
    @Published var score: Int = 0
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "flappy_high_score")
    @Published var gameState: GameState = .waiting

    // MARK: 游戏参数常量
    private let gravity: CGFloat = 900
    private let flapVelocity: CGFloat = -380
    private let pipeSpeed: CGFloat = 200
    private let pipeWidth: CGFloat = 60
    private let pipeGapHeight: CGFloat = 160
    private let birdSize: CGFloat = 40
    private let groundHeight: CGFloat = 80
    private let pipeSpawnInterval: TimeInterval = 1.8

    // MARK: 内部状态
    private var birdVelocity: CGFloat = 0
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private var lastUpdate: TimeInterval = 0

    // 运行时从 View 传入的容器尺寸
    private(set) var containerWidth: CGFloat = 0
    private(set) var containerHeight: CGFloat = 0

    // MARK: - 公共接口

    /// 初始化游戏区域，在 View 的 .onAppear 或 GeometryReader 中调用一次
    func configure(containerWidth: CGFloat, containerHeight: CGFloat) {
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        resetGame()
    }

    /// 点击屏幕：开始 / 拍翅膀
    func tap() {
        switch gameState {
        case .waiting:
            startGame()
        case .playing:
            flap()
        case .gameOver:
            resetGame()
        }
    }

    /// 停止所有计时器（页面消失时调用）
    func stopTimers() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }

    // MARK: - 游戏流程

    private func resetGame() {
        stopTimers()
        birdY = containerHeight * 0.4
        birdVelocity = 0
        birdRotation = 0
        pipes = []
        score = 0
        gameState = .waiting
    }

    private func startGame() {
        birdY = containerHeight * 0.4
        birdVelocity = 0
        birdRotation = 0
        pipes = []
        score = 0
        gameState = .playing

        lastUpdate = CACurrentMediaTime()
        gameTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 60.0,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }

        spawnTimer = Timer.scheduledTimer(
            withTimeInterval: pipeSpawnInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in self?.spawnPipe() }
        }

        // 立即生成第一个管道
        spawnPipe()
    }

    private func flap() {
        birdVelocity = flapVelocity
    }

    // MARK: - 每帧更新

    private func update() {
        guard gameState == .playing else { return }

        let now = CACurrentMediaTime()
        let dt = CGFloat(min(now - lastUpdate, 0.05)) // 防止大 delta
        lastUpdate = now

        // 物理：重力 + 速度 → 位移
        birdVelocity += gravity * dt
        birdY += birdVelocity * dt

        // 旋转：根据速度映射角度（向上 -30°，向下 60°）
        let maxUpAngle: Double = -25
        let maxDownAngle: Double = 60
        let velocityRange: CGFloat = 600
        let clampedVelocity = max(-velocityRange, min(velocityRange, birdVelocity))
        birdRotation = Double(clampedVelocity / velocityRange) * maxDownAngle
        if birdRotation < maxUpAngle { birdRotation = maxUpAngle }

        // 管道左移
        for i in pipes.indices {
            pipes[i].x -= pipeSpeed * dt
        }

        // 移除离开屏幕的管道
        pipes.removeAll { $0.x < -pipeWidth }

        // 计分：管道经过小鸟
        let birdX = containerWidth * 0.25
        for i in pipes.indices where !pipes[i].hasScored && pipes[i].x + pipeWidth / 2 < birdX {
            pipes[i].hasScored = true
            score += 1
        }

        // 碰撞检测
        if checkCollision(birdX: birdX) {
            endGame()
        }

        // 触地 / 触顶
        let playableTop: CGFloat = 0
        let playableBottom = containerHeight - groundHeight
        if birdY - birdSize / 2 <= playableTop || birdY + birdSize / 2 >= playableBottom {
            endGame()
        }
    }

    private func spawnPipe() {
        guard gameState == .playing else { return }

        let minY = containerHeight * 0.2
        let maxY = (containerHeight - groundHeight) * 0.8
        let gapY = CGFloat.random(in: minY...maxY)

        let pipe = PipeModel(
            x: containerWidth + pipeWidth,
            gapY: gapY,
            gapHeight: pipeGapHeight
        )
        pipes.append(pipe)
    }

    // MARK: - 碰撞检测

    private func checkCollision(birdX: CGFloat) -> Bool {
        let halfBird = birdSize / 2
        let halfPipeW = pipeWidth / 2
        let halfGap = pipeGapHeight / 2

        for pipe in pipes {
            // AABB 碰撞检测
            let left = pipe.x - halfPipeW
            let right = pipe.x + halfPipeW
            let topGap = pipe.gapY - halfGap
            let bottomGap = pipe.gapY + halfGap

            // 水平重叠
            if birdX + halfBird > left && birdX - halfBird < right {
                // 垂直重叠：碰到上管道或下管道
                if birdY - halfBird < topGap || birdY + halfBird > bottomGap {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - 结束

    private func endGame() {
        gameState = .gameOver
        stopTimers()

        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "flappy_high_score")
        }
    }
}
