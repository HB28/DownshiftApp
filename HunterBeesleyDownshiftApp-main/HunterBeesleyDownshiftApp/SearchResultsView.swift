//
//  SearchResults.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/18/24.
//

import SwiftUI
import SwiftData

struct SearchResultsView: View {
    @Binding var cars:CarList
    @Binding var context:ModelContext
    @ObservedObject var locAuth : LocationDataManager
    @State var goNext:String = ""
    @State var nav = false
    @ViewBuilder
    var body: some View {
        NavigationStack{
            VStack{
                VStack{
                    ZStack{
                        Rectangle().foregroundStyle(Color("CharcoalColor")).frame(maxHeight:.infinity, alignment:.top).ignoresSafeArea()
                        HStack{
                            Button{
                                goNext = "menu"
                                nav = true
                            } label: {
                                Image(systemName:"line.horizontal.3").font(.system(size:35, weight:.bold)).padding(.horizontal, 12.5).foregroundStyle(Color("NeonYellow"))
                            }
                            Text("Cars For You").font(.custom("NotoSans-Bold", size:30)).foregroundStyle(Color.white)
                            Button{
                                goNext = "filter"
                                nav = true
                            } label: {
                                Image(systemName:"slider.horizontal.3").font(.system(size:35, weight:.bold)).padding(.horizontal, 12.5).foregroundStyle(Color("NeonYellow"))
                            }
                        }.frame(maxHeight:.infinity, alignment: .top)
                    }.frame(maxHeight:75)
                    
                }
                if(cars.isEmpty)
                {
                    Text("No cars match your criteria.").padding(.top, 40).font(.custom("NotoSans-Regular", size: 24)).frame(maxWidth:.infinity, alignment: .center)
                    Image(systemName: "exclamationmark.magnifyingglass").foregroundStyle(Color.yellow).font(.system(size:40, weight: .semibold)).padding(.top, 40).frame(maxWidth:.infinity, alignment: .center)
                }
                else if(cars.carList.count == 0)
                {
                    Text("Finding cars ...").padding(.top, 40).font(.custom("NotoSans-Regular", size: 24))
                    ProgressView()
                }
                List(0..<cars.carList.count, id: \.self){ index in
                    Section{
                        ZStack {
                            VStack{
                                VStack{
                                    HStack{
                                        Text(cars.carList[index].carMake + " " + cars.carList[index].carModel).font(.custom("NotoSans-SemiBold", size:20)).foregroundStyle(Color.white).padding(.top, 20).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).frame(maxWidth:.infinity, alignment: .leading).padding(.leading, 15)
                                    }
                                    VStack{
                                        let mpgType = cars.carList[index].carFuel == "Electric" ? " MPGe" : " MPG"
                                        let message = "Mileage: " + String(cars.carList[index].mpgOverall) + mpgType
                                        let half = "Seats: " + String(cars.carList[index].numSeats)
                                        Text(message).font(.custom("NotoSans-Regular", size:20)).foregroundStyle(Color(UIColor.systemGray6)).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).frame(maxWidth:.infinity, alignment: .leading).padding(.leading, 15).padding(.top, 0.5)
                                        Text(half).font(.custom("NotoSans-Regular", size:20)).foregroundStyle(Color(UIColor.systemGray6)).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).frame(maxWidth:.infinity, alignment: .leading).padding(.leading, 15)
                                    }
                                }
                                Spacer()
                                
                            }
                            NavigationLink(destination:CarDetailView(car: cars.carList[index], cars: $cars, context: $context, locAuth: locAuth)){}.opacity(0)
                        }
                    }.listStyle(PlainListStyle()).background(Color("CharcoalColor")).listRowSeparator(.hidden).frame(maxWidth:.infinity, maxHeight:140 ).clipShape(RoundedRectangle(cornerRadius: 10)).ignoresSafeArea()
                }.scrollContentBackground(.hidden).frame(maxWidth:.infinity).ignoresSafeArea()
            }
        }.navigationBarHidden(true).navigationDestination(isPresented: $nav){
            if(goNext == "filter"){
                FilterView(carList: $cars, context: $context, locAuth: locAuth)
            }
            else if(goNext == "menu" ){
                MenuView(context: $context, cars: $cars, locAuth: locAuth)
            }
        }
    }
}
