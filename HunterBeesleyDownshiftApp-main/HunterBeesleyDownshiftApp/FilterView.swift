//
//  SwiftUIView.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/17/24.
//

import SwiftUI
import SwiftData

struct FilterView: View {
    @Binding var carList: CarList
    @Binding var context:ModelContext
    @ObservedObject var locAuth : LocationDataManager
    @State var fuelSelected:String = "Hybrid"
    @State var styleSelected:String = "Hatchback"
    @State var seatSelected:Float = 4
    @State var mpgSelected:Float = 30
    @State var seatInt:Int = 4
    @State var mpgInt:Int = 30
    @State var goNext = false
    @State var searchResults:[CarObject]? = nil
    
    @ViewBuilder
    var body: some View {
        NavigationStack
        {
            ZStack{
                Color("CharcoalColor").ignoresSafeArea()
                VStack {
                    Text("Enter Your Preferences").font(.custom("NotoSans-Bold", size: 30)).foregroundStyle(Color.white).padding(.top,40).padding(.bottom, 50)
                    
                    Section{
                        HStack{
                            Text("Fuel Type").font(.custom("NotoSans-SemiBold", size:25)).foregroundStyle(Color.white)
                            Picker("Fuel Type", selection: $fuelSelected) {
                                ForEach(["Gas", "Diesel", "Electric", "Hybrid"], id: \.self) { fuelStr in
                                    Text(fuelStr)
                                        .tag(fuelStr)
                                }
                            }.tint(Color("NeonYellow")).padding(.top,2).foregroundStyle(Color.white).padding(.horizontal, 20).scaleEffect(1.5)
                            
                        }
                        HStack{
                            Text("Body Style").font(.custom("NotoSans-SemiBold", size:25)).foregroundStyle(Color.white)
                            Picker("Body Style", selection: $styleSelected) {
                                ForEach(["Sedan", "Coupe", "Hatchback", "Convertible", "SUV", "Crossover", "Wagon", "Minivan", "Van", "Truck"], id: \.self) { bodyStr in
                                    Text(bodyStr)
                                        .tag(bodyStr)
                                }
                            }.tint(Color("NeonYellow")).padding(.top,2).foregroundStyle(Color.white).padding(.horizontal, 20).scaleEffect(1.5)
                            
                        }.padding(20)
                        Text("Number of seats: " + String(format: "%.0f", seatSelected)).font(.custom("NotoSans-SemiBold", size:25)).foregroundStyle(Color.white)
                        Slider(value: $seatSelected, in:1...8, step:1).tint(Color("NeonYellow")).padding(.horizontal, 40).padding(.bottom, 20)
                        if(fuelSelected != "Electric"){
                            Text("Gas Mileage: " + String(format: "%.0f", mpgSelected) + " MPG").font(.custom("NotoSans-SemiBold", size:25)).foregroundStyle(Color.white)
                            Slider(value: $mpgSelected, in:1...65, step:1).tint(Color("NeonYellow")).padding(.horizontal, 40).padding(.bottom, 40)
                        }
                        else{
                            Text("Electric Mileage: " + String(format: "%.0f", mpgSelected) + " MPGe").font(.custom("NotoSans-SemiBold", size:25)).foregroundStyle(Color.white)
                            Slider(value: $mpgSelected, in:1...160, step:1).tint(Color("NeonYellow")).padding(.horizontal, 40).padding(.bottom, 40)
                        }
                        Button("Next"){
                            seatInt = Int(seatSelected)
                            mpgInt = Int(mpgSelected)
                            goNext = true
                            carList = CarList(context: carList.modelContext, delete: true)
                            carList.pageNum = 1
                            
                            carList.pagesLen = -1
                            carList.makeModIdSet = Set<Int>()
                            carList.idSeatSet = Set<Int>()
                            carList.makeModTrimIdSet = Set<Int>()
                            carList.isEmpty = false
                            carList.requestEngineAndBody(fuel: fuelSelected, mileage: mpgInt, style: styleSelected, seats: seatInt)
                            carList.newFilters(style: styleSelected, fuel: fuelSelected, mpg: mpgInt, seats: seatInt)
                        }.frame(width:100).background(Color("NeonYellow")).font(.custom("NotoSans-Bold", size:33)).foregroundStyle(Color("CharcoalColor")).clipShape(.buttonBorder).padding()
                        Spacer()
                    }
                }.background(Color("CharcoalColor")).onAppear{
                    if(carList.filterParams.count > 0)
                    {
                        seatSelected = Float(carList.filterParams[0].numSeats)
                        mpgSelected = Float(carList.filterParams[0].mpgOverall)
                        fuelSelected = carList.filterParams[0].carFuel
                        styleSelected = carList.filterParams[0].bodyStyle
                    }
                }
                
            }.navigationDestination(isPresented: $goNext){
                
                SearchResultsView(cars: $carList, context: $context, locAuth: locAuth)
            }
        }.navigationBarBackButtonHidden(true)
    }
}
