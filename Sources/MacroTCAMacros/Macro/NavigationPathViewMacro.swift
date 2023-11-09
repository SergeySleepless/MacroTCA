//
//  NavigationPathViewMacro.swift
//
//
//  Created by Сергей Гаврилов on 09.11.2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NavigationPathViewMacro: DeclarationMacro {
    
    enum NavigationPathViewMacroError: Error {
        case invalidMacroArgument
    }
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let root = node.argumentList.first?.expression
            .description
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ".self", with: ""),
              let lastExpression = node.argumentList.last?.expression,
              let array = lastExpression.as(ArrayExprSyntax.self)?.elements.map({ 
                  $0.expression.description
                      .replacingOccurrences(of: ".self", with: "")
                  .trimmingCharacters(in: .whitespacesAndNewlines) }),
              array.count > 0
        else {
            throw NavigationPathViewMacroError.invalidMacroArgument
        }
        
        let function = FunctionDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: "private")
            },
            funcKeyword: "func",
            name: "destination",
            signature: makeSignature(path: TokenSyntax(stringLiteral: root)),
            body:
                CodeBlockSyntax(
                    leftBrace: "{",
                    rightBrace: "\n}"
                ) {
                    ExprSyntax(stringLiteral: "switch state {\n")
                    for item in array {
                        makeSwitchCase(root: root, item: item)
                    }
                    ExprSyntax(stringLiteral: "\n\t}")
                }
        )
        
        return [DeclSyntax(function)]
    }
    
    private static func makeSignature(path: TokenSyntax) -> FunctionSignatureSyntax {
        FunctionSignatureSyntax(
            parameterClause: .init(parametersBuilder: {
                .init(stringLiteral: "state: \(path).Path.State")
            }),
            returnClause: ReturnClauseSyntax(
                arrow: "->",
                type: TypeSyntax(stringLiteral: "some View")
            )
        )
    }
    
    private static func makeSwitchCase(root: String, item: String) -> ExprSyntax {
        ExprSyntax(stringLiteral:
            """
            
                case .\(item.lowercasingFirstLetter()):
                    \(makeCaseBlock(root: root, item: item))
            """
        )
    }
    
    private static func makeCaseBlock(root: String, item: String) -> CodeBlockItemListSyntax {
        CodeBlockItemListSyntax(stringLiteral:
            """
            return CaseLet(
                    \(makeStateSegment(root: root, item: item)),
                    \(makeActionSegment(root: root, item: item)),
                    \(makeViewSegment(item: item)))
            \n
            """
        )
    }
    
    private static func makeStateSegment(root: String, item: String) -> LabeledExprSyntax {
        LabeledExprSyntax(
            expression: ExprSyntax(
                stringLiteral: "/\(root).Path.State.\(item.lowercasingFirstLetter())")
        )
    }
    
    private static func makeActionSegment(root: String, item: String) -> LabeledExprSyntax {
        LabeledExprSyntax(
            expression: ExprSyntax(
                stringLiteral:
                    "action: \(root).Path.Action.\(item.lowercasingFirstLetter())"
            )
        )
    }
    
    private static func makeViewSegment(item: String) -> LabeledExprSyntax {
        LabeledExprSyntax(
            expression: ExprSyntax(
                stringLiteral:
                    "then: \(item)View.init(store:)"
            )
        )
    }
    
}
