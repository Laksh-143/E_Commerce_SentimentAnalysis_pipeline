import torch
from transformers import pipeline
from tqdm import tqdm
import pandas as pd

class OlistSentimentPipeline:
    def __init__(self, device):
        print("🤖 Initializing Olist Enterprise AI Pipeline...")
        self.device = device
        self.classifier = pipeline(
            task="zero-shot-classification",
            model="MoritzLaurer/mDeBERTa-v3-base-mnli-xnli",
            device=self.device
        )
        
        self.categories = [
            "produto excelente",
            "produto com defeito",
            "entrega rápida",
            "entrega atrasada",
            "ótimo atendimento",
            "péssimo atendimento",
            "embalagem ruim ou danificada"
        ]
        self.template = "Este comentário de cliente é sobre {}."

    def run_analysis(self, texts, batch_size=32, show_progress=True):
        # THE FIX: Hard truncate to 400 chars to protect the GPU
        safe_texts = [str(text)[:400] for text in texts]
        
        print(f"⚡ Processing {len(safe_texts)} reviews (Batch Size: {batch_size})...")
        
        # Bring back the progress bar feature!
        results = []
        iterator = tqdm(
            self.classifier(
                safe_texts,
                candidate_labels=self.categories,
                hypothesis_template=self.template,
                multi_label=True,
                batch_size=batch_size,
                truncation=True
            ),
            total=len(safe_texts),
            disable=not show_progress,
            desc="AI Analysis"
        )

        detected_aspects = []
        highest_confidences = []

        for res in iterator:
            top_aspect = res['labels'][0]
            top_score = res['scores'][0]

            if top_score < 0.60:
                detected_aspects.append("neutro / misto / inconclusivo")
            else:
                detected_aspects.append(top_aspect)
                
            highest_confidences.append(top_score)

        return detected_aspects, highest_confidences

    def generate_insights(self, df):
        """Restoring your business insights generator!"""
        print("\n" + "="*50)
        print("📊 FINAL BUSINESS INSIGHTS SUMMARY")
        print("="*50)
        
        insights = df['ABSA_Primary_Insight'].value_counts()
        for category, count in insights.items():
            percentage = (count / len(df)) * 100
            print(f"• {category}: {count:,} tickets ({percentage:.1f}%)")
        
        print("="*50)
        return insights