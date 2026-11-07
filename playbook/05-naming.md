# Kansas Eats: name, icon and palette (final: Nick's decision 2026-11-07, "Yes, as proposed")

## Name
- **App Store name:** "Kansas Eats: Restaurants" (24). **Subtitle:** "Chicken & BBQ across Kansas" (27; the prompt asks for "across
  Kansas" in the subtitle). **Home Screen:** "Kansas Eats" (11).
- Checked 2026-11-06 with Apple's public search (itunes.apple.com/search): no app is named "Kansas Eats", "Sunflower Eats" or "Wheat
  State Eats". "Kansas Eats" brings up Kansas City news apps, the Chiefs' app and Campit KS; "Sunflower Eats" brings up restaurant
  ordering apps (Sunflower & Sage); "Wheat State Eats" brings up gluten-free and grocery apps.
- Alternatives from the prompt: "Sunflower Eats" ("Sunflower" is common in Kansas business names, e.g. Sunflower Health Plan: check
  trademarks before choosing it) and "Wheat State Eats" (reads as a bread or gluten app). "Kansas Eats" is the family's pattern and
  the best search fit.
- Avoided: "To The Stars" (Kansas Tourism's tagline), "Ad Astra" (the state motto), Jayhawk / Rock Chalk, Wildcat / Powercat, Shocker,
  Chiefs / Arrowhead, Oz imagery ("There's no place like home").

## Icon
- **D (final, Nick 2026-11-07): a bierock cut open**, front view: a domed bun's golden crust (#E8A93A), its pale crumb (#F4EBD0),
  the beef pocket (#8A5A3A) and four pieces of cabbage (#CFE0A0), on Kansas navy. The Volga German stuffed bun of Hays and Victoria, on
  the prompt's own list. `scripts/icon-concepts.swift` (concept D), `scripts/make-brand.swift` (app icon, site icons, og.png); the site's
  logo SVG in `scripts/make-site.py` mirrors it. Passes `state-prompts/icon-style/check.swift` (5 colours, coverage 25.7%); at 60 px it
  reads as a cut bun with a meat filling, next to Oklahoma's onion burger, Nebraska's Reuben, Missouri's toasted ravioli, Idaho's
  potato and South Dakota's chislic.
- **Why it changed:** A, a fried chicken drumstick, was the first pick, but Tennessee's live icon is a fried drumstick and Nick chose a
  chicken leg for Alabama, so Kansas is off chicken (the parent session's request for Nick, 2026-11-07).
- E: a wheat-bread loaf with three score marks (the Wheat State). Passes check.swift and reads plainly as bread at 60 px, but bread isn't
  a Kansas dish; the runner-up.
- B: the first bierock, a flat bread round with the filling: at 60 px it reads as a pie. C: an onion slider: reads as any burger, and
  Oklahoma's icon is an onion burger. A (drumstick): retired, see above.
- No team marks (Jayhawk, Powercat, Shocker, Chiefs), no seal, no Oz.

## Palette (from the prompt: KU, K-State and Wichita State split the state; the Chiefs and Royals play in Missouri)
- Flag-inspired navy #1B3A6B (11.3:1 on white): titles, tint, accents, the icon background.
- Prairie green #4F6B2F (white on it 6.0:1): hand-checked guide cards, focus rings.
- Sunflower gold #F2B705: fills only (pins, the title shadow, the header's sunflowers), under navy text (6.2:1); never text on
  white (1.8:1).
- Sunflower-seed brown #6B4423 (8.5:1): honors chips. Wheat #F4EBD0: pages.
- Header: the horizon, a navy sky over a wheat-gold field with a row of sunflowers on the line (Theme.swift `Stripes`, the site's band).
