import Foundation
import SwiftData

@Model
class FilterObject
{
    var bodyStyle:String = "Sedan"
    var carFuel:String = "Gas"
    var numSeats:Int
    var mpgOverall:Int
    
    init(style:String, fuel:String, seats:Int, mpg:Int)
    {
        self.bodyStyle = style
        self.carFuel = fuel
        self.numSeats = seats
        self.mpgOverall = mpg
    }
}
