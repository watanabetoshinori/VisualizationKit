//
//  MagneticSensor.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import CoreMotion

class MagneticSensor: Sensor {
    
    let kMagneticThreshold: Double = 100
    
    var title = "Magnetic"
    
    var image = UIImage(named: "Magnetic")!
    
    var updateInterval: Double = 0.25
    
    var motionManager = CMMotionManager()
    
    func initialize() {
        
    }

    func start() {
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func update() -> SensorData? {
        guard let motion = motionManager.deviceMotion else {
            return nil
        }
        
        let x = Double(motion.magneticField.field.x)
        let y = Double(motion.magneticField.field.y)
        let z = Double(motion.magneticField.field.z)
        let net = sqrt(x * x + y * y + z * z)
        
        if net < kMagneticThreshold {
            return nil
        }

        let strength = min(1, net / 1000)
        return SensorData(
            title: String(format: "%dµT", Int(net)),
            value: strength,
            radius: 0.005,
            x: 0,
            y: -0.1,
            z: 0)
    }
    
    func refresh() {
        
    }
    
}
