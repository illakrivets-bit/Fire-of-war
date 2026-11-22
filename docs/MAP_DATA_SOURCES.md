# Map boundary data

The map renderer expects these local files:

- `assets/maps/ukraine_adm1.geojson`
- `assets/maps/russia_adm1.geojson`

## Initial source records

The initial source candidate is geoBoundaries gbOpen, ADM1:

- Ukraine metadata: https://www.geoboundaries.org/api/current/gbOpen/UKR/ADM1/
- Ukraine simplified GeoJSON: https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/UKR/ADM1/geoBoundaries-UKR-ADM1_simplified.geojson
- Russia metadata: https://www.geoboundaries.org/api/current/gbOpen/RUS/ADM1/
- Russia simplified GeoJSON: https://github.com/wmgeolab/geoBoundaries/raw/main/releaseData/gbOpen/RUS/ADM1/geoBoundaries-RUS-ADM1_simplified.geojson

The metadata currently identifies both layers as representing **2017**. It reports 27 Ukraine ADM1 units and 83 Russia ADM1 units. These are source-layer facts, not a claim that the data expresses current political or administrative status. Before release, review whether the data is suitable for the intended present-day map and document any known coverage or status limitations.

The metadata lists the source license as Open Data Commons Open Database License 1.0 (ODbL). Read the current source metadata and license before redistributing modified datasets. Preserve attribution and comply with any share-alike obligations that apply to the database.

## Download procedure

1. Download the Ukraine simplified GeoJSON from the direct link above and save it as `assets/maps/ukraine_adm1.geojson`.
2. Download the Russia simplified GeoJSON from the direct link above and save it as `assets/maps/russia_adm1.geojson`.
3. Keep the source files unchanged. If further simplification is needed for mobile performance, document the tool and tolerance and retain an untouched source copy outside the runtime assets.
4. Keep the metadata response, source date, source URL, license, and any processing steps in this folder.
5. Validate that each file is a GeoJSON FeatureCollection with Polygon or MultiPolygon features before testing the scene.

Do not treat disputed or changing boundaries as an independent political determination. The app should present source attribution and data vintage clearly.

## Attribution

Source: geoBoundaries, William & Mary geoLab, https://www.geoboundaries.org/
