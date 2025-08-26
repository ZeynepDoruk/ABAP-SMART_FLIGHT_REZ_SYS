from flask import Flask, request, jsonify
import smtplib
import ssl
from email.message import EmailMessage
import os

app = Flask(__name__)

#  Ortam değişkenlerinden SMTP bilgileri (önce .env'e yazılabilir)
SMTP_SERVER = " "
SMTP_PORT = 587
EMAIL_ADDRESS = os.environ.get(" " "")
EMAIL_PASSWORD = os.environ.get("" "")  # App şifresi

#  /send-confirmation → Bilet kodu gönderme
@app.route('/send-confirmation', methods=['POST'])
def send_confirmation():
    data = request.get_json()
    email = data.get('email')
    ticket_code = data.get('ticket_code')  # 🔁 SAP'ten alınan bilet kodu

    if not email or not ticket_code:
        return jsonify({"success": False, "error": "Email ve ticket_code zorunludur"}), 400

    try:
        msg = EmailMessage()
        msg['Subject'] = "Bilet Kodunuz"
        msg['From'] = EMAIL_ADDRESS
        msg['To'] = email

        body = f"""
Merhaba,

Bilet kodunuz: {ticket_code}

Bu kod ile rezervasyonunuzu SAP sisteminde takip edebilirsiniz.

Smart Flight Reservation Sistemi
"""
        msg.set_content(body)

        context = ssl.create_default_context()
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls(context=context)
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.send_message(msg)

        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

#   /send-cancel-code → SAP tarafından üretilen iptal kodunu mail ile gönderme
@app.route('/send-cancel-code', methods=['POST'])
def send_cancel_code():
    data = request.get_json()
    email = data.get('email')
    ticket_code = data.get('ticket_code')
    code = data.get('code')  # 🔑 SAP'te üretilen doğrulama kodu

    if not email or not ticket_code or not code:
        return jsonify({"success": False, "error": "Email, ticket_code ve code zorunludur"}), 400

    try:
        msg = EmailMessage()
        msg['Subject'] = "Rezervasyon İŞLEM Kodunuz"
        msg['From'] = EMAIL_ADDRESS
        msg['To'] = email

        body = f"""
Merhaba,

Bilet kodunuz: {ticket_code}
İptal işlemi için doğrulama kodunuz: {code}

Lütfen bu kodu SAP ekranında ilgili alana girerek rezervasyonunuzu iptal edin.

İyi günler dileriz.

Smart Flight Reservation Sistemi
"""
        msg.set_content(body)

        context = ssl.create_default_context()
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls(context=context)
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.send_message(msg)

        return jsonify({"success": True}), 200

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

#  Uygulama başlat
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)
