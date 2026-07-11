import Foundation
import CoreLocation
internal import Combine


final class LocationService: NSObject,
                              ObservableObject,
                              CLLocationManagerDelegate {


    static let shared = LocationService()


    private let manager = CLLocationManager()



    @Published var currentLocation: CLLocationCoordinate2D?



    @Published var authorizationStatus:
    CLAuthorizationStatus = .notDetermined





    private override init() {

        super.init()


        manager.delegate = self


        manager.desiredAccuracy =
        kCLLocationAccuracyBest


        authorizationStatus =
        manager.authorizationStatus

    }






    func requestPermission() {


        print("REQUEST LOCATION PERMISSION")


        switch manager.authorizationStatus {


        case .notDetermined:


            manager.requestWhenInUseAuthorization()



        case .authorizedWhenInUse,
             .authorizedAlways:


            startUpdatingLocation()



        case .denied:


            print(
                "LOCATION DENIED - Open Settings"
            )



        case .restricted:


            print(
                "LOCATION RESTRICTED"
            )



        @unknown default:

            break

        }

    }







    private func startUpdatingLocation() {


        print(
            "START GPS"
        )


        manager.startUpdatingLocation()


    }








    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {


        authorizationStatus =
        manager.authorizationStatus



        print(
            "AUTH STATUS:",
            authorizationStatus.rawValue
        )



        if authorizationStatus == .authorizedWhenInUse ||
           authorizationStatus == .authorizedAlways {


            startUpdatingLocation()

        }

    }








    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {


        guard let location =
                locations.last

        else {

            return

        }



        let coordinate =
        location.coordinate



        print(
            """
            ======================

            GPS LOCATION FOUND

            Latitude:
            \(coordinate.latitude)

            Longitude:
            \(coordinate.longitude)

            ======================
            """
        )



        DispatchQueue.main.async {


            self.currentLocation =
            coordinate


        }


    }








    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {


        print(
            "GPS ERROR:",
            error.localizedDescription
        )

    }


}
