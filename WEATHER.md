# Setting up an Apigee Proxy for api.weather.gov

This document outlines the steps to create an Apigee proxy for the `api.weather.gov` backend, specifically targeting the `/stations` resource. We will also include an Assign Message policy to set a unique User-Agent header.

## 1. Prerequisites

*   An active Apigee account and access to an Apigee organization.
*   Basic understanding of Apigee proxy creation.

## 2. Manual Proxy Creation via Apigee Console UI

This section details how to manually create the Apigee proxy using the Apigee console wizard.

### Proxy Creation Wizard Fields

When creating a new API Proxy, you will encounter a wizard. Here's how to fill in the relevant fields:

| Field                        | Value                                        | Notes                                                              |
| :--------------------------- | :------------------------------------------- | :----------------------------------------------------------------- |
| **Proxy type**               | Reverse proxy (most common)                  |                                                                    |
| **Proxy Name**               | `weather_stations`                           | A unique name for your API proxy.                                  |
| **Proxy Base Path**          | `/weather/v1/stations`                       | The URL path that clients will use to access your proxy.           |
| **Description**              | A proxy for weather station data from api.weather.gov | (Optional) A brief description of the proxy.                       |
| **Existing API (Target URL)**| `https://api.weather.gov/`                   | The backend service that your proxy will invoke.                   |
| **Security**                 | No Authorization                             | For this example, as `api.weather.gov` public endpoints don't require API keys. |
| **Virtual Hosts (Environments)**| Select your desired environments (e.g., `test`, `prod`) | Deploy your proxy to one or more environments.                     |

### Example JSON Responses and Invocations

Here are examples of responses you can expect and how to invoke the endpoints:

#### Get all stations (`/stations`)

**Invocation (via your Apigee proxy):**
```bash
curl -v https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations
```

**Example JSON Response (snippet):**
```json
{
    "@context": [
        "https://geojson.org/geojson-ld/geojson-context.jsonld",
        {
            "@version": "1.1",
            "wx": "https://api.weather.gov/ontology#",
            "s": "https://schema.org/",
            "geo": "http://www.opengis.net/ont/geosparql#",
            "unit": "http://codes.wmo.int/common/unit/",
            "@vocab": "https://api.weather.gov/ontology#",
            "geometry": {
                "@id": "s:GeoCoordinates",
                "@type": "geo:wktLiteral"
            },
            "city": "s:addressLocality",
            "state": "s:addressRegion",
            "distance": {
                "@id": "s:Distance",
                "@type": "s:QuantitativeValue"
            },
            "bearing": {
                "@type": "s:QuantitativeValue"
            },
            "value": {
                "@id": "s:value"
            },
            "unitCode": {
                "@id": "s:unitCode",
                "@type": "@id"
            },
            "forecastOffice": {
                "@type": "@id"
            },
            "forecastGridData": {
                "@type": "@id"
            },
            "publicZone": {
                "@type": "@id"
            },
            "county": {
                "@type": "@id"
            },
            "observationStations": {
                "@container": "@list",
                "@type": "@id"
            }
        }
    ],
    "type": "FeatureCollection",
    "features": [
        {
            "id": "https://api.weather.gov/stations/0007W",
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [
                    -84.1787,
                    30.53099
                ]
            },
            "properties": {
                "@id": "https://api.weather.gov/stations/0007W",
                "@type": "wx:ObservationStation",
                "elevation": {
                    "unitCode": "wmoUnit:m",
                    "value": 49.0728
                },
                "stationIdentifier": "0007W",
                "name": "Montford Middle",
                "timeZone": "America/New_York",
                "forecast": "https://api.weather.gov/zones/forecast/FLZ017",
                "county": "https://api.weather.gov/zones/county/FLC073",
                "fireWeatherZone": "https://api.weather.gov/zones/fire/FLZ017"
            }
        }
    ]
}
```

#### Get a specific station by ID (`/stations/{id}`)

**Invocation (via your Apigee proxy, using KNYC as an example):**
```bash
curl -v https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations/KNYC
```

