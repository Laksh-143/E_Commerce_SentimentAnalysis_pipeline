# 🛒 Olist Enterprise AI Support Router

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)
![PyTorch](https://img.shields.io/badge/PyTorch-GPU--Accelerated-red?logo=pytorch)
![Hugging Face](https://img.shields.io/badge/HuggingFace-mDeBERTa--v3-yellow?logo=huggingface)
![Streamlit](https://img.shields.io/badge/Streamlit-Live%20Demo-ff4b4b?logo=streamlit)
![SQL Server](https://img.shields.io/badge/SQL%20Server-Medallion%20Architecture-blue?logo=microsoftsqlserver)
![Accuracy](https://img.shields.io/badge/Pipeline%20Accuracy-83.2%25-brightgreen)

An end-to-end Machine Learning and Data Engineering pipeline built on the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). This project processes 47,000+ unstructured customer reviews through a SQL Medallion architecture and a Multilingual Zero-Shot Transformer to automate customer support ticket routing — replacing a basic positive/negative sentiment classifier with a real operational tool.

---
Deployed app 
https://ecommercesentimentanalysispipeline-9tt6evambyzhxhtpzrvtkd.streamlit.app/
## 🧠 Architecture Overview

```
Raw CSVs (Olist Dataset)
        │
        ▼
┌─────────────────────┐
│   BRONZE LAYER      │  ← Bulk INSERT via stored procedure
│   (Raw Ingestion)   │    Handles dirty data & text qualifiers
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   SILVER LAYER      │  ← TRY_CAST type standardization
│   (Cleaned Data)    │    Anomaly detection (is_valid_order_timeline)
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│    GOLD LAYER       │  ← Kimball Star Schema
│  (Star Schema BI)   │    Fact_Orders / Fact_Reviews / Fact_Payments
│                     │    dim_customers / dim_sellers / dim_products
└────────┬────────────┘
         │
         ▼ SQLAlchemy + pyodbc
┌─────────────────────┐
│  Python AI Pipeline │  ← mDeBERTa-v3 Zero-Shot ABSA
│  (sentiment_analysis│    GPU-accelerated batch processing
│   _pt.py)           │    8 business routing categories
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  Streamlit Frontend │  ← Live bilingual (PT/EN) inference
│  (interface.py)     │    Real-time ticket routing dashboard
└─────────────────────┘
```

---

## 📊 Pipeline Performance

| Metric | Value |
|---|---|
| Reviews Processed | 47,548 |
| Overall Accuracy (vs. Star Ratings) | **83.2%** |
| POS Sentiment F1-Score | **0.92** |
| NEG Sentiment F1-Score | **0.79** |
| Mean Model Confidence | **96.6%** |
| Processing Speed | 800+ reviews/sec (RTX 4050) |

> **Note on NEU class:** The neutral class (3-star reviews) has a low F1 (0.05) — a known limitation of zero-shot classification on inherently ambiguous text. These reviews contain genuinely mixed signals that don't map cleanly to any single business category, and are flagged for human review.

---

## 🚀 Key Features

**Zero-Shot Aspect Classification**
Bypasses basic positive/negative sentiment analysis. The model dynamically categorizes reviews into 8 specific operational buckets without any task-specific fine-tuning.

| ABSA Category | Business Dept | Urgency | Volume |
|---|---|---|---|
| ótimo atendimento (Great Support) | Customer Success | Low 🟢 | 23.0% |
| produto excelente (Excellent Product) | Marketing | Low 🟢 | 21.3% |
| entrega rápida (Fast Delivery) | Logistics | Low 🟢 | 17.3% |
| entrega atrasada (Delayed Delivery) | Logistics | High 🟠 | 16.8% |
| produto com defeito (Defective Product) | Quality Assurance | Critical 🔴 | 11.1% |
| péssimo atendimento (Poor Support) | Customer Success | Critical 🔴 | 8.6% |
| neutro / inconclusivo (Neutral/Inconclusive) | Human Agent | — | 1.2% |
| embalagem danificada (Damaged Packaging) | Warehouse | Medium 🟡 | 0.8% |

**Bilingual Command Center**
A dynamic UI toggle swaps the underlying NLI hypothesis template (`"Este comentário é sobre {}."` ↔ `"This review is about {}."`) allowing accurate inference in both Portuguese and English without retraining the model.

**Memory-Optimized GPU Processing**
Implements 400-character hard truncation and GPU-safe batching (batch_size=32) to process 47,000+ reviews at 800+ iterations/second on 6GB VRAM without OOM crashes.

**Production-Style Evaluation**
`evaluation_model.py` benchmarks the ABSA pipeline against ground-truth star ratings using a rule-based label rollup (4–5 stars → POS, 1–2 → NEG, 3 → NEU), providing precision, recall, F1, and a confusion matrix.

---

## 🛠️ Tech Stack

| Layer | Tools |
|---|---|
| Data Engineering | Microsoft SQL Server, T-SQL, Stored Procedures, BULK INSERT |
| Data Architecture | Medallion Architecture (Bronze/Silver/Gold), Kimball Star Schema |
| Python Integration | SQLAlchemy, pyodbc, Pandas |
| Machine Learning | PyTorch, Hugging Face Transformers, `mDeBERTa-v3-base-mnli-xnli` |
| NLP Technique | Zero-Shot Classification, Aspect-Based Sentiment Analysis (ABSA) |
| Evaluation | scikit-learn (accuracy, F1, confusion matrix), seaborn |
| Frontend | Streamlit, Altair |
| Deployment | Hugging Face Spaces |

---

## 🏃 How to Run Locally

### 1. Prerequisites

- Python 3.10+
- Microsoft SQL Server with ODBC Driver 18
- NVIDIA GPU (optional but recommended)

### 2. Clone the repository

```bash
git clone https://github.com/Laksh-143/E_Commerce_SentimentAnalysis_pipeline.git
cd E_Commerce_SentimentAnalysis_pipeline
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure your database connection

Copy the example environment file and fill in your SQL Server details:

```bash
cp .env.example .env
```

```env
DB_SERVER=localhost\SQLEXPRESS
DB_NAME=Olist_dw
DB_DRIVER=ODBC Driver 18 for SQL Server
TRUSTED_CONNECTION=yes
TRUST_SERVER_CERTIFICATE=yes
```

### 5. Run the batch pipeline (processes all 47K reviews)

```bash
python main.py
```

Output: `sentiment_results.csv`

### 6. Evaluate pipeline accuracy

```bash
python evaluation_model.py
```

### 7. Launch the interactive Streamlit app

```bash
streamlit run interface.py
```

---

## ⚠️ Known Limitations

- **Neutral class accuracy is low (F1: 0.05):** 3-star reviews contain genuinely ambiguous language that zero-shot models struggle to classify. In production, these would be routed to a human agent queue, which is already implemented in the pipeline.
- **Short/misspelled text:** Extremely short reviews (e.g. a single misspelled word) can be confidently misclassified. The 60% confidence threshold mitigates this partially.

---

## 📁 Project Structure

```
├── config.py                  # DB connection settings via environment variables
├── data_loader.py             # SQLAlchemy engine + Gold Layer table loader
├── review_preprocessing.py    # Text cleaning and full_review_text construction
├── sentiment_analysis_pt.py   # OlistSentimentPipeline class (ABSA + batch GPU)
├── main.py                    # End-to-end pipeline orchestrator
├── evaluation_model.py        # Accuracy benchmarking vs. star ratings
├── interface.py               # Streamlit bilingual AI Command Center
├── requirements.txt           # Python dependencies
└── .env.example               # Environment variable template
```

---

## 🙏 Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 100k orders from 2016–2018, made publicly available by Olist on Kaggle.
