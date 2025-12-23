//
//  HeaderView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//


import SwiftUI

struct HeaderView: View {
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Text("Code Calender")
                    .font(.system(.largeTitle, design: .serif))
                    .italic()
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}
