//
//  HeaderView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//


import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "hammer.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            Text("DevDash")
                .font(.custom("DancingScript-Regular", size: 32))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}
