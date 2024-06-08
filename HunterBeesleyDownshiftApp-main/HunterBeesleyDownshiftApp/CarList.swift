//
//  CarList.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/18/24.
//



import Foundation
import SwiftData

struct mmtData : Decodable {
    var id : Int
    var make_model_id : Int
}

struct collData : Decodable {
    var pages : Int
}

struct queryResponse : Decodable {
    var collection : collData
    var data : [mmtData]?
}

struct innerMakeData : Decodable {
    var name : String
}

struct innerMMData: Decodable {
    var name : String
    var make : innerMakeData
}

struct mmtBodyData : Decodable {
    var make_model_id : Int
    var make_model:innerMMData
}

struct mmtMileageData : Decodable {
    var id:Int
    var make_model_id:Int
}

struct mileageDataEV : Decodable{
    var epa_combined_mpg_electric:Int
    var make_model_trim:mmtMileageData
}

struct mileageDataNonEV : Decodable {
    var combined_mpg:Int
    var make_model_trim:mmtMileageData
}

struct bodyData : Decodable {
    var seats : Int
    var make_model_trim : mmtBodyData
}

struct bodyQueryResponse : Decodable {
    var collection : collData
    var data : [bodyData]?
}

struct mileageQueryResponseEV : Decodable {
    var collection : collData
    var data : [mileageDataEV]?
}

struct mileageQueryResponseNonEV : Decodable {
    var collection : collData
    var data : [mileageDataNonEV]?
}

struct carInfoStruct {
    var makeStr : String?
    var modelStr : String?
    var mpgNum : Int?
    var seatNum : Int?
}

let gasTypes = ["flex-fuel (FFV)", "gas", "natural gas (CNG)"]
let electricTypes = ["electric", "electric (fuel cell)"]
let hybridTypes = ["hybrid", "mild hybrid", "plug-in hybrid"]


let vanType = [
    "Cargo Van",
    "Ext Cargo Van",
    "Ext Van",
    "Passenger Van",
    "Van"
]

let minivanType = [
    "Ext Cargo Minivan",
    "Ext Minivan",
    "Minivan"
]

let truckType = [
    "Truck (Access Cab)",
    "Truck (Cab Plus)",
    "Truck (Club Cab)",
    "Truck (Crew Cab)",
    "Truck (CrewMax)",
    "Truck (Double Cab)",
    "Truck (Extended Cab)",
    "Truck (King Cab)",
    "Truck (Mega Cab)",
    "Truck (Quad Cab)",
    "Truck (Regular Cab)",
    "Truck (SuperCab)",
    "Truck (SuperCrew)",
    "Truck (Xtracab)"
]

@Observable
class CarList{
    var modelContext:ModelContext
    var carList:[CarObject] = [CarObject]()
    var pageNum:Int = 1
    var pagesLen:Int = -1
    var makeModIdSet:Set<Int> = Set<Int>()
    var makeModTrimIdSet:Set<Int> = Set<Int>()
    var makeModData: [Int: carInfoStruct] = [:]
    var isEmpty = false
    var netIncrease:Double  = 0
    var filterParams:[FilterObject] = [FilterObject(style: "Hatchback", fuel: "Hybrid", seats: 4, mpg: 30)]
    
    init(context:ModelContext, delete: Bool){
        self.modelContext = context
        if(delete)
        {
            do {
                try self.modelContext.delete(model: CarObject.self)
                try self.modelContext.delete(model: FilterObject.self)
            } catch {
                print("Failed to delete CarObjects")
            }
        }
        self.fetchCars()
    }
    
    func fetchCars(){
        do {
            let fd = FetchDescriptor<CarObject>()
            carList = try modelContext.fetch(fd)
            let fr = FetchDescriptor<FilterObject>()
            filterParams = try modelContext.fetch(fr)
        } catch {
            print("Fetch failed")
        }
    }
    
    func getList(bodyParam: String, fuelParam: String)
    {
        for item in self.makeModIdSet
        {
            self.modelContext.insert(CarObject(make: self.makeModData[item]!.makeStr ?? "Make", model: self.makeModData[item]!.modelStr ?? "Model", style: bodyParam, fuel: fuelParam, seats: self.makeModData[item]!.seatNum ?? 0, mpg: self.makeModData[item]!.mpgNum ?? 0))
            self.fetchCars()
        }
        
    }
    
    func newFilters(style:String, fuel:String, mpg:Int, seats:Int)
    {
        do {
            try self.modelContext.delete(model: FilterObject.self)
            self.modelContext.insert(FilterObject(style: style, fuel: fuel, seats: seats, mpg: mpg))
            self.fetchCars()
        } catch {
            print("Failed to delete CarObjects")
        }
    }
    
