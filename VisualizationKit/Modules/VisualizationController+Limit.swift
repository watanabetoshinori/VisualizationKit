//
//  VisualizationController+Limit.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import ARKit

extension VisualizationController {
    
    enum Limit {
        case notAvailable
        case cameraTracking(ARCamera.TrackingState.Reason)
        case tooDark
        
        var recommendation: String {
            switch self {
            case .cameraTracking(.excessiveMotion):
                return "Slowing down your movement."
            case .cameraTracking(.insufficientFeatures):
                return "Pointing at a flat surface."
            case .cameraTracking(.initializing):
                return "Moving left or right."
            case .cameraTracking(.relocalizing):
                return "Returning to the location where you left off."
            case .tooDark:
                return "More light required."
            default:
                return ""
            }
        }
        
    }
    
}
