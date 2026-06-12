import streamlit as st
import pandas as pd
import torch
from transformers import pipeline
import altair as alt

# 1. Page Configuration
st.set_page_config(
    page_title="Olist AI Command Center", 
    page_icon="🛒", # E-commerce Icon
    layout="wide", 
    initial_sidebar_state="expanded"
)

# 2. Session State for Interactive History & Input
if 'ticket_history' not in st.session_state:
    st.session_state.ticket_history = []
if 'test_text' not in st.session_state:
    st.session_state.test_text = ""

# 3. Cache the AI Model
@st.cache_resource(show_spinner=False)
def load_absa_model():
    device = 0 if torch.cuda.is_available() else -1
    return pipeline(
        task="zero-shot-classification",
        model="MoritzLaurer/mDeBERTa-v3-base-mnli-xnli",
        device=device
    )

# 4. The "Translation & Routing" Engine
BUSINESS_LOGIC = {
    "produto excelente": {
        "en_name": "Excellent Product", "dept": "Marketing", "urgency": "Low 🟢",
        "action": "Route to Marketing for Website Testimonials.", "color": "#27ae60"
    },
    "entrega rápida": {
        "en_name": "Fast Delivery", "dept": "Logistics", "urgency": "Low 🟢",
        "action": "Log in Logistics DB as 'On-Time Success'.", "color": "#2ecc71"
    },
    "ótimo atendimento": {
        "en_name": "Great Support", "dept": "Customer Success", "urgency": "Low 🟢",
        "action": "Route to CS Manager for Employee Praise.", "color": "#1abc9c"
    },
    "produto com defeito": {
        "en_name": "Defective Product", "dept": "Quality Assurance", "urgency": "Critical 🔴",
        "action": "URGENT: Flag QA Team & Trigger Auto-Return Email.", "color": "#e74c3c"
    },
    "entrega atrasada": {
        "en_name": "Delayed Delivery", "dept": "Logistics", "urgency": "High 🟠",
        "action": "URGENT: Route to Carrier Escalation Queue.", "color": "#e67e22"
    },
    "péssimo atendimento": {
        "en_name": "Poor Support", "dept": "Customer Success", "urgency": "Critical 🔴",
        "action": "URGENT: Flag for Support Team Lead Review.", "color": "#c0392b"
    },
    "embalagem ruim ou danificada": {
        "en_name": "Damaged Packaging", "dept": "Warehouse", "urgency": "Medium 🟡",
        "action": "Route to Warehouse Manager for Packaging Audit.", "color": "#f1c40f"
    }
}

# --- UI LAYOUT STARTS HERE ---

st.title("🛒 Olist AI Command Center")
st.markdown("Real-time ABSA (Aspect-Based Sentiment Analysis) routing engine for e-commerce customer support.")

# Sidebar Controls
with st.sidebar:
    st.header("⚙️ Settings")
    # Default is "Select Language...", forcing the user to make a choice
    lang_choice = st.selectbox("Customer Language:", ["Select Language...", "Portuguese 🇧🇷", "English 🇺🇸"])
    
    st.divider()
    st.header("🧪 Test Scenarios")
    
    if lang_choice == "Select Language...":
        st.info("Please select a language above to view test scenarios.")
    elif "Portuguese" in lang_choice:
        st.markdown("**Simulate incoming tickets:**")
        if st.button("🟢 Happy Product", use_container_width=True):
            st.session_state.test_text = "O produto é excelente, recomendo a todos! Chegou ontem."
        if st.button("🔴 Late & Angry", use_container_width=True):
            st.session_state.test_text = "Péssimo atendimento! Além disso, a entrega demorou 15 dias a mais do que o prometido."
        if st.button("🟡 Mixed Review", use_container_width=True):
            st.session_state.test_text = "O celular funciona bem, mas a caixa chegou toda rasgada e amassada."
    else:
        st.markdown("**Simulate incoming tickets:**")
        if st.button("🟢 Happy Product", use_container_width=True):
            st.session_state.test_text = "The product is excellent, highly recommend! Arrived yesterday."
        if st.button("🔴 Late & Angry", use_container_width=True):
            st.session_state.test_text = "Terrible service! Furthermore, the delivery took 15 days longer than promised."
        if st.button("🟡 Mixed Review", use_container_width=True):
            st.session_state.test_text = "The phone works well, but the box arrived completely torn and crushed."
            
    st.divider()
    st.caption("AI Model: Multilingual DeBERTa Zero-Shot")

# Create Tabs
tab1, tab2 = st.tabs(["🎯 Live Inference", "📋 Session Ticket History"])

