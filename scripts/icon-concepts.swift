// Kansas Eats icon concepts (2026-11-06; D and E added 2026-11-07), drawn in the shared Eats Ranked style (state-prompts/ICON-STYLE.md):
// one flat, level, centred food on the Kansas navy #1B3A6B (state-prompts/KANSAS_PROMPT.md), no backing shape, no text or texture, no team
// marks, no Oz imagery. Food hexes: fried crust #E8A93A, crust crags #C9781F, bone / crumb (wheat) #F4EBD0, bread #E3B66A, beef #8A5A3A,
// cabbage #CFE0A0.
//   A  a fried chicken drumstick, side view, lying level (retired 2026-11-07: Tennessee's live icon is a drumstick and Alabama's a chicken leg)
//   B  a bierock cut in half, front view: the bread round and its beef-and-cabbage filling (reads as a pie at 60 px)
//   C  an onion slider, side view: bun, onions, patty, bun (reads as any burger; Oklahoma's icon is an onion burger)
//   D  a bierock cut open, front view: a domed bun's golden crust, its pale crumb and the beef-and-cabbage filling
//   E  a wheat-bread loaf, side view: the Wheat State's loaf with three score marks and a darker base
// Usage, from ks-eats/: swift scripts/icon-concepts.swift <out dir>   -> concept-{a,b,c,d,e}-1024.png
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
}
let NAVY: UInt32 = 0x1B3A6B, CRUST: UInt32 = 0xE8A93A, CRAG: UInt32 = 0xC9781F, BONE: UInt32 = 0xF4EBD0
let BREAD: UInt32 = 0xE3B66A, BEEF: UInt32 = 0x8A5A3A, CABBAGE: UInt32 = 0xCFE0A0

/// A: the drumstick. CoreGraphics y-up, s = canvas size. Identical to make-brand.swift's drumstick().
func drumstick(_ c: CGContext, _ s: CGFloat) {
    func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
    // the bone first, so the crust's neck covers its left end: a shaft and a two-knob knuckle
    c.setFillColor(rgb(BONE))
    c.addPath(CGPath(roundedRect: CGRect(x: 0.62 * s, y: 0.440 * s, width: 0.20 * s, height: 0.080 * s), cornerWidth: 0.04 * s, cornerHeight: 0.04 * s, transform: nil))
    c.fillPath()
    c.fillEllipse(in: CGRect(x: 0.765 * s, y: 0.395 * s, width: 0.10 * s, height: 0.10 * s))
    c.fillEllipse(in: CGRect(x: 0.765 * s, y: 0.465 * s, width: 0.10 * s, height: 0.10 * s))
    // the crust: a round end at the left tapering into the neck
    c.setFillColor(rgb(CRUST))
    c.fillEllipse(in: CGRect(x: 0.145 * s, y: 0.295 * s, width: 0.49 * s, height: 0.37 * s))
    let neck = CGMutablePath()
    neck.move(to: P(0.56, 0.36))
    neck.addCurve(to: P(0.69, 0.445), control1: P(0.62, 0.38), control2: P(0.66, 0.43))
    neck.addLine(to: P(0.69, 0.515))
    neck.addCurve(to: P(0.56, 0.60), control1: P(0.66, 0.53), control2: P(0.62, 0.58))
    neck.closeSubpath()
    c.addPath(neck); c.fillPath()
    // three crags on the underside (darker faces down)
    c.setFillColor(rgb(CRAG))
    for (x, y) in [(0.26, 0.40), (0.38, 0.355), (0.50, 0.39)] as [(CGFloat, CGFloat)] {
        c.fillEllipse(in: CGRect(x: (x - 0.034) * s, y: (y - 0.034) * s, width: 0.068 * s, height: 0.068 * s))
    }
}

