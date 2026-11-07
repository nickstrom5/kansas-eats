"""Writes data/research/app/*.json (hand-checked Kansas guides), data/research/michelin.json, jbf.json and closed.json from the
compact lists below. Ported from in-eats/pipeline/build_research.py (2026-11-06).

Each entry cites the page that names it, read on 2026-11-06: an official tourism page (travelks.com, Kansas Tourism; visitkc.com,
Visit KC), a page dated 2025-26 on a robots-checked host (check_sources.py), or jamesbeard.org. The address comes from the map listing
we already hold for that name in that town (site/kansas.json); a name that isn't found exactly once in its town (or at the street
number given) is left out and listed in data/research/app/LEADS.md. A place the map data doesn't show as a place to eat is added only
with a street address from its official listing or our own map data (ADDR).
Usage: ../.venv/bin/python build_research.py   (then kansas.py)"""
import json, os, re
from brands import brand_of
from common import norm_name
ROOT = os.path.join(os.path.dirname(__file__), "..")
R = os.path.join(ROOT, "data", "research")
d = json.load(open(os.path.join(ROOT, "site", "kansas.json")))
C, M = d["cols"], d["meta"]
norm = lambda s: re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (s or "").lower().replace("'", "").replace("’", ""))).strip()

# each dated on its face, or an official tourism page (read 2026-11-06)
TK_CHICKEN = "https://www.travelks.com/blog/stories/post/the-ultimate-southeast-kansas-fried-chicken-guide/"          # Kansas Tourism, 2026-08-11
TK_BBQ = "https://www.travelks.com/blog/stories/post/for-the-love-of-barbeque-kansas-bbq-restaurants-to-try-on-your-next-road-trip/"   # 2025-05-30
TK_ICT = "https://www.travelks.com/blog/stories/post/a-taste-of-americana-in-kansas-classic-comfort-food-stops-in-wichita/"   # Visit Wichita, 2026-07-06
TK_PRAIRIE = "https://www.travelks.com/kansas-magazine/articles/post/little-restaurant-on-the-prairie/"                  # KANSAS! magazine, 2026-03-05
TK_R66 = "https://www.travelks.com/kansas-magazine/articles/post/kansas-route-66-food-guide-eat-your-way-across-kansas-132-miles-of-the-mother-road/"   # 2026-07-27
VKC = "https://www.visitkc.com/food-drink/barbecue/"                                                          # Visit KC barbecue directory, Kansas Side (© 2026)
KS8 = "https://kansassampler.org/8wondersofkansas-cuisine"                                                   # Kansas Sampler Foundation, 8 Wonders of Kansas Cuisine (2008-10 contest)
KS8_COZY = "https://kansassampler.org/8wondersofkansas-cuisine/cozy-inn-salina"                              # its Cozy Inn page (opened spring 1922)
KS8_NUWAY = "https://kansassampler.org/8wondersofkansas-cuisine/nuway-cafe-wichita"                         # its NuWay page (July 4, 1930, 1416 W. Douglas)
COZY26 = "https://www.ksal.com/appeals-court-sides-with-cozy-inn/"   # KSAL, 2026-10-30: the appeals court ruling; serving hamburgers since 1922
BOBOS25 = "https://www.visittopeka.com/listing/bobos-drive-in/2230/"   # Visit Topeka (Greater Topeka Partnership, (c) 2026): "since 1948", 2300 SW 10th
KMUW_VOLGA = "https://www.kmuw.org/podcast/hidden-kansas/2026-01-30/bierocks-brats-dumplings-and-beer-volga-germans-celebrate-150-years-of-heritage-in-kansas"   # 2026-01-30
TT_OLDREST = "https://www.tastingtable.com/1975409/oldest-restaurant-every-state-still-open/"          # 2025-09-23
JBF26 = "https://www.jamesbeard.org/stories/james-beard-award-semifinalists-2026"                   # 2026-01-21
JBF25 = "https://www.jamesbeard.org/stories/the-2025-james-beard-award-semifinalists"               # 2025-01-22
KCUR23 = "https://www.kcur.org/arts-life/2023-03-29/james-beard-awards-name-2-finalists-from-kansas-city-drastic-measures-and-yoli-tortilleria"   # KCUR, 2023-03-29
KSAL_BROOKVILLE = "https://www.ksal.com/?p=151913"                                                 # KSAL, 2026-05-06: the Brookville Hotel has closed
MI_UT = "https://guide.michelin.com/us/en"                                                         # no MICHELIN Guide covers Kansas