**Example JSON Response (snippet):**
```json
{
    "@context": [
        "https://geojson.org/geojson-ld/geojson-context.jsonld",
        {
            "@version": "1.1",
            "wx": "https://api.weather.gov/ontology#",
            "s": "https://schema.org/",
            "geo": "http://www.opengis.net/ont/geosparql#",
            "unit": "http://codes.wmo.int/common/unit/",
            "@vocab": "https://api.weather.gov/ontology#",
            "geometry": {
                "@id": "s:GeoCoordinates",
                "@type": "geo:wktLiteral"
            },
            "city": "s:addressLocality",
            "state": "s:addressRegion",
            "distance": {
                "@id": "s:Distance",
                "@type": "s:QuantitativeValue"
            },
            "bearing": {
                "@type": "s:QuantitativeValue"
            },
            "value": {
                "@id": "s:value"
            },
            "unitCode": {
                "@id": "s:unitCode",
                "@type": "@id"
            },
            "forecastOffice": {
                "@type": "@id"
            },
            "forecastGridData": {
                "@type": "@id"
            },
            "publicZone": {
                "@type": "@id"
            },
            "county": {
                "@type": "@id"
            }
        }
    ],
    "id": "https://api.weather.gov/stations/KNYC",
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [
            -73.9666699,
            40.78333
        ]
    },
    "properties": {
        "@id": "https://api.weather.gov/stations/KNYC",
        "@type": "wx:ObservationStation",
        "elevation": {
            "unitCode": "wmoUnit:m",
            "value": 46.9392
        },
        "stationIdentifier": "KNYC",
        "name": "New York City, Central Park",
        "timeZone": "America/New_York",
        "forecast": "https://api.weather.gov/zones/forecast/NYZ072",
        "county": "https://api.weather.gov/zones/county/NYC061",
        "fireWeatherZone": "https://api.weather.gov/zones/fire/NYZ212"
    }
}
```

#### Get a specific station by ID (Dallas example - `/stations/KDAL`)

**Invocation (via your Apigee proxy):**
```bash
curl -v https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations/KDAL
```

**Example JSON Response (snippet):**
```json
{
    "@context": [
        "https://geojson.org/geojson-ld/geojson-context.jsonld",
        {
            "@version": "1.1",
            "wx": "https://api.weather.gov/ontology#",
            "s": "https://schema.org/",
            "geo": "http://www.opengis.net/ont/geosparql#",
            "unit": "http://codes.wmo.int/common/unit/",
            "@vocab": "https://api.weather.gov/ontology#",
            "geometry": {
                "@id": "s:GeoCoordinates",
                "@type": "geo:wktLiteral"
            },
            "city": "s:addressLocality",
            "state": "s:addressRegion",
            "distance": {
                "@id": "s:Distance",
                "@type": "s:QuantitativeValue"
            },
            "bearing": {
                "@type": "s:QuantitativeValue"
            },
            "value": {
                "@id": "s:value"
            },
            "unitCode": {
                "@id": "s:unitCode",
                "@type": "@id"
            },
            "forecastOffice": {
                "@type": "@id"
            },
            "forecastGridData": {
                "@type": "@id"
            },
            "publicZone": {
                "@type": "@id"
            },
            "county": {
                "@type": "@id"
            }
        }
    ],
    "id": "https://api.weather.gov/stations/KDAL",
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [
            -96.85506,
            32.85416
        ]
    },
    "properties": {
        "@id": "https://api.weather.gov/stations/KDAL",
        "@type": "wx:ObservationStation",
        "elevation": {
            "unitCode": "wmoUnit:m",
            "value": 145.0848
        },
        "stationIdentifier": "KDAL",
        "name": "Dallas Love Field",
        "timeZone": "America/Chicago",
        "forecast": "https://api.weather.gov/zones/forecast/TXZ119",
        "county": "https://api.weather.gov/zones/county/TXC113",
        "fireWeatherZone": "https://api.weather.gov/zones/fire/TXZ119"
    }
}
```

#### Get a specific station by ID (Reston/Dulles example - `/stations/KIAD`)

**Invocation (via your Apigee proxy):**
```bash
curl -v https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations/KIAD
```

