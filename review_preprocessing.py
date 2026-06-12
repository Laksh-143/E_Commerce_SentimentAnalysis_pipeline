import pandas as pd

def combine_review_text(row):
    title = str(row['review_title']) if pd.notna(row['review_title']) else 'No Title'
    message = str(row['review_message']) if pd.notna(row['review_message']) else 'No Message'

    if title != 'No Title' and message != 'No Message':
        return title + ". " + message
    elif title != 'No Title':
        return title
    else:
        return message

def preprocess_reviews(df):
    print("Cleaning text and dropping empty reviews...")
    df['full_review_text'] = df.apply(combine_review_text, axis=1)
    df['full_review_text'] = df['full_review_text'].astype(str).str.strip()
    
    df = df[
        (df['full_review_text'] != 'No Message') &
        (df['full_review_text'].str.len() > 5)
    ].copy()
    
    # THE PANDAS FIX: Reset the index so it perfectly aligns with our AI output arrays!
    df = df.reset_index(drop=True)
    return df