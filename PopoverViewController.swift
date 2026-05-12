import Cocoa

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

class PopoverViewController: NSViewController {

    var power: Bool = false {
        didSet {
            updatePowerButton()
        }
    }

    let powerButton = NSButton()
    let brightnessSlider = BrightnessSliderView(frame: .zero)
    let expandButton = NSButton()
    var isExpanded: Bool = false {
        didSet {
            updateExpandButton()
            updateExpandedContent()
        }
    }
    let expandedLabel = NSTextField(labelWithString: "Expanded menu")
    let devicePopup = NSPopUpButton()

    override func loadView() {
        let height: CGFloat = isExpanded ? 200 : 70
        let frame = NSRect(x: 0, y: 0, width: 300, height: height)
        self.view = FlippedView(frame: frame)
        self.preferredContentSize = NSSize(width: 300, height: height)
        resizePopover(toHeight: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPowerButton()
        setupBrightnessSlider()
        setupExpandButton()
        setupExpandedLabel()
        setupDevicePopup()
    }

    func setupPowerButton() {
        powerButton.translatesAutoresizingMaskIntoConstraints = false
        powerButton.bezelStyle = .shadowlessSquare
        powerButton.isBordered = false
        powerButton.imageScaling = .scaleProportionallyDown
        powerButton.target = self
        powerButton.action = #selector(togglePower)
        updatePowerButton()
        view.addSubview(powerButton)
        NSLayoutConstraint.activate([
            powerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            powerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            powerButton.widthAnchor.constraint(equalToConstant: 40),
            powerButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func updatePowerButton() {
        powerButton.image = NSImage(named: power ? "on" : "off")
    }

    @objc func togglePower() {
        power.toggle()
        updatePowerButton()
        if !power {
            powerOff()
        }
        print("Power is now \(power ? "ON" : "OFF")")
    }

    func powerOff() {
        print("Powering off")
    }

    func setupBrightnessSlider() {
        brightnessSlider.translatesAutoresizingMaskIntoConstraints = false
        brightnessSlider.wantsLayer = true
        brightnessSlider.layer?.cornerRadius = 25 / 2
        brightnessSlider.target = self
        brightnessSlider.action = #selector(brightnessChanged(_:))
        view.addSubview(brightnessSlider)
        NSLayoutConstraint.activate([
            brightnessSlider.leadingAnchor.constraint(equalTo: powerButton.trailingAnchor, constant: 9),
            brightnessSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            brightnessSlider.topAnchor.constraint(equalTo: powerButton.topAnchor, constant: 5),
            brightnessSlider.heightAnchor.constraint(equalToConstant: 33)
        ])
    }

    @objc func brightnessChanged(_ sender: BrightnessSliderView) {
        print("Brightness changed to \(sender.value)")
    }

    func setupExpandButton() {
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.bezelStyle = .shadowlessSquare
        expandButton.isBordered = false
        expandButton.imageScaling = .scaleNone
        expandButton.imagePosition = .imageOnly
        expandButton.target = self
        expandButton.action = #selector(toggleExpanded)
        updateExpandButton()
        view.addSubview(expandButton)
        NSLayoutConstraint.activate([
            expandButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            expandButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            expandButton.widthAnchor.constraint(equalToConstant: 40),
            expandButton.heightAnchor.constraint(equalToConstant: 10)
        ])
    }

    func updateExpandButton() {
        let imageName = isExpanded ? "up" : "down"
        if let original = NSImage(named: imageName) {
            let resized = NSImage(size: NSSize(width: 15, height: 5))
            resized.lockFocus()
            original.draw(in: NSRect(x: 0, y: 0, width: 15, height: 5),
                          from: NSRect(origin: .zero, size: original.size),
                          operation: .copy,
                          fraction: 1.0)
            resized.unlockFocus()
            expandButton.image = resized
        } else {
            expandButton.image = nil
        }
        expandButton.title = ""
    }

    func setupExpandedLabel() {
        expandedLabel.translatesAutoresizingMaskIntoConstraints = false
        expandedLabel.isHidden = true
        view.addSubview(expandedLabel)

        NSLayoutConstraint.activate([
            expandedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            expandedLabel.topAnchor.constraint(equalTo: powerButton.bottomAnchor, constant: 20)
        ])
    }

    func setupDevicePopup() {
        devicePopup.translatesAutoresizingMaskIntoConstraints = false
        devicePopup.addItems(withTitles: ["Device 1", "Device 2", "Device 3"])
        devicePopup.target = self
        devicePopup.action = #selector(deviceSelected(_:))
        devicePopup.isHidden = true
        view.addSubview(devicePopup)

        NSLayoutConstraint.activate([
            devicePopup.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            devicePopup.topAnchor.constraint(equalTo: expandedLabel.bottomAnchor, constant: 10),
            devicePopup.widthAnchor.constraint(equalToConstant: 150),
            devicePopup.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    @objc func deviceSelected(_ sender: NSPopUpButton) {
        print("Selected device: \(sender.titleOfSelectedItem ?? "")")
    }

    func updateExpandedContent() {
        if isExpanded {
            expandedLabel.isHidden = false
            devicePopup.isHidden = false
            resizePopover(toHeight: 200)
        } else {
            expandedLabel.isHidden = true
            devicePopup.isHidden = true
            resizePopover(toHeight: 70)
        }

    }

    func resizePopover(toHeight newHeight: CGFloat) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.preferredContentSize = NSSize(width: 300, height: newHeight)
        }
    }

    @objc func toggleExpanded() {
        isExpanded.toggle()
    }


    override func viewDidAppear() {
        super.viewDidAppear()
        resizePopover(toHeight: isExpanded ? 200 : 70)
    }
}

