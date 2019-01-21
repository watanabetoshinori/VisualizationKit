//
//  MessageView.swift
//  VisualizationKit
//
//  Created by Watanabe Toshinori on 1/19/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

@IBDesignable
class MessageView: UIVisualEffectView {
    
    @IBOutlet weak var label: UILabel!
    
    internal var messageExpirationTimer: Timer?
    
    internal var startTimeOfLastMessage: TimeInterval?
    
    internal var expirationTimeOfLastMessage: TimeInterval?
    
    // MARK: - Initializing View

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 7
        clipsToBounds = true
    }

    // MARK: - Managing Message
    
    func display(_ message: String, expirationTime: TimeInterval) {
        startTimeOfLastMessage = Date().timeIntervalSince1970
        expirationTimeOfLastMessage = expirationTime
        
        DispatchQueue.main.async {
            self.label.text = message
            self.isHidden = false
            self.startExpirationTimer(duration: expirationTime)
        }
    }
    
    func clear() {
        let now = Date().timeIntervalSince1970
        
        if let startTimeOfLastMessage = startTimeOfLastMessage,
            let expirationTimeOfLastMessage = expirationTimeOfLastMessage,
            now - startTimeOfLastMessage < expirationTimeOfLastMessage {
            
            // Defer clearing the info label if the last message hasn't reached its expiration time.
            
            let timeToKeepLastMessageOnScreen = expirationTimeOfLastMessage - (now - startTimeOfLastMessage)
            startExpirationTimer(duration: timeToKeepLastMessageOnScreen)
            
        } else {
            // Otherwise hide the info label immediately.
            
            self.label.text = ""
            self.isHidden = true
        }
    }
    
    // MARK: - Managing Timers
    
    private func startExpirationTimer(duration: TimeInterval) {
        cancelExpirationTimer()
        
        messageExpirationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { (timer) in
            self.cancelExpirationTimer()
            self.label.text = ""
            self.isHidden = true
            
            self.startTimeOfLastMessage = nil
            self.expirationTimeOfLastMessage = nil
        }
    }
    
    private func cancelExpirationTimer() {
        messageExpirationTimer?.invalidate()
        messageExpirationTimer = nil
    }
    
}
