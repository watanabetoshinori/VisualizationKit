//
//  VisualizationController+State.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import ARKit

extension VisualizationController {
    
    enum State {
        case startARSession
        case notReady
        case ready
    }
    
    func updateState(to newState: State) {
        guard let trackingState = sceneView.session.currentFrame?.camera.trackingState else {
            state = .startARSession
            return
        }
        
        switch (newState, trackingState) {
        case (.notReady, .normal):
            state = .ready
        case (.notReady, .limited),
             (.notReady, .notAvailable):
            state = .notReady
        case (.ready, .normal):
            state = .ready
        case (.ready, .limited),
             (.ready, .notAvailable):
            state = .notReady
        default:
            state = newState
        }
    }
    
    func updateState(with trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .notAvailable, .limited:
            state = .notReady
            
        case .normal:
            state = .ready
        }
    }
    
}
