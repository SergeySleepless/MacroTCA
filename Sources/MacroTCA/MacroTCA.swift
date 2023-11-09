// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Макрос генерирует структуру `Path` для навигации в TCA.
/// Должен находиться в корневом редьюсере.
///
///
/// Пример использования:
///
///     #NavigationPath([ReducerA.self, ReducerB.self])
///
/// Генерирует структуру:
///
///     struct Path: Reducer {
///         enum State: Equatable {
///            case reducerA(ReducerA.State)
///            case reducerB(ReducerB.State)
///         }
///         enum Action {
///             case reducerA(ReducerA.Action)
///             case reducerB(ReducerB.Action)
///         }
///         var body: some ReducerOf<Self> {
///             Scope(state: /State.reducerA, action: /Action.reducerA) {
///                 ReducerA()
///             }
///             Scope(state: /State.reducerB, action: /Action.reducerB) {
///                 ReducerB()
///             }
///         }
///     }
///
/// - Parameters:
///     - reducers: Массив Reducer\`ов для View, которые будут пушиться с текущего View
///
@freestanding(declaration, names: arbitrary)
public macro NavigationPath<Reducer>(_ reducers: [Reducer]) = #externalMacro(
    module: "MacroTCAMacros",
    type: "NavigationPathMacro"
)

/// Макрос для генерации `View.Destination`
///
///
/// Макрос генерирует функцию:
///
///     func destination(state: EnterPhone.Path.State)
///
///
/// Её необходимо передать в поле `NavigationStackStore.destination`,
/// чтобы получилось:
///
///     NavigationStackStore(
///         store,
///         root,
///         destination: destination(state:)
///     )
///
/// Должена находиться в корневом вью.
/// 
/// Пример использования:
///
///     #NavigationPathView(
///         path: RootReducer,
///         [ReducerA.self, ReducerB.self]
///     )
///
/// Генерирует функцию:
///
///     private func destination(state: RootReducer.Path.State) -> some View {
///         switch state {
///         case .reducerA:
///             return CaseLet(
///             /RootReducer.Path.State.reducerA,
///             action: RootReducer.Path.Action.reducerA,
///             then: ReducerAView.init(store:))
///         case .reducerB:
///             return CaseLet(
///             /RootReducer.Path.State.reducerB,
///             action: RootReducer.Path.Action.reducerB,
///             then: ReducerBView.init(store:))
///         }
///     }
///
/// - Parameters:
///     - root: Reducer текущего View.
///     - reducers: Массив Reducer\`ов для View, которые будут пушиться с текущего View
///
@freestanding(declaration, names: arbitrary)
public macro NavigationPathView<Root, Reducer>(
    root: Root,
    _ reducers: [Reducer]
) = #externalMacro(
    module: "MacroTCAMacros",
    type: "NavigationPathViewMacro"
)
