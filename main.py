import pandas as pd
import torch
from data_loader import load_all_gold_tables
from review_preprocessing import preprocess_reviews
from sentiment_analysis_pt import OlistSentimentPipeline

def main():
    print("="*50)
    print(" OLIST ENTERPRISE AI PIPELINE")
    print("="*50)

    try:
        # 1. Load Data
        gold_layer = load_all_gold_tables()
        merge_reviews = pd.merge(gold_layer["Fact_Reviews"], gold_layer["dim_reviews"], on='review_id', how='inner')
        merged_data = pd.merge(gold_layer["Fact_Orders"], merge_reviews, on='order_id', how='inner')

        # 2. Preprocess 
        merged_data = preprocess_reviews(merged_data)

        # 3. Initializing Pipeline Class
        device = 0 if torch.cuda.is_available() else -1
        ai_pipeline = OlistSentimentPipeline(device=device)

        # 4. Running Analysis 
        texts = merged_data['full_review_text'].tolist()
        aspects, confidences = ai_pipeline.run_analysis(
            texts=texts, 
            batch_size=32, 
            show_progress=True
        )

        # 5. Saving Results
        merged_data['ABSA_Primary_Insight'] = aspects
        merged_data['ABSA_Confidence'] = confidences
        
        # 6. Generating Insights
        ai_pipeline.generate_insights(merged_data)

        merged_data.to_csv("sentiment_results.csv", index=False)
        print("\n Processing Complete! File saved as 'sentiment_results.csv'.")

    except Exception as e:
        print(f"\n Pipeline Error: {e}")

if __name__ == "__main__":
    main()