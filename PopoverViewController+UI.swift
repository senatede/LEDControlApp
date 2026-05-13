import Cocoa

extension PopoverViewController {

    // MARK: - Helpers

    func paddedImage(systemName: String) -> NSImage? {
        guard let image = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) else { return nil }
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        guard let configured = image.withSymbolConfiguration(config) else { return nil }
        let size = NSSize(width: 24, height: 24)
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        let drawRect = NSRect(
            x: (size.width - configured.size.width) / 2.0,
            y: (size.height - configured.size.height) / 2.0,
            width: configured.size.width,
            height: configured.size.height
        )
        configured.draw(in: drawRect)
        newImage.unlockFocus()
        newImage.isTemplate = true
        return newImage
    }

    // MARK: - Power Button

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

    // MARK: - Brightness Slider

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

    // MARK: - Expand Button

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

    // MARK: - Expanded UI

    func setupExpandedUI() {
        expandedContainer.wantsLayer = true
        expandedContainer.isHidden = true
        view.addSubview(expandedContainer)

        // Separator Line
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.boxType = .separator
        expandedContainer.addSubview(separatorLine)

        // Serial Port Label
        serialPort.translatesAutoresizingMaskIntoConstraints = false
        serialPort.isBordered = false
        serialPort.bezelStyle = .shadowlessSquare
        serialPort.title = "Serial port:"
        serialPort.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        serialPort.imagePosition = .imageLeft
        serialPort.alignment = .left
        (serialPort.cell as? NSButtonCell)?.highlightsBy = []
        serialPort.image = paddedImage(systemName: "cable.connector")
        serialPort.contentTintColor = .secondaryLabelColor
        expandedContainer.addSubview(serialPort)

        // Device Popup
        devicePopup.translatesAutoresizingMaskIntoConstraints = false
        devicePopup.target = self
        devicePopup.action = #selector(deviceSelected(_:))
        expandedContainer.addSubview(devicePopup)

        // Total Number of LEDs Label
        numLedsLabel.translatesAutoresizingMaskIntoConstraints = false
        numLedsLabel.isBordered = false
        numLedsLabel.bezelStyle = .shadowlessSquare
        numLedsLabel.title = "Total number of leds:"
        numLedsLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        numLedsLabel.imagePosition = .imageLeft
        numLedsLabel.alignment = .left
        (numLedsLabel.cell as? NSButtonCell)?.highlightsBy = []
        numLedsLabel.image = paddedImage(systemName: "circle.grid.2x2")
        numLedsLabel.contentTintColor = .secondaryLabelColor
        expandedContainer.addSubview(numLedsLabel)

        // Total Number of LEDs Field
        numLedsField.translatesAutoresizingMaskIntoConstraints = false
        numLedsField.stringValue = "114"
        numLedsField.alignment = .center
        numLedsField.bezelStyle = .roundedBezel
        numLedsField.drawsBackground = false
        numLedsField.delegate = self
        numLedsField.tag = 0
        expandedContainer.addSubview(numLedsField)

        // Horizontal Axis Label
        xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        xAxisLabel.isBordered = false
        xAxisLabel.bezelStyle = .shadowlessSquare
        xAxisLabel.title = "Horizontal axis:"
        xAxisLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        xAxisLabel.imagePosition = .imageLeft
        xAxisLabel.alignment = .left
        (xAxisLabel.cell as? NSButtonCell)?.highlightsBy = []
        xAxisLabel.image = paddedImage(systemName: "x.circle")
        xAxisLabel.contentTintColor = .secondaryLabelColor
        expandedContainer.addSubview(xAxisLabel)

        // Horizontal Axis Field
        xAxisField.translatesAutoresizingMaskIntoConstraints = false
        xAxisField.stringValue = "37"
        xAxisField.alignment = .center
        xAxisField.bezelStyle = .roundedBezel
        xAxisField.drawsBackground = false
        xAxisField.delegate = self
        xAxisField.tag = 1
        expandedContainer.addSubview(xAxisField)

        // Vertical Axis Label
        yAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        yAxisLabel.isBordered = false
        yAxisLabel.bezelStyle = .shadowlessSquare
        yAxisLabel.title = "Vertical Axis:"
        yAxisLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        yAxisLabel.imagePosition = .imageLeft
        yAxisLabel.alignment = .left
        (yAxisLabel.cell as? NSButtonCell)?.highlightsBy = []
        yAxisLabel.image = paddedImage(systemName: "y.circle")
        yAxisLabel.contentTintColor = .secondaryLabelColor
        expandedContainer.addSubview(yAxisLabel)

        // Vertical Axis Field
        yAxisField.translatesAutoresizingMaskIntoConstraints = false
        yAxisField.stringValue = "20"
        yAxisField.alignment = .center
        yAxisField.bezelStyle = .roundedBezel
        yAxisField.drawsBackground = false
        yAxisField.delegate = self
        yAxisField.tag = 2
        expandedContainer.addSubview(yAxisField)

        // Quit Button
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        quitButton.bezelStyle = .shadowlessSquare
        quitButton.isBordered = false
        quitButton.title = "Quit LEDControlApp"
        quitButton.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        quitButton.alignment = .center
        quitButton.layer?.borderWidth = 1
        quitButton.layer?.borderColor = NSColor.separatorColor.cgColor
        quitButton.target = self
        quitButton.action = #selector(quitApp)
        expandedContainer.addSubview(quitButton)

        // FPS Label
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        fpsLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        fpsLabel.textColor = .secondaryLabelColor
        expandedContainer.addSubview(fpsLabel)

        // Constraints relative to the expandedContainer
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor, constant: 25),
            separatorLine.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -25),
            separatorLine.topAnchor.constraint(equalTo: expandedContainer.topAnchor, constant: 10),

            serialPort.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor, constant: 20),
            serialPort.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),

            devicePopup.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -20),
            devicePopup.centerYAnchor.constraint(equalTo: serialPort.centerYAnchor),
            devicePopup.widthAnchor.constraint(equalToConstant: 160),

            numLedsLabel.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor, constant: 20),
            numLedsLabel.topAnchor.constraint(equalTo: serialPort.bottomAnchor, constant: 5),

            numLedsField.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -20),
            numLedsField.centerYAnchor.constraint(equalTo: numLedsLabel.centerYAnchor),
            numLedsField.widthAnchor.constraint(equalToConstant: 60),
            numLedsField.heightAnchor.constraint(equalToConstant: 22),

            xAxisLabel.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor, constant: 20),
            xAxisLabel.topAnchor.constraint(equalTo: numLedsLabel.bottomAnchor, constant: 5),

            xAxisField.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -20),
            xAxisField.centerYAnchor.constraint(equalTo: xAxisLabel.centerYAnchor),
            xAxisField.widthAnchor.constraint(equalToConstant: 60),
            xAxisField.heightAnchor.constraint(equalToConstant: 22),

            yAxisLabel.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor, constant: 20),
            yAxisLabel.topAnchor.constraint(equalTo: xAxisLabel.bottomAnchor, constant: 5),

            yAxisField.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -20),
            yAxisField.centerYAnchor.constraint(equalTo: yAxisLabel.centerYAnchor),
            yAxisField.widthAnchor.constraint(equalToConstant: 60),
            yAxisField.heightAnchor.constraint(equalToConstant: 22),

            quitButton.centerXAnchor.constraint(equalTo: expandedContainer.centerXAnchor),
            quitButton.topAnchor.constraint(equalTo: yAxisLabel.bottomAnchor, constant: 8),
            quitButton.widthAnchor.constraint(equalToConstant: 160),
            quitButton.heightAnchor.constraint(equalToConstant: 28),

            fpsLabel.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor, constant: -20),
            fpsLabel.centerYAnchor.constraint(equalTo: quitButton.centerYAnchor)
        ])
    }
}
