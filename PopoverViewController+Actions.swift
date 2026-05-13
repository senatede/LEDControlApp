import Cocoa

extension PopoverViewController {

    @objc func togglePower() {
        power.toggle()
        if !power { powerOff() }
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
        print("Selected device: \(sender.titleOfSelectedItem ?? "")")
    }
}
