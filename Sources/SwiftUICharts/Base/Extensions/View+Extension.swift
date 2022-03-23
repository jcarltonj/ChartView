import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}

struct SizeModifer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            )
    }
}

struct PositionPreferenceKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue: Value = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}

struct PositionModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: PositionPreferenceKey.self, value: geometry.frame(in: coordinateSpace))
                }
            )
    }
}

extension View {
    /// Attach chart style to a View
    /// - Parameter style: chart style
    /// - Returns: `View` with chart style attached
    public func chartStyle(_ style: ChartStyle) -> some View {
        self.environmentObject(style)
    }
    
    func onSizeChanged(_ completion: @escaping (CGSize) -> Void) -> some View {
        self
            .modifier(SizeModifer())
            .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                completion(value)
            })
    }
    
    func onViewLayout(coordinateSpace: CoordinateSpace, _ completion: @escaping (CGRect) -> Void) -> some View {
        self
            .modifier(PositionModifier(coordinateSpace: coordinateSpace))
            .onPreferenceChange(PositionPreferenceKey.self) { value in
                completion(value)
            }
    }
}
