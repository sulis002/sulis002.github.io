title: "OM 621 — Analytics Portfolio"
layout: page
nav_order: 2
description: "Python exploratory analysis, transportation delay insights, invoice time-series evaluation, and predictive analytics storytelling for Qualcomm."
---

# 🧠 OM 621 — Analytics Portfolio  
**Natasha Christina Sulistyo**  
**Course:** Tools & Technologies for Analytics  
**Instructor:** Dr. Karimi  
**Semester:** Fall 2025  

---

## 🎥 Video Overview (3–5 Minutes)

*A short video introducing the project, methods, and dashboard will be placed here after recording.*

---

# 📌 Project Summary

This subpage summarizes the complete analytics workflow developed across three core assignments of OM 621:

- Strategic storytelling and audience framing (Assignment 1)  
- Exploratory Python data analysis (Assignment 2)  
- Delay distribution, time-series analysis, and conceptual cost forecasting (Assignment 3)  

GitHub repository:  
➡️ **https://github.com/sulis002/om621-assignments**

---

# 🟦 Assignment 1 — Context, Audience, Storytelling, and Storyboard

## 🎯 Who, What, and How

### **Who — Audience**
The primary audience is the **Director of Supply Chain at Qualcomm**, responsible for global logistics, transportation budgets, and operational cost control.

### **What — The Recommendation**
A **predictive analytics system** is proposed to help Qualcomm:

- Forecast transportation costs  
- Reduce budgeting volatility  
- Improve divisional visibility  
- Anticipate financial impacts before invoices arrive  

### **How — Presentation Strategy**
The communication plan uses:

- Historical shipment and invoice data  
- Predictive insights on cost behavior  
- A live interactive dashboard with:
  - Time-series charts  
  - Slope charts  
  - Division-level comparisons  

---

## 🔹 Understanding the Audience  
Audience understanding involved:

1. **Research**  
2. **Direct discovery questions**  
3. **Reviewing supply-chain KPIs and budgeting structure**  

This ensures recommendations align with decision-maker priorities.

---

## 🔹 Data Needs  

To build a cost-forecasting analytics system, the following attributes are required:

- Shipment date, mode, carrier  
- Invoice date & invoice amount  
- Origin & destination  
- Shipment weight/volume  
- Division / business unit  

Breakdowns needed:

- By month/quarter  
- By mode/carrier  
- By division  
- Historical vs. predicted trends  

---

## 🔹 3-Minute Story  

> “Imagine managing Qualcomm's logistics budget while invoices for global shipments arrive unpredictably late. This creates unnecessary uncertainty and financial stress.  
> 
> Using Qualcomm’s shipment history, we can forecast transportation costs proactively. A clear dashboard shows trends, division-level insights, and future cost estimates before invoices are issued.  
> 
> With this system, Qualcomm can reduce budgeting errors, improve cash flow, and make more confident operational decisions.”

---

## 🔹 Storyboard Summary

1. **Define the problem** — cost unpredictability  
2. **Show the data reality** — delays, invoice gaps, shipment behavior  
3. **Introduce predictive analytics**  
4. **Walk through the dashboard**  
5. **Highlight business impact**  

---

# 🟦 Assignment 2 — Python Data Expectations & Exploratory Analysis  
**Notebook:** [assignment_2.ipynb](https://github.com/sulis002/om621-assignments/blob/main/notebooks/assignment_2.ipynb)

Assignment 2 validates dataset assumptions and builds foundational understanding of shipment and invoice structures.

---

## 🔹 Data Expectations Review

- Invoice fields contain operationally meaningful missing values  
- Shipping data is more complete than financial data  
- Timing gaps reflect real workflow processes  

---

## 🔹 Exploratory Data Analysis

Activities include:

- Counting missing vs. complete attributes  
- Summary statistics  
- Structural inspection  
- Identification of potential patterns in delays  

Plots available here:  
➡️ **[View Plots](https://github.com/sulis002/om621-assignments/tree/main/plots)**

---

# 🟦 Assignment 3 — Python Delay Analysis, Time-Series Behavior & Cost Forecasting  
**Notebook:** [assignment_3.ipynb](https://github.com/sulis002/om621-assignments/blob/main/notebooks/assignment_3.ipynb)

Assignment 3 expands on delays, invoice patterns, and forecasting implications.

---

## 🔹 Delay Distribution by Mode  

- Different transportation modes have unique delay characteristics  
- Some modes show skewed distributions and reliability issues  

---

## 🔹 Invoice Time Series Analysis

Findings include:

- Mild upward cost trend  
- Short-term cost volatility  
- Possible batching cycles  
- Insightful signals for forecasting  

Plots available here:  
➡️ **[View Plots](https://github.com/sulis002/om621-assignments/tree/main/plots)**

---

## 🔹 Cost Estimation & Forecasting Reflection

Key takeaways:

- Costs rise gradually over time  
- Short-term variability is operational  
- Forecasting depends on recognizing trend + noise  
- Mode-specific behavior affects budgeting  

---

# 📊 Power BI Dashboard  
**File:** [Assignment_4.pbix](https://github.com/sulis002/om621-assignments/blob/main/pbi/Assignment_4.pbix)

Includes:

- Time-series charts  
- Delay distributions  
- Division-level insights  
- KPI indicators  

---

# 📁 Project Structure
om621-assignments/
│
├── data/
├── notebooks/
│ ├── assignment_2.ipynb
│ └── assignment_3.ipynb
├── pbi/
│ └── Assignment_4.pbix
├── plots/
└── README.md


---

# 🏁 Final Reflection

This portfolio integrates storytelling, exploratory analytics, operational insights, and professional visualization to support cost forecasting and supply-chain decision-making for a complex global environment like Qualcomm.



