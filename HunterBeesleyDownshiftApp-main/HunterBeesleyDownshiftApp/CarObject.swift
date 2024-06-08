//
//  CarObject.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/18/24.
//

import Foundation
import SwiftData

//["Gas", "Diesel", "Electric", "Hybrid"]
//["Sedan", "Coupe", "Hatchback", "Convertible", "SUV", "Crossover", "Wagon", "Minivan", "Van", "Truck"]

@Model
class CarObject
{
    var carMake:String
    var carModel:String
    var bodyStyle:String = "Sedan"
    var carFuel:String = "Gas"
    var numSeats:Int
    var mpgOverall:Int
    
    init(make:String, model:String, style:String, fuel:String, seats:Int, mpg:Int)
    {
        self.carMake = make
        self.carModel = model
        self.bodyStyle = style
        self.carFuel = fuel
        self.numSeats = seats
        self.mpgOverall = mpg
    }
}
