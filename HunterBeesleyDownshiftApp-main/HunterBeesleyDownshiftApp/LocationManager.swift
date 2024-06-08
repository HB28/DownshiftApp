//
//  LocationManager.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 4/14/24.
//

import Foundation
import CoreLocation

class LocationDataManager : NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init(){
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            authorizationStatus = .notDetermined
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            break
        case .restricted:
            authorizationStatus = .restricted
            break
        case .denied:
            authorizationStatus = .denied
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
