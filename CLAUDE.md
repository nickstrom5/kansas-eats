# Kansas Eats (ks-eats) — notes for Claude Code sessions

Built 2026-11-06 by a side session for Nick's "build the 17 states left" (group: Kentucky, Indiana, Missouri, Kansas), ported from
`../in-eats/` (itself from `../ky-eats/` and `../va-eats/`) with every fix through 2026-11-05 (delivery-only brands hidden, the website
blocklist and `link_blocklist.py`, the Share link `Links.site + explore/#p=<id>`, over-the-air data, the adult-venue rules, the Denny's
check, `playbook/app-store/listing.json`). Local only: git-ignored data, no repo, no remote, nothing published. Sources:
`playbook/12-sources.md`. Brand: `playbook/05-naming.md` — **provisional**, every choice waits for Nick ("Kansas Eats: Restaurants",
subtitle "Chicken & BBQ across Kansas", Home Screen "Kansas Eats"; a bierock cut open on navy #1B3A6B (changed from a drumstick 2026-11-07), prairie green #4F6B2F
cards, sunflower gold #F2B705 fill only, wheat #F4EBD0 pages; a horizon band with sunflowers).

## Kansas is different
- **No official data used.** The Kansas Department of Agriculture inspects every county with no score or grade; its portals are
  reCAPTCHA-gated (new) or need Nick's yes to harvest (old, frozen at July 5, 2026), or a KORA request. KDOR ABC's licensee database
  opens only after a KORA certification. Both are **Nick's call** (playbook/12-sources.md). So no place is "official", no inspection
  result shows, and "Serves alcohol" is unknown everywhere. Every place links KDA's inspection-results page.
- **No Google data at all** (the UCSD snapshot isn't downloaded; `listings.py` and `kansas.py` run without it).
- **ZIPs** 660xx-679xx. **One region** ("Kansas", one detail file); the site groups lists by county. The Kansas City metro straddles
  State Line Road: Missouri rows drop by the state outline (`fetch_overture.py` checks Kansas City, KS in and Kansas City, MO out).
  Wichita County (seat Leoti) is not the city of Wichita: counties come from each point, never the town name.
- **Guides** (tags in `kansas.py` TAGS; bits 1..16): chicken (Crawford County fried chicken, Kansas Tourism Aug. 2026), bbq (Visit KC's
  Kansas side, Kansas Tourism May 2025, Visit Wichita July 2026), sliders (Cozy Inn, Bobo's, NuWay, Old Mill Tasty Shop, Ty's), heritage
  (Hays House 1857, Gella's, Chef Stan's Place, Nelson's Old Riverton Store), oldest. The 8 Wonders of Kansas Cuisine (Kansas Sampler,
  2008-10) is cited only beside a 2025-26 source. Honors: James Beard only (no MICHELIN Guide covers Kansas): Drastic Measures (finalist
  2023, semifinalist 2026) and the 2025-26 semifinalists; the Brookville Hotel (America's Classics 2007) closed in May 2026.
- **Venues:** Wichita's Eisenhower National (2277 Eisenhower Airport Pkwy and a terminal box), Topeka Regional (6510 SE Forbes Ave), the
  Kansas Speedway, Children's Mercy Park, INTRUST Bank Arena, Allen Fieldhouse, Bill Snyder Family Stadium, the State Fairgrounds in
  Hutchinson, Fort Riley, Fort Leavenworth, McConnell AFB, the prisons.

## Rebuild
```bash
cd pipeline
../.venv/bin/python fetch_overture.py && ../.venv/bin/python fetch_extras.py && ../.venv/bin/python fetch_official.py
../.venv/bin/python geocode_official.py && ../.venv/bin/python geocode_census.py && ../.venv/bin/python listings.py
../.venv/bin/python calibrate.py && ../.venv/bin/python kansas.py && ../.venv/bin/python build_research.py && ../.venv/bin/python kansas.py
KS_APP=1 ../.venv/bin/python kansas.py && cd .. && cp data/app/places.json data/app/detail-*.json KansasEats/Resources/
.venv/bin/python pipeline/check_websites.py && .venv/bin/python pipeline/check_websites.py --retry-transient   # then re-export
.venv/bin/python scripts/make-site.py && .venv/bin/python scripts/publish_app_data.py && .venv/bin/python scripts/publish_app_data.py --check
.venv/bin/python scripts/qa-site.py --static
```
The `.venv` is a copy of va-eats' (python.org framework 3.12). Run `xcodegen generate` when the set of `Resources/*.json` changes.

## App, site, screenshots
- App: `KansasEats/` (bundle `com.kansaseats.ios`), tests in `KansasEatsTests/` (fixture, outline with Kansas City KS, Leawood, Elwood,
  Baxter Springs, Liberal, Goodland and White Cloud in and Kansas City MO, St. Joseph, Joplin, Miami OK, Burlington CO and Falls City NE
  out, bundled-data guards) and `KansasEatsUITests/`. Archive only with Xcode 1.app (27.2, 27B52).
- Site: `scripts/make-site.py` (nickstrom5.github.io/kansas-eats until a CNAME exists), `scripts/explore.js`, `scripts/qa-site.py`.
- Screenshots: `scripts/capture-screenshots.sh` (ScreenshotMode: downtown Wichita; Pittsburg for fried chicken, Kansas City, Kansas,
  for barbecue; detail = the Hays House), then `scripts/site-images.sh`, `scripts/appstore-screenshots.py`. Icons:
  `scripts/icon-concepts.swift`, `scripts/make-brand.swift`.

## Status (2026-11-07, ready to publish; nothing public)
- Pipeline: app 6,055 places / 5,711 restaurants in 374 towns (Census CBP 2023: 5,922 NAICS 722); 47/47 hand-checked entries matched
  (chicken 6, bbq 23, sliders 6, heritage 4, oldest 7; 8 James Beard); leads in data/research/app/LEADS.md (Knackies is in McPherson in
  the map data, Two Brothers BBQ has two Wichita places, PaPa C's isn't in it); websites link-checked (2,985 OK; travelks.com listing
  pages count as a directory, check_websites.py BAD_HOSTS); every cited host passes check_sources.py (KCTV5 and Yahoo disallow
  ClaudeBot: replaced by KSAL and Visit Topeka). Venues: ICT terminal stands hidden. **No official data used** (see "Kansas is different").
- Tests (Xcode 1.app, iOS 27.0): unit 49/49 on iPhone 17 Pro Max and iPad Pro 13" M5; UI 5/6 on both (testLaunchIsQuick skipped itself
  under load). The iPad tour searches "cozy inn" (a leftover Indiana name failed it once and left the iPad landscape).
- Site: 14 pages (one city page, Wichita), `qa-site.py --static` OK; OTA `--check` OK (local only). Screens: docs/screenshots (11), App
  Store frames playbook/app-store/iphone (8) and ipad (6). Icon D (a bierock cut open; the drumstick was retired 2026-11-07) passes check.swift and reads at 60 px (strip60).
  `playbook/app-store/listing.json` (all limits OK; support/privacy URLs on nickstrom5.github.io/kansas-eats/, 404 until Pages is on).
- **Nick decides:** name, icon and palette (playbook/05-naming.md); an inspection route (his own CSV export from KDA's new portal, a
  harvest of the frozen old portal, or a KORA request) and KDOR ABC's licensee database (an "I agree" certification); the repo, Pages,
  App Store Connect record and upload. K.S.A. 45-230: never market to names from these records.

## Rules
No commits, pushes, public repos, App Store Connect or DNS changes without Nick's yes each time; never submit for review or accept
agreements; never publish Google-derived data; never script KDA's reCAPTCHA portal, click KDOR's "I agree" or send a KORA request
without Nick. Support email nick@eatsranked.com. Commit author "Nick Soderstrom" <329204362+nickstrom5@users.noreply.github.com> via
`-c user.name -c user.email`.
