from PIL import Image
import numpy as np
import tensorflow as tf
import os

# Check if model exists
if not os.path.exists("soil_classifier.tflite"):
    print("ERROR: soil_classifier.tflite NOT FOUND!")
    print("Current folder contents:")
    print(os.listdir("."))
    exit()

print("Model found! Running test...")

# CHANGE THIS TO YOUR BLACK SOIL IMAGE PATH
# Put a black soil image in the same folder and name it exactly this:
image_path = "black_test.jpg"   # ← RENAME YOUR BLACK SOIL PHOTO TO black_test.jpg

if not os.path.exists(image_path):
    print(f"ERROR: {image_path} not found!")
    print("Please put a BLACK SOIL photo in this folder and name it black_test.jpg")
    exit()

img = Image.open(image_path).convert("RGB").resize((224, 224))
arr = np.array(img).astype(np.uint8)[np.newaxis, ...]

interpreter = tf.lite.Interpreter(model_path="soil_classifier.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

interpreter.set_tensor(input_details[0]['index'], arr)
interpreter.invoke()
pred = interpreter.get_tensor(output_details[0]['index'])[0]

idx = np.argmax(pred)
confidence = pred[idx] / 255.0

print("\n" + "="*50)
print("BLACK SOIL TEST RESULT")
print("="*50)
print(f"Raw Index: {idx}")
print(f"Confidence: {confidence:.1%}")
print(f"All scores: {pred}")
print(f"Index 0: {pred[0]:.1f} | Index 1: {pred[1]:.1f} | Index 2: {pred[2]:.1f} | Index 3: {pred[3]:.1f}")
print("="*50)