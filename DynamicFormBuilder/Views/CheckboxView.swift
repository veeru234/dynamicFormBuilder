//
//  CheckboxView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import SwiftUI
 
struct CheckboxView: View {
    let field: CheckboxFieldModel
    @Binding var value: Bool
    let theme: ThemeModel
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .top, spacing: 12) {
                
                Image(systemName: value ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(
                        value ? Color.blue : Color.white.opacity(0.5)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    if let metadata = field.metadata, !metadata.isEmpty {
                        richTextLabel()
                    } else {
                        Text(field.label)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        error != nil
                        ? Color.red
                        : Color.white.opacity(0.1),
                        lineWidth: 1.2
                    )
            )
            .onTapGesture {
                value.toggle()
            }
            
            if let error = error {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text(error)
                }
                .font(.system(size: 12))
                .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }
    
    private func richTextLabel() -> some View {
        let metadata = field.metadata ?? [:]
        let currentLabel = field.label
        
        // 1. Initialize an empty AttributedString
        var container = AttributedString()
        
        // 2. Find the link key inside the label
        var linkKey: String? = nil
        for key in metadata.keys {
            if currentLabel.contains(key) {
                linkKey = key
                break
            }
        }
        
        let defaultColor = Color(hex: theme.textColor)
        
        if let key = linkKey,
           let urlString = metadata[key],
           let url = URL(string: urlString) {
            
            // Split the text into before and after the clickable link
            let parts = currentLabel.components(separatedBy: key)
            
            if parts.count == 2 {
                // Text before the link
                var beforeText = AttributedString(parts[0])
                beforeText.foregroundColor = defaultColor
                container.append(beforeText)
                
                // The Clickable Link
                var linkText = AttributedString(key)
                linkText.link = url
                linkText.foregroundColor = Color(hex: field.clickableTextColor ?? theme.borderColor)
                // Optional: linkText.underlineStyle = .single if you want it underlined
                container.append(linkText)
                
                // Text after the link
                var afterText = AttributedString(parts[1])
                afterText.foregroundColor = defaultColor
                container.append(afterText)
            }
        } else {
            // Fallback if no metadata match is found
            var plainText = AttributedString(currentLabel)
            plainText.foregroundColor = defaultColor
            container.append(plainText)
        }
        if field.required {
            var asterisk = AttributedString(" *")
            asterisk.foregroundColor = Color(hex: theme.errorColor)
            container.append(asterisk)
        }
        return Text(container)
            .font(.system(size: 14))
            .environment(\.openURL, OpenURLAction { url in
                return .systemAction
            })
    }
}
 
