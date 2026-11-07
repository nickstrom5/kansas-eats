"""Download the Overture Maps extracts that kansas.py reads -> data/ks/

- overture_ks_bbox.parquet     every place in Kansas's bounding box (name, category, address, point)
- overture_ks_sources.parquet  which datasets each Kansas eating/drinking listing came from (Meta, Foursquare, ...)
- ks_shapes.json               simplified state and county outlines for the map
- ks_state_detail.geojson      the state outline at full detail, for the in-state test

Reads the public Overture bucket over S3 with DuckDB (no account needed). Ported from ky-eats/pipeline/fetch_overture.py (2026-11-06).
Kansas: 105 counties from Overture's land division areas (the Unified Government of Wyandotte County and Kansas City is still one
county). The script checks the towns on the lines with Missouri, Nebraska, Colorado and Oklahoma (Kansas City, KS in, Kansas City, MO
out; Elwood in, St. Joseph out; Baxter Springs in, Joplin and Miami out; Liberal and Elkhart in; Goodland in, Burlington out).
"""
import os, re, json, time
import duckdb
from shapely import wkb
from shapely.geometry import mapping, Polygon

RELEASE = "2026-10-21.0"
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "ks")
# Kansas (36.99°N–40.00°N, 94.59°W–102.05°W) plus a margin for the border towns (State Line Road, the Missouri River towns)
BBOX = "bbox.xmin BETWEEN -102.2 AND -94.45 AND bbox.ymin BETWEEN 36.9 AND 40.1"
EAT = "('restaurant','casual_eatery','bar','fast_food_restaurant','coffee_shop','cafe','smoothie_juice_bar','brewery','food_court')"
os.makedirs(OUT, exist_ok=True)

