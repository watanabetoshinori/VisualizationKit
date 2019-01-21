//
//  ARCameraTrackingState+recommendation.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import ARKit

extension ARCamera.TrackingState {
    
    var recommendation: String {
        switch self {
        case .notAvailable:
            return "Move device to Start."
        case .limited(.excessiveMotion):
            return "Slowing down your movement."
        case .limited(.insufficientFeatures):
            return "Pointing at a flat surface."
        case .limited(.initializing):
            return "Moving left or right."
        case .limited(.relocalizing):
            return "Returning to the location where you left off."
        default:
            return ""
        }
    }
    
}
