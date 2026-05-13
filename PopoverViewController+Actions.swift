import Cocoa

extension PopoverViewController {

    @objc func togglePower() {
        power.toggle()
        if !power { powerOff() }
        UserDefaults.standard.set(power, forKey: "powerState")
        print("Power is now \(power ? "ON" : "OFF")")
    }

    func powerOff() {
        print("Powering off")
    }

    @objc func brightnessChanged(_ sender: BrightnessSliderView) {
        print("Brightness changed to \(sender.value)")
    }

    @objc func toggleExpanded() {
        isExpanded.toggle()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc func deviceSelected(_ sender: NSPopUpButton) {
        let selected = sender.titleOfSelectedItem ?? ""
        UserDefaults.standard.set(selected, forKey: "selectedPort")
        print("Selected device: \(selected)")
    }

    func loadSettings() {
        let defaults = UserDefaults.standard
        
        // Power state
        power = defaults.bool(forKey: "powerState")
        
        // LED Dimensions
        if let total = defaults.string(forKey: "totalLEDs") {
            numLedsField.stringValue = total
        }
        if let x = defaults.string(forKey: "xAxis") {
            xAxisField.stringValue = x
        }
        if let y = defaults.string(forKey: "yAxis") {
            yAxisField.stringValue = y
        }
    }
}

// MARK: - LED Dimension Formula (2x + 2y = total)

extension PopoverViewController: NSTextFieldDelegate {

    func controlTextDidEndEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }

        switch field.tag {
        case 0: // total changed — round down to multiple of 2 and preserve ratio
            var total = Int(numLedsField.stringValue) ?? 0
            total = (total / 2) * 2
            numLedsField.stringValue = "\(total)"
            
            let oldX = Double(Int(xAxisField.stringValue) ?? 1)
            let oldY = Double(Int(yAxisField.stringValue) ?? 1)
            let sum = oldX + oldY
            let targetSum = Double(total) / 2.0
            
            if sum > 0 {
                let newX = Int(round(targetSum * (oldX / sum)))
                let newY = Int(targetSum) - newX
                xAxisField.stringValue = "\(newX)"
                yAxisField.stringValue = "\(newY)"
            }

        case 1: // x changed — recalculate y
            let total = Int(numLedsField.stringValue) ?? 0
            let x = Int(xAxisField.stringValue) ?? 0
            let y = max(0, (total - 2 * x) / 2)
            yAxisField.stringValue = "\(y)"
            // Ensure total remains consistent (2x + 2y = total)
            numLedsField.stringValue = "\(2 * x + 2 * y)"

        case 2: // y changed — recalculate x
            let total = Int(numLedsField.stringValue) ?? 0
            let y = Int(yAxisField.stringValue) ?? 0
            let x = max(0, (total - 2 * y) / 2)
            xAxisField.stringValue = "\(x)"
            // Ensure total remains consistent (2x + 2y = total)
            numLedsField.stringValue = "\(2 * x + 2 * y)"

        default:
            break
        }
        
        // Save current values
        UserDefaults.standard.set(numLedsField.stringValue, forKey: "totalLEDs")
        UserDefaults.standard.set(xAxisField.stringValue, forKey: "xAxis")
        UserDefaults.standard.set(yAxisField.stringValue, forKey: "yAxis")
    }
}
