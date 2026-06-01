//
//  DropdownView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import SwiftUI

struct DropdownView: View {
    let field: DropdownFieldModel
    let theme: ThemeModel
    let error: String?
    @State private var selectedIds: Set<String> = []
    @State private var selectedId: String = ""
    var onSelectionChange: (FormStateValue) -> Void
    
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
            }
            
            if field.allowMultiple {
                multiSelectDropdown()
            } else {
                singleSelectDropdown()
            }
            
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
        .onAppear {
            // Initialize with default values
            if field.allowMultiple {
                selectedIds = Set(field.defaultValues ?? [])
            } else {
                selectedId = field.defaultValues?.first ?? ""
            }
        }
    }
    
    private func singleSelectDropdown() -> some View {
        Menu {
            ForEach(field.options, id: \.id) { option in
                Button(action: {
                    selectedId = option.id
                    onSelectionChange(.singleSelect(option.id))
                }) {
                    HStack {
                        Text(option.label)
                        if selectedId == option.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedId.isEmpty ? "Select an option" : field.options.first(where: { $0.id == selectedId })?.label ?? "Select an option")
                    .foregroundColor(selectedId.isEmpty ? .gray : Color(hex: theme.textColor))
                    .lineLimit(1)
                
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: theme.borderColor))
            }
            .padding(12)
            .background(Color(hex: theme.backgroundColor))
            .border(Color(hex: error != nil ? theme.errorColor : theme.borderColor), width: 1)
            .cornerRadius(8)
        }
    }
    
    private func multiSelectDropdown() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(field.options, id: \.id) { option in
                Button(action: {
                    if selectedIds.contains(option.id) {
                        selectedIds.remove(option.id)
                    } else {
                        selectedIds.insert(option.id)
                    }
                    onSelectionChange(.multiSelect(Array(selectedIds)))
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIds.contains(option.id) ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedIds.contains(option.id) ? Color(hex: theme.borderColor) : .gray)
                            .font(.system(size: 18))
                        
                        Text(option.label)
                            .foregroundColor(Color(hex: theme.textColor))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(hex: theme.backgroundColor))
                }
            }
            .border(Color(hex: error != nil ? theme.errorColor : theme.borderColor), width: 1)
            .cornerRadius(8)
        }
    }
}
