//
//  CellularSensor.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class CellularSensor: Sensor {
    
    var title = "Cellular"
    
    var image = UIImage(named: "Cellular")!
    
    var updateInterval: Double = 0.5
    
    func initialize() {
        
    }

    func start() {
        
    }
    
    func stop() {
        
    }
    
    func update() -> SensorData? {
        let strength = getCellularStrength()
        return SensorData(
            title:  String(format: "%d%%", Int(strength * 100)) ,
            value: strength,
            radius: 0.01,
            x: 0,
            y: 0,
            z: -0.15)
    }
    
    func refresh() {
        
    }
    
    // MARK: - Load Cellular Strength
    
    // Gist: jonahsiegle/Signal.swift
    // https://gist.github.com/jonahsiegle/ffb955b3ff88067fa499a0e6d70bf470
    
    private func getCellularStrength() -> Double {
        if let numberOfBars = getCellularStrengthiPhoneX() {
            return Double(numberOfBars) * 0.25
            
        }
        if let numberOfBars = getCellularStrengthNoniPhoneX() {
            return Double(numberOfBars) * 0.25
        }
        
        return 0.0
    }
    
    private func getCellularStrengthiPhoneX() -> Int? {
        guard let containerBar = UIApplication.shared.value(forKey: "statusBar") as? UIView else {
            return nil
        }
        
        guard let statusBarMorden = NSClassFromString("UIStatusBar_Modern"),
            containerBar.isKind(of: statusBarMorden),
            let statusBar = containerBar.value(forKey: "statusBar") as? UIView else {
                return nil
        }
        
        guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else {
            return  nil
        }
        
        var numberOfActiveBars: Int?
        
        for view in foregroundView.subviews {
            for v in view.subviews {
                if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarCellularSignalView"), v .isKind(of: statusBarWifiSignalView) {
                    if let val = v.value(forKey: "numberOfActiveBars") as? Int {
                        numberOfActiveBars = val
                        break
                    }
                }
            }
            
            if let _ = numberOfActiveBars {
                break
            }
        }
        
        return numberOfActiveBars
    }
    
    private func getCellularStrengthNoniPhoneX() -> Int? {
        guard let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView else {
            return nil
        }
        
        if let statusBarMorden = NSClassFromString("UIStatusBar_Modern"),
            statusBar.isKind(of: statusBarMorden) {
            return nil
        }
        
        guard let foregroundView = statusBar.value(forKey: "foregroundView") as? UIView else {
            return nil
        }
        
        var rssi: Int?
        
        for view in foregroundView.subviews {
            if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarSignalStrengthItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                if let val = view.value(forKey: "signalStrengthBars") as? Int {
                    rssi = val
                    break
                }
            }
        }
        
        return rssi
    }
    
}
