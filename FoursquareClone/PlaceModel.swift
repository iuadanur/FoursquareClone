//
//  PlaceModel.swift
//  FoursquareClone
//
//  Created by İbrahim Utku Adanur on 7.08.2023.
//

import Foundation
import UIKit
class PlaceModel {
    
    static let sharedInstance = PlaceModel()
    
    var placeName = ""
    var placeType = ""
    var placeAtmosphere = ""
    var placeImage = UIImage()
    var placeLatitude = ""
    var placeLongitude = ""
    
    private init(){}
}
