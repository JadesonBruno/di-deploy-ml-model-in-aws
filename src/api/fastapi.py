# Import native libraries
from pathlib import Path
from typing import List

# Import third-party libraries
import joblib
from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel

# App
app = FastAPI(title="ML Prediction API")

# Templates
PROJECT_ROOT = Path(__file__).parent.parent.parent
templates = Jinja2Templates(directory=str(PROJECT_ROOT / "src/templates"))

# Trained Model
MODEL_PATH = PROJECT_ROOT / "src/ml/trained_model.pkl"
model = joblib.load(MODEL_PATH)


class Features(BaseModel):
    features: List[float]


# Main Route (Render HTML)
@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


# Predict via formulário
@app.post("/predict", response_class=HTMLResponse)
def predict_form(
    request: Request,
    feature1: float = Form(..., description="Última Compra", float=True),
    feature2: float = Form(..., description="Penúltima Compra", float=True),
    feature3: float = Form(..., description="Antepenúltima Compra", float=True),
    feature4: float = Form(..., description="Quarta Última Compra", float=True),
):
    features = [feature1, feature2, feature3, feature4]
    prediction = model.predict([features])[0]
    prediction_text = f"Previsão do Modelo (1 - Cliente Fará Outra Compra / 0 - Cliente Não Fará Outra Compra): {int(prediction)}"

    return templates.TemplateResponse("index.html", {"request": request, "prediction_text": prediction_text})
