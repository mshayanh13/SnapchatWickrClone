//
//  MaterialButton.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/10/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).cgColor
        layer.shadowOpacity = 0.8 //Little less than fully opaque
        layer.shadowRadius = 5.0 // How much to blur
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0) // offset to right and going down
        
    }

}