    func requestEngineAndBody(fuel: String, mileage: Int, style : String, seats: Int) {
       
        var inBounds = true
        
        // Define closure for handling API response
        let handleResponse: (Data?, URLResponse?, Error?) -> Void = { [self] data, response, error in
            
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(queryResponse.self, from: data)
                DispatchQueue.main.async {
                    if self.self.pagesLen == -1 {
                        self.self.pagesLen = decodedData.collection.pages
                        //exit(0)
                    }
                    if(decodedData.data != nil)
                    {
                        for item in decodedData.data! {
                            self.makeModIdSet.insert(item.make_model_id)
                            self.makeModTrimIdSet.insert(item.id)
                            self.makeModData[item.make_model_id] = carInfoStruct(makeStr:nil, modelStr: nil, mpgNum: nil, seatNum: nil)
                        }
                    }
                    self.pageNum += 1
                    inBounds = (self.pageNum <= self.self.pagesLen)
                    if inBounds {
                        self.requestEngineAndBody(fuel: fuel, mileage: mileage, style: style, seats: seats)
                    } else {
                        print("API 1 request completed")
                        if(self.makeModIdSet.count > 0)
                        {
                            self.pageNum = 1
                            self.pagesLen = -1
                            self.requestMileageInfo(mpg: mileage, fuel: fuel, style: style, seats: seats)
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.isEmpty = true
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding data:", error)
            }
        }
        let urlStart = "https://carapi.app/api/trims?limit=1000&page=\(self.pageNum)&verbose=yes&json="
        var engineStr = ""
        switch fuel {
        case "Gas":
            engineStr = gasTypes.description
        case "Hybrid":
            engineStr = hybridTypes.description
        case "Electric":
            engineStr = electricTypes.description
        default:
            engineStr = [fuel].description
        }
        var styleStr = ""
        switch style {
        case "Truck":
            styleStr = truckType.description
        case "Minivan":
            styleStr = minivanType.description
        case "Van":
            styleStr = vanType.description
        default:
            styleStr = [style].description
        }
        let urlQuery = "[{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"}, {\"field\":\"engines.engine_type\", \"op\":\"in\", \"val\":\(engineStr)}, {\"field\":\"bodies.type\", \"op\":\"in\", \"val\":\(styleStr)}]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("AAAAAA:  [{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"}, {\"field\":\"engines.engine_type\", \"op\":\"in\", \"val\":\(engineStr)}, {\"field\":\"bodies.type\", \"op\":\"in\", \"val\":\(styleStr)}]")
        let urlString = urlStart + urlQuery
        print("Requesting URL:", urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url, completionHandler: handleResponse)
        task.resume()
        
    }
    
    var idMileageSet = Set<Int>()
    var trimIdMileageSet = Set<Int>()
    func requestMileageInfo(mpg: Int, fuel: String, style: String, seats: Int) {
        var inBounds = true
        
        // Define closure for handling API response
        let handleResponseEV: (Data?, URLResponse?, Error?) -> Void = { [self] data, response, error in
            
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                
                let decodedData = try JSONDecoder().decode(mileageQueryResponseEV.self, from: data)
                DispatchQueue.main.async {
                    if self.self.pagesLen == -1 {
                        self.self.pagesLen = decodedData.collection.pages
                        //exit(0)
                    }
                    if(decodedData.data != nil)
                    {
                        for item in decodedData.data! {
                            if(self.makeModTrimIdSet.contains(item.make_model_trim.id))
                            {
                                self.idMileageSet.insert(item.make_model_trim.make_model_id)
                                
                                if( self.makeModData[item.make_model_trim.make_model_id] != nil)
                                {
                                    self.makeModData[item.make_model_trim.make_model_id]!.mpgNum = item.epa_combined_mpg_electric
                                }
                            }
                        }
                    }
                    self.pageNum += 1
                    inBounds = (self.pageNum <= self.self.pagesLen)
                    if inBounds {
                        // Continue fetching if there are more pages
                        self.requestMileageInfo(mpg: mpg, fuel: fuel, style: style, seats: seats)
                    } else {
                        // Handle completion
                        print("API 2 request completed")
                        self.makeModIdSet = self.makeModIdSet.intersection(self.idMileageSet)
                        self.makeModTrimIdSet = self.makeModTrimIdSet.intersection(self.trimIdMileageSet)
                        if(self.makeModIdSet.count > 0)
                        {
                            self.pageNum = 1
                            self.pagesLen = -1
                            self.requestSeatsInfo(fuel: fuel, style: style, seats: seats)
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.isEmpty = true
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding data:", error)
            }
        }
        
        let handleResponseNonEV: (Data?, URLResponse?, Error?) -> Void = { [self] data, response, error in
            
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                
                let decodedData = try JSONDecoder().decode(mileageQueryResponseNonEV.self, from: data)
                DispatchQueue.main.async {
                    if self.self.pagesLen == -1 {
                        self.self.pagesLen = decodedData.collection.pages
                    }
                    if(decodedData.data != nil)
                    {
                        for item in decodedData.data! {
                            if(self.makeModTrimIdSet.contains(item.make_model_trim.id))
                            {
                                self.idMileageSet.insert(item.make_model_trim.make_model_id)
                                self.trimIdMileageSet.insert(item.make_model_trim.id)
                                if( self.makeModData[item.make_model_trim.make_model_id] != nil)
                                {
                                    self.makeModData[item.make_model_trim.make_model_id]!.mpgNum = item.combined_mpg
                                }
                            }
                        }
                    }
                    self.pageNum += 1
                    inBounds = (self.pageNum <= self.self.pagesLen)
                    if inBounds {
                        // Continue fetching if there are more pages
                        self.requestMileageInfo(mpg: mpg, fuel: fuel, style: style, seats: seats)
                    } else {
                        // Handle completion
                        print("API 2 request completed")
                        self.makeModIdSet = self.makeModIdSet.intersection(self.idMileageSet)
                        self.makeModTrimIdSet = self.makeModTrimIdSet.intersection(self.trimIdMileageSet)
                        if(self.makeModIdSet.count > 0)
                        {
                            self.pageNum = 1
                            self.pagesLen = -1
                            self.requestSeatsInfo(fuel: fuel, style: style, seats: seats)
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.isEmpty = true
                            }
                        }
                    }
                }
            } catch {
                print("Error decoding data:", error)
            }
        }
        
        let urlStart = "https://carapi.app/api/mileages?limit=1000&page=\(self.pageNum)&verbose=yes&json="
        var fuelStr = ""
        if fuel != "Electric"
        {
            fuelStr = "combined_mpg"
        }
        else
        {
            fuelStr = "epa_combined_mpg_electric"
        }
        let urlQuery = "[{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"}, {\"field\":\"\(fuelStr)\", \"op\":\">=\", \"val\":\(mpg)}, {\"field\":\"make_model_id\", \"op\":\"in\", \"val\":\(Array(self.makeModIdSet).description)}]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("[{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"}, {\"field\":\"\(fuelStr)\", \"op\":\">=\", \"val\":\(mpg)}, {\"field\":\"make_model_id\", \"op\":\"in\", \"val\":\(Array(self.makeModIdSet).description)}]")
        let urlString = urlStart + urlQuery
        print("Requesting URL:", urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let urlSession = URLSession.shared
        var task:URLSessionDataTask
        if(fuel != "Electric")
        {
            task = urlSession.dataTask(with: url, completionHandler: handleResponseNonEV)
        }
        else
        {
            task = urlSession.dataTask(with: url, completionHandler: handleResponseEV)
        }
        task.resume()
        
    }
    
    var idSeatSet = Set<Int>()
    func requestSeatsInfo(fuel: String, style : String, seats: Int) {
        
        var inBounds = true
        
        // Define closure for handling API response
        let handleResponse: (Data?, URLResponse?, Error?) -> Void = { [self] data, response, error in
            
            guard let data = data else {
                print("No data received:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(bodyQueryResponse.self, from: data)
                DispatchQueue.main.async {
                    if self.self.pagesLen == -1 {
                        self.self.pagesLen = decodedData.collection.pages
                        //exit(0)
                    }
                    if(decodedData.data != nil)
                    {
                        for item in decodedData.data! {
                            self.idSeatSet.insert(item.make_model_trim.make_model_id)
                            if( self.makeModData[item.make_model_trim.make_model_id] != nil)
                            {
                                self.makeModData[item.make_model_trim.make_model_id]!.makeStr = item.make_model_trim.make_model.make.name
                                self.makeModData[item.make_model_trim.make_model_id]!.modelStr = item.make_model_trim.make_model.name
                                self.makeModData[item.make_model_trim.make_model_id]!.seatNum = item.seats
                            }
                        }
                    }
                    self.pageNum += 1
                    inBounds = (self.pageNum <= self.self.pagesLen)
                    if inBounds {
                        self.requestSeatsInfo(fuel: fuel, style: style, seats: seats)
                    } else {
                        print("API 3 request completed")
                        self.makeModIdSet = self.makeModIdSet.intersection(self.idSeatSet)
                        self.getList(bodyParam: style, fuelParam: fuel)
                    }
                }
            } catch {
                print("Error decoding data:", error)
            }
        }
        
        let urlStart = "https://carapi.app/api/bodies?limit=1000&page=\(self.pageNum)&verbose=yes&json="
        let urlQuery = "[{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"},{\"field\":\"make_model_id\", \"op\":\"in\", \"val\":\(Array(self.makeModIdSet).description)}, {\"field\":\"seats\", \"op\":\">=\", \"val\":\(seats)}]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("[{\"field\":\"year\", \"op\":\">=\", \"val\":\"2015\"},{\"field\":\"year\", \"op\":\"<=\", \"val\":\"2020\"},{\"field\":\"make_model_id\", \"op\":\"in\", \"val\":\(Array(self.makeModIdSet).description)}, {\"field\":\"make_model_id\", \"op\":\"in\", \"val\":\(Array(self.makeModIdSet).description)}, {\"field\":\"seats\", \"op\":\">=\", \"val\":\(seats)}]")
        let urlString = urlStart + urlQuery
        print("Requesting URL:", urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url, completionHandler: handleResponse)
        task.resume()
        
    }
    
}