# (name as the source writes it or as our listing spells it, town as our listing has it, street number to pick the location (or
# None), note, founded, founded_note, [sources])
KC, ICT = "Kansas City", "Wichita"
GUIDES = {
 "crawford county fried chicken": [   # Kansas Tourism's southeast Kansas fried chicken guide (Aug. 2026); an 8 Wonders of Kansas Cuisine pick
  ("Chicken Annie's Original", "Pittsburg", "1143", "Annie Pichler's chicken dinners, northeast of Pittsburg, since 1934.", None, None, [TK_CHICKEN, KS8]),
  ("Chicken Mary's", "Pittsburg", "1133", "Next door to Chicken Annie's Original on East 600th Avenue since 1942.", None, None, [TK_CHICKEN, KS8]),
  ("Barto's Idle Hour", "Frontenac", "201", "Fried chicken dinners on Santa Fe Street in Frontenac since 1951.", None, None, [TK_CHICKEN, KS8]),
  ("Gebhardt's Chicken Dinners", "Mulberry", "124", "A farmhouse chicken-dinner hall near Mulberry, open since 1946.", None, None, [TK_CHICKEN, KS8]),
  ("Pichler's Chicken Annie's", "Pittsburg", "1271", "The Pichler family's chicken dinners south of Pittsburg.", None, None, [TK_CHICKEN, KS8]),
  ("Chicken Annie's Girard", "Girard", "498", "Chicken dinners on K-47 at Girard; Kansas Tourism's listing says open since 1971.", None, None, [TK_CHICKEN]),
 ],
 "kansas barbecue": [   # Visit KC's Kansas-side barbecue, Kansas Tourism's road-trip list (May 2025) and Visit Wichita (July 2026)
  ("Joe's Kansas City Bar-B-Que", KC, "3002", "The original, in a gas station on West 47th Avenue on the Kansas side.", None, None, [VKC]),
  ("Slaps BBQ", KC, "553", "Barbecue on Central Avenue in Strawberry Hill.", None, None, [VKC]),
  ("Jack Stack Barbecue", "Overland Park", "9520", "Jack Stack on Metcalf Avenue in Overland Park.", None, None, [VKC]),
  ("Jack Stack Barbecue", "Lenexa", "8721", "Jack Stack on Ryckert Street in Lenexa.", None, None, [VKC]),
  ("Gates Bar-B-Q", "Leawood", "2001", "Gates on West 103rd Street.", None, None, [VKC]),
  ("Meat Mitch", "Leawood", "3620", "A competition team's barbecue restaurant on West 95th Street.", None, None, [VKC]),
  ("Q39 South", "Overland Park", "11051", "Q39's Kansas location on Antioch Road.", None, None, [VKC]),
  ("Roy's Hickory Pit Bar-B-Q", "Hutchinson", None, "A small Hutchinson pit that sells out.", None, None, [TK_BBQ]),
  ("Guy & Mae's Tavern", "Williamsburg", None, "Ribs by the slab in a small-town tavern; one of the 8 Wonders of Kansas Cuisine.", None, None, [TK_BBQ, KS8]),
  ("Bite Me Barbecue", "Marysville", "1405", "Barbecue on Center Street in Marysville.", None, None, [TK_BBQ]),
  ("Hickory Hut", "Salina", "1617", "Barbecue on West Crawford Street in Salina.", None, None, [TK_BBQ]),
  ("Knackies Bear-B-Cue", "Inman", "115", "Barbecue on Main Street in Inman.", None, None, [TK_BBQ]),
  ("BobbyD's Merchant Street BBQ", "Emporia", "607", "Barbecue on Merchant Street in downtown Emporia.", None, None, [TK_BBQ]),
  ("Brady's Smoke House", "Hill City", None, "A northwest Kansas smokehouse.", None, None, [TK_BBQ]),
  ("Iron Rail Brewing", "Topeka", "705", "A brewpub with smoked meats on South Kansas Avenue.", None, None, [TK_BBQ]),
  ("LaVon's Bakery & BBQ", "Buhler", "216", "A bakery and barbecue on North Maple in Buhler.", None, None, [TK_BBQ]),
  ("Smoked Creations BBQ", "Ottawa", None, "Barbecue in Ottawa.", None, None, [TK_BBQ]),
  ("The Smoking Barrel", "Ellsworth", "112", "Barbecue on West 1st Street in Ellsworth.", None, None, [TK_BBQ]),
  ("Station 8 BBQ", ICT, None, "Barbecue in a restored 1920s firehouse.", None, None, [TK_ICT]),
  ("Delano Barbeque Company", ICT, None, "Barbecue in the Delano district.", None, None, [TK_ICT]),
  ("B and C Barbeque", ICT, None, "A Wichita barbecue pub since 1996.", None, None, [TK_ICT]),
  ("Barrel Boys BBQ", ICT, None, "Wichita barbecue.", None, None, [TK_ICT]),
  ("Two Brothers BBQ", ICT, None, "Wichita barbecue.", None, None, [TK_ICT]),
  ("When Pigs Fly BBQ", ICT, None, "Locally owned since 2010.", None, None, [TK_ICT]),
  ("Georgio's BBQ", ICT, None, "Wichita barbecue.", None, None, [TK_ICT]),
  ("PaPa C's Backyard BBQ", ICT, None, "Wichita barbecue.", None, None, [TK_ICT]),
 ],
 "sliders and drive ins": [   # 8 Wonders of Kansas Cuisine picks still open (each with a 2025-26 source) and Visit Wichita's classics
  ("Cozy Inn", "Salina", "108", "Onion-heavy sliders at six stools on North 7th Street since 1922; one of the 8 Wonders of Kansas Cuisine.", None, None, [COZY26, KS8_COZY]),
  ("Bobo's Drive In", "Topeka", "2300", "A carhop drive-in on SW 10th Avenue, serving Topeka since 1948; one of the 8 Wonders of Kansas Cuisine.", None, None, [BOBOS25, KS8]),
  ("NuWay Burgers", ICT, "1416", "The West Douglas original: crumbled loose-meat burgers and homemade root beer since 1930.", None, None, [TK_ICT, KS8_NUWAY]),
  ("NuWay Burgers", ICT, "7301", "NuWay's West Central location: the same crumbled loose-meat burgers.", None, None, [TK_ICT]),
  ("Old Mill Tasty Shop", ICT, "604", "A soda fountain and lunch counter since 1932.", None, None, [TK_ICT]),
  ("Ty's Diner", ICT, None, "A burger counter since the 1950s.", None, None, [TK_ICT]),
 ],
 "heritage tables": [   # old buildings and the state's settler cooking
  ("Hays House 1857 Restaurant & Tavern", "Council Grove", "112", "On the Santa Fe Trail in Council Grove since 1857; one of the 8 Wonders of Kansas Cuisine.", None, None, [TT_OLDREST, KS8]),
  ("Gella's Diner", "Hays", None, "Volga German cooking in Hays: green bean dumpling soup, grebble and bierocks.", None, None, [KMUW_VOLGA]),
  ("Chef Stan's Place", "Strong City", "225", "Dinner and Sunday brunch in a restored 1905 church.", None, None, [TK_PRAIRIE]),
  ("Nelson's Old Riverton Store", "Riverton", None, "A Route 66 landmark store with a deli counter.", None, None, [TK_R66]),
 ],
 "oldest": [
  ("Hays House 1857 Restaurant & Tavern", "Council Grove", "112", "A Santa Fe Trail restaurant and tavern since 1857.", 1857,
   "Tasting Table's oldest restaurant in every state (Sept. 2025): Kansas's is the Hays House, open since 1857 (\"oldest west of the Mississippi\" is its own claim).", [TT_OLDREST]),
  ("Cozy Inn", "Salina", "108", "Sliders on North 7th Street since spring 1922.", 1922, "The Kansas Sampler Foundation's 8 Wonders page: opened in the spring of 1922.", [KS8_COZY, COZY26]),
  ("NuWay Burgers", ICT, "1416", "Loose-meat burgers on West Douglas since 1930.", 1930, "The Kansas Sampler Foundation's 8 Wonders page: the NuWay tradition began on July 4, 1930, and the original is at 1416 W. Douglas; Visit Wichita (July 2026) lists it open.", [KS8_NUWAY, TK_ICT]),
  ("Old Mill Tasty Shop", ICT, "604", "A soda fountain since 1932.", 1932, "Visit Wichita (July 2026): since 1932.", [TK_ICT]),
  ("Chicken Annie's Original", "Pittsburg", "1143", "Chicken dinners since 1934.", 1934, "Kansas Tourism (Aug. 2026): founded 1934.", [TK_CHICKEN]),
  ("Chicken Mary's", "Pittsburg", "1133", "Chicken dinners since 1942.", 1942, "Kansas Tourism (Aug. 2026): established 1942.", [TK_CHICKEN]),
  ("Gebhardt's Chicken Dinners", "Mulberry", "124", "Chicken dinners since 1946.", 1946, "Kansas Tourism (Aug. 2026): opened 1946.", [TK_CHICKEN]),
 ],
}
# street addresses for places the map data doesn't show as a place to eat: from the official listing, or our own map listing for it
ADDR = {("Hays House 1857 Restaurant & Tavern", "Council Grove"): "112 W Main St", ("Chef Stan's Place", "Strong City"): "225 Church St",
        ("Gebhardt's Chicken Dinners", "Mulberry"): "124 N 260th St", ("Chicken Annie's Girard", "Girard"): "498 KS-47"}