/// B: a bierock cut in half, from the front: the bread round, the filling inside it, four cabbage pieces.
func bierock(_ c: CGContext, _ s: CGFloat) {
    c.setFillColor(rgb(BREAD)); c.fillEllipse(in: CGRect(x: 0.14 * s, y: 0.27 * s, width: 0.72 * s, height: 0.42 * s))
    c.setFillColor(rgb(BEEF)); c.fillEllipse(in: CGRect(x: 0.24 * s, y: 0.34 * s, width: 0.52 * s, height: 0.26 * s))
    c.setFillColor(rgb(CABBAGE))
    for (x, y) in [(0.34, 0.47), (0.45, 0.42), (0.56, 0.49), (0.65, 0.44)] as [(CGFloat, CGFloat)] {
        c.fillEllipse(in: CGRect(x: (x - 0.036) * s, y: (y - 0.036) * s, width: 0.072 * s, height: 0.072 * s))
    }
}

/// C: an onion slider from the side: bottom bun, patty, onions, a domed top bun.
func slider(_ c: CGContext, _ s: CGFloat) {
    func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
        CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
    }
    c.setFillColor(rgb(BREAD)); c.addPath(R(0.14, 0.29, 0.72, 0.10, 0.04)); c.fillPath()   // the bottom bun
    c.setFillColor(rgb(BEEF)); c.addPath(R(0.15, 0.39, 0.70, 0.08, 0.04)); c.fillPath()    // the patty
    c.setFillColor(rgb(BONE)); c.addPath(R(0.16, 0.47, 0.68, 0.04, 0.02)); c.fillPath()    // the onions
    c.setFillColor(rgb(BREAD)); c.addPath(R(0.14, 0.51, 0.72, 0.18, 0.09)); c.fillPath()   // the domed top bun
}

func R(_ s: CGFloat, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) -> CGPath {
    CGPath(roundedRect: CGRect(x: x * s, y: y * s, width: w * s, height: h * s), cornerWidth: r * s, cornerHeight: r * s, transform: nil)
}

/// D: a bierock cut open, from the front: the bun's cross-section (flat base, high dome) in golden crust, the pale crumb inside it,
/// the beef pocket and four pieces of cabbage. CoreGraphics y-up, s = canvas size. Identical to make-brand.swift's bierock().
func bierockOpen(_ c: CGContext, _ s: CGFloat) {
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

/// E: a wheat-bread loaf from the side: a darker base, the domed golden loaf, three slanted score marks in the crumb colour.
func loaf(_ c: CGContext, _ s: CGFloat) {
    c.setFillColor(rgb(CRAG))
    c.addPath(R(s, 0.14, 0.30, 0.72, 0.12, 0.06)); c.fillPath()
    c.setFillColor(rgb(CRUST))
    c.addPath(R(s, 0.14, 0.345, 0.72, 0.16, 0.06)); c.fillPath()
    c.fillEllipse(in: CGRect(x: 0.14 * s, y: 0.345 * s, width: 0.72 * s, height: 0.35 * s))
    c.setStrokeColor(rgb(BONE)); c.setLineWidth(0.042 * s); c.setLineCap(.round)
    for x in [0.33, 0.48, 0.63] as [CGFloat] {
        c.move(to: CGPoint(x: (x - 0.04) * s, y: 0.50 * s)); c.addLine(to: CGPoint(x: (x + 0.05) * s, y: 0.61 * s)); c.strokePath()
    }
}

func render(_ n: Int, _ path: String, _ draw: (CGContext, CGFloat) -> Void) {
    let ctx = CGContext(data: nil, width: n, height: n, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.setFillColor(rgb(NAVY)); ctx.fill(CGRect(x: 0, y: 0, width: n, height: n))
    draw(ctx, CGFloat(n))
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(d, ctx.makeImage()!, nil)
    guard CGImageDestinationFinalize(d) else { fatalError("could not write \(path)") }
    print("wrote", path)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "playbook/brand"
render(1024, out + "/concept-a-1024.png", drumstick)
render(1024, out + "/concept-b-1024.png", bierock)
render(1024, out + "/concept-c-1024.png", slider)
render(1024, out + "/concept-d-1024.png", bierockOpen)
render(1024, out + "/concept-e-1024.png", loaf)
