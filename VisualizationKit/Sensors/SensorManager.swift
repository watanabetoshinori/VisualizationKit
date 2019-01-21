//
//  SensorManager.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

protocol SensorManagerDelegate: class {
    
    func sensorManagerDidChangeSensor()
    
}

class SensorManager: NSObject {
    
    weak var delegate: SensorManagerDelegate?
    
    var sensors: [Sensor] = [
        WifiSensor(),
        CellularSensor(),
        MagneticSensor(),
        BluetoothSensor(),
        ]
    
    var selectedSensorIndex: Int = 0 {
        didSet {
            delegate?.sensorManagerDidChangeSensor()
        }
    }
    
    var sensor: Sensor {
        return sensors[selectedSensorIndex]
    }
    
    // MARK: - Initializing a Singleton
    
    static let shared = SensorManager()
    
    override private init() {
        
    }
    
}
