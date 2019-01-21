//
//  RoundedView.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    // MARK: - Initializing View
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 18
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
    
}
