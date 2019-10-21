# bubble-pop

Find nearby POIs that are in challenge or application mode, meaning you can walk by it and verify its information to contribute to the FOAM map.

![demo](/demo.png)

## Usage

You can run the server side bits with `node index.js` or use the dockerfile built with `yarn build`.

To run on a physical device, make sure your backend is available and change the `localhost:3000` reference to your endpoint.

## Notes

This uses a backend service because:

1) in the future we want the heavy lifting to be done on a personal server to help background location updates
2) for the hackathon we built clay, a personal server, and it was designed to run on clay.
3) you could make a client-only version pretty easily imo.

## Misc

Example Response

```json
{
  "poi": {
    "state": {
      "status": {
        "endDate": "2019-05-15T23:48:20Z",
        "type": "applied"
      },
      "createdAt": "2019-05-12T23:48:20Z",
      "deposit": "0x2b5e3af16b1880000"
    },
    "listingHash": "0x6915c4fd135abc263a618a7e1ba188d25f9e5c0713fc81b1a8faf5bbd491a953",
    "owner": "0x1dc96f305645b5ac12dda5151eb6704677c7db12",
    "geohash": "dr5rt53um47z",
    "name": "Little Choc Apothecary ",
    "tags": [
      "Food"
    ]
  },
  "info": {
    "phone": "(718) 963-0420",
    "uUID": "bf8ca568-1f48-486b-b38d-e48f787bcf38",
    "address": "141 Havemeyer Street, Brooklyn, New York, New York 11211, United States",
    "geohash": "dr5rt53um47z",
    "name": "Little Choc Apothecary ",
    "web": "littlechoc.nyc",
    "description": " Little Choc Apothecary is the first fully vegan and gluten-free crêperie in NYC. We offer a creative selection of sweet and savory crepes, as well as homemade baked goods. Our products are completely plant-based, made from scratch, and are free of any chemical binders, gums, artificial flavors, and overly processed sugars and flours. We source our ingredients from farms and distributors who focus on sustainability, and providing local, organic, and fair trade products whenever possible.\n\nOur liquid menu includes natural, biodynamic and vegan wine and beer, freshly pressed juices, Toby’s Estate coffee and espresso drinks made with homemade almond and coconut milks, as well as an apothecary-like selection of house blended teas. With over 100 different herb varieties, our guests can request off menu, personalized tea blends based on their health benefits, or taste preferences. Any individual herb or tea blend is available to take home by the ounce.",
    "tags": [
      "Food"
    ]
  }
}
```
