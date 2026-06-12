import pandas as pd
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

def evaluate_absa_pipeline():
    print("Loading AI results from 'sentiment_results.csv'...")
    try:
        df = pd.read_csv("sentiment_results.csv")
    except FileNotFoundError:
        print("Error: Could not find 'sentiment_results.csv'. Make sure you run main.py first!")
        return

    # 1. Map the specific Portuguese ABSA Categories back to base Sentiment
    absa_to_sentiment = {
        "produto excelente": "POS",
        "entrega rápida": "POS",
        "ótimo atendimento": "POS",
        "produto com defeito": "NEG",
        "entrega atrasada": "NEG",
        "péssimo atendimento": "NEG",
        "embalagem ruim ou danificada": "NEG",
        "neutro / misto / inconclusivo": "NEU"
    }

    # 2. Map actual Star Ratings to base Sentiment (Our Ground Truth)
    def stars_to_sentiment(stars):
        if stars >= 4: return "POS"
        elif stars <= 2: return "NEG"
        else: return "NEU"

    print("Mapping ABSA categories to compare against Star Ratings...")
    # Create the comparison columns
    df['AI_Predicted_Sentiment'] = df['ABSA_Primary_Insight'].map(absa_to_sentiment)
    df['Actual_Customer_Sentiment'] = df['review_score'].apply(stars_to_sentiment)

    # Drop any edge cases where mapping failed
    df = df.dropna(subset=['AI_Predicted_Sentiment', 'Actual_Customer_Sentiment'])

    y_true = df['Actual_Customer_Sentiment']
    y_pred = df['AI_Predicted_Sentiment']

    # 3. Calculate and Print Metrics
    print("\n" + "="*50)
    print("📊 ENTERPRISE AI PIPELINE EVALUATION REPORT")
    print("="*50)

    accuracy = accuracy_score(y_true, y_pred)
    print(f"\nOverall Pipeline Accuracy: {accuracy * 100:.2f}%\n")

    print("Classification Report (Precision, Recall, F1-Score):")
    labels = ['NEG', 'NEU', 'POS']
    print(classification_report(y_true, y_pred, labels=labels))

    # 4. Generate the Confusion Matrix Graphic
    print("Generating Confusion Matrix visualization...")
    cm = confusion_matrix(y_true, y_pred, labels=labels)

    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                xticklabels=['Predicted NEG', 'Predicted NEU', 'Predicted POS'], 
                yticklabels=['Actual NEG', 'Actual NEU', 'Actual POS'])
    plt.title('Upgraded DeBERTa ABSA Model vs. Star Ratings')
    plt.xlabel('AI Predicted Sentiment (Rolled Up)')
    plt.ylabel('Actual Customer Star Rating (Ground Truth)')
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    evaluate_absa_pipeline()