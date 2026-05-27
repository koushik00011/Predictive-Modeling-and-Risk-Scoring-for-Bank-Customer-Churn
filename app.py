import streamlit as st
import joblib
import pandas as pd

# LOAD MODEL
model = joblib.load("gb_model.pkl")

# PAGE CONFIG
st.set_page_config(
    page_title="Bank Churn Prediction",
    page_icon="🏦",
    layout="centered"
)

# TITLE
st.title("🏦 Bank Customer Churn Prediction")
st.markdown("Predict customer churn risk using Machine Learning")

st.divider()

# CUSTOMER DETAILS
st.subheader("Customer Information")

col1, col2 = st.columns(2)

with col1:

    credit_score = st.slider(
        "Credit Score",
        300,
        900,
        650
    )

    age = st.slider(
        "Age",
        18,
        100,
        35
    )

    tenure = st.slider(
        "Tenure",
        0,
        10,
        5
    )

    balance = st.number_input(
        "Account Balance",
        min_value=0.0,
        value=50000.0
    )

    estimated_salary = st.number_input(
        "Estimated Salary",
        min_value=0.0,
        value=70000.0
    )

with col2:

    num_of_products = st.selectbox(
        "Number of Products",
        [1, 2, 3, 4]
    )

    has_cr_card = st.radio(
        "Has Credit Card?",
        ["Yes", "No"]
    )

    is_active_member = st.radio(
        "Is Active Member?",
        ["Yes", "No"]
    )

    gender = st.selectbox(
        "Gender",
        ["Male", "Female"]
    )

    geography = st.selectbox(
        "Country",
        ["France", "Germany", "Spain"]
    )

# CONVERSIONS
has_cr_card = 1 if has_cr_card == "Yes" else 0

is_active_member = 1 if is_active_member == "Yes" else 0

gender_male = 1 if gender == "Male" else 0

geography_germany = 1 if geography == "Germany" else 0

geography_spain = 1 if geography == "Spain" else 0

# FEATURE ENGINEERING
age_tenure = age * tenure

balance_to_salary_ratio = balance / (estimated_salary + 1)

engagement_product = is_active_member * num_of_products

product_density = num_of_products / (tenure + 1)

# PREDICTION BUTTON
st.divider()

if st.button("Predict Churn Risk"):

    input_data = pd.DataFrame([[
        credit_score,
        age,
        tenure,
        balance,
        num_of_products,
        has_cr_card,
        is_active_member,
        estimated_salary,
        gender_male,
        geography_germany,
        geography_spain,
        age_tenure,
        balance_to_salary_ratio,
        engagement_product,
        product_density
    ]])

    prediction = model.predict(input_data)

    probability = model.predict_proba(input_data)[0][1]

    st.subheader("Prediction Result")

    st.metric(
        "Churn Probability",
        f"{round(probability * 100, 2)} %"
    )

    if probability > 0.7:
        st.error("⚠️ High Risk Customer")

    elif probability > 0.4:
        st.warning("⚠️ Medium Risk Customer")

    else:
        st.success("✅ Low Risk Customer")