import SwiftUI
import UIKit

enum KeyboardDismiss {
    static func hide() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

private final class KeyboardDismissCoordinator: NSObject, UIGestureRecognizerDelegate {
    static let shared = KeyboardDismissCoordinator()
    private let gestureName = "AppKeyboardDismissTap"

    func installIfNeeded(on window: UIWindow) {
        if window.gestureRecognizers?.contains(where: { $0.name == gestureName }) == true {
            return
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.name = gestureName
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        KeyboardDismiss.hide()
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        var view = touch.view
        while let current = view {
            if current is UIControl { return false }
            let typeName = String(describing: type(of: current))
            if typeName.contains("TextField") || typeName.contains("TextView") {
                return false
            }
            view = current.superview
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

private struct WindowKeyboardDismissInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let window = view.window {
                KeyboardDismissCoordinator.shared.installIfNeeded(on: window)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let window = uiView.window {
                KeyboardDismissCoordinator.shared.installIfNeeded(on: window)
            }
        }
    }
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .background(WindowKeyboardDismissInstaller())
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }

    func keyboardDoneToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    KeyboardDismiss.hide()
                }
                .foregroundStyle(Color("AppPrimary"))
            }
        }
    }
}
