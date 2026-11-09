# Kansas sources (checked 2026-11-06)

## Official data used
- **None.** Kansas has one inspector and no open data for it; alcohol licenses sit behind a certification. Every place links KDA's
  inspection-results page; "Serves alcohol" is unknown everywhere (never "no").

## Linked, not read (Nick's call)
- **Kansas Department of Agriculture, Food Safety and Lodging** (agriculture.ks.gov/divisions-programs/food-safety-and-lodging/
  inspection-results; it answers 403 to scripts, read in a browser 2026-11-06). KDA inspects in all 105 counties; results are "In
  Compliance" or "Out of Compliance" plus violations, with no score, grade or placard (prompt). The page says the program "has
  transitioned inspection data platforms": results on or after July 6, 2026 on the new portal (portal.kda.ks.gov/Food/
  FoodInspectionSearch, updated nightly; search, map and Export CSV are reCAPTCHA v3-gated and rate-limited: never scripted), and
  August 5, 2015 to July 5, 2026 on the old one (foodsafety.kda.ks.gov, ASP.NET, an Export button, no CAPTCHA seen). Nick said yes to a
  one-time harvest of the old portal (2026-11-07), but it has no robots.txt: the server answers HTTP 500 for every missing file,
  robots.txt included, and RFC 9309 reads a 5xx there as "assume complete disallow". Our rule is to follow robots.txt, so it is **on
  hold** (the parent session, 2026-11-07): Kansas ships with no inspection results. Earlier records need an Open Records (KORA) request. The page cites K.S.A. 45-230: names and addresses from public
  records may not be used for certain commercial purposes (civil penalty up to $500 each). **Nick's routes, not now** (2026-11-07): his own CSV
  export from the new portal, or a KORA request; without one the app ships with no inspection results, as now.
- **KDOR Alcoholic Beverage Control** licensee database (kdor.ks.gov/apps/liquorlicensee/): opens only after an "I agree" to a KORA
  no-commercial-use certification. Not clicked (**Nick's call**). Cereal malt beverage (beer to 6%) retailers are licensed by city and
  county clerks and may be missing from it. The on-premise license map (Jan 4, 2024: about 2,800) and abcMapsSummary.xlsx (Jan 20,
  2026: all 105 counties allow liquor by the drink; 56 need 30% food sales) are from the prompt, not re-read.
- **Johnson County AIMS "Restaurants" layer** (aims.jocogov.org/AIMSData/FreeData.aspx: 1,243 food establishments with a cuisine
  class, updated Sept 19, 2026, per the prompt): its terms limit reuse, so it is for measuring only; not downloaded in this pass.

## Research sources (robots-checked with pipeline/check_sources.py; KCTV5 and Yahoo disallow ClaudeBot, so neither is cited)
- travelks.com (Kansas Tourism): the southeast Kansas fried chicken guide (2026-08-11), "For the Love of Barbeque" (2025-05-30), Visit
  Wichita's classic comfort food stops (2026-07-06), "Little Restaurant on the Prairie" (KANSAS! magazine, 2026-03-05), the Route 66
  food guide (2026-07-27).
- visitkc.com/food-drink/barbecue/ (Visit KC, © 2026): the "Kansas Side" listings.
- kansassampler.org/8wondersofkansas-cuisine (Kansas Sampler Foundation): the 8 Wonders of Kansas Cuisine, a 2008-10 contest; it
  marks closures but is dated, so it is cited only as the honor, beside a 2025-26 source for each place.
- News and listings: KSAL (2026-10-30, the Cozy Inn's appeals-court ruling, "serving hamburgers since 1922"), Visit Topeka's
  Bobo's Drive In listing (© 2026, "since 1948"), KMUW (2026-01-30, Volga German heritage: Gella's), KSAL (2026-05-06, the Brookville Hotel has closed), KCUR (2023-03-29,
  Drastic Measures a James Beard finalist), Tasting Table (2025-09-23, oldest restaurant in every state: the Hays House, 1857).
- jamesbeard.org: 2026 semifinalists (2026-01-21: Drastic Measures, Of Course, FioRito) and 2025 semifinalists (2025-01-22: Georges
  French Bistro, The Restaurant at 1900, Saltwell Farm Kitchen, John Brown's Underground, Wild Child). The Brookville Hotel's 2007
  America's Classics award is listed as closed, not as an honor. No MICHELIN Guide covers Kansas.
- Leads waiting for a 2025-26 source: data/research/app/LEADS.md (the other 8 Wonders picks, bierocks beyond Hays, Czech kolaches in
  Wilson, Swedish Lindsborg, Southwest Kansas Mexican).

## Map data and calibration
- Overture 2026-10-21.0, Kansas's outline from Overture divisions; border checks: Kansas City, KS, Leawood, Elwood, Baxter Springs,
  Liberal, Goodland and White Cloud in; Kansas City, MO, St. Joseph, Joplin, Miami (OK), Burlington (CO) and Falls City (NE) out.
- Census CBP 2023: 5,922 NAICS 722 establishments (Johnson 1,250, Sedgwick 1,145, Shawnee 341, Douglas 302, Wyandotte 274), per the
  prompt. No Google 2021 snapshot is read at all.
