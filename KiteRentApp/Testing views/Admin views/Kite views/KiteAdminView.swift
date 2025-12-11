//
//  KiteAdmin.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteAdmin: View {
    var kite: DBKite
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(kite.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    TagView(text: textFromState(state: kite.state), backgroundColor: colorFromState(state: kite.state))
                }
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 4)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    func textFromState(state: KiteState) -> String {
        switch state {
        case .free:
            return "Wolny"
        case .used:
            return "Na zajęciach"
        case .serviced:
            return "W serwisie"
        }
    }
    
    func colorFromState(state: KiteState) -> Color {
        switch state {
        case .free:
            return .green
        case .used:
            return .blue
        case .serviced:
            return .red
        }
    }
}

struct TagView: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

struct KiteAdmin_Previews: PreviewProvider {
    static var previews: some View {
        KiteAdmin(kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
