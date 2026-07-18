import SwiftUI

// MARK: - Flappy Bird 游戏视图
// 纯 UI 层：渲染小鸟、管道、地面、分数面板
// 所有逻辑在 ViewModel 中

struct FlappyGameView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FlappyGameViewModel()

    @State private var containerSize: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // 天空背景
                LinearGradient(
                    colors: [Color(red: 0.33, green: 0.78, blue: 0.98),
                             Color(red: 0.70, green: 0.90, blue: 0.98)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 管道
                ForEach(viewModel.pipes) { pipe in
                    pipeView(pipe)
                }

                // 小鸟
                birdView
                    .position(x: width * 0.25, y: viewModel.birdY)
                    .rotationEffect(.degrees(viewModel.birdRotation))

                // 地面
                VStack(spacing: 0) {
                    Spacer()
                    groundView(width: width)
                        .frame(height: 80)
                }
                .ignoresSafeArea(edges: .bottom)

                // 分数
                scoreDisplay

                // 状态覆盖层（等待 / 结束）
                if viewModel.gameState != .playing {
                    overlayView
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.tap()
            }
            .onAppear {
                let newSize = CGSize(width: width, height: height)
                if containerSize != newSize {
                    containerSize = newSize
                    viewModel.configure(containerWidth: width, containerHeight: height)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.stopTimers()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                }
            }
        }
        .onDisappear {
            viewModel.stopTimers()
        }
    }

    // MARK: - 小鸟

    private var birdView: some View {
        ZStack {
            // 身体
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)

            // 眼睛
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 14)
                .offset(x: 6, y: -4)
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 6)
                .offset(x: 7, y: -4)

            // 嘴巴
            Triangle()
                .fill(Color.orange)
                .frame(width: 12, height: 8)
                .offset(x: 20, y: 2)
        }
    }

    // MARK: - 管道

    private func pipeView(_ pipe: PipeModel) -> some View {
        let halfGap = pipe.gapHeight / 2
        let topPipeHeight = pipe.gapY - halfGap
        let bottomPipeTop = pipe.gapY + halfGap

        return ZStack {
            // 上管道
            pipeSegment(height: topPipeHeight, isTop: true)
                .position(x: pipe.x, y: topPipeHeight / 2)

            // 下管道
            pipeSegment(height: 600, isTop: false) // 足够高以覆盖下方
                .position(x: pipe.x, y: bottomPipeTop + 300)
        }
    }

    private func pipeSegment(height: CGFloat, isTop: Bool) -> some View {
        let pipeWidth: CGFloat = 60

        return VStack(spacing: 0) {
            if !isTop {
                // 下管道：先画管道口（加宽部分）
                pipeMouthView()
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.green, Color(red: 0.2, green: 0.7, blue: 0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: pipeWidth, height: max(0, height))
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.1, green: 0.5, blue: 0.1), lineWidth: 1.5)
                )

            if isTop {
                // 上管道：底部画管道口
                pipeMouthView()
            }
        }
    }

    private func pipeMouthView() -> some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 70, height: 14)
            .overlay(
                Rectangle()
                    .stroke(Color(red: 0.1, green: 0.5, blue: 0.1), lineWidth: 1.5)
            )
    }

    // MARK: - 地面

    private func groundView(width: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.85, green: 0.73, blue: 0.45))

            Rectangle()
                .fill(Color(red: 0.5, green: 0.78, blue: 0.25))
                .frame(height: 18)

            // 地面纹理条纹
            HStack(spacing: 40) {
                ForEach(0..<Int(width / 40) + 2, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(red: 0.73, green: 0.60, blue: 0.30))
                        .frame(width: 20, height: 80)
                }
            }
        }
        .clipped()
    }

    // MARK: - 分数

    private var scoreDisplay: some View {
        VStack {
            Text("\(viewModel.score)")
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .padding(.top, 60)

            Spacer()
        }
    }

    // MARK: - 覆盖层

    private var overlayView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if viewModel.gameState == .waiting {
                    Text("Flappy Bird")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)

                    Text("Tap to Start")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                } else if viewModel.gameState == .gameOver {
                    Text("Game Over")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)

                    VStack(spacing: 8) {
                        Text("Score: \(viewModel.score)")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Best: \(viewModel.highScore)")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)

                    Text("Tap to Retry")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                        .padding(.top, 8)
                }
            }
            .padding(40)
        }
    }
}

// MARK: - 三角形 Shape（小鸟嘴巴）

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
