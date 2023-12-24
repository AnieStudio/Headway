//
//  LaunchView.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.primaryBlue
            
            VStack {
                VStack(spacing: 12) {
                    Image(.logo)
                        .resizable()
                        .frame(width: 54, height: 48)
                    
                    Text("Headway")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                }
                ProgressView()
                    .controlSize(.large)
                    .tint(.white.opacity(0.5))
                    .padding(.top, 20)
            }
        }
        .ignoresSafeArea(.all)
    }
}