con = duckdb.connect()
con.execute("INSTALL httpfs; LOAD httpfs; INSTALL spatial; LOAD spatial; SET s3_region='us-west-2';")
places = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=places/type=place/*.parquet"

t = time.time()
if not os.path.exists(f"{OUT}/overture_ks_bbox.parquet"):
    con.execute(f"""
COPY (
  SELECT id, names.primary AS name, basic_category AS cat, taxonomy.primary AS tax, taxonomy.hierarchy AS hier, confidence,
         operating_status AS status, brand.names.primary AS brand, addresses[1].freeform AS street, addresses[1].locality AS city,
         addresses[1].postcode AS zip, addresses[1].region AS region, ST_Y(geometry) AS lat, ST_X(geometry) AS lon, websites[1] AS web,
         phones[1] AS phone
  FROM read_parquet('{places}', hive_partitioning=1) WHERE {BBOX}
) TO '{OUT}/overture_ks_bbox.parquet' (FORMAT PARQUET)""")
    print("places in bbox", round(time.time() - t), "s", flush=True)
if not os.path.exists(f"{OUT}/overture_ks_sources.parquet"):
    con.execute(f"""
COPY (
  SELECT id, list_transform(sources, lambda x: x.dataset) AS ds, list_transform(sources, lambda x: x.update_time) AS ut,
         list_transform(sources, lambda x: x.record_id) AS rid,
         len(socials) AS n_soc, len(websites) AS n_web, len(phones) AS n_ph
  FROM read_parquet('{places}', hive_partitioning=1)
  WHERE {BBOX} AND basic_category IN {EAT}
) TO '{OUT}/overture_ks_sources.parquet' (FORMAT PARQUET)""")
    print("sources", round(time.time() - t), "s", flush=True)

areas = f"s3://overturemaps-us-west-2/release/{RELEASE}/theme=divisions/type=division_area/*.parquet"
rows = con.execute(f"""
  SELECT subtype, names.primary AS name, ST_AsWKB(geometry) AS g
  FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE country = 'US' AND region = 'US-KS' AND subtype IN ('region', 'county') AND class = 'land'
    AND bbox.xmin > -102.3 AND bbox.xmax < -94.3 AND bbox.ymin > 36.8 AND bbox.ymax < 40.2""").fetchall()
# Kansas has no independent cities; a unified government's area keeps its county name ("Unified Government of Wyandotte County
# and Kansas City" -> "Wyandotte County")
def _cname(sub, name):
    if sub == "region" or name.endswith(" County"):
        return name
    m = re.search(r"\b([A-Z][a-z]+) County\b", name)
    return m.group(1) + " County" if m else name + " County"
rows = [(sub, _cname(sub, name), g) for sub, name, g in rows]


def rings(geom, tol, min_area):
    geom = geom.simplify(tol, preserve_topology=True)
    polys = [p for p in getattr(geom, "geoms", [geom]) if p.geom_type == "Polygon" and p.area >= min_area]
    return [[[round(x, 3), round(y, 3)] for x, y in p.exterior.coords] for p in polys]


out = {"state": None, "counties": []}
for sub, name, g in rows:
    geom = wkb.loads(bytes(g)).buffer(0)
    if sub == "region":
        json.dump(mapping(geom.simplify(0.0005, preserve_topology=True)), open(f"{OUT}/ks_state_detail.geojson", "w"))
        out["state"] = [[r] for r in rings(geom, 0.002, 0.000005)]
    else:
        out["counties"].append({"name": name, "c": rings(geom, 0.004, 0.00002)})
# full-detail county polygons for assigning each place to a county (not shipped)
json.dump({name: mapping(wkb.loads(bytes(g)).buffer(0).simplify(0.0003, preserve_topology=True))
           for sub, name, g in rows if sub == "county"}, open(f"{OUT}/ks_counties_detail.geojson", "w"))
json.dump(out, open(f"{OUT}/ks_shapes.json", "w"), separators=(",", ":"))
print("outlines: state", len(out["state"] or []), "rings +", len(out["counties"]), "counties;", round(time.time() - t), "s total")
# islands, shores and border towns: each must fall on the right side of the detailed state outline
from shapely.geometry import shape, Point
st = shape(json.load(open(f"{OUT}/ks_state_detail.geojson")))
for nm, lon, lat, want in [("Wichita", -97.3301, 37.6872, True), ("Topeka", -95.6890, 39.0473, True), ("Kansas City, KS", -94.6275, 39.1141, True),
                           ("Kansas City, MO", -94.5786, 39.0997, False), ("Westport, MO", -94.5928, 39.0517, False), ("Leawood", -94.6169, 38.9667, True),
                           ("Overland Park", -94.6708, 38.9822, True), ("Leavenworth", -94.9225, 39.3111, True), ("Atchison", -95.1216, 39.5631, True),
                           ("Elwood", -94.8722, 39.7558, True), ("St. Joseph, MO", -94.8466, 39.7675, False), ("White Cloud", -95.2983, 39.9764, True),
                           ("Falls City, NE", -95.5972, 40.0608, False), ("Pittsburg", -94.7049, 37.4109, True), ("Joplin, MO", -94.5133, 37.0842, False),
                           ("Baxter Springs", -94.7355, 37.0237, True), ("Miami, OK", -94.8772, 36.8745, False), ("Arkansas City", -97.0384, 37.0620, True),
                           ("Ponca City, OK", -97.0856, 36.7070, False), ("Liberal", -100.9210, 37.0431, True), ("Elkhart", -101.8899, 37.0081, True),
                           ("Goodland", -101.7101, 39.3508, True), ("Burlington, CO", -102.2690, 39.3061, False), ("Syracuse", -101.7524, 37.9806, True),
                           ("Holly, CO", -102.1235, 38.0553, False), ("St. Francis", -101.8000, 39.7722, True), ("Superior, NE", -98.0684, 40.0209, False),
                           ("Dodge City", -100.0171, 37.7528, True), ("Hays", -99.3268, 38.8792, True), ("Lawrence", -95.2353, 38.9717, True)]:
    ok = st.contains(Point(lon, lat))
    print(f"  {nm}: {'inside' if ok else 'outside'}{'' if ok == want else '  <-- WRONG'}")
print("counties:", len(out["counties"]), sorted(c["name"] for c in out["counties"]))

# the neighbours' land (Missouri, Nebraska, Colorado, Oklahoma): listings.py widens Kansas's outline ~300 m for river shores, but only
# where no neighbour's land is, so a Kansas City, MO listing across State Line Road or the Missouri River stays out
nb = con.execute(f"""
  SELECT region, ST_AsWKB(geometry) FROM read_parquet('{areas}', hive_partitioning=1)
  WHERE country = 'US' AND region IN ('US-MO', 'US-NE', 'US-CO', 'US-OK') AND subtype = 'region' AND class = 'land'""").fetchall()
from shapely.ops import unary_union
from shapely.geometry import box
near = box(-102.3, 36.8, -94.3, 40.2)
nbg = unary_union([wkb.loads(bytes(g)).buffer(0).intersection(near) for _, g in nb])
json.dump(mapping(nbg.simplify(0.0002, preserve_topology=True)), open(f"{OUT}/ks_neighbors.geojson", "w"))
print("neighbours:", sorted(r for r, _ in nb))
