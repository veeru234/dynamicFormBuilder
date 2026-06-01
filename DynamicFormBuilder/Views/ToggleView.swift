//
//  ToggleView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import SwiftUI
 
struct ToggleView: View {
    let field: ToggleFieldModel
    @Binding var value: Bool
    let theme: ThemeModel
    let error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(field.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: theme.textColor))
                
                if field.required {
                    Text("*")
                        .foregroundColor(Color(hex: theme.errorColor))
                }
                
                Spacer()
                
                Toggle("", isOn: $value)
                    .tint(Color.green)
            }
            .padding(12)
            .background(Color(hex: theme.backgroundColor))
            .border(Color(hex: error != nil ? theme.errorColor : theme.borderColor), width: 1)
            .cornerRadius(8)
            
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
}