CUISINE = {("Hays House 1857 Restaurant & Tavern", "Council Grove"): "American & Other", ("Chef Stan's Place", "Strong City"): "American & Other",
           ("Gebhardt's Chicken Dinners", "Mulberry"): "Chicken & Wings", ("Chicken Annie's Girard", "Girard"): "Chicken & Wings"}
KINDS = {k: [k] for k in ("crawford county fried chicken", "kansas barbecue", "sliders and drive ins", "heritage tables", "oldest")}

# MICHELIN: no guide covers Kansas
MICHELIN = []
MI_MATCH = {}
# James Beard (facts with sources): Kansas's 2025-26 semifinalists and Drastic Measures' 2023 finalist nod; the one Kansas winner, the
# Brookville Hotel (America's Classics 2007), closed in May 2026 (CLOSED below)
MW = "Best Chef: Midwest"
JBF = [{"name": "Drastic Measures", "city": "Shawnee", "honors": ["Outstanding Bar semifinalist 2026", "Outstanding Bar Program finalist 2023"], "sources": [JBF26, KCUR23]},
       {"name": "Of Course Kitchen & Company", "city": "Overland Park", "honors": [f"{MW} semifinalist 2026 (Swetha Newcomb)"], "sources": [JBF26], "match_names": ["OF COURSE"]},
       {"name": "FioRito Ristorante", "city": ICT, "honors": [f"{MW} semifinalist 2026 (Jason and Jordan Rickard)"], "sources": [JBF26], "match_names": ["FIORITO"]},
       {"name": "Georges French Bistro", "city": ICT, "honors": ["Outstanding Restaurant semifinalist 2025"], "sources": [JBF25]},
       {"name": "The Restaurant at 1900", "city": "Mission Woods", "honors": [f"{MW} semifinalist 2025 (Linda Duerr)"], "sources": [JBF25]},
       {"name": "Saltwell Farm Kitchen", "city": "Overbrook", "honors": [f"{MW} semifinalist 2025 (Rozz Petrozz)"], "sources": [JBF25]},
       {"name": "John Brown's Underground", "city": "Lawrence", "honors": ["Outstanding Bar semifinalist 2025"], "sources": [JBF25]},
       {"name": "Wild Child Libations", "city": "Shawnee", "honors": ["Outstanding Professional in Cocktail Service semifinalist 2025 (Jay Sanders)"], "sources": [JBF25], "match_names": ["WILD CHILD"]}]
