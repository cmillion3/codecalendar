//
//  ImportOptionsView.swift
//  codecalendar
//
//  Created by Cameron on 3/18/26.
//


//
//  ImportAlertView.swift
//  codecalendar
//
//  Created by Cameron on 12/26/25.
//

import SwiftUI

struct ImportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    let onImport: (ImportStrategy) -> Void
    
    enum ImportStrategy {
        case merge
        case replace
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            Text("Import Data")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("How would you like to import the data?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button {
                    onImport(.merge)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.merge")
                        Text("Merge with existing data")
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Button {
                    onImport(.replace)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Replace all existing data")
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 40)
    }
}