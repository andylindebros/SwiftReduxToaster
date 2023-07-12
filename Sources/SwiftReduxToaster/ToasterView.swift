import SwiftUI

@MainActor
public struct ToasterView<Content: View>: View {
    public typealias ToasterDispatcher = @MainActor (ToasterActionProvider) -> Void
    public init(
        state: ToasterState,
        dispatch: @escaping ToasterDispatcher,
        navigationId: UUID,
        @ViewBuilder content: @escaping (ToasterModel, Task<Void, Never>?) -> Content
    ) {
        self.state = state
        self.dispatch = dispatch
        self.navigationId = navigationId
        self.content = content
    }

    @ObservedObject private var state: ToasterState

    private let dispatch: ToasterDispatcher
    private let navigationId: UUID
    private let content: (ToasterModel, Task<Void, Never>?) -> Content

    public var body: some View {
        ZStack {
            if let model = state.models.first(where: { $0.target.isValid(for: navigationId) }), navigationId == state.activeNavigationId {
                ToastWrapper(model: model, dispatch: dispatch, content: content)
            }
        }.animation(.easeOut, value: state.isActive)
    }
}

struct ToastWrapper<Content: View>: View {
    init(model: ToasterModel, dispatch: @escaping ToasterView.ToasterDispatcher, @ViewBuilder content: @escaping (ToasterModel, Task<Void, Never>?) -> Content) {
        self.model = model
        self.dispatch = dispatch
        self.content = content

        if model.timeoutInterval > 0 {
            task = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(model.timeoutInterval * 1_000_000_000))
                } catch {}

                await dispatch(ToasterAction.dismiss(model))
            }
        }
    }

    let model: ToasterModel
    let dispatch: ToasterView.ToasterDispatcher
    let content: (ToasterModel, Task<Void, Never>?) -> Content

    var task: Task<Void, Never>?

    let backgrounds = [Color.red, Color.pink, Color.yellow, Color.green, Color.purple]

    var body: some View {
        content(model, task)
    }
}

public struct DefaultToast: View {
    public init(model: ToasterModel, task: Task<Void, Never>?, onClose: @escaping () -> Void) {
        self.model = model
        self.onClose = onClose
        self.task = task
    }

    private let model: ToasterModel
    private let onClose: () -> Void
    private let task: Task<Void, Never>?

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: iconImage)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(detailColor)
                    .frame(width: 24, height: 24)
                    .padding(.top, 4)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text(model.title)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16))
                        Spacer()
                    }

                    if let message = model.message {
                        HStack(spacing: 0) {
                            Text(message)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 14))
                            Spacer()
                        }
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)

                if model.isDismissable {
                    Spacer()
                    Button(action: {
                        task?.cancel()
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 12, height: 12)
                            .padding(4)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)

            .frame(maxWidth: .infinity)
            .background(backgroundColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundColor(foregroundColor)
    }

    private var foregroundColor: Color {
        .black
    }

    private var iconImage: String {
        switch model.type {
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.bubble.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch model.type {
        case .success:
            return Color(red: 227 / 255, green: 245 / 255, blue: 234 / 255, opacity: 0.8)
        case .info:
            return Color(red: 213 / 255, green: 230 / 255, blue: 251 / 255, opacity: 0.8)
        case .warning:
            return Color(red: 253 / 255, green: 244 / 255, blue: 220 / 255, opacity: 0.8)
        case .error:
            return Color(red: 251 / 255, green: 221 / 255, blue: 221 / 255, opacity: 0.8)
        }
    }

    private var detailColor: Color {
        switch model.type {
        case .success:
            return Color(red: 111 / 255, green: 207 / 255, blue: 151 / 255, opacity: 1)
        case .info:
            return Color(red: 47 / 255, green: 128 / 255, blue: 237 / 255, opacity: 1)
        case .warning:
            return Color(red: 241 / 255, green: 202 / 255, blue: 75 / 255, opacity: 1)
        case .error:
            return Color(red: 235 / 255, green: 87 / 255, blue: 87 / 255, opacity: 1)
        }
    }
}
