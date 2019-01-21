//
//  BluetoothDeviceListController.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/21/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothDeviceListControllerDelegate: class {
    func bluetoothDeviceListControllerDidSelectDevice(_ identifier: String)
}

class BluetoothDeviceListController: UITableViewController, CBCentralManagerDelegate {
    
    let kRSSIThreshold: Double = -90

    var delegate: BluetoothDeviceListControllerDelegate?
    
    var manager: CBCentralManager?

    var devices = [CBPeripheral]()

    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CBCentralManager(delegate: self, queue: .main)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = devices[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = device.name ?? "(Unknown)"
        cell.detailTextLabel?.text = device.identifier.uuidString
        return cell
    }
    
    // MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        manager?.stopScan()
        
        let device = devices[indexPath.row]

        delegate?.bluetoothDeviceListControllerDidSelectDevice(device.identifier.uuidString)
    }

    
    // MARK: - Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.doubleValue < kRSSIThreshold {
            return
        }
        
        if devices.first(where: { $0.identifier == peripheral.identifier }) == nil {
            devices.append(peripheral)
            
            tableView.reloadData()
        }
    }

}
