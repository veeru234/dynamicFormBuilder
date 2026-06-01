//
//  ContentView.swift
//  DynamicFormBuilder
//
//  Created by Veeru Masal on 27/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = FormViewModel()
    
    var body: some View {
        ZStack {
            
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(hex: "#121212"),
                    Color(hex: "#1E1E1E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if let form = viewModel.form {
                    VStack(spacing: 20) {
                        
                        // HEADER
                        VStack(alignment: .leading, spacing: 5) {
                            Text(form.formTitle)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                            Text("Fill in the details below")
                                .font(.system(size: 14))
                                .padding(.horizontal)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)
                        
                        // FORM FIELDS (CARD STYLE)
                        ScrollView(showsIndicators: false) {
                        ForEach(Array(viewModel.getSortedFields().enumerated()), id: \.offset) { index, field in
                            renderField(field, for: form.theme)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.05))
                                )
                                .padding(.horizontal, 4)
                                .opacity(viewModel.form != nil ? 1 : 0)
                                .offset(y: viewModel.form != nil ? 0 : 20)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.8)
                                    .delay(Double(index) * 0.05),
                                    value: viewModel.form != nil
                                )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
                
                // FLOATING SUBMIT BUTTON
                VStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.submitForm()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            }
                            
                            Text(viewModel.isSubmitting ? "Submitting..." : "Submit")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 6)
                        .scaleEffect(viewModel.isSubmitting ? 0.97 : 1)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isSubmitting)
                    }
                    .padding()
                }
                
            } else {
                SkeletonView()
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                viewModel.resetForm()
            }
        } message: {
            Text(viewModel.successMessage)
        }
    }
    
    // MARK: - Render Field based on Type
    
    @ViewBuilder
    private func renderField(_ field: FormField, for theme: ThemeModel) -> some View {
        switch field {
        case .text(let textField):
            let binding = Binding(
                get: {
                    if case .text(let value) = viewModel.formState[textField.id] {
                        return value
                    }
                    return ""
                },
                set: { newValue in
                    viewModel.updateFieldValue(fieldId: textField.id, value: .text(newValue))
                }
            )
            
            TextFieldView(
                field: textField,
                value: binding,
                theme: theme,
                error: viewModel.validationErrors[textField.id]
            )
            
        case .dropdown(let dropdownField):
            let onSelectionChange = { (value: FormStateValue) in
                viewModel.updateFieldValue(fieldId: dropdownField.id, value: value)
            }
            
            DropdownView(
                field: dropdownField,
                theme: theme,
                error: viewModel.validationErrors[dropdownField.id],
                onSelectionChange: onSelectionChange
            )
            
        case .toggle(let toggleField):
            let binding = Binding(
                get: {
                    if case .boolean(let value) = viewModel.formState[toggleField.id] {
                        return value
                    }
                    return false
                },
                set: { newValue in
                    viewModel.updateFieldValue(fieldId: toggleField.id, value: .boolean(newValue))
                }
            )
            
            ToggleView(
                field: toggleField,
                value: binding,
                theme: theme,
                error: viewModel.validationErrors[toggleField.id]
            )
            
        case .checkbox(let checkboxField):
            let binding = Binding(
                get: {
                    if case .boolean(let value) = viewModel.formState[checkboxField.id] {
                        return value
                    }
                    return false
                },
                set: { newValue in
                    viewModel.updateFieldValue(fieldId: checkboxField.id, value: .boolean(newValue))
                }
            )
            
            CheckboxView(
                field: checkboxField,
                value: binding,
                theme: theme,
                error: viewModel.validationErrors[checkboxField.id]
            )
            
        case .unknown:
            EmptyView()
        case .colorPicker(_):
            EmptyView()
        }
    }
}

struct SkeletonView: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<6) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 60)
                    .shimmer()
            }
        }
        .padding()
    }
}


extension View {
    func shimmer() -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.4),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(
                    .linear(duration: 1.2)
                        .repeatForever(autoreverses: false),
                    value: UUID()
                )
            )
    }
}
 
#Preview {
    ContentView()
}
