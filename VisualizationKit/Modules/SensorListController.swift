//
//  SensorListController.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

protocol SensorListControllerDelegate: class {

    func sensorListControllerDidClosed(_ viewController: SensorListController)

}

class SensorListController: UITableViewController {
    
    weak var delegate: SensorListControllerDelegate?
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - TableView datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SensorManager.shared.sensors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sensor = SensorManager.shared.sensors[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.imageView?.image = sensor.image
        cell.textLabel?.text = sensor.title
        cell.accessoryType = (indexPath.row == SensorManager.shared.selectedSensorIndex) ? .checkmark : .none
        return cell
    }
    
    // MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SensorManager.shared.selectedSensorIndex != indexPath.row {
            SensorManager.shared.selectedSensorIndex = indexPath.row
        }

        tableView.reloadData()
    }
    
    // MARK: - Action
    
    @IBAction func closeTapped(_ sender: Any) {
        delegate?.sensorListControllerDidClosed(self)
    }
    
}
