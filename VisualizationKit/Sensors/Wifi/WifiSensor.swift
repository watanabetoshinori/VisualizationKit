//
//  WifiSensor.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class WifiSensor: Sensor {
    
    var title = "Wifi"
    
    var image = UIImage(named: "Wifi")!
    
    var updateInterval: Double = 0.5
    
    func initialize() {
        
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
    
    func update() -> SensorData? {
        let strength = getWifiStrength()
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
    
    // MARK: - Load Wifi Strength
    
    // Stackoverflow: Using Private API To read WiFi RSSI Value
    // https://stackoverflow.com/a/48083845
    
    private func getWifiStrength() -> Double {
        if let numberOfBars = getWiFiNumberOfActiveBars() {
            return Double(numberOfBars) * 0.33
            
        } else if let RSSI = getWiFiRSSI() {
            return (min(-30, Double(RSSI)) + 90) / 60
        }
        
        return 0.0
    }
    
    private func getWiFiNumberOfActiveBars() -> Int? {
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
                if let statusBarWifiSignalView = NSClassFromString("_UIStatusBarWifiSignalView"), v .isKind(of: statusBarWifiSignalView) {
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
    
    private func getWiFiRSSI() -> Int? {
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
            if let statusBarDataNetworkItemView = NSClassFromString("UIStatusBarDataNetworkItemView"), view .isKind(of: statusBarDataNetworkItemView) {
                if let val = view.value(forKey: "wifiStrengthRaw") as? Int {
                    rssi = val
                    break
                }
            }
        }
        
        return rssi
    }
    
}