with tab1:
    if lang_choice == "Select Language...":
        st.info("👋 Welcome! Please select the language of the review from the sidebar on the left to activate the AI Command Center.")
    else:
        col_input, col_results = st.columns([1, 1.2], gap="large")
        
        with col_input:
            st.subheader("📥 Incoming Review")
            user_input = st.text_area(
                f"Customer Text ({lang_choice.split()[0]}):", 
                value=st.session_state.test_text,
                height=150
            )
            
            analyze_btn = st.button("🧠 Process Review via AI", type="primary", use_container_width=True)
        
        with col_results:
            st.subheader("📤 AI Output & Routing")
            
            if analyze_btn and user_input.strip():
                with st.spinner("Analyzing neural weights..."):
                    analyzer = load_absa_model()
                    
                    # Setup AI parameters based on language selection
                    if "Portuguese" in lang_choice:
                        categories = list(BUSINESS_LOGIC.keys())
                        template = "Este comentário de cliente é sobre {}."
                    else:
                        categories = [logic["en_name"] for logic in BUSINESS_LOGIC.values()]
                        template = "This customer review is about {}."
                    
                    # Run Model
                    results = analyzer(
                        user_input[:400], 
                        candidate_labels=categories, 
                        hypothesis_template=template,
                        multi_label=True
                    )
                    
                    # Parse Top 2 Results
                    top_aspect = results['labels'][0]
                    top_score = results['scores'][0] * 100
                    
                    second_aspect = results['labels'][1]
                    second_score = results['scores'][1] * 100
                    
                    # Map English labels back to our Portuguese dictionary keys for logic mapping
                    if "English" in lang_choice:
                        top_aspect_pt = next(key for key, val in BUSINESS_LOGIC.items() if val["en_name"] == top_aspect)
                        second_aspect_pt = next(key for key, val in BUSINESS_LOGIC.items() if val["en_name"] == second_aspect)
                    else:
                        top_aspect_pt = top_aspect
                        second_aspect_pt = second_aspect
                    
                    # Safety Net for vague reviews
                    if top_score < 60.0:
                        st.warning("⚠️ **Low Confidence:** Review is too vague. Routing to Human Agent.")
                    else:
                        # Fetch Metadata
                        logic = BUSINESS_LOGIC[top_aspect_pt]
                        
                        # 1. Top Level Metrics
                        m1, m2, m3 = st.columns(3)
                        m1.metric("Primary Aspect", logic["en_name"])
                        m2.metric("AI Confidence", f"{top_score:.1f}%")
                        m3.metric("Urgency Level", logic["urgency"])
                        
                        # 2. Secondary Insight (Detecting mixed sentiments)
                        if second_score > 50.0:
                            sec_logic = BUSINESS_LOGIC[second_aspect_pt]
                            st.info(f"🔍 **Secondary Aspect Detected:** {sec_logic['en_name']} ({second_score:.1f}% confidence)")
                        
                        # 3. Action Box
                        st.markdown("### ⚡ Automated Action Workflow")
                        if "Low" in logic["urgency"]:
                            st.success(f"**Target Department:** {logic['dept']}  \n**Action:** {logic['action']}")
                        else:
                            st.error(f"**Target Department:** {logic['dept']}  \n**Action:** {logic['action']}")
                        
                        # 4. Save to History
                        st.session_state.ticket_history.append({
                            "Review Snippet": user_input[:50] + "...",
                            "Detected Aspect": logic["en_name"],
                            "Confidence": f"{top_score:.1f}%",
                            "Department": logic["dept"],
                            "Urgency": logic["urgency"].split()[0]
                        })
                        
                        # 5. Interactive Chart
                        st.markdown("#### 🧠 AI Probability Distribution")
                        chart_df = pd.DataFrame({
                            "Business Aspect": [BUSINESS_LOGIC[key]["en_name"] if "English" in lang_choice else BUSINESS_LOGIC[key]["en_name"] for key in (results['labels'] if "Portuguese" in lang_choice else [next(k for k, v in BUSINESS_LOGIC.items() if v["en_name"] == label) for label in results['labels']])],
                            "Probability (%)": [s * 100 for s in results['scores']],
                            "Color": [BUSINESS_LOGIC[key]["color"] if "Portuguese" in lang_choice else BUSINESS_LOGIC[next(k for k, v in BUSINESS_LOGIC.items() if v["en_name"] == key)]["color"] for key in results['labels']]
                        })
                        
                        bar_chart = alt.Chart(chart_df).mark_bar(cornerRadiusEnd=4).encode(
                            x=alt.X('Probability (%):Q', scale=alt.Scale(domain=[0, 100])),
                            y=alt.Y('Business Aspect:N', sort='-x'),
                            color=alt.Color('Color:N', scale=None),
                            tooltip=['Business Aspect', alt.Tooltip('Probability (%):Q', format='.1f')]
                        ).properties(height=250)
                        
                        st.altair_chart(bar_chart, use_container_width=True)
                        
            elif not analyze_btn:
                st.info("👈 Enter a review and click 'Process Review' to see AI insights.")

        # --- EDUCATIONAL FOOTER ---
        st.divider()
        st.subheader("📚 How to Read These Results")
        st.markdown("""
        * **Primary Aspect:** The core business topic the AI detected. It bypasses simple "positive/negative" sentiment and categorizes the root cause of the ticket.
        * **AI Confidence:** The mathematical probability (0-100%) that the AI's prediction is correct. Scores below 60% automatically flag the ticket for manual human review.
        * **Urgency Level:** Priority scoring (Low, Medium, High, Critical) based on the severity of the operational failure. 
        * **Secondary Aspect:** Many reviews contain mixed feedback (e.g., "Good product, but late delivery"). The AI flags secondary issues to ensure no problems are ignored.
        * **Automated Action Workflow:** The recommended routing destination, simulating how this pipeline integrates with support CRMs like Zendesk or Salesforce.
        """)

with tab2:
    st.subheader("📋 Processed Tickets (Session History)")
    if len(st.session_state.ticket_history) == 0:
        st.write("No tickets processed yet. Run an analysis on the Live Inference tab!")
    else:
        history_df = pd.DataFrame(st.session_state.ticket_history)
        st.dataframe(
            history_df, 
            use_container_width=True,
            hide_index=True
        )
        st.markdown(f"**No. of Reviews Processed:** {len(history_df)}")