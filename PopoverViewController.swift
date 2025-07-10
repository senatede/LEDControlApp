import Cocoa

class PopoverViewController: NSViewController {

    var power: Bool = false {
        didSet {
            updatePowerButton()
        }
    }

    let powerButton = NSButton()
    let brightnessSlider = BrightnessSliderView(frame: .zero)
    let expandButton = NSButton()
    var isExpanded = false {
        didSet {
            updateExpandButton()
            updateExpandedContent()
        }
    }
    let expandedLabel = NSTextField(labelWithString: "Expanded menu")

    override func loadView() {
        // Set fixed size for the popover content view
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 70))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPowerButton()
        setupBrightnessSlider()
        setupExpandButton()
        setupExpandedLabel()
    }

    func setupPowerButton() {
        let iconSize = NSSize(width: 35, height: 35)
        powerButton.frame = NSRect(origin: CGPoint(x: 13, y: view.bounds.height - iconSize.height - 10), size: iconSize)
        powerButton.bezelStyle = .shadowlessSquare
        powerButton.isBordered = false
        powerButton.imageScaling = .scaleProportionallyDown
        powerButton.target = self
        powerButton.action = #selector(togglePower)
        updatePowerButton()
        view.addSubview(powerButton)
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
        let sliderWidth = view.bounds.width - 35 - 40
        let sliderHeight: CGFloat = 25
        brightnessSlider.frame = NSRect(x: 35 + 20, y: view.bounds.height - sliderHeight - 15, width: sliderWidth, height: sliderHeight)
        brightnessSlider.wantsLayer = true
        brightnessSlider.layer?.cornerRadius = sliderHeight / 2
        brightnessSlider.target = self
        brightnessSlider.action = #selector(brightnessChanged(_:))
        view.addSubview(brightnessSlider)
    }

    @objc func brightnessChanged(_ sender: BrightnessSliderView) {
        print("Brightness changed to \(sender.value)")
    }

    func setupExpandButton() {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 30
        let sliderFrame = brightnessSlider.frame
        let xPos = (view.bounds.width - buttonWidth) / 2
        let yPos = sliderFrame.origin.y - buttonHeight

        expandButton.frame = NSRect(x: xPos, y: yPos, width: buttonWidth, height: buttonHeight)
        expandButton.bezelStyle = .shadowlessSquare
        expandButton.isBordered = false
        expandButton.imageScaling = .scaleNone
        expandButton.imagePosition = .imageOnly
        expandButton.target = self
        expandButton.action = #selector(toggleExpanded)

        updateExpandButton()
        view.addSubview(expandButton)
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
        expandedLabel.frame = CGRect(x: 10, y: 50, width: 200, height: 20)
        expandedLabel.isHidden = true
        view.addSubview(expandedLabel)
    }

    func updateExpandedContent() {
        if isExpanded {
            expandedLabel.isHidden = false
            resizePopover(toHeight: 170)
        } else {
            expandedLabel.isHidden = true
            resizePopover(toHeight: 70)
        }

        let iconSize = NSSize(width: 35, height: 35)
        powerButton.frame.origin.y = view.bounds.height - iconSize.height - 10
        let sliderHeight: CGFloat = 25
        brightnessSlider.frame.origin.y = view.bounds.height - sliderHeight - 15
    }

    func resizePopover(toHeight height: CGFloat) {
        var frame = view.frame
        frame.size.height = height
        view.frame = frame
        // Inform popover container to resize
        if let popoverWindow = self.view.window {
            popoverWindow.setContentSize(frame.size)
        }
    }

    @objc func toggleExpanded() {
        isExpanded.toggle()
    }
}
