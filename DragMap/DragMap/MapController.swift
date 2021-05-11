//
//  ViewController.swift
//  DragMap
//
//  Created by Ashwani Choudhary on 12/05/21.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController {
    @IBOutlet var locationLBL : UILabel!
    @IBOutlet var resetBTN : UIButton!

    @IBOutlet var mapper : MKMapView!{
        didSet{
            mapper.delegate = self
        }
    }
    var lastLattitude = 0.0
    var lastLongitude = 0.0
    let locationManager = CLLocationManager()

    public let pinView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    private var pinViewCenterYConstraint: NSLayoutConstraint!
    private var pinViewImageHeight: CGFloat {
        return pinView.image!.size.height
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pinView.image = UIImage(named: "gps")

        mapper.addSubview(pinView)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pinView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: pinView, attribute: .centerX, relatedBy: .equal, toItem: mapper, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        pinViewCenterYConstraint = NSLayoutConstraint(item: pinView, attribute: .centerY, relatedBy: .equal, toItem: mapper, attribute: .centerY, multiplier: 1, constant: -pinViewImageHeight / 2)
        pinViewCenterYConstraint.isActive = true
    }
 
    @IBAction func resetAction(_ sender : UIButton){
        self.getAddressFromLatLon(latitude: self.lastLattitude, withLongitude: self.lastLongitude)
        let center = CLLocationCoordinate2D(latitude: self.lastLattitude, longitude: self.lastLongitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapper.setRegion(region, animated: true)
    }
    func getAddressFromLatLon(latitude: Double, withLongitude longitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = latitude
        //21.228124
        let lon: Double = longitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        if lastLattitude == 0.0{
            lastLattitude = lat
        }
        if lastLongitude == 0.0{
            lastLongitude = lon
        }
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        if pm.count > 0 {
                                            let pm = placemarks![0]
                                            var addressString : String = ""
                                            if pm.subLocality != nil {
                                                addressString = addressString + pm.subLocality! + ", "
                                            }
                                            if pm.thoroughfare != nil {
                                                addressString = addressString + pm.thoroughfare! + ", "
                                            }
                                            if pm.locality != nil {
                                                addressString = addressString + pm.locality! + ", "
                                            }
                                            if pm.country != nil {
                                                addressString = addressString + pm.country! + ", "
                                            }
                                            if pm.postalCode != nil {
                                                addressString = addressString + pm.postalCode! + " "
                                            }
                                            
                                            print(addressString)
                                            
                                            self.locationLBL.text = addressString
                                        }
                                    })
        
    }
}

extension MapController : MKMapViewDelegate,CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

        print("didUpdateLocations")
        self.lastLattitude = locValue.latitude
        self.lastLongitude = locValue.longitude
        locationManager.stopUpdatingLocation()
        
        self.resetAction(resetBTN)
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        print("regionWillChangeAnimated")
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.pinView.frame.origin.y -= self.pinViewImageHeight / 2
            }, completion: nil)
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        print("regionDidChangeAnimated",mapView.centerCoordinate)
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.getAddressFromLatLon(latitude: mapView.centerCoordinate.latitude, withLongitude: mapView.centerCoordinate.longitude)
                self.pinView.frame.origin.y += self.pinViewImageHeight / 2
            }, completion: nil)
        }
    }
}
