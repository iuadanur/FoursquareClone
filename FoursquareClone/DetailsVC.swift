//
//  DetailsVC.swift
//  FoursquareClone
//
//  Created by İbrahim Utku Adanur on 7.08.2023.
//

import UIKit
import MapKit
import Parse

class DetailsVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var detailsNameLabel: UILabel!
    
    @IBOutlet weak var detailsTypeLabel: UILabel!
    
    @IBOutlet weak var detailsAtmosphereLabel: UILabel!
    
    @IBOutlet weak var detailsMapView: MKMapView!
    
    var chosenPlaceId = ""
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromParse()
        detailsMapView.delegate = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic

        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
                                        NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .largeTitle)
                                        ]
        for navItem in(self.navigationController?.navigationBar.subviews)! {
             for itemSubView in navItem.subviews {
                 if let largeLabel = itemSubView as? UILabel {
                     largeLabel.text = self.title
                     largeLabel.numberOfLines = 0
                     largeLabel.lineBreakMode = .byWordWrapping
                 }
             }
        }
    }
    
    func getDataFromParse(){
        let query = PFQuery(className: "Places")
        query.whereKey("objectId", equalTo: chosenPlaceId)
        query.findObjectsInBackground { objects, error in
            if error != nil{
                
            }else{
                if objects != nil{
            
                    //OBJECTS
                    let myObject = objects![0]
                    
                    if let placeName = myObject.object(forKey: "name") as? String{
                        self.detailsNameLabel.text = placeName
                        self.title = placeName
                    }
                    if let placeType = myObject.object(forKey: "type") as? String{
                        self.detailsTypeLabel.text = placeType
                    }
                    if let placeAtmosphere = myObject.object(forKey: "atmosphere") as? String{
                        self.detailsAtmosphereLabel.text = placeAtmosphere
                    }
                    if let placeLatitude = myObject.object(forKey: "latitude") as? String{
                        if let placeLatitudeDouble = Double(placeLatitude){
                            self.chosenLatitude = placeLatitudeDouble
                        }
                    }
                    if let placeLongitude = myObject.object(forKey: "longitude") as? String{
                        if let placeLongitudeDouble = Double(placeLongitude){
                            self.chosenLongitude = placeLongitudeDouble
                        }
                    }
                    if let imageData = myObject.object(forKey: "image") as? PFFileObject{
                        imageData.getDataInBackground { data, error in
                            if error == nil{
                                if data != nil {
                                    self.imageView.image = UIImage(data: data!)
                                }
                            }
                        }
                    }
                    //MAPS
                    let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                    let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.detailsMapView.setRegion(region, animated: true)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = self.detailsNameLabel.text
                    annotation.subtitle = self.detailsTypeLabel.text
                    
                    self.detailsMapView.addAnnotation(annotation)
                }
            }
        }
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if self.chosenLatitude != 0.0 && self.chosenLongitude != 0.0 {
            let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.detailsNameLabel.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
}
