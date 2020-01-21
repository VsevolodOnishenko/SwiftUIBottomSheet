//
//  RestaurantDetailView.swift
//  SwiftUIBottomSheet
//

import SwiftUI

struct RestaurantDetailView: View {
    
    let restaurant: Restaurant
    @GestureState private var dragState = DragState.inactive
    @State private var positionOffset: CGFloat = 0.0
    @State private var viewState = ViewState.half
    @Binding var isShow: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HandleBar()
                
                ScrollView(.vertical) {
                    TitleBar()
                    HeaderView(restaurant: self.restaurant)
                    DetailInfoView(icon: "map", info: self.restaurant.location)
                    DetailInfoView(icon: "phone", info: self.restaurant.phone)
                    DetailInfoView(icon: nil, info: self.restaurant.description)
                        .padding(.top)
                }
                .background(Color.white)
                .cornerRadius(10, antialiased: true)
                .disabled(self.viewState == .half || self.dragState.isDragging)
            }
            .offset(y: geometry.size.height/2 + self.dragState.translation.height + self.positionOffset)
            .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0))
            .edgesIgnoringSafeArea(.all)
            .gesture(
                DragGesture()
                    .updating(self.$dragState, body: { (value, state, transaction) in
                        state = .dragging(translation: value.translation)
                    })
                    .onEnded { value in
                        switch self.viewState {
                        case .half:
                            if value.translation.height < -geometry.size.height * 0.25 {
                                self.positionOffset = -geometry.size.height/2 + 50
                                self.viewState = .full
                            }
                            
                            if value.translation.height > geometry.size.height * 0.3 {
                                self.isShow = false
                            }
                        case .full:
                            if value.translation.height > geometry.size.height * 0.25 {
                                self.positionOffset = 0
                                self.viewState = .half
                            }
                            
                            if value.translation.height > geometry.size.height * 0.75 {
                                self.isShow = false
                            }
                        }
                    }
            )
        }
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(restaurant: restaurants[1], isShow: .constant(true))
            .background(Color.black.opacity(0.3))
            .edgesIgnoringSafeArea(.all)
    }
}

struct HandleBar: View {
    
    var body: some View {
        Rectangle()
            .frame(width: 50, height: 3)
            .foregroundColor(Color(.systemGray5))
            .cornerRadius(10)
    }
}

struct TitleBar: View {
    
    var body: some View {
        HStack {
            Text("Restaurant Details")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding()
    }
}

struct HeaderView: View {
    
    let restaurant: Restaurant
    
    var body: some View {
        Image(restaurant.image)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(restaurant.name)
                            .foregroundColor(.white)
                            .font(.system(.largeTitle, design: .rounded))
                            .bold()
                        Text(restaurant.type)
                    }
                    .padding()
                    
                    Spacer()
                }
        )
    }
}

struct DetailInfoView: View {
    
    let icon: String?
    let info: String
    
    var body: some View {
        HStack {
            if icon != nil {
                Image(systemName: icon!).padding(.trailing, 10)
            }
            Text(info).font(.system(.body, design: .rounded))
            Spacer()
        }
        .padding(.horizontal)
    }
}

enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .dragging, .pressing:
            return true
        case .inactive:
            return false
        }
    }
}

enum ViewState {
    case full
    case half
}