# closed, each with a source: (name, town, street number or None, note, source)
CLOSED = [("Brookville Hotel", "Abilene", None, "Closed in May 2026 (it reopened in 2022 as Legacy Kansas: Munson's Prime & Brookville Hotel).", KSAL_BROOKVILLE),
          ("Legacy Kansas", "Abilene", None, "Closed in May 2026 (the Brookville Hotel's last name).", KSAL_BROOKVILLE)]

def key(s):
    """The name key without a leading "the": "Varsity" is our "The Varsity"."""
    return re.sub(r"^the ", "", norm(s))


def find(name, town, num):
    k = key(name)
    hits = [i for i, n in enumerate(C["name"]) if C["city"][i] is not None and M["cities"][C["city"][i]] == town
            and (key(n) == k or key(n).startswith(k + " ") or k.startswith(key(n) + " ") or key(n).replace(" ", "") == k.replace(" ", "")
                 or (key(n).split()[:2] == k.split()[:2] and len(k.split()) >= 2))]
    if num:
        hits = [i for i in hits if (C["addr"][i] or "").split(" ")[0] == num]
    return hits


leads, n_out = [], {}
for kind, rows in GUIDES.items():
    out = []
    for name, town, num, note, founded, fnote, srcs in rows:
        hits = find(name, town, num)
        if not hits and (name, town) in ADDR:
            out.append({"name": name, "address": ADDR[(name, town)], "city": town, "zip": None, "kinds": KINDS[kind], "dishes": [], "note": note,
                        "founded": founded, "founded_note": fnote, "website": None, "open": True, "evidence_date": "2026-10",
                        "sources": srcs, "match_names": []} | ({"cuisine": CUISINE[(name, town)]} if (name, town) in CUISINE else {}))
            continue
        if len(hits) != 1:
            leads.append(f"- {kind}: {name} ({town}{', ' + num if num else ''}) — {len(hits)} matches in our data; not added"); continue
        i = hits[0]
        out.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "zip": str(C["zip"][i]) if C["zip"][i] else None,
                    "kinds": KINDS[kind], "dishes": [], "note": note, "founded": founded, "founded_note": fnote, "website": None, "open": True,
                    "evidence_date": "2026-10", "sources": srcs, "match_names": [name.upper()] if norm(name) != norm(C["name"][i]) else []})
        if brand_of(norm_name(name)):   # a chain shows under its own spelling at every branch, whatever the listing says
            out[-1]["display"] = name
        if (name, town) in CUISINE:
            out[-1]["cuisine"] = CUISINE[(name, town)]
    fn = re.sub(r"[^a-z]+", "_", kind).strip("_")
    json.dump(out, open(f"{R}/app/{fn}.json", "w"), indent=1, ensure_ascii=False)
    n_out[kind] = len(out)

