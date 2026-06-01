//
//  FormResponse.swift
//  DynamicFormBuilder
//  Created by Veeru Masal on 27/05/26.
//

import Foundation

// MARK: - Theme Model
struct ThemeModel: Codable {
    let backgroundColor: String
    let textColor: String
    let borderColor: String
    let errorColor: String
    
    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
}

// MARK: - Form Model (Root)
struct FormModel: Codable {
    let theme: ThemeModel
    let formTitle: String
    let fields: [FormField]
    
    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
}

indirect enum FormField: Codable {
    case text(TextFieldModel)
    case dropdown(DropdownFieldModel)
    case toggle(ToggleFieldModel)
    case checkbox(CheckboxFieldModel)
    case colorPicker(CheckboxFieldModel)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "TEXT":
            let textField = try TextFieldModel(from: decoder)
            self = .text(textField)
        case "DROPDOWN":
            let dropdown = try DropdownFieldModel(from: decoder)
            self = .dropdown(dropdown)
        case "TOGGLE":
            let toggle = try ToggleFieldModel(from: decoder)
            self = .toggle(toggle)
        case "CHECKBOX":
            let checkbox = try CheckboxFieldModel(from: decoder)
            self = .checkbox(checkbox)
            
        case "COLOR_PICKER":
            self = .unknown // or create new model
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let model):
            try model.encode(to: encoder)
        case .dropdown(let model):
            try model.encode(to: encoder)
        case .toggle(let model):
            try model.encode(to: encoder)
        case .checkbox(let model):
            try model.encode(to: encoder)
        case .unknown:
            break
        case .colorPicker(_):
            break
        }
    }
}

// MARK: - TEXT Field Model

struct TextFieldModel: Codable, FieldProtocol {
    let id: String
    let order: Int
    let type: String = "TEXT"
    let subtype: String // PLAIN, MULTILINE, NUMBER, URI, SECURE
    let label: String
    let placeholder: String?
    let supportingText: String?
    let maxLength: Int?
    let required: Bool
    let errorMessage: String?
    let regex: String? // Optional regex validation
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case subtype
        case label
        case placeholder
        case supportingText = "supporting_text"
        case maxLength = "max_length"
        case required
        case errorMessage = "error_message"
        case regex
    }
    
    var fieldId: String { id }
    var fieldOrder: Int { order }
    var fieldLabel: String { label }
    var isRequired: Bool { required }
}

// MARK: - DROPDOWN Field Model

struct DropdownOption: Codable {
    let id: String
    let label: String
}

struct DropdownFieldModel: Codable, FieldProtocol {
    let id: String
    let order: Int
    let type: String = "DROPDOWN"
    let label: String
    let allowMultiple: Bool
    let defaultValues: [String]?
    let required: Bool
    let options: [DropdownOption]
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case required
        case options
        case errorMessage = "error_message"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.order = try container.decode(Int.self, forKey: .order)
        self.label = try container.decode(String.self, forKey: .label)
        self.allowMultiple = try container
            .decodeIfPresent(Bool.self, forKey: .allowMultiple) ?? false
        self.defaultValues = try container
            .decodeIfPresent([String].self, forKey: .defaultValues)
        self.required = try container.decode(Bool.self, forKey: .required)
        self.options = try container
            .decode([DropdownOption].self, forKey: .options)
        self.errorMessage = try container
            .decodeIfPresent(String.self, forKey: .errorMessage)
    }
    
    var fieldId: String { id }
    var fieldOrder: Int { order }
    var fieldLabel: String { label }
    var isRequired: Bool { required }
}

// MARK: - TOGGLE Field Model

struct ToggleFieldModel: Codable, FieldProtocol {
    let id: String
    let order: Int
    let type: String = "TOGGLE"
    let label: String
    let required: Bool
    let defaultValue: Bool?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case required
        case defaultValue = "default_value"
        case errorMessage = "error_message"
    }
    
    var fieldId: String { id }
    var fieldOrder: Int { order }
    var fieldLabel: String { label }
    var isRequired: Bool { required }
}

// MARK: - CHECKBOX Field Model

struct CheckboxFieldModel: Codable, FieldProtocol {
    let id: String
    let order: Int
    let type: String = "CHECKBOX"
    let label: String
    let required: Bool
    let defaultValue: Bool?
    let errorMessage: String?
    let metadata: [String: String]?
    let clickableTextColor: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case required
        case defaultValue = "default_value"
        case errorMessage = "error_message"
        case metadata
        case clickableTextColor = "clickable_text_color"
    }
    
    var fieldId: String { id }
    var fieldOrder: Int { order }
    var fieldLabel: String { label }
    var isRequired: Bool { required }
}

// MARK: - Common Field Protocol

protocol FieldProtocol {
    var fieldId: String { get }
    var fieldOrder: Int { get }
    var fieldLabel: String { get }
    var isRequired: Bool { get }
}

// MARK: - Form State Value (Unified Type for All Field Values)

enum FormStateValue: Equatable {
    case text(String)
    case number(String)
    case boolean(Bool)
    case multiSelect([String])
    case singleSelect(String)
    
    static func == (lhs: FormStateValue, rhs: FormStateValue) -> Bool {
        switch (lhs, rhs) {
        case (.text(let a), .text(let b)):
            return a == b
        case (.number(let a), .number(let b)):
            return a == b
        case (.boolean(let a), .boolean(let b)):
            return a == b
        case (.multiSelect(let a), .multiSelect(let b)):
            return Set(a) == Set(b)
        case (.singleSelect(let a), .singleSelect(let b)):
            return a == b
        default:
            return false
        }
    }
}
