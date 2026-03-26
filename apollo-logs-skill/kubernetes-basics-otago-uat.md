# Understanding Otago UAT Environment - Kubernetes Basics

> A beginner-friendly guide to understanding the Otago UAT environment and Kubernetes concepts

## **What is Otago UAT?**

Think of it like this:

### **🏢 Real World Analogy**
- **Otago** = A customer's name (like a company called "Otago University")
- **UAT** = "User Acceptance Testing" = A safe testing environment (like a practice room before the real performance)

### **🖥️ In Technical Terms**
**Otago UAT** is a **separate testing environment** specifically for the Otago customer to test OnSite mobile app features before they go live to their real users.

## **Kubernetes Breakdown (Simple)**

Think of Kubernetes like **apartment buildings** in a city:

### **🌆 The City (AWS Account)**
- Your company has an AWS account (like owning land in a city)
- Account ID: `946135482630`

### **🏢 The Buildings (EKS Clusters)**
- **Cluster**: `prod-apollo-cluster` (us-east-2)
- Think of this as a **big apartment building** that houses different apps

### **🏠 The Apartments (Namespaces)** 
- **Namespace**: `otago-uat`
- This is like a **specific apartment floor** dedicated only to Otago's testing

### **🏃‍♂️ The Residents (Pods)**
- **Pod**: `apollo-otago-uat-79545b5c95-pnsxr`
- This is like a **specific apartment unit** where the Apollo app actually runs
- The long name is like an apartment number: Building-Floor-Unit-ID

### **📋 The Files (Logs)**
- **Logs**: `/app/logs/onsite-apollo-error-2026-03-11-20.log.gz`
- These are like **security camera recordings** that show what happened and when

## **Why Separate Environments?**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  DEVELOPMENT │    │     UAT     │    │ PRODUCTION  │
│   (Dev Test)│ ──▶│ (Customer   │──▶ │ (Real Users)│
│             │    │   Test)     │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
      ↑                    ↑                  ↑
   "Lab work"         "Dress rehearsal"   "Live show"
```

- **Development**: Developers test their code
- **UAT** (Otago): Customer tests new features safely
- **Production**: Real users use the live app

## **Your Job as CloudOps**

When someone says **"Get logs from Otago UAT"**, you're essentially:

1. **Going to the right building** (connect to `prod-apollo-cluster`)
2. **Going to the right floor** (namespace `otago-uat`) 
3. **Knocking on the right door** (pod `apollo-otago-uat-*`)
4. **Asking for security footage** (downloading log files)

## **What Makes Otago Special?**

- **Customer-specific**: Only Otago's test data and users
- **Isolated**: Problems here won't affect other customers
- **Safe testing**: They can break things without hurting real users
- **Realistic**: Uses real-like data and scenarios

## **Simple Command Translation**

When you run:
```powershell
.\quick-extract.ps1 -Environment "otago-uat" -Hours "20,21"
```

You're saying:
- "Go to the Otago customer's testing apartment"
- "Get the security recordings from 8pm-9pm UTC"
- "Bring them back to my computer"

## **Kubernetes Concepts Explained Simply**

### **Cluster** 
- **What**: A group of computers working together
- **Analogy**: Like a shopping mall with multiple stores
- **Example**: `prod-apollo-cluster`

### **Namespace**
- **What**: A way to separate apps within a cluster
- **Analogy**: Like different floors in a shopping mall
- **Example**: `otago-uat`, `staging`, `prod`

### **Pod**
- **What**: The smallest unit that runs your app
- **Analogy**: Like individual store units in the mall
- **Example**: `apollo-otago-uat-79545b5c95-pnsxr`

### **Logs**
- **What**: Files that record what the app is doing
- **Analogy**: Like security cameras recording everything
- **Example**: Error logs, application logs

## **Your Otago UAT Setup**

```
AWS Account: 946135482630
    └── EKS Cluster: prod-apollo-cluster (us-east-2)
            └── Namespace: otago-uat
                    └── Pod: apollo-otago-uat-79545b5c95-pnsxr
                            └── Logs: /app/logs/onsite-apollo-*.log.gz
```

## **Common Operations**

### **Connect to Cluster**
```bash
aws eks update-kubeconfig --name prod-apollo-cluster --region us-east-2
```
*Translation: "Give me the keys to the apartment building"*

### **List Pods**
```bash
kubectl get pods -n otago-uat
```
*Translation: "Show me all the apartment units on the Otago floor"*

### **Get Logs**
```bash
kubectl exec -it apollo-otago-uat-pod -n otago-uat -- cat /app/logs/error.log
```
*Translation: "Go to apartment XYZ and get me the security footage"*

## **Why This Matters for CM Tickets**

When customers like Otago report issues:
1. **They test in UAT first** (safe environment)
2. **You extract logs** to see what went wrong
3. **Developers fix the issue** based on the logs
4. **Customer retests** in UAT before going to production

**Bottom Line**: Otago UAT is just a **safe testing space** for one specific customer, completely separate from everyone else. 🏠