MI_ADDR = {}
json.dump({"restaurants": [{"name": n, "address": MI_ADDR.get(n), "city": t, "zip": None, "distinction": dist, "cuisine": cu, "green_star": False,
                             "michelin_url": MI_UT, "sources": [MI_UT], "match_names": [x.upper() for x in MI_MATCH.get(n, [])], "open": True}
                            for n, t, dist, cu in MICHELIN]}, open(f"{R}/michelin.json", "w"), indent=1, ensure_ascii=False)
json.dump([dict({"address": None}, **j, zip=None, open=True) for j in JBF], open(f"{R}/jbf.json", "w"), indent=1, ensure_ascii=False)
closed = []
for name, town, num, note, src in CLOSED:
    for i in find(name, town, num):
        closed.append({"name": C["name"][i], "address": C["addr"][i], "city": town, "note": note, "sources": [src], "open": False,
                       "match_names": [name.upper()]})
json.dump(closed, open(f"{R}/closed.json", "w"), indent=1, ensure_ascii=False)
open(f"{R}/app/LEADS.md", "w").write("# Kansas research leads (not yet verified)\n\nWritten by pipeline/build_research.py.\n\n" + "\n".join(leads) + """

## Waiting for a source we may use, or for the map data
- 8 Wonders of Kansas Cuisine (Kansas Sampler, a 2008-10 contest) picks with no 2025-26 source yet: Free State Brewing and WheatFields
  Bakery (Lawrence), Homer's Drive Inn (Leavenworth), Carolyn's Essenhaus (Arlington), C.W. Porubsky's (Topeka), Anchor Inn
  (Hutchinson), Charlie's Mexican (Leoti), Crazy R's (Goodland), Grand Central Hotel (Cottonwood Falls), Paolucci's (Atchison), Pho Hoa
  (Garden City), Prairie Nut Hut (Altoona), Trapper's. Closed per the page: Hibachi Hut, Josie's Ristorante, Olive Tree Bistro.
- Bierocks and Volga German cooking beyond Gella's (Hays, Victoria), Czech kolaches (Wilson), Swedish Lindsborg and Southwest Kansas
  Mexican (Garden City, Dodge City, Liberal): no 2025-26 source per place yet.
- Honors: 40 Sardines (Overland Park, a 2003 design award) closed long ago; not listed.
- Official data: KDA's inspection portals (the new one is reCAPTCHA-gated: never scripted; the old frozen one: harvest only with Nick's
  yes), a KORA request, and KDOR ABC's licensee database (behind an "I agree" certification): Nick's call. Johnson County AIMS's
  Restaurants layer: measure only.
""")
print(n_out, "| leads:", len(leads))
for l in leads: print(l)
