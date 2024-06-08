//
//  MenuView.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/18/24.
//

import SwiftUI
import SwiftData

struct MenuView: View {
    @State var nav = false
    @Binding var context:ModelContext
    @State var view = ""
    @Binding var cars:CarList
    @ObservedObject var locAuth : LocationDataManager
    @ViewBuilder
    var body: some View {
        NavigationStack{
            ZStack{
                Color("CharcoalColor").ignoresSafeArea()
                HStack{
                    Spacer()
                    HStack{
                        Rectangle().foregroundStyle(Color("NeonYellow")).frame(width:15).padding(.trailing,12)
                        Rectangle().foregroundStyle(Color("NeonYellow")).frame(width:15)
                    }.ignoresSafeArea().padding(.trailing,31)
                }
                VStack{
                    HStack{
                        Button("Cars For You"){
                            view = "Cars For You"
                            nav = true
                        }
                        Spacer()
                    }.padding(.bottom, 20).font(.custom("NotoSans-Bold", size:35)).foregroundStyle(Color.white)
                    Spacer()
                }.padding(.leading,35.5).padding(.top,50)
            }
        }.navigationBarBackButtonHidden(true).navigationDestination(isPresented: $nav){
            if(view == "Cars For You")
            {
                SearchResultsView(cars: $cars, context: $context, locAuth: locAuth)
            }
        }
    }
}
