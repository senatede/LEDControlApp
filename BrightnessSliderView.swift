import Cocoa

class BrightnessSliderView: NSView {
    var value: Double = 0.7 {
        didSet {
            needsDisplay = true
            UserDefaults.standard.set(value, forKey: "lastBrightness")
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadSavedBrightness()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        loadSavedBrightness()
    }

    private func loadSavedBrightness() {
        guard let saved = UserDefaults.standard.object(forKey: "lastBrightness") as? Double else { return }
        value = saved
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let cornerRadius: CGFloat = bounds.height / 2

        let trackPath = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
        NSColor.darkGray.withAlphaComponent(0.4).setFill()
        trackPath.fill()

        let knobRadius: CGFloat = bounds.height / 2 - 2
        let minKnobX = knobRadius + 2
        let maxKnobX = bounds.width - knobRadius - 2
        let knobCenter = CGPoint(x: minKnobX + CGFloat(value) * (maxKnobX - minKnobX), y: bounds.midY)

        let fillWidth = knobCenter.x + knobRadius
        let fillRect = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
        let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: cornerRadius, yRadius: cornerRadius)
        NSColor.white.setFill()
        fillPath.fill()

        let knobPath = NSBezierPath(ovalIn: CGRect(x: knobCenter.x - knobRadius, y: knobCenter.y - knobRadius, width: knobRadius * 2, height: knobRadius * 2))
        NSColor.white.setFill()
        
        NSGraphicsContext.saveGraphicsState()

        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: -2, height: 0)
        shadow.shadowBlurRadius = 2
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
        shadow.set()

        knobPath.fill()

        NSGraphicsContext.restoreGraphicsState()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.menuFont(ofSize: 10),
            .foregroundColor: NSColor(calibratedRed: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0)
        ]
        let fullString = "Brightness: \(Int((value * 100).rounded()))%"
        let size = fullString.size(withAttributes: attributes)
        let textRect = CGRect(x: 10, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
        fullString.draw(in: textRect, withAttributes: attributes)
    }

    override func mouseDown(with event: NSEvent) {
        updateValue(from: event)
    }

    override func mouseDragged(with event: NSEvent) {
        updateValue(from: event)
    }

    private func updateValue(from event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let rawValue = min(max(0.0, Double(location.x / bounds.width)), 1.0)
        let steps: [Double] = [0.01, 0.02, 0.03, 0.04, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0]
        if let nearest = steps.min(by: { abs($0 - rawValue) < abs($1 - rawValue) }) {
            value = nearest
        }
        sendAction()
    }

    var target: AnyObject?
    var action: Selector?

    private func sendAction() {
        if let target = target, let action = action {
            _ = target.perform(action, with: self)
        }
    }
}
