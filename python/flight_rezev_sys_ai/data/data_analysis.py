import pickle
import os

# Dosya yolu
encoders_path = r"C:\Users\Zeynep\Desktop\bitirme_projesi_2\flight_rezev_sys_ai\model\model_save\encoders.pkl"

# Dosyayı oku
with open(encoders_path, "rb") as f:
    label_encoders = pickle.load(f)

# 'name' kolonunun sınıflarını yazdır
if "name" in label_encoders:
    airline_names = label_encoders["name"].classes_
    print(" Modele uygun airline isimleri:")
    for name in airline_names:
        print("-", name)
else:
    print(" 'name' label encoder bulunamadı.")


# Kullanılabilir tüm label encoder anahtarlarını yazdır
print("LabelEncoder alanları:")
print(label_encoders.keys())

# Origin ve destination şehirlerini yazdır
for key in ["origin", "dest"]:
    if key in label_encoders:
        print(f"\n Modele uygun {key} şehirleri:")
        for city in label_encoders[key].classes_:
            print("-", city)
    else:
        print(f"'{key}' label encoder bulunamadı.")
print(label_encoders["origin"].classes_)  # Tüm desteklenen kalkış yerleri
print(label_encoders["dest"].classes_)  # Tüm desteklenen varış yerleri
