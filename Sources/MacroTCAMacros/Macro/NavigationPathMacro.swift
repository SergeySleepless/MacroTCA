//
//  PathMacro.swift
//
//
//  Created by Сергей Гаврилов on 07.11.2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NavigationPathMacro: DeclarationMacro {
    
    enum NavigationPathMacroError: Error {
        case invalidMacroArgument
    }
    
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let firstExpression = node.argumentList.first?.expression,
              let array = firstExpression.as(ArrayExprSyntax.self)?.elements.map ({
                  $0.expression
                      .description
                      .trimmingCharacters(in: .whitespacesAndNewlines)
              }),
              array.count > 0
        else {
            throw NavigationPathMacroError.invalidMacroArgument
        }
        let formattedArray = array.map { $0.replacingOccurrences(of: ".self", with: "")}
        let structDeclSyntax = StructDeclSyntax(
            name: "Path",
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Reducer")))
            }
        ) {
            EnumDeclSyntax(
                name: "State",
                inheritanceClause: InheritanceClauseSyntax {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Equatable"))
                }
            ) {
                for reducer in formattedArray {
                    EnumCaseDeclSyntax {
                        EnumCaseElementListSyntax.ArrayLiteralElement(
                            name: .init(stringLiteral: reducer.lowercasingFirstLetter()),
                            parameterClause: EnumCaseParameterClauseSyntax.init(parameters: EnumCaseParameterListSyntax.init(arrayLiteral: .init(stringLiteral: reducer + ".State"))))
                    }
                }
            }
            EnumDeclSyntax(name: "Action") {
                for reducer in formattedArray {
                    EnumCaseDeclSyntax {
                        EnumCaseElementListSyntax.ArrayLiteralElement(
                            name: .init(stringLiteral: reducer.lowercasingFirstLetter()),
                            parameterClause: EnumCaseParameterClauseSyntax.init(parameters: EnumCaseParameterListSyntax.init(arrayLiteral: .init(stringLiteral: reducer + ".Action"))))
                    }
                }
            }
            VariableDeclSyntax(bindingSpecifier: .init(stringLiteral: "var"), bindingsBuilder: {
                PatternBindingSyntax(
                    leadingTrivia: .space,
                    pattern: IdentifierPatternSyntax(identifier: .init(stringLiteral: "body")),
                    typeAnnotation: .init(
                        colon: .colonToken(),
                        type: IdentifierTypeSyntax(name: "some ReducerOf<Self>")),
                    accessorBlock: AccessorBlockSyntax(
                        leftBrace: .leftBraceToken(trailingTrivia: .newline),
                        accessors: .getter(CodeBlockItemListSyntax.init(stringLiteral: makeAccessors(reducers: formattedArray))),
                        rightBrace: .rightBraceToken(leadingTrivia: .newline))
                )
            })
        }
        
        return [
            DeclSyntax(structDeclSyntax)
        ]
    }
    
    private static func makeAccessors(reducers: [String]) -> String {
        reducers.map {
            """
\tScope(state: /State.\($0.lowercasingFirstLetter()), action: /Action.\($0.lowercasingFirstLetter())) {
\t\t\($0.capitalizingFirstLetter())()
\t}
"""
        }
        .joined(separator: "\n")
    }
    
}
