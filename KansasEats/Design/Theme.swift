import SwiftUI
import UIKit
import CoreText

/// Kansas palette (provisional, 2026-11-06; Nick decides, playbook/05-naming.md), light only. KU (crimson and blue), K-State (purple)
/// and Wichita State (black and gold) split the state, and the Chiefs and Royals play in Missouri, so the colors are the state's own
/// (state-prompts/KANSAS_PROMPT.md): flag-inspired navy #1B3A6B (11.3:1 on white) for titles, tint and accents; prairie green #4F6B2F
/// (white on it 6.0:1) for the hand-checked guide cards; sunflower gold #F2B705 only as a pin and card fill under navy text (6.2:1; as
/// text on white it's 1.8:1); sunflower-seed brown #6B4423 (8.5:1) for honors chips; wheat #F4EBD0 pages. The names `green`/`gold` are
/// kept from Wisconsin Eats so the shared views read the same; here `green` is navy and `gold` is prairie green.
enum Theme {
    static let green = Color(hex: 0x1B3A6B)      // navy: titles, tint, primary text accents
    static let green2 = Color(hex: 0x2C4F7F)
    static let gold = Color(hex: 0x4F6B2F)       // prairie green: card fills under white text, chips
    static let goldSoft = Color(hex: 0xE3EAD6)   // soft prairie
    static let lime = Color(hex: 0xF2B705)       // sunflower gold, fills only (hand-checked pins, the title shadow), under navy text
    static let limeSoft = Color(hex: 0xFBEBB5)
    static let sand = Color(hex: 0xF4EBD0)       // the Home background, wheat
    static let red = Color(hex: 0x6B4423)        // honors chips, sunflower-seed brown
    static let sandstone = Color(hex: 0x6B4423)
    static let teal = Color(hex: 0x2F6B5E)       // accent (6.2:1 on white)
    static let ink = Color(hex: 0x1A1A1A)
    static let ink2 = Color(hex: 0x2E3440)
    static let muted = Color(hex: 0x5B6270)
    static let surface = Color.white
    static let surface2 = Color(hex: 0xEEE4C8)
    static let surface3 = Color(hex: 0xE2D7B8)
    static let rule = Color(hex: 0xE2D7B8)
    static let rule2 = Color(hex: 0xC9BC98)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// A small uppercase label: "STONE CRAB", "1 MICHELIN STAR".
struct Chip: View {
    enum Style { case gold, green, red, plain, dashed }
    let text: String
    var style: Style = .plain

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .foregroundStyle(style == .green || style == .red ? Color.white : style == .dashed ? Theme.muted : style == .gold ? Theme.ink : Theme.green)
            .background {
                RoundedRectangle(cornerRadius: 5).fill(style == .gold ? Theme.goldSoft : style == .green ? Theme.green : style == .red ? Theme.red
                                                       : style == .dashed ? .clear : Theme.surface2)
            }
            .overlay {
                if style == .dashed { RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.rule2, style: StrokeStyle(lineWidth: 1, dash: [3, 2])) }
            }
            .accessibilityLabel(text)
    }
}

/// Kansas Eats' lettering: the system face drawn compressed and heavy for titles and guide names (like a show poster), and the
/// system monospaced face for numbers, dates and small labels. No bundled fonts.
struct DisplayFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .black
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight).width(.compressed))
    }
}

/// Numbers, dates and small labels in the system monospaced face, scaled like DisplayFont.
struct MonoFont: ViewModifier {
    let size: CGFloat
    var weight: Font.Weight = .semibold
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content.font(.system(size: size * min(scale, 1.6), weight: weight, design: .monospaced))
    }
}

extension View {
    func displayFont(_ size: CGFloat, weight: Font.Weight = .black) -> some View {
        modifier(DisplayFont(size: size, weight: weight))
    }

    func monoFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        modifier(MonoFont(size: size, weight: weight))
    }
}

/// The header band: the horizon, a navy sky over a wheat-gold field with a row of sunflowers on the line between them.
struct Stripes: View {
    var height: CGFloat = 6

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height, horizon = h * 0.42
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: horizon)), with: .color(Theme.green))
            ctx.fill(Path(CGRect(x: 0, y: horizon, width: w, height: h - horizon)), with: .color(Color(hex: 0xE8C468)))
            // sunflowers: gold heads with brown centres, evenly spaced along the horizon
            let r = h * 0.30, gap = r * 3.2
            var x = gap / 2
            while x < w {
                ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: horizon - r, width: 2 * r, height: 2 * r)), with: .color(Theme.lime))
                ctx.fill(Path(ellipseIn: CGRect(x: x - r * 0.45, y: horizon - r * 0.45, width: r * 0.9, height: r * 0.9)), with: .color(Theme.red))
                x += gap
            }
        }
        .frame(height: height * 2.4)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
    }
}

extension View {
    /// An inline navigation title in the display type. UINavigationBar.appearance() didn't reach every SwiftUI bar on iOS 27
    /// (the Map title went from compressed blue to plain black after a push and pop; place titles were always plain), so the
    /// title is our own view in the bar. The navigation title is still set, for the back button and VoiceOver.
    func inlineTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title).displayFont(19, weight: .heavy).foregroundStyle(Theme.green)
                        .lineLimit(1).minimumScaleFactor(0.7)
                        .accessibilityAddTraits(.isHeader)
                }
            }
    }
}
