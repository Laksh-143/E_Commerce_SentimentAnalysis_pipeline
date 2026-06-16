# 🛒 Olist Enterprise AI Support Router

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)
![PyTorch](https://img.shields.io/badge/PyTorch-GPU--Accelerated-red?logo=pytorch)
![Hugging Face](https://img.shields.io/badge/HuggingFace-mDeBERTa--v3-yellow?logo=huggingface)
![Streamlit](https://img.shields.io/badge/Streamlit-Live%20Demo-ff4b4b?logo=streamlit)
![SQL Server](https://img.shields.io/badge/SQL%20Server-Medallion%20Architecture-blue?logo=microsoftsqlserver)
![Accuracy](https://img.shields.io/badge/Pipeline%20Accuracy-83.2%25-brightgreen)

**Live Demo:** https://ecommercesentimentanalysispipeline-9tt6evambyzhxhtpzrvtkd.streamlit.app/

---

## 🔍 The Problem

Olist is a Brazilian e-commerce marketplace connecting thousands of independent sellers to customers across Brazil. After every order, customers leave a written review — in Portuguese — describing what went right or wrong.

At scale, **manual review reading is impossible.** But the bigger problem isn't volume — it's that existing solutions ask the wrong question.

A basic sentiment model answers: *"Is this review positive or negative?"*

That's useless to an operations team. A logistics manager doesn't need to know a review is "negative." They need to know **a specific shipment was delayed** so they can escalate to the carrier. A QA team doesn't need a sentiment score — they need a **defective product flag triggered the moment it's detected**, before more units ship.

This project replaces coarse sentiment scoring with a real operational tool: an AI pipeline that reads Portuguese reviews, identifies the specific business problem, and routes each ticket to the correct department with an urgency level — automatically.

---

## 📊 What the Data Reveals

After running 47,548 reviews through the pipeline, three findings stand out:

**1. Logistics is a coin flip.**
Of all reviews mentioning delivery, **50.7% praise fast delivery and 49.3% complain about delays.** This near-equal split (8,236 fast vs. 8,011 delayed) signals a systemic logistics inconsistency — not isolated incidents. A business seeing this would immediately audit carrier SLAs.

**2. Nearly 1 in 5 reviews requires urgent action.**
Combined, "Defective Product" and "Poor Support" account for **19.7% of all reviews (9,353 tickets)**. These are the two highest-urgency categories in the pipeline. Without automated routing, these critical tickets sit in a generic inbox alongside positive feedback, getting triaged manually and slowly.

**3. The overall picture is healthier than it looks — but only if you separate the noise.**
At a surface level, **61.5% of reviews carry a positive signal** and 37.3% carry a negative one. But the raw star ratings tell a misleading story: 23,333 five-star reviews sit alongside 10,420 one-star reviews, with very few in between. This bimodal distribution means aggregated "average rating" metrics hide the real operational problems. The ABSA pipeline surfaces them.

| ABSA Category | Dept | Urgency | Volume | Confidence |
|---|---|---|---|---|
| ótimo atendimento (Great Support) | Customer Success | Low 🟢 | 23.0% | 98.4% |
| produto excelente (Excellent Product) | Marketing | Low 🟢 | 21.3% | 97.1% |
| entrega rápida (Fast Delivery) | Logistics | Low 🟢 | 17.3% | 98.3% |
| entrega atrasada (Delayed Delivery) | Logistics | High 🟠 | 16.8% | 96.6% |
| produto com defeito (Defective Product) | Quality Assurance | Critical 🔴 | 11.1% | 95.6% |
| péssimo atendimento (Poor Support) | Customer Success | Critical 🔴 | 8.6% | 95.6% |
| neutro / inconclusivo | Human Agent | — | 1.2% | 41.1% |
| embalagem danificada (Damaged Packaging) | Warehouse | Medium 🟡 | 0.8% | 98.3% |

> Packaging damage (0.8%) is not a systemic issue — it's isolated. Logistics delay (16.8%) is.

---

## 📈 Pipeline Performance

| Metric | Value |
|---|---|
| Reviews Processed | 47,548 |
| Overall Accuracy (vs. Star Ratings) | **83.2%** |
| POS Sentiment F1-Score | **0.92** |
| NEG Sentiment F1-Score | **0.79** |
| Mean Model Confidence | **96.6%** |
| Processing Speed | 800+ reviews/sec (RTX 4050) |

> **Note on NEU class (F1: 0.05):** 3-star reviews contain genuinely ambiguous language — customers who say "product was okay but delivery was slow" don't map cleanly to any single category. The model's low confidence on these reviews (41.1% avg vs. 96–98% on all others) correctly flags them for human review rather than misrouting them.

---

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

## 🚀 Key Technical Features

**Zero-Shot Aspect Classification**
The model classifies reviews into 8 operational buckets without any task-specific fine-tuning. Using NLI (Natural Language Inference), each review is tested against hypothesis templates like *"Este comentário de cliente é sobre entrega atrasada."* — allowing the model to reason about meaning rather than pattern-match keywords.

**Bilingual Command Center**
A dynamic UI toggle swaps the underlying hypothesis template between Portuguese and English, enabling accurate inference in both languages without retraining or a separate model.

**Memory-Optimized GPU Processing**
400-character hard truncation and GPU-safe batching (batch_size=32) allow 47,000+ reviews to be processed at 800+ iterations/second on 6GB VRAM without OOM crashes.

**Production-Style Evaluation**
`evaluation_model.py` benchmarks the pipeline against ground-truth star ratings using a rule-based label rollup (4–5 stars → POS, 1–2 → NEG, 3 → NEU), generating precision, recall, F1, and a full confusion matrix.

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
| Deployment | Streamlit Community Cloud |

---

## 🏃 How to Run Locally

### Prerequisites
- Python 3.10+
- Microsoft SQL Server with ODBC Driver 18
- NVIDIA GPU (optional but recommended)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/Laksh-143/E_Commerce_SentimentAnalysis_pipeline.git
cd E_Commerce_SentimentAnalysis_pipeline

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure database connection
cp .env.example .env
# Edit .env with your SQL Server details

# 4. Run the batch pipeline (produces sentiment_results.csv)
python main.py

# 5. Evaluate accuracy against star ratings
python evaluation_model.py

# 6. Launch the Streamlit app
streamlit run interface.py
```

### Environment Variables (`.env.example`)

```env
DB_SERVER=localhost\SQLEXPRESS
DB_NAME=Olist_dw
DB_DRIVER=ODBC Driver 18 for SQL Server
TRUSTED_CONNECTION=yes
TRUST_SERVER_CERTIFICATE=yes
```

---

## ⚠️ Known Limitations

**Neutral class accuracy is low (F1: 0.05).** 3-star reviews are inherently ambiguous — "the product was fine but took forever" has no single correct ABSA label. These are correctly routed to a human agent queue in the pipeline, but counted as misclassifications in the evaluation.

**Short or misspelled text can misclassify confidently.** Zero-shot models have no spell-check layer. The 60% confidence threshold catches many of these, but not all.

**No fine-tuning was applied.** The model runs entirely zero-shot. Fine-tuning `mDeBERTa-v3` on a labelled subset of Olist reviews would likely push accuracy above 90%.

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
