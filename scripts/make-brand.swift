// Kansas Eats brand (final: Nick's decision 2026-11-07): the app icon is concept D of
// scripts/icon-concepts.swift, a bierock cut open (golden crust, pale crumb, beef and cabbage), on the Kansas navy; the shared Eats Ranked icon style,
// state-prompts/ICON-STYLE.md, no backing shape. No team or university marks (Jayhawk, Powercat, Shocker, Chiefs), no Oz imagery,
// no seal.
// Usage, from ks-eats/: swift scripts/make-brand.swift   -> KansasEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png,
// docs/ favicons and touch icons, docs/og.png. scripts/make-site.py draws the same mark as its inline SVG: change both together.
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let NAVY: UInt32 = 0x1B3A6B, CRUST: UInt32 = 0xE8A93A, BONE: UInt32 = 0xF4EBD0, BEEF: UInt32 = 0x8A5A3A, CABBAGE: UInt32 = 0xCFE0A0
let SUNFLOWER: UInt32 = 0xF2B705, SEED: UInt32 = 0x6B4423, FIELD: UInt32 = 0xE8C468

func R(_ s: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
    CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
}

/// D: a bierock cut open, from the front: the bun's cross-section (flat base, high dome) in golden crust, the pale crumb inside it,
/// the beef pocket and four pieces of cabbage. CoreGraphics y-up, s = canvas size. Identical to icon-concepts.swift's bierockOpen().
func bierock(_ c: CGContext, _ s: CGFloat) {
    c.setFillColor(rgb(CRUST))
    c.addPath(R(s, 0.14, 0.30, 0.72, 0.20, 0.07)); c.fillPath()
    c.fillEllipse(in: CGRect(x: 0.14 * s, y: 0.32 * s, width: 0.72 * s, height: 0.38 * s))
    c.setFillColor(rgb(BONE))
    c.addPath(R(s, 0.18, 0.34, 0.64, 0.16, 0.05)); c.fillPath()
    c.fillEllipse(in: CGRect(x: 0.18 * s, y: 0.36 * s, width: 0.64 * s, height: 0.30 * s))
    c.setFillColor(rgb(BEEF))
    c.fillEllipse(in: CGRect(x: 0.27 * s, y: 0.39 * s, width: 0.46 * s, height: 0.21 * s))
    c.setFillColor(rgb(CABBAGE))
    for (x, y) in [(0.37, 0.52), (0.46, 0.45), (0.55, 0.53), (0.63, 0.46)] as [(CGFloat, CGFloat)] {
        c.fillEllipse(in: CGRect(x: (x - 0.027) * s, y: (y - 0.027) * s, width: 0.054 * s, height: 0.054 * s))
    }
}

func render(_ n: Int, _ path: String, background: Bool) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: background ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    if background { ctx.setFillColor(rgb(NAVY)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n)) }
    bierock(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
render(1024, "KansasEats/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png", background: true)
try? FileManager.default.createDirectory(atPath: "docs", withIntermediateDirectories: true)
for (n, name) in [(512, "icon-512.png"), (192, "icon-192.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")] {
    render(n, "docs/" + name, background: true)
}

/// The share image (1200 x 630): navy, the bierock at the left, the name and tagline at the right, and the app's header band
/// along the bottom: a wheat-gold field with a row of sunflowers on the horizon (Theme.swift's Stripes).
func og(_ path: String) {
    let W = 1200, H = 630
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(NAVY)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let horizon: CGFloat = 40
    ctx.setFillColor(rgb(FIELD)); ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(W), height: horizon))
    var x: CGFloat = 20
    while x < CGFloat(W) {
        ctx.setFillColor(rgb(SUNFLOWER)); ctx.fillEllipse(in: CGRect(x: x - 15, y: horizon - 15, width: 30, height: 30))
        ctx.setFillColor(rgb(SEED)); ctx.fillEllipse(in: CGRect(x: x - 7, y: horizon - 7, width: 14, height: 14))
        x += 48
    }
    ctx.saveGState(); ctx.translateBy(x: 30, y: 70); bierock(ctx, 540); ctx.restoreGState()
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let title = NSFont(name: "AvenirNextCondensed-Heavy", size: 92) ?? NSFont.boldSystemFont(ofSize: 80)
    let sub = NSFont(name: "AvenirNextCondensed-DemiBold", size: 34) ?? NSFont.boldSystemFont(ofSize: 30)
    NSAttributedString(string: "KANSAS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 600, y: 370))
    NSAttributedString(string: "EATS", attributes: [.font: title, .foregroundColor: NSColor.white]).draw(at: NSPoint(x: 600, y: 276))
    NSAttributedString(string: "FRIED CHICKEN, BBQ & SLIDERS", attributes: [.font: sub, .foregroundColor: NSColor(srgbRed: 0.949, green: 0.718, blue: 0.020, alpha: 1)]).draw(at: NSPoint(x: 604, y: 226))
    NSGraphicsContext.restoreGraphicsState()
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
og("docs/og.png")
