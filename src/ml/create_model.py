# Importing third-party libraries
import joblib
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split

# Fake dataset Generation
X, y = make_classification(n_samples=1000, n_features=4, random_state=42)

# Splitting the dataset into training and testing
X_TRAINNING, X_TEST, y_trainning, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Model Training
model = LogisticRegression()
model.fit(X_TRAINNING, y_trainning)

# Model Evaluation
y_pred = model.predict(X_TEST)
accuracy = accuracy_score(y_test, y_pred)
print(f"Model Accuracy: {accuracy * 100:.2f}%")

# Model Saving
joblib.dump(model, "trained_model.pkl")
