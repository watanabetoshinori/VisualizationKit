//
//  VisualizationController.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreMotion

class VisualizationController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, SensorManagerDelegate, SensorListControllerDelegate {
    
    let kLightThreshold: CGFloat = 500
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var maskView: UIView!
    
    @IBOutlet weak var messageView: MessageView!
    
    @IBOutlet weak var refreshButton: RoundedButton!
    
    @IBOutlet weak var sensorButton: RoundedButton!
    
    @IBOutlet weak var recordButtonBackground: UIImageView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var recordView: UIView!
    
    @IBOutlet weak var sensorListView: UIView!
    
    @IBOutlet weak var sensorListViewBottomConstraint: NSLayoutConstraint!
    
    var sensorListController: SensorListController! {
        didSet {
            sensorListController.delegate = self
        }
    }
    
    var state: State = .startARSession {
        didSet {
            visualizationViewControllerDidChangeState(state)
        }
    }
    
    var limit: Limit? {
        didSet {
            if let limit = limit {
                messageView.display(limit.recommendation, expirationTime: 3.0)
            } else {
                messageView.clear()
            }
        }
    }

    var updateTimer: Timer?
    
    var isRecording = false {
        didSet {
            let imageName = isRecording ? "RecordFinish" : "RecordStart"
            recordButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification,  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification,  object: nil)
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        SensorManager.shared.delegate = self
        
        sensorButton.setImage(SensorManager.shared.sensor.image, for: .normal)

        // Make sure the application launches in .startARSession state.
        // Entering this state will run() the ARSession.
        updateState(to: .startARSession)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, segue.identifier) {
        case (let navigationController as UINavigationController, "LoadSensorListController"?):
            guard let viewController = navigationController.topViewController as? SensorListController else {
                return
            }
            sensorListController = viewController
        default:
            break
        }
    }
    
    // MARK: - Application lifecycle
    
    @objc func applicationWillResignActive(_ notification: Notification) {
        blurView?.isHidden = false
        
        messageView.isHidden = true
        
        sensorButton.isHidden = true
        refreshButton.isHidden = true
        recordButton.isHidden = true
        recordButtonBackground.isHidden = true
        
        // Stop recording
        if isRecording {
            recordTapped(recordButton)
        }
    }
    
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        blurView?.isHidden = true
        
        sensorButton.isHidden = false
        refreshButton.isHidden = false
        recordButton.isHidden = false
        recordButtonBackground.isHidden = false
    }
    
    // MARK: - Update State
    
    func visualizationViewControllerDidChangeState(_ state: State) {
        switch state {
        case .startARSession:
            print("State: Starting ARSession")
            
            limit = nil
            
            initializeScene()
            
        case .notReady:
            print("State: Not ready to scan")
            
        case .ready:
            print("State: Ready")
        }
    }
    
    // MARK: - Update TrackingState
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateState(with: camera.trackingState)
        
        switch camera.trackingState {
        case .notAvailable:
            limit = .notAvailable
            
        case .limited(let reason):
            limit = .cameraTracking(reason)
            
        case .normal:
            limit = nil
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        
        switch state {
        case .ready:
            if let lightEstimate = frame.lightEstimate, lightEstimate.ambientIntensity < kLightThreshold {
                limit = .tooDark
            }
        default:
            break
        }
    }
    
    // MARK: - SensorManager delegate
    
    func sensorManagerDidChangeSensor() {
        refreshTapped(refreshButton)
        
        sensorButton.setImage(SensorManager.shared.sensor.image, for: .normal)
        
        let sensor = SensorManager.shared.sensor
        sensor.initialize()
    }
    
    // MARK: - SensorListController delegate
    
    func sensorListControllerDidClosed(_ viewController: SensorListController) {
        hideSensorList()
    }
    
    // MARK: - Action

    @IBAction func sensorTapped(_ sender: Any) {
        showSensorList()
    }

    @IBAction func refreshTapped(_ sender: Any) {
        state = .startARSession
        
        // Stop recording
        if isRecording {
            recordTapped(recordButton)
        }
        
        let sensor = SensorManager.shared.sensor
        sensor.refresh()
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        let sensor = SensorManager.shared.sensor

        if isRecording {
            isRecording = false

            sensor.stop()

            updateTimer?.invalidate()
            updateTimer = nil
            
        } else {
            isRecording = true
            
            sensor.start()

            updateTimer = Timer.scheduledTimer(withTimeInterval: sensor.updateInterval, repeats: true, block: { (timer) in
                if let data = sensor.update() {
                    self.addSphere(with: data)
                    
                    // Uncomment to display title
                    // self.addText(with: data)
                }
            })
        }
    }
    
    // MARK: - Show and Hide Sensor List
    
    func showSensorList() {
        sensorListViewBottomConstraint.constant = 0
        
        maskView.isHidden = false
        maskView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.sensorButton.alpha = 0
            self.refreshButton.alpha = 0
            self.maskView.alpha = 1
            self.view.layoutIfNeeded()
            
        }) { (_) in
            self.sensorButton.isHidden = true
            self.refreshButton.isHidden = true
        }
    }
    
    func hideSensorList() {
        sensorButton.isHidden = false
        sensorButton.alpha = 0
        
        refreshButton.isHidden = false
        refreshButton.alpha = 0
        
        sensorListViewBottomConstraint.constant = -sensorListView.frame.height
        
        UIView.animate(withDuration: 0.5, animations: {
            self.sensorButton.alpha = 1
            self.refreshButton.alpha = 1
            self.maskView.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { (_) in
            self.maskView.isHidden = true
        }
    }

    // MARK: - ARKit
    
    func initializeScene() {
        // Make sure the SCNScene is cleared of any SCNNodes from previous scans.
        sceneView.scene = SCNScene()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        sceneView.session.run(configuration, options: .resetTracking)
        
        let node = SCNNode()
        node.light = SCNLight()
        node.light?.type = .omni
        node.position = SCNVector3(x: 0, y: 10, z: 10)
        sceneView.scene.rootNode.addChildNode(node)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
    }
    
    // MARK: - Add Object
    
    func addSphere(with data: SensorData) {
        guard let camera = sceneView.pointOfView else {
            return
        }

        let hue = CGFloat(data.value) * 100 / 255
        
        let node = SCNNode(geometry: SCNSphere(radius: CGFloat(data.radius)))
        node.position = camera.convertPosition(SCNVector3(data.x, data.y, data.z), to: nil)
        
        // Create the reflective material and apply it to the sphere
        let reflectiveMaterial = SCNMaterial()
        reflectiveMaterial.lightingModel = .physicallyBased
        reflectiveMaterial.metalness.contents = 0
        reflectiveMaterial.roughness.contents = 0
        reflectiveMaterial.diffuse.contents = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        node.geometry?.firstMaterial = reflectiveMaterial
        
        sceneView.scene.rootNode.addChildNode(node)
    }

    func addText(with data: SensorData) {
        guard let camera = sceneView.pointOfView else {
            return
        }

        let text = SCNText(string: data.title, extrusionDepth: 0)
        text.font = UIFont.systemFont(ofSize: 1)
        text.flatness = 0
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue

        let node = SCNNode(geometry: text)
        node.scale = SCNVector3(0.02, 0.02, 0.02)
        node.position = camera.convertPosition(SCNVector3(data.x, data.y - Float(data.radius / 2), data.z), to: nil)
        
        let max = text.boundingBox.max
        let min = text.boundingBox.min
        node.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2.0, 0, 0)
        
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = .all
        node.constraints = [constraint]
        
        sceneView.scene.rootNode.addChildNode(node)
    }

}
