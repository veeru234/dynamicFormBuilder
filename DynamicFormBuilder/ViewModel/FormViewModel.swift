//
//  FormViewModel.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//


import Foundation
import Combine

// MARK: - Form State Manager ViewModel

@MainActor
class FormViewModel: ObservableObject {
    @Published var form: FormModel?
    @Published var formState: [String: FormStateValue] = [:]
    @Published var validationErrors: [String: String] = [:]
    @Published var isSubmitting = false
    @Published var showSuccessAlert = false
    @Published var successMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadFormFromJSON()
    }
    
    // MARK: - Load Form from JSON
    
    func loadFormFromJSON() {
        guard let jsonURL = Bundle.main.url(forResource: "form", withExtension: "json"),
              let jsonData = try? Data(contentsOf: jsonURL) else {
            print("❌ Failed to load form.json from app bundle")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let loadedForm = try decoder.decode(FormModel.self, from: jsonData)
            self.form = loadedForm
            
            // Initialize form state with default values
            initializeFormState(from: loadedForm)
            print("✅ Form loaded successfully: \(loadedForm.formTitle)")
        }  catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted:", context.debugDescription)
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key:", key, context.debugDescription)
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch:", type, context.debugDescription)
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Value not found:", value, context.debugDescription)
        } catch {
            print("❌ Unknown error:", error)
        }
    }
    
    // MARK: - Initialize Form State
    
    private func initializeFormState(from form: FormModel) {
        for field in form.fields {
            switch field {
            case .text(let textField):
                formState[textField.id] = .text("")
                
            case .dropdown(let dropdownField):
                if let defaultValues = dropdownField.defaultValues {
                    if dropdownField.allowMultiple {
                        formState[dropdownField.id] = .multiSelect(defaultValues)
                    } else {
                        // For single select, use the first default value
                        formState[dropdownField.id] = .singleSelect(defaultValues.first ?? "")
                    }
                } else {
                    if dropdownField.allowMultiple {
                        formState[dropdownField.id] = .multiSelect([])
                    } else {
                        formState[dropdownField.id] = .singleSelect("")
                    }
                }
                
            case .toggle(let toggleField):
                formState[toggleField.id] = .boolean(toggleField.defaultValue ?? false)
                
            case .checkbox(let checkboxField):
                formState[checkboxField.id] = .boolean(checkboxField.defaultValue ?? false)
                
            case .unknown:
                // Skip unknown field types
                break
            case .colorPicker(_):
                break
            }
        }
    }
    
    // MARK: - Update Field Value
    func updateFieldValue(fieldId: String, value: FormStateValue) {
        formState[fieldId] = value
        // Clear validation error when user starts editing
        validationErrors.removeValue(forKey: fieldId)
    }
    
    // MARK: - Validation
    func validateForm() -> Bool {
        validationErrors.removeAll()
        var isValid = true
        
        guard let form = form else { return false }
        
        for field in form.fields {
            switch field {
            case .text(let textField):
                if !validateTextField(textField) {
                    isValid = false
                }
                
            case .dropdown(let dropdownField):
                if !validateDropdownField(dropdownField) {
                    isValid = false
                }
                
            case .toggle(let toggleField):
                if !validateToggleField(toggleField) {
                    isValid = false
                }
                
            case .checkbox(let checkboxField):
                if !validateCheckboxField(checkboxField) {
                    isValid = false
                }
                
            case .unknown:
                break
            case .colorPicker(_):
                break
            }
        }
        
        return isValid
    }
    
    private func validateTextField(_ field: TextFieldModel) -> Bool {
        guard field.required else { return true }
        
        let currentValue = formState[field.id] as? FormStateValue
        
        switch currentValue {
        case .text(let text):
            if text.trimmingCharacters(in: .whitespaces).isEmpty {
                validationErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
                return false
            }
            
            // Validate regex if provided
            if let regex = field.regex {
                if !isValidRegex(text: text, pattern: regex) {
                    validationErrors[field.id] = "Invalid format for \(field.label)"
                    return false
                }
            }
            
            return true
            
        default:
            validationErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
            return false
        }
    }
    
    private func validateDropdownField(_ field: DropdownFieldModel) -> Bool {
        guard field.required else { return true }
        
        let currentValue = formState[field.id]
        
        if field.allowMultiple {
            if case .multiSelect(let selections) = currentValue, !selections.isEmpty {
                return true
            }
        } else {
            if case .singleSelect(let selection) = currentValue, !selection.isEmpty {
                return true
            }
        }
        
        validationErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
        return false
    }
    
    private func validateToggleField(_ field: ToggleFieldModel) -> Bool {
        guard field.required else { return true }
        
        if case .boolean(let isOn) = formState[field.id], isOn {
            return true
        }
        
        validationErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
        return false
    }
    
    private func validateCheckboxField(_ field: CheckboxFieldModel) -> Bool {
        guard field.required else { return true }
        
        if case .boolean(let isChecked) = formState[field.id], isChecked {
            return true
        }
        
        validationErrors[field.id] = field.errorMessage ?? "\(field.label) is required."
        return false
    }
    
    private func isValidRegex(text: String, pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(text.startIndex..., in: text)
            return regex.firstMatch(in: text, options: [], range: range) != nil
        } catch {
            print("⚠️ Invalid regex pattern: \(error.localizedDescription)")
            return true // If regex is invalid, don't block submission
        }
    }
    
    // MARK: - Submit Form
    
    func submitForm() {
        guard validateForm() else {
            print("❌ Form validation failed")
            return
        }
        
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.isSubmitting = false
            self.printFormState()
            
            // Show success alert
            self.successMessage = "Form submitted successfully"
            self.showSuccessAlert = true
        }
    }
    
    // MARK: - Print Form State to Console
    private func printFormState() {
        var output: [String: Any] = [:]
        
        for (key, value) in formState {
            switch value {
            case .text(let text):
                output[key] = text
            case .number(let num):
                output[key] = num
            case .boolean(let bool):
                output[key] = bool
            case .multiSelect(let selections):
                output[key] = selections
            case .singleSelect(let selection):
                output[key] = selection
            }
        }
        
        print("\n✅ FORM SUBMISSION SUCCESS")
        print("=" * 50)
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: output, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print(output)
        }
        
        print("=" * 50 + "\n")
    }
    
    
    // MARK: - Reset Form
    func resetForm() {
        guard let form = form else { return }
        
        formState.removeAll()
        validationErrors.removeAll()
        initializeFormState(from: form)
    }
    
    // MARK: - Helper: Get Sorted Fields
    
    func getSortedFields() -> [FormField] {
        guard let form = form else { return [] }
        
        return form.fields
            .filter { field in
                if case .unknown = field {
                    return false
                }
                return true
            }
            .sorted { a, b in
                let orderA = getFieldOrder(a)
                let orderB = getFieldOrder(b)
                return orderA < orderB
            }
    }
    
    private func getFieldOrder(_ field: FormField) -> Int {
        switch field {
        case .text(let model):
            return model.order
        case .dropdown(let model):
            return model.order
        case .toggle(let model):
            return model.order
        case .checkbox(let model):
            return model.order
        case .unknown:
            return Int.max
        case .colorPicker(_):
            return Int.max
        }
    }
}

// String multiplication helper for console output
extension String {
    static func * (lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
