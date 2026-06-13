# 🛒 Olist Enterprise AI Support Router

An end-to-end Machine Learning and Data Engineering pipeline built on the Brazilian E-Commerce Public Dataset by Olist. This project extracts unstructured review data from a SQL Medallion architecture and processes it through a Multilingual Zero-Shot Transformer to automate customer support routing.

The AI pipeline is deployed, can be verified from here and see for different review:
https://ecommercesentimentanalysispipeline-9tt6evambyzhxhtpzrvtkd.streamlit.app/

## 🧠 Architecture & Tech Stack
* **Data Engineering:** SQL Server (T-SQL) Medallion Architecture (Bronze, Silver, Gold), SQLAlchemy.
* **Machine Learning:** PyTorch, Hugging Face Transformers (`mDeBERTa-v3-base`), Aspect-Based Sentiment Analysis (ABSA).
* **Application Layer:** Streamlit, Pandas, Altair for interactive data visualization.

## 🚀 Key Features
* **Zero-Shot Topic Classification:** Bypasses basic positive/negative sentiment analysis by dynamically categorizing reviews into highly specific business problems (e.g., "Delayed Delivery", "Defective Product").
* **Bilingual Command Center:** Features a dynamic UI toggle that swaps underlying AI hypothesis templates, allowing the model to accurately process tickets in both English and Portuguese without retraining.
* **Memory-Optimized Processing:** Implements text truncation (`[:400]` characters) and GPU-safe batching to process 47,000+ reviews at over 800 iterations/second on limited VRAM.
* **Database Integration:** Seamlessly extracts Gold-layer dimension tables via SQLAlchemy and outputs processed behavioral data (`sentiment_results.csv`) for downstream BI consumption.

## 🛠️ How to Run Locally

### 1. Clone the repository
```bash
git clone [https://github.com/Laksh-143/E_Commerce_SentimentAnalysis_pipeline.git](https://github.com/Laksh-143/E_Commerce_SentimentAnalysis_pipeline.git)
cd E_Commerce_SentimentAnalysis_pipeline
