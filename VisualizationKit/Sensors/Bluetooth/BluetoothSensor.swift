//
//  BluetoothSensor.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/21/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothSensor: NSObject, Sensor, CBCentralManagerDelegate, BluetoothDeviceListControllerDelegate {
    
    var title = "Bluetooth"
    
    var image = UIImage(named: "Bluetooth")!
    
    var updateInterval: Double = 0.5
    
    var manager: CBCentralManager?
    
    var identifier: String?

    var RSSI: Double = 0.0
    
    func initialize() {
        if manager == nil {
            manager = CBCentralManager(delegate: self, queue: .main)
        }

        showDeviceListAlert()
    }
    
    func start() {
        if identifier == nil {
            return
        }

        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stop() {
        manager?.stopScan()
    }
    
    func update() -> SensorData? {
        if identifier == nil {
            return nil
        }

        let value = (min(-30, Double(RSSI)) + 90) / 60
        return SensorData(
            title:  String(format: "%.2f%", RSSI) ,
            value: value,
            radius: 0.01,
            x: 0,
            y: 0,
            z: -0.15)
    }
    
    func refresh() {

    }
    
    // MARK: - CBCentralManager Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier.uuidString == identifier {
            self.RSSI = RSSI.doubleValue
        }
    }
    
    // MARK: - Bluetooth List Delegate
    
    func bluetoothDeviceListControllerDidSelectDevice(_ identifier: String) {
        self.identifier = identifier
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        start()
    }
    
    // MARK: - Show Bluetooth List
    
    func showDeviceListAlert() {
        let alertController = UIAlertController(title: "Select Device", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        let viewController = UIStoryboard(name: "Bluetooth", bundle: nil).instantiateInitialViewController() as! BluetoothDeviceListController
        viewController.delegate = self
        viewController.preferredContentSize = CGSize(width: 272, height: 176)
        alertController.setValue(viewController, forKey: "contentViewController")
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
