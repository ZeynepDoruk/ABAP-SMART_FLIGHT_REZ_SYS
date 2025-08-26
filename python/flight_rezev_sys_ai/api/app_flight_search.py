from flask import Flask, request, jsonify
from amadeus import Client, ResponseError
from flask_cors import CORS
from dotenv import load_dotenv
import os
import traceback 

load_dotenv()  
app = Flask(__name__)
CORS(app)

amadeus = Client(
    client_id=os.getenv("AMADEUS_CLIENT_ID"),
    client_secret=os.getenv("AMADEUS_CLIENT_SECRET")
)

@app.route("/flightsearch", methods=["POST"])
def search_flights():
    try:

        print(" Yeni POST isteği alındı.")
        print(" Headers:", dict(request.headers))

        data = request.get_json()
        print(" Body (JSON):", data)
        adults = int(data.get("adults", 1))

        # Yolcu sayısı kadar traveler oluştur
        travelers = [
            {
                "id": str(i + 1),
                "travelerType": "ADULT"
            } for i in range(adults)
        ]

        body = {
            "currencyCode": "USD",
            "originDestinations": [
                {
                    "id": "1",
                    "originLocationCode": data["origin"],
                    "destinationLocationCode": data["destination"],
                    "departureDateTimeRange": {
                        "date": data["date"],
                        "time": data.get("time", "09:00:00")
                    }
                }
            ],
            "travelers": travelers,
            "sources": ["GDS"],
            "searchCriteria": {
                "maxFlightOffers": int(data.get("max", 5))
            }
        }

        response = amadeus.shopping.flight_offers_search.post(body=body)

        results = []
        for flight in response.data:
            itinerary = flight['itineraries'][0]
            segments = itinerary['segments']
            first_segment = segments[0]
            last_segment = segments[-1]

            results.append({
                "FLIGHT_ID": flight['id'],
                "AIRLINE": flight['validatingAirlineCodes'][0],
                "PRICE": flight['price']['total'],
                "CURRENCY": flight['price']['currency'],
                "DEP_AIRPORT": first_segment['departure']['iataCode'],
                "ARR_AIRPORT": last_segment['arrival']['iataCode'],
                "DEP_TIME": first_segment['departure']['at'],
                "ARR_TIME": last_segment['arrival']['at'],
                "DURATION": itinerary['duration']
            })

        print(f" {len(results)} uçuş bulundu ve gönderildi.")
        return jsonify(results)

    except ResponseError as error:
        print("Amadeus API hatası:", error)
        return jsonify({"error": error.response.body}), 500

    except Exception as e:
        print(" Genel hata:", str(e))
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5050)
