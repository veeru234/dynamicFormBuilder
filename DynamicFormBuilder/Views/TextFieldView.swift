//
//  TextFieldView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import SwiftUI

struct TextFieldView: View {
    let field: TextFieldModel
    @Binding var value: String
    let theme: ThemeModel
    let error: String?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label with required indicator
            HStack {
                Text(field.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: theme.textColor))
                
                if field.required {
                    Text("*")
                        .foregroundColor(Color(hex: theme.errorColor))
                }
            }
            
            // Supporting text (if available)
            if let supportingText = field.supportingText {
                Text(supportingText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: theme.textColor).opacity(0.6))
            }
            
            // Input field based on subtype
            switch field.subtype {
            case "PLAIN":
                plainTextField()
                
            case "MULTILINE":
                multilineTextField()
                
            case "NUMBER":
                numberTextField()
                
            case "URI":
                uriTextField()
                
            case "SECURE":
                secureTextField()
                
            default:
                plainTextField()
            }
            
            // Character counter (if max_length is specified)
            if let maxLength = field.maxLength {
                HStack {
                    Spacer()
                    Text("\(value.count)/\(maxLength)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(hex: theme.textColor).opacity(0.5))
                }
            }
            
            // Error message
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 12, weight: .regular))
                }
                .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }
    
    private func plainTextField() -> some View {
        TextField(field.placeholder ?? "", text: $value)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05)) // 🔥 MATCH CARD STYLE
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused
                        ? Color.blue
                        : (error != nil ? Color.red : Color.white.opacity(0.1)),
                        lineWidth: 1.2
                    )
            )
            .focused($isFocused)
            .onChange(of: value) { newValue in
                if let maxLength = field.maxLength, newValue.count > maxLength {
                    value = String(newValue.prefix(maxLength))
                }
            }
    }
    
    private func multilineTextField() -> some View {
        TextEditor(text: $value)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .focused($isFocused)
            .frame(minHeight: 100)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused
                        ? Color.blue
                        : (error != nil ? Color.red : Color.white.opacity(0.1)),
                        lineWidth: 1.2
                    )
            )
            .onChange(of: value) { newValue in
                if let maxLength = field.maxLength, newValue.count > maxLength {
                    value = String(newValue.prefix(maxLength))
                }
            }
    }
    
    private func numberTextField() -> some View {
        TextField(field.placeholder ?? "", text: $value)
            .keyboardType(.decimalPad)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .focused($isFocused)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused
                        ? Color.blue
                        : (error != nil ? Color.red : Color.white.opacity(0.1)),
                        lineWidth: 1.2
                    )
            )
            .onChange(of: value) { newValue in
                // Allow only numbers and dot
                let filtered = newValue.filter { $0.isNumber || $0 == "." }
                var finalValue = filtered
                if let maxLength = field.maxLength, finalValue.count > maxLength {
                    finalValue = String(finalValue.prefix(maxLength))
                }
                if finalValue != value {
                    value = finalValue
                }
            }
    }
    
    private func uriTextField() -> some View {
        TextField("", text: $value, prompt:
                    Text(field.placeholder ?? "https://")
            .foregroundColor(.gray)
        )
        .keyboardType(.URL)
        .font(.system(size: 14))
        .foregroundColor(.white)
        .focused($isFocused)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isFocused
                    ? Color.blue
                    : (error != nil ? Color.red : Color.white.opacity(0.1)),
                    lineWidth: 1.2
                )
        )
    }
    
    private func secureTextField() -> some View {
        SecureField("", text: $value, prompt:
                        Text(field.placeholder ?? "")
            .foregroundColor(.gray)
        )
        .font(.system(size: 14))
        .foregroundColor(.white)
        .focused($isFocused)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isFocused
                    ? Color.blue
                    : (error != nil ? Color.red : Color.white.opacity(0.1)),
                    lineWidth: 1.2
                )
        )
    }
}
