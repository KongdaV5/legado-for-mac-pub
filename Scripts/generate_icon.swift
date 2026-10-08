#!/usr/bin/env swift

import AppKit
import Foundation

// 生成符合 macOS 图标习惯的 App 图标。
// 重点是保留透明圆角、避免满版方形底色，并让书页使用柔和的圆角和统一的光影。
func generateAppIcon(size: CGSize, outputPath: String) {
    let image = NSImage(size: size)
    image.lockFocus()

    let canvas = NSRect(origin: .zero, size: size)
    NSColor.clear.setFill()
    canvas.fill()

    let cornerRadius = size.width * 0.22
    let roundedRect = NSBezierPath(
        roundedRect: NSRect(
            x: size.width * 0.025,
            y: size.height * 0.025,
            width: size.width * 0.95,
            height: size.height * 0.95
        ),
        xRadius: cornerRadius,
        yRadius: cornerRadius
    )

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.24)
    shadow.shadowBlurRadius = size.width * 0.035
    shadow.shadowOffset = NSSize(width: 0, height: -size.width * 0.012)

    NSGraphicsContext.current?.saveGraphicsState()
    shadow.set()
    NSColor.black.withAlphaComponent(0.01).setFill()
    roundedRect.fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    let gradient = NSGradient(colors: [
        NSColor(red: 0.42, green: 0.64, blue: 0.98, alpha: 1.0),
        NSColor(red: 0.16, green: 0.34, blue: 0.78, alpha: 1.0)
    ])

    NSGraphicsContext.current?.saveGraphicsState()
    roundedRect.addClip()
    gradient?.draw(in: canvas, angle: 135)
    NSGraphicsContext.current?.restoreGraphicsState()

    // 用两张圆角书页表达阅读，不再叠加一个生硬的黑色圆形。
    let bookWidth = size.width * 0.56
    let bookHeight = size.height * 0.39
    let pageGap = size.width * 0.025
    let pageWidth = (bookWidth - pageGap) / 2
    let pageY = (size.height - bookHeight) / 2
    let leftPage = NSBezierPath(
        roundedRect: NSRect(
            x: (size.width - bookWidth) / 2,
            y: pageY,
            width: pageWidth,
            height: bookHeight
        ),
        xRadius: size.width * 0.055,
        yRadius: size.width * 0.055
    )
    let rightPage = NSBezierPath(
        roundedRect: NSRect(
            x: (size.width - bookWidth) / 2 + pageWidth + pageGap,
            y: pageY,
            width: pageWidth,
            height: bookHeight
        ),
        xRadius: size.width * 0.055,
        yRadius: size.width * 0.055
    )

    let pageShadow = NSShadow()
    pageShadow.shadowColor = NSColor.black.withAlphaComponent(0.17)
    pageShadow.shadowBlurRadius = size.width * 0.018
    pageShadow.shadowOffset = NSSize(width: 0, height: -size.width * 0.008)

    NSGraphicsContext.current?.saveGraphicsState()
    pageShadow.set()
    NSColor.white.withAlphaComponent(0.98).setFill()
    leftPage.fill()
    rightPage.fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    // 中缝使用低对比度阴影，保持书页的立体感但不制造硬边。
    let crease = NSBezierPath()
    crease.move(to: NSPoint(x: size.width / 2, y: pageY + size.width * 0.045))
    crease.curve(
        to: NSPoint(x: size.width / 2, y: pageY + bookHeight - size.width * 0.045),
        controlPoint1: NSPoint(x: size.width / 2 - size.width * 0.008, y: pageY + bookHeight * 0.35),
        controlPoint2: NSPoint(x: size.width / 2 + size.width * 0.008, y: pageY + bookHeight * 0.65)
    )
    crease.lineWidth = size.width * 0.012
    NSColor(red: 0.16, green: 0.34, blue: 0.78, alpha: 0.18).setStroke()
    crease.stroke()

    image.unlockFocus()

    // 保存为 PNG
    if let tiffData = image.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ 生成图标: \(outputPath)")
    }
}

// 生成不同尺寸的图标
let sizes: [(size: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

let basePath = "Resources/Assets.xcassets/AppIcon.appiconset"

for (size, scale) in sizes {
    let actualSize = CGFloat(size * scale)
    let filename = scale == 1 ? "icon_\(size)x\(size).png" : "icon_\(size)x\(size)@\(scale)x.png"
    let outputPath = "\(basePath)/\(filename)"
    generateAppIcon(size: CGSize(width: actualSize, height: actualSize), outputPath: outputPath)
}

print("✅ 所有图标生成完成")
