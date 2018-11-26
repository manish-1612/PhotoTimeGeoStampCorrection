//
//  LocationManager .swift
//  InnorideUserApp
//
//  Created by Manish Kumar on 23/05/17.
//  Copyright © 2017 Innofied Solution Pvt. Ltd. All rights reserved.
//

import Foundation
import CoreLocation


class LocationManager: NSObject {
    

    var locationManager = CLLocationManager()
    var currentAddress : String?
    var currentLocation: CLLocationCoordinate2D?{
        didSet{
            //getCurrentAddress(location: currentLocation!)
        }
    }
    
    var currentAuthorizationStatus:CLAuthorizationStatus = .notDetermined
    var timerForLocationUpdate : Timer?
   
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        initializeLocationSetup()
        //initializeTimerForLocationUpdate()

    }
    /**
     function to setup CLLocationManager for the application
     */
    
    func initializeLocationSetup(){
        
        currentAuthorizationStatus = CLLocationManager.authorizationStatus()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        askForAuthorization()
    }
    
    
    
    func askForAuthorization(){
        
        // user activated automatic authorization info mode
        if currentAuthorizationStatus == .notDetermined || currentAuthorizationStatus == .denied {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            //locationManager.requestAlwaysAuthorization()
            locationManager.requestAlwaysAuthorization()
        }else if currentAuthorizationStatus == .authorizedAlways {
            //Don't do anything
        }
        
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        guard let currentLocation = self.currentLocation else { return nil }
        return currentLocation
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        if CLLocationManager.significantLocationChangeMonitoringAvailable(){
            locationManager.startMonitoringSignificantLocationChanges()
        }

    }
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        if CLLocationManager.significantLocationChangeMonitoringAvailable(){
            locationManager.startMonitoringSignificantLocationChanges()
        }

        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    deinit {
        //stopUpdatingLocation()
    }

}

//MARK:- CLLocationManager Delegate
extension LocationManager : CLLocationManagerDelegate{
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
       
        
        currentLocation = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!,
                                                 longitude: (locations.last?.coordinate.longitude)!)
        
        if currentLocation != nil {
            //NotificationCenter.default.post(name: IRNotifications.locationUpdate.name, object: currentLocation)
            
        }

    }
    
    // Authorization Status Change
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        /*
        self.currentAuthorizationStatus = status
        NotificationCenter.default.post(name: IRNotifications.locationTrackAuthorizarionStatusUpdate.name, object: NSNumber(value: status.rawValue))
 */
        
        // Save the current status in user's settings
        //let driverState = DriverStateLocalStorage.shared.currentState
    }

}

/*
extension LocationManager{
    
    func getCurrentAddress(location: CLLocationCoordinate2D){
        if geocoder == nil {
           geocoder = GMSGeocoder()
        }
        geocoder?.reverseGeocodeCoordinate(location) { response, error in
            if error == nil && response != nil {
                
                if let address = response?.firstResult() {
                    
                    let lines = address.lines! as [String]
                    let address = lines.joined(separator: ", ")

                    self.currentAddress = address
                }
            }else if error != nil && response == nil {
                Log.e("error : \(error!.localizedDescription)")
            }
        }

    }
}
*/
/*
//MARK:- Location Updater
extension LocationManager{
    
    func initializeTimerForLocationUpdate(){
        
        timerForLocationUpdate = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(updateUserCurrentLocationToServer), userInfo: nil, repeats: true)
        timerForLocationUpdate?.fire()
    }
    
    
    @objc func updateUserCurrentLocationToServer(){
        
        guard let currentLocation = self.currentLocation else{
            return
        }

        let locationArray : [NSNumber] = [NSNumber(value: currentLocation.longitude), NSNumber(value: currentLocation.latitude)]
        let time = Utility.getISO8601DateString(date: Date())
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.appDependencies?.updateLocationToServer(location: locationArray, time: time)
        
    }
    
    
}
*/
