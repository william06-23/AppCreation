import SwiftUI
import UIKit

// MARK: - SwiftUI View 扩展
// 收窄常用修饰符组合

extension View {

    /// 圆角 + 边框组合
    func roundedBorder(_ color: Color = .gray.opacity(0.3), radius: CGFloat = 8) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: 1)
            )
    }

    /// 隐藏键盘（点击空白区域）
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
