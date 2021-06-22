//
//  ViewController.swift
//  NewNode VPN
//
//  Created by Gregory Hazel on 7/9/19.
//  Copyright © 2019 Clostra. All rights reserved.
//

import os.log
import UIKit
import Network
import NetworkExtension


class ViewController: UIViewController {
    
    @IBOutlet var gradient: GradientView!
    @IBOutlet weak var powerButton: UIButton!
    @IBOutlet weak var spinner: SpinnerView!
    @IBOutlet weak var netGlobes: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet var statPeriods: [UIButton]!
    @IBOutlet var statTexts: [UILabel]!
    let monitor = NWPathMonitor()
    
    var selectedPeriod: TimeFrame.Period = .day
    var statistics: DataVolume = DataVolume(direct: 0, peer: 0) {
        didSet {
            updateStatistics()
        }
    }
    
    var toggleState: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "toggle")
        }
        set(newValue){
            UserDefaults.standard.set(newValue, forKey: "toggle")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLayout(animated: false)
        
        monitor.pathUpdateHandler = { path in
            self.update()
        }
        monitor.start(queue: .main)
        
        NotificationCenter.default.addObserver(self, selector:#selector(foreground), name:
                                                UIApplication.willEnterForegroundNotification, object: nil)
        
        update()
        if toggleState {
            stateChanged()
        }
    }
    
    func updateLayout(animated: Bool) {
        let on = toggleState
        let backgroundImage = on ? UIImage(named: "earth_globe") : UIImage(named: "gray_circle")
        powerButton.setBackgroundImage(backgroundImage, for: .normal)
        
        gradient.startColor = on ? UIColor(named:"gradient_on1")! : UIColor(named:"gradient_off1")!
        gradient.endColor = on ? UIColor(named:"gradient_on2")! : UIColor(named:"gradient_off2")!
        
        hint.text = NSLocalizedString(on ? "hint_connected" : "hint_disconnected", comment: "")
        
        if animated {
            netGlobes.alpha = on ? 0 : 1
            UIView.animate(withDuration: 0.5) {
                self.netGlobes.alpha = on ? 1 : 0
            }
        }
        
        updatePeriod()
    }
    
    func updatePeriod() {
        for button in statPeriods {
            button.underline(bold: button.tag == selectedPeriod.rawValue)
        }
        updateStatistics()
    }
    
    func updateStatistics() {
        let formatter = ByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        
        statTexts[0].text = NSLocalizedString("direct", comment: "") + formatter.string(fromByteCount: statistics.direct)
        statTexts[1].text = NSLocalizedString("peers", comment: "") + formatter.string(fromByteCount: statistics.peer)
    }
    
    @IBAction func infoTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let infoVC = storyboard.instantiateViewController(identifier: "InfoViewController")
        
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.modalTransitionStyle = .crossDissolve
        present(infoVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func waitForStop(_ manager: NETunnelProviderManager) {
        manager.loadFromPreferences(completionHandler: { (error: Error?) in
            self.update()
            if manager.connection.status == .disconnected {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.waitForStop(manager)
            }
        })
    }
    
    func enforceState(_ manager: NETunnelProviderManager) {
        os_log("manager.connection.status:%@ toggle:%@",
               String(manager.connection.status.rawValue), String(toggleState))
        if toggleState {
            do {
                os_log("starting...")
                try manager.connection.startVPNTunnel()
            } catch {
                os_log("Unexpected error %@", error.localizedDescription)
                manager.connection.stopVPNTunnel()
                self.waitForStop(manager)
            }
        } else {
            os_log("stopping...")
            manager.connection.stopVPNTunnel()
            self.waitForStop(manager)
        }
    }
    
    func stateChanged() {
        NETunnelProviderManager.loadAllFromPreferences { (managers: [NETunnelProviderManager]?, error: Error?) in
            guard let managers = managers else {
                os_log("loadAllFromPreferences %@", error?.localizedDescription ?? "")
                return
            }
            if managers.count == 0 {
                let manager = NETunnelProviderManager()
                let providerProtocol = NETunnelProviderProtocol()
                providerProtocol.providerBundleIdentifier = "com.newnode.vpn.tunnel"
                providerProtocol.serverAddress = "NewNode"
                manager.protocolConfiguration = providerProtocol
                manager.isEnabled = true
                manager.localizedDescription = "NewNode"
                
                manager.saveToPreferences(completionHandler: { (error: Error?) in
                    os_log("saveToPreferences %@", error?.localizedDescription ?? "")
                    manager.loadFromPreferences(completionHandler: { (error: Error?) in
                        os_log("loadFromPreferences %@", error?.localizedDescription ?? "")
                        self.enforceState(manager)
                    })
                })
            } else if managers.count > 0 {
                let manager = managers.first!
                self.enforceState(manager)
            }
            self.update()
        }
    }
    
    @IBAction func toggleTapped() {
        let oldToggleState = toggleState
        os_log("didTapSwitch %@ -> %@", String(oldToggleState), String(!oldToggleState))
        toggleState = !oldToggleState
        stateChanged()
        updateLayout(animated: true)
    }
    
    @IBAction func statPeriodTapped(_ sender: UIButton) {
        if let newPeriod = TimeFrame.Period(rawValue: sender.tag) {
            selectedPeriod = newPeriod
            updatePeriod()
        }
    }
    
    @objc func foreground() {
        stateChanged()
    }
    
    func update() {
        NETunnelProviderManager.loadAllFromPreferences { (managers: [NETunnelProviderManager]?, error: Error?) in
            guard let managers = managers else {
                os_log("loadAllFromPreferences %@", error?.localizedDescription ?? "")
                return
            }
            var status: NEVPNStatus = .disconnected
            if managers.count > 0 {
                let manager = managers.first!
                status = manager.connection.status
            }
            
            self.updateLayout(animated: false)
            self.label.text = statusAsText(status)
            
            if isTransitionalStatus(status) {
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
            }
            
            // todo: remove this sample code
            func getRandomValue() -> Int64 { Int64(pow(10.0, Double.random(in: 0...15))) }
            self.statistics = DataVolume(direct: getRandomValue(), peer: getRandomValue())
        }
    }
}


func isTransitionalStatus(_ status: NEVPNStatus) -> Bool {
    switch status {
    case .connecting, .reasserting, .disconnecting:
        return true
    default:
        return false
    }
}

func statusAsText(_ status: NEVPNStatus) -> String {
    let resource_title: String = {
        switch status {
        case .invalid: return "invalid"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .reasserting: return "reconnecting"
        case .disconnecting: return "disconnecting"
        @unknown default: return ""
        }
    }()
    //print(resource_title)
    return NSLocalizedString(resource_title, comment: "")
}