**Example JSON Response (snippet):**
```json
{
    "@context": [
        "https://geojson.org/geojson-ld/geojson-context.jsonld",
        {
            "@version": "1.1",
            "wx": "https://api.weather.gov/ontology#",
            "s": "https://schema.org/",
            "geo": "http://www.opengis.net/ont/geosparql#",
            "unit": "http://codes.wmo.int/common/unit/",
            "@vocab": "https://api.weather.gov/ontology#",
            "geometry": {
                "@id": "s:GeoCoordinates",
                "@type": "geo:wktLiteral"
            },
            "city": "s:addressLocality",
            "state": "s:addressRegion",
            "distance": {
                "@id": "s:Distance",
                "@type": "s:QuantitativeValue"
            },
            "bearing": {
                "@type": "s:QuantitativeValue"
            },
            "value": {
                "@id": "s:value"
            },
            "unitCode": {
                "@id": "s:unitCode",
                "@type": "@id"
            },
            "forecastOffice": {
                "@type": "@id"
            },
            "forecastGridData": {
                "@type": "@id"
            },
            "publicZone": {
                "@type": "@id"
            },
            "county": {
                "@type": "@id"
            }
        }
    ],
    "id": "https://api.weather.gov/stations/KIAD",
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [
            -77.4475,
            38.93472
        ]
    },
    "properties": {
        "@id": "https://api.weather.gov/stations/KIAD",
        "@type": "wx:ObservationStation",
        "elevation": {
            "unitCode": "wmoUnit:m",
            "value": 95.0976
        },
        "stationIdentifier": "KIAD",
        "name": "Washington/Dulles International Airport, DC",
        "timeZone": "America/New_York",
        "forecast": "https://api.weather.gov/zones/forecast/VAZ053",
        "county": "https://api.weather.gov/zones/county/VAC059",
        "fireWeatherZone": "https://api.weather.gov/zones/fire/VAZ053"
    }
}
```

## 3. Add an Assign Message Policy for User-Agent

The `api.weather.gov` service recommends setting a unique `User-Agent` header to identify your application.

1.  **Access Proxy Editor**: Once the proxy is created, navigate to its "Develop" tab.
2.  **Add Policy**: In the "Proxy Endpoint" section (usually `default`), locate the "PreFlow" section.
    *   Click the "+" button next to "Policies" (or "Add Policy" if available).
    *   Select "Assign Message" from the policy types.
    *   Name the policy (e.g., `AM-SetUserAgent`).
    *   Click "Add".
3.  **Configure Policy**: The policy XML will open. Replace its content with the following:

    ```xml
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <AssignMessage async="false" continueOnError="false" enabled="true" name="AM-SetUserAgent">
        <DisplayName>AM-SetUserAgent</DisplayName>
        <Properties/>
        <Set>
            <Headers>
                <Header name="User-Agent">apigee-demo (kdrowe@google.com)</Header>
            </Headers>
        </Set>
        <IgnoreUnresolvedVariables>true</IgnoreUnresolvedVariables>
        <AssignTo createNew="false" transport="http" type="request"/>
    </AssignMessage>
    ```
    This policy adds a `User-Agent` header to the outgoing request to the backend.

4.  **Attach Policy to PreFlow**:
    *   In the "Proxy Endpoint" > "PreFlow" section, drag and drop the `AM-SetUserAgent` policy from the "Policies" list to the "Request" flow.
    *   Ensure it's placed before any other policies that might modify headers.

5.  **Save and Deploy**: Click "Save" (or "Save Proxy") to save the changes. If prompted, deploy the updated proxy to your desired environment(s).

## 4. Testing the Proxy

1.  **Get Proxy URL**: Go to the "Overview" tab of your `weather_stations` proxy. Copy the "Proxy URL" for the environment you deployed to (e.g., `https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations`).
2.  **Test with a client**: Use a tool like `curl` or Postman to make a request to your proxy.

    ```bash
    curl -v https://YOUR_ORG-YOUR_ENV.apigee.net/weather/v1/stations
    ```
    You should receive a response from `api.weather.gov` listing weather stations. The `-v` flag in `curl` will show the request headers sent, allowing you to verify that the `User-Agent` header is correctly set by Apigee before forwarding the request to the backend.