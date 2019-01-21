//
//  Sensor.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

protocol Sensor {
    
    var title: String { get }
    
    var image: UIImage { get }
    
    var updateInterval: Double { get }
    
    func initialize()
    
    func start()
    
    func stop()
    
    func update() -> SensorData?
    
    func refresh()

}
