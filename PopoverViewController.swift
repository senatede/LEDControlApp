import Cocoa

class PopoverViewController: NSViewController {

    // MARK: - State

    var power: Bool = false {
        didSet { updatePowerButton() }
    }

    var isExpanded: Bool = false {
        didSet {
            updateExpandButton()
            updateExpandedContent()
        }
    }

    // MARK: - Views

    let powerButton     = NSButton()
    let brightnessSlider = BrightnessSliderView(frame: .zero)
    let expandButton    = NSButton()

    let expandedContainer = NSView(frame: NSRect(x: 0, y: 50, width: 300, height: 130))
    let separatorLine   = NSBox()
    let serialPort      = NSButton()
    let devicePopup     = NSPopUpButton()
    let numLedsLabel    = NSButton()
    let numLedsField    = NSTextField()
    let quitButton      = HoverButton()
    let fpsLabel        = NSTextField(labelWithString: "FPS: 0")

    // MARK: - Lifecycle

    override func loadView() {
        let height: CGFloat = isExpanded ? 180 : 70
        view = FlippedView(frame: NSRect(x: 0, y: 0, width: 300, height: height))
        view.wantsLayer = true
        preferredContentSize = NSSize(width: 300, height: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPowerButton()
        setupBrightnessSlider()
        setupExpandedUI()
        setupExpandButton()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        preferredContentSize = NSSize(width: 300, height: isExpanded ? 180 : 70)
    }

    // MARK: - UI State

    func updateExpandedContent() {
        let expanding = isExpanded
        let newHeight: CGFloat = expanding ? 180 : 70

        if expanding {
            expandedContainer.isHidden = false
        }

        // NSPopover natively animates its size change when preferredContentSize changes
        preferredContentSize = NSSize(width: 300, height: newHeight)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            expandedContainer.animator().alphaValue = expanding ? 1.0 : 0.0
        }, completionHandler: {
            if !expanding {
                self.expandedContainer.isHidden = true
            }
        })
    }

    // MARK: - Backend Integration

    /// Call this from the backend to update the displayed FPS counter.
    func updateFPS(_ fps: Int) {
        fpsLabel.stringValue = "FPS: \(fps)"
    }

    /// Call this from the backend to populate the serial device dropdown.
    func updateSerialDevices(_ devices: [String]) {
        devicePopup.removeAllItems()
        devicePopup.addItems(withTitles: devices)
        if let first = devices.first {
            devicePopup.selectItem(withTitle: first)
        }
    }
}
