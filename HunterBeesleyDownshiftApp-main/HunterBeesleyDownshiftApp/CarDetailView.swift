//
//  CarDetailView.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/18/24.
//

import SwiftUI
import CoreLocation
import MapKit
import SwiftData

struct Location: Identifiable {
    let id = UUID()
    var locName: String
    var locCoords: CLLocationCoordinate2D
}

struct build_struct : Decodable {
    var year : Int?
    var make : String?
    var model : String?
    var trim : String?
}

struct dealer_struct : Decodable {
    var website : String?
    var name : String?
    var street : String?
    var city : String?
    var state : String?
    var country : String?
    var latitude : String?
    var longitude : String?
    var zip : String?
    var phone : String?
    
}

struct img_struct : Decodable {
    var photo_links : [String]?
}

struct listing_struct : Decodable {
    var price : Double?
    var miles : Double?
    var vdp_url : String?
    var inventory_type : String?
    var media : img_struct?
    var dealer : dealer_struct?
    var build : build_struct?
    var dist : Double?
}

struct nearby : Decodable {
    var num_found : Int
    var listings : [listing_struct]
}

struct CarDetailView: View {
    var car:CarObject
    @Binding var cars:CarList
    @Binding var context:ModelContext
    @ObservedObject var locAuth:LocationDataManager
    @State var nav = false
    @State var listingArr : [listing_struct] = [listing_struct]()
    @State var find = true
    @State private var cityArea = MKCoordinateRegion()
    @State private var markers:[Location] = [Location]()
    @State var notSearched = true
    @ViewBuilder
    var body: some View {
        NavigationStack{
            switch locAuth.locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                VStack{
                    ZStack{
                        Rectangle().foregroundStyle(Color("CharcoalColor")).frame(maxHeight:125).ignoresSafeArea()
                        HStack{
                            Button{
                                nav = true
                            } label: {
                                Image(systemName:"line.horizontal.3").font(.system(size:35, weight:.bold)).padding(.top, 45).padding(.horizontal, 12.5).foregroundStyle(Color("NeonYellow"))
                            }.padding(.leading,27.5)
                            Text("Cars For You").font(.custom("NotoSans-Bold", size:30)).foregroundStyle(Color.white).padding(.top, 45)
                            Spacer()
                        }.frame(height:125)
                    }.frame(height:0)
                    Text(car.carMake + " " + car.carModel).font(.custom("NotoSans-SemiBold",size:32)).foregroundStyle(Color.black).padding(.top, 75).frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 45)
                    ZStack{
                        Rectangle().foregroundStyle(Color("NeonYellow")).frame(height:30).ignoresSafeArea()
                        HStack{
                            Spacer()
                            Text(car.carFuel).font(.custom("NotoSans-Regular", size:17.5))
                            Spacer()
                            Text(String(car.numSeats) + " Seats").font(.custom("NotoSans-Regular", size:17.5))
                            Spacer()
                            Text(car.bodyStyle).font(.custom("NotoSans-Regular", size:17.5))
                            Spacer()
                        }
                    }
                    
                    if(locAuth.locationManager.location?.coordinate.latitude.description != nil && locAuth.locationManager.location?.coordinate.longitude.description != nil)
                    {
                        Text(car.carMake + " Dealerships Near You").font(.custom("NotoSans-Regualr",size:24)).foregroundStyle(Color.black).padding(.top, 15).frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 45).padding(.trailing, 15).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        if notSearched
                        {
                            let other = updateCityArea(coord: locAuth.locationManager.location!.coordinate)
                        }
                        else
                        {
                            Map(bounds: MapCameraBounds(centerCoordinateBounds: cityArea, minimumDistance:1000, maximumDistance:.infinity), interactionModes: .all
                            ){
                                
                                UserAnnotation()
                                ForEach(0..<markers.count){ index in
                                    Marker(markers[index].locName, coordinate: markers[index].locCoords)
                                    
                                }
                                
                                
                            }.padding(.vertical,15).frame(maxWidth:350, maxHeight:400, alignment: .center).mapControls{
                                MapUserLocationButton()
                            }
                        }
                        
                        if(find)
                        {
                            let x = requestNearbyCars(lonParam: (locAuth.locationManager.location?.coordinate.longitude.description)!, latParam: (locAuth.locationManager.location?.coordinate.latitude.description)!)
                        }
                        
                        if(listingArr.count > 0)
                        {
                            Text(car.carModel + " Listings Near You").font(.custom("NotoSans-Regualr",size:24)).foregroundStyle(Color.black).padding(.top, 15).frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 45).padding(.trailing, 15).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            Form {
                                ForEach(0..<listingArr.count, id: \.self) { index in 
                                    if(listingArr[index].media != nil && listingArr[index].media!.photo_links != nil && listingArr[index].price != nil && listingArr[index].dist != nil && listingArr[index].build != nil && listingArr[index].build!.year != nil && listingArr[index].build!.trim != nil && listingArr[index].dealer != nil && listingArr[index].dealer!.name != nil && listingArr[index].dealer!.street != nil && listingArr[index].dealer!.city != nil && listingArr[index].dealer!.state != nil)
                                    {
                                        ZStack {
                                            Section {
                                                ZStack {
                                                    // Asynchronously load image
                                                    
                                                    VStack{
                                                        if let imageURL = URL(string: (listingArr[index].media!.photo_links!.count > 1 ? listingArr[index].media!.photo_links![1] : listingArr[index].media!.photo_links!.first) ?? "") {
                                                            AsyncImage(url: imageURL) { image in
                                                                image.resizable().aspectRatio(contentMode: .fill).frame(width: 350, height: 100, alignment: .center)
                                                            } placeholder: {
                                                                Image(systemName: "car.fill").resizable().aspectRatio(contentMode: .fill).frame(width: 350, height: 100, alignment: .center).font(.system(size:25, weight:.bold)).foregroundStyle(Color("NeonYellow")).background(Color("CharcoalColor"))
                                                            }
                                                            ZStack{
                                                                Rectangle().foregroundStyle(Color("CharcoalColor")).frame(height:110)
                                                                VStack{
                                                                    let titleCar:String = " \(car.carMake) \(car.carModel) \(listingArr[index].build!.trim!)"
                                                                    Text(String(listingArr[index].build!.year!) + titleCar).frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 25).font(.custom("NotoSans-Bold", size: 16)).foregroundStyle(Color.white)
                                                                    HStack{
                                                                        Text(String(format: "$%.0f",listingArr[index].price!)).font(.custom("NotoSans-Bold", size: 16)).foregroundStyle(Color.white)
                                                                        Text(String(format: "%.2f miles away",listingArr[index].dist!)).padding(.leading, 2.5).font(.custom("NotoSans-SemiBold", size: 16)).foregroundStyle(Color.white)
                                                                    }.frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 25)
                                                                    Text("\(listingArr[index].dealer!.name!)").frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 25).font(.custom("NotoSans-Bold", size: 16)).foregroundStyle(Color.white)
                                                                    Text("\(listingArr[index].dealer!.street!) \(listingArr[index].dealer!.city!) \(listingArr[index].dealer!.state!)").foregroundStyle(Color.white).font(.custom("NotoSans-Bold", size: 16)).foregroundStyle(Color.white).frame(maxWidth:.infinity, alignment:.leading).padding(.leading, 25)
                                                                }.frame(maxWidth:.infinity, alignment: .top)
                                                            }.ignoresSafeArea(edges:.bottom).frame(maxHeight:.infinity, alignment: .bottom)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        Spacer().frame(height:7.5)
                                    }
                                    
                                }.listRowSeparator(.hidden).clipShape(RoundedRectangle(cornerRadius:10))
                            }.scrollContentBackground(.hidden).frame(maxHeight:.infinity)
                        }
                    }
                    Spacer()
                }.ignoresSafeArea(edges:.bottom).frame(maxHeight:.infinity)
                
            case .restricted, .denied:  // Location services currently unavailable.
                // Insert code here of what should happen when Location services are NOT authorized
                Text("Current location data was restricted or denied.")
            case .notDetermined:        // Authorization not determined yet.
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
        }.navigationBarBackButtonHidden(true).navigationDestination(isPresented:$nav){
            MenuView(context: $context, cars: $cars, locAuth: locAuth)
        }
    }
    func requestNearbyCars(lonParam:String, latParam:String) {
        
        
        // Define closure for handling API response
        let handleResponse: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(nearby.self, from: data)
                DispatchQueue.main.async {
                    listingArr = decodedData.listings
                }
            } catch {
                print("Error decoding data:", error)
            }
        }
        DispatchQueue.main.async {
            self.find = false
        }
        var keyStr = ""
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String{
            keyStr = apiKey
        }
        let urlStr = "https://mc-api.marketcheck.com/v2/search/car/active?api_key=\(keyStr)&car_type=used&make=\(car.carMake)&model=\(car.carModel)&latitude=\(latParam)&longitude=\(lonParam)&radius=100&sort_by=dist&sort_order=asc&include_relevant_links=true"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            return
        }
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url, completionHandler: handleResponse)
        task.resume()
        
    }
    
    func updateCityArea(coord: CLLocationCoordinate2D)
    {
        DispatchQueue.main.async{
            self.cityArea = MKCoordinateRegion(center: coord, span:  MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            searchDealerships()
        }
    }
    
    func searchDealerships()
    {
        DispatchQueue.main.async{
            
            
            
            let searchRequest = MKLocalSearch.Request()
            
            searchRequest.naturalLanguageQuery = "\(self.car.carMake) Dealerships"
            
            searchRequest.region = self.cityArea
            
            MKLocalSearch(request: searchRequest).start { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error").")
                    return
                }
                self.cityArea = response.boundingRegion
                markers = response.mapItems.map { item in
                    Location(
                        
                        locName: item.name ?? "",
                        locCoords: item.placemark.coordinate
                    )
                }
            }
            self.notSearched = false
        }
    }
    
}
