//
//  BookDetailsView.swift
//  Headway
//
//  Created by Hlib Serediuk-Personal on 23.12.2023.
//

import SwiftUI
import ComposableArchitecture

struct BookDetailsView: View {
    let store: StoreOf<BookDetailsReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { screen in
                if viewStore.book == .empty {
                    LaunchView()
                } else {
                    ZStack {
                        Color
                            .primaryBackground
                        
                        VStack {
                            VStack {
                                Image(viewStore.book.previewID)
                                    .resizable()
                                    .frame(width: screen.size.width * 0.6, height: screen.size.height * 0.4)
                                    .shadow(radius: 10)
                                    .padding(.top, screen.size.height * 0.03)
                            }
                            .padding(.top, screen.size.width * 0.09)
                            
                            PlayerControlsView(
                                store: .init(
                                    initialState: PlayerControlsReducer.State(book: viewStore.book),
                                    reducer: { PlayerControlsReducer() }
                                ), screen: screen)
                            
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BookDetailsView(store: .init(initialState: BookDetailsReducer.State(bookID: "1"), reducer: {BookDetailsReducer()}))
}
