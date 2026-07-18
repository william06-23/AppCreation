import SwiftUI

// MARK: - 页面级视图
// 只负责 UI 布局和样式，数据从 ViewModel 获取，不包含业务逻辑

struct HomeView: View {

    @EnvironmentObject var env: AppEnvironment
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        FlappyGameView()
                    } label: {
                        HStack {
                            Image(systemName: "bird.fill")
                                .foregroundStyle(.yellow)
                                .font(.title3)
                            Text("Flappy Bird")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "play.fill")
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Users") {
                    ForEach(viewModel.users) { user in
                        UserRow(user: user)
                    }
                }
            }
            .navigationTitle("My App")
            .task {
                await viewModel.loadUsers()
            }
            .refreshable {
                await viewModel.loadUsers()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
