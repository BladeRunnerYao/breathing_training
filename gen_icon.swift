import AppKit
import CoreGraphics

let size = 1024
let width = size
let height = size
let colorSpace = CGColorSpaceCreateDeviceRGB()

let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: bitmapInfo
)!

// Turquoise gradient background
let topColor = NSColor(calibratedRed: 0.78, green: 0.95, blue: 0.93, alpha: 1.0).cgColor
let bottomColor = NSColor(calibratedRed: 0.40, green: 0.84, blue: 0.80, alpha: 1.0).cgColor
let gradient = CGGradient(colorsSpace: colorSpace, colors: [topColor, bottomColor] as CFArray, locations: [0.0, 1.0])!
context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: width, y: 0), options: [])

let center = CGPoint(x: width / 2, y: height / 2)
let outerRadius = CGFloat(size) * 0.36
let innerRadius = CGFloat(size) * 0.26

// Outer ring
context.setStrokeColor(NSColor(calibratedRed: 0.10, green: 0.58, blue: 0.56, alpha: 0.95).cgColor)
context.setLineWidth(CGFloat(size) * 0.02)
context.strokeEllipse(in: CGRect(x: center.x - outerRadius, y: center.y - outerRadius, width: outerRadius * 2, height: outerRadius * 2))

// Inner glow
context.setFillColor(NSColor(calibratedRed: 0.20, green: 0.72, blue: 0.68, alpha: 0.30).cgColor)
context.fillEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2))

// Wave line
let waveY = center.y - CGFloat(size) * 0.12
let waveAmp = CGFloat(size) * 0.03
let waveLen = CGFloat(size) * 0.6
let startX = center.x - waveLen / 2
let endX = center.x + waveLen / 2

context.setStrokeColor(NSColor(calibratedRed: 0.08, green: 0.45, blue: 0.44, alpha: 0.95).cgColor)
context.setLineWidth(CGFloat(size) * 0.02)

let path = CGMutablePath()
let steps = 200
for i in 0...steps {
    let t = CGFloat(i) / CGFloat(steps)
    let x = startX + (endX - startX) * t
    let angle = t * 4 * CGFloat.pi
    let y = waveY + waveAmp * 0.5 * sin(angle)
    if i == 0 {
        path.move(to: CGPoint(x: x, y: y))
    } else {
        path.addLine(to: CGPoint(x: x, y: y))
    }
}
context.addPath(path)
context.strokePath()

let cgImage = context.makeImage()!
let rep = NSBitmapImageRep(cgImage: cgImage)
let data = rep.representation(using: .png, properties: [:])!

let outURL = URL(fileURLWithPath: "/Users/yao/Documents/breathing_training/BreathTraining/Assets.xcassets/AppIcon.appiconset/Icon-1024.png")
try data.write(to: outURL)
print("Wrote \(outURL.path)")
