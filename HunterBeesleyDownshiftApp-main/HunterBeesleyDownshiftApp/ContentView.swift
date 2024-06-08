//
//  ContentView.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var carList:CarList
    @State var isTapped = false
    @State var context:ModelContext
    @ObservedObject var locAuth : LocationDataManager
    var body: some View {
        NavigationStack
        {
            ZStack{
                Color("CharcoalColor").ignoresSafeArea()
                HStack{
                    Rectangle().foregroundStyle(Color("NeonYellow")).frame(width:15).padding(.trailing,12)
                    Rectangle().foregroundStyle(Color("NeonYellow")).frame(width:15)
                }.ignoresSafeArea()
                VStack {
                    Text("Downshift").font(.custom("NotoSans-Bold", size: 55.5)).foregroundStyle(Color.white).padding(.top,20)
                    Text("Tap anywhere to continue").font(.custom("NotoSans-Regular", size: 22)).foregroundStyle(Color.white).padding(.bottom,20)
                }.background(Color("CharcoalColor"))
                
            }.onTapGesture{isTapped = true}.navigationDestination(isPresented: $isTapped){
                if(carList.carList.count == 0)
                {
                    FilterView(carList: $carList, context: $context, locAuth: locAuth)
                }
                else
                {
                    SearchResultsView(cars: $carList, context: $context, locAuth: locAuth)
                }
            }
        }
    }
    
    init(modelContext: ModelContext){
        let carList = CarList(context: modelContext, delete: false)
        _carList = State(initialValue: carList)
        locAuth = LocationDataManager()
        context = modelContext
        _context = State(initialValue: modelContext)
    }
}
