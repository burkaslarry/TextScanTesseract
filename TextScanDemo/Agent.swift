//
//  User.swift
//  TaxIRD
//
//  Created by Larry Lo Wai Lun on 12/9/2017.
//  Copyright © 2017 Larry Lo Wai Lun. All rights reserved.
//

import UIKit

class Agent : NSObject {
    
    static let sharedInstance = Agent  ()
    
    var scannedItem : [String] = []
    var scannedImage : UIImage? = nil
    
    
    private override init() {
        print("init...")
    }
 
    
    func setScannedlist ( list : [String] ) {
        scannedItem  = list
    }
    
    func capImage(captured :  UIImage  ) {
        scannedImage = captured
    }
    
    
}
