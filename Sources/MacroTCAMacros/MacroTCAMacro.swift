import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacroTCAPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NavigationPathMacro.self,
        NavigationPathViewMacro.self
    ]
}
