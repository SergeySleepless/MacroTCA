//
//  String+Extension.swift
//  
//
//  Created by Сергей Гаврилов on 09.11.2023.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
    
    func lowercasingFirstLetter() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
