import SwiftUI
import Combine

// MARK: - ViewModel
// 职责：持有 Models、调用 Services、暴露 @Published 给 View
// View 不直接调 API，只通过 ViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient(logger: Logger(subsystem: "com.myapp", category: "viewmodel"))

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            users = try await apiClient.request(.getUsers)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
