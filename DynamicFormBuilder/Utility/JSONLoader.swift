//
//  JSONLoader.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import Foundation


class JSONLoader {
    static func load(_ filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
}
