from flask import Flask, request, Response
import tensorflow as tf
import numpy as np
import pickle
import os
import json
from sklearn.preprocessing import StandardScaler
from datetime import datetime

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

#  Model ve yardımcı dosyalar
model = tf.keras.models.load_model(os.path.join(BASE_DIR, "model/model_save/delay_predictor_model.h5"))

with open(os.path.join(BASE_DIR, "model/model_save/scaler.pkl"), "rb") as f:
    scaler = pickle.load(f)

with open(os.path.join(BASE_DIR, "model/model_save/encoders.pkl"), "rb") as f:
    label_encoders = pickle.load(f)

@app.route("/predict_delay", methods=["POST"])
def predict_delay():
    try:
        data = request.get_json()

        input_row = [[
            int(data["month"]),
            int(data["day"]),
            int(data["dep_time_hour"]),
            label_encoders["origin"].transform([data["origin"]])[0],
            label_encoders["dest"].transform([data["dest"]])[0],
            int(data["distance"]),
            label_encoders["name"].transform([data["name"]])[0],
            int(data["sched_dep_time_total_minutes"])
        ]]

        input_scaled = scaler.transform(input_row)
        input_reshaped = np.expand_dims(input_scaled, axis=1)
        prediction = model.predict(input_reshaped)
        delay_probability = float(prediction[0][0])

        #  Terminal logu (hem gelen istek hem tahmin sonucu)
        print("\n Yeni İstek Alındı")
        print(" Zaman:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        print("Gelen Veri:", json.dumps(data, ensure_ascii=False, indent=2))
        print(f" Tahmin Sonucu: %{delay_probability * 100:.2f} gecikme olasılığı")
        print("=" * 60)

        return Response(
            json.dumps({"probability": delay_probability}),
            mimetype='application/json'
        )

    except Exception as e:
        import traceback
        error_message = str(e)
        traceback_info = traceback.format_exc()

        print(" HATA OLUŞTU:")
        print(error_message)
        print(traceback_info)

        return Response(
            json.dumps({"error": error_message}),
            mimetype='application/json',
            status=500
        )

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)
