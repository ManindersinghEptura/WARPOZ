# Otago UAT Advanced Details - Explained Simply

> Taking the complex technical stuff and making it as easy as understanding your neighborhood

## **🏢 The Complete Apartment Building (EKS Cluster)**

Remember our **apartment building** analogy? Let's go deeper:

### **🏗️ Building Specifications**
```
Building Name: prod-apollo-cluster
Address: us-east-2 (Ohio neighborhood)
Building Age: Built in 2021, renovated multiple times
Floors: 6 different floors (subnets)
Security: Front desk + key cards (authentication)
Elevators: 6 elevators (availability zones)
```

**Think of it like**: A modern apartment complex with multiple towers, security systems, and backup power.

### **🔐 Building Security System**
- **Front Desk**: AWS authentication (your badge to get in)
- **Key Cards**: Kubernetes tokens (access to specific floors)
- **Security Guards**: Load balancer (directs visitors to right apartments)
- **Surveillance**: Logging system (records everything that happens)

## **🏠 Otago's Specific Apartment (Namespace)**

### **📍 Address Details**
```
Building: prod-apollo-cluster (Ohio)
Floor: otago-uat (Otago's testing floor)
Apartment: apollo-otago-uat-79545b5c95-pnsxr
Rent: Running for 295+ days (very stable tenant!)
```

**Think of it like**: Otago rents their own private floor, and they've been excellent tenants for almost a year.

### **🏃‍♂️ The Apartment Resident (Apollo App)**
- **Name**: Apollo GraphQL Server
- **Version**: 6.3.4 (like saying "iOS 6.3.4")
- **Job**: Answering questions from OnSite mobile app
- **Status**: Working 24/7, never takes a break
- **Needs**: Upgrade to version 6.4.x (like updating your iPhone)

## **🌐 The Building's Internet & Phone System**

### **📞 Phone Numbers (URLs)**
```
Public Phone: apollo-otago-uat.archibus.cloud
Internal Extension: 4000 (apartment internal)
Building Switchboard: 30330 (building level)
Main Reception: 80 (external calls)
```

**Think of it like**: Otago has their own phone number, but calls go through the building's switchboard system.

### **📡 Internet Connection (Load Balancer)**
- **ISP**: `prod-apollo-604503780.us-east-2.elb.amazonaws.com`
- **Router**: Application Load Balancer (ALB)
- **WiFi Name**: apollo-otago-uat.archibus.cloud
- **Security**: SSL/TLS (encrypted connection)

**Translation**: Like having a secure, business-grade internet connection with a custom domain name.

## **🏢 The Back Office (WebCentral Node 3)**

Remember, OnSite needs **two buildings** to work:
1. **Front Building**: Apollo (where we get logs) - Ohio
2. **Back Building**: WebCentral - Sydney, Australia

### **🏢 Back Office Details**
```
Building: WebCentral Node 3
Location: Sydney, Australia (ap-southeast-2)
Purpose: The "database and business logic" building
Office Number: i-0f8b77b19aa4ceb11
Status: Always open (24/7 operations)
```

**Think of it like**: The front desk (Apollo) takes requests, but the actual work happens in the back office (WebCentral).

### **📁 Important Filing Cabinets (Config Files)**
```
Main Cabinet: /opt/tomcat/webapps/archibus/WEB-INF/config/

File Folders:
├── oidc.properties           → "Employee ID Badge System"
├── configservice.properties  → "OnSite App Settings"  
└── push-notification.properties → "Alert System Settings"
```

**Translation**: Like having different file cabinets for employee badges, app settings, and notification systems.

## **🔑 The ID Badge System (Authentication)**

### **🏢 Corporate Badge System**
- **Company**: Azure AD (Microsoft's employee system)
- **Badge Type**: OIDC tokens (digital employee badges)
- **Problem**: `autoCreateUserAccount=false` 
- **Translation**: "Don't automatically make badges for new employees"
- **Issue**: New employees can't get in without pre-made badges!

**Simple Fix**: Change setting to `autoCreateUserAccount=true` (auto-create badges)

## **📋 The Security Camera System (Logging)**

### **🎥 Camera Setup**
```
Camera Location: /app/logs/ (inside Otago's apartment)
Recording Pattern: onsite-apollo-{type}-YYYY-MM-DD-HH.log

Camera Types:
├── error cameras    → Record when things go wrong
├── activity cameras → Record normal daily activities  
└── audit cameras    → Record who accessed what
```

### **📼 Video Storage System**
- **Recent Videos**: Stored as regular files (.log)
- **Old Videos**: Compressed to save space (.log.gz) 
- **Storage Time**: About 30 days of recordings
- **Timezone**: All cameras use UTC time (like Greenwich Mean Time)

**Think of it like**: A security system that automatically compresses old footage to save disk space.

### **📊 What the Cameras See**
```
Busy Hours: 20:00-22:00 UTC (2pm-4pm Mountain Time)
Typical Activity: Very light (539 bytes = like 1 page of text)
Peak Activity: ~20KB when compressed (like 10-20 pages)
```

**Translation**: Otago's apartment is pretty quiet - not much drama happening!

## **📱 The App Versions (Compatibility)**

Think of it like **iPhone and iOS versions**:

| iPhone App | iOS Version | Status |
|------------|-------------|---------|
| OnSite 6.4.x | Apollo 6.4.x | ✅ Latest (iPhone 15 + iOS 17) |
| OnSite 6.3.x | Apollo 6.3.x | ✅ Current (iPhone 14 + iOS 16) - Otago |
| OnSite 6.4.x | Apollo 6.3.x | ⚠️ Problem (New app, old OS) |

**Otago's Situation**: They have iPhone 14 + iOS 16 - works fine, but should upgrade to iPhone 15 + iOS 17 for new features.

## **🏥 Health Checkups (Monitoring)**

### **🩺 Daily Health Check**
```bash
Doctor Visit: curl -X POST https://apollo-otago-uat.archibus.cloud/
Health Question: "How are you feeling today?"
Expected Answer: "I'm version 6.3.4, feeling great!"
```

**Think of it like**: A daily wellness check where the app reports its version and status.

### **🚨 Common Health Problems**
```
Symptom: "Cannot query field 'mobileApps'"
Diagnosis: App version too old
Treatment: Upgrade Apollo to newer version

Symptom: "Authentication must be not null"  
Diagnosis: Badge system broken (autoCreateUserAccount=false)
Treatment: Fix badge settings

Symptom: Slow response/timeouts
Diagnosis: Not enough worker threads (was 150, fixed to 800)
Treatment: Increase worker capacity
```

## **📞 Emergency Contacts (Key People)**

Think of it like **apartment building staff**:

| Problem | Call This Person | Backup |
|---------|------------------|---------|
| Apartment issues (Apollo) | Alex Plotkin | Building Manager |
| Back office problems (WAR) | Dany Silva | - |
| Building maintenance (Infrastructure) | Santosh Prasad | - |
| Badge system (Authentication) | Dany Silva | - |
| Alert system (Notifications) | Santosh Prasad | - |

## **🔧 Performance Tuning (Building Maintenance)**

### **🔌 Electrical System (Thread Pool)**
- **Old Setup**: 150 electrical outlets (not enough!)
- **New Setup**: 800 electrical outlets (plenty of power!)
- **Result**: No more power outages during busy times

**Think of it like**: Upgrading from 150-amp to 800-amp electrical service so everyone can run their appliances.

### **📊 Building Metrics**
```bash
# Check apartment power usage
kubectl top pod → "How much electricity is Otago using?"

# Check building power usage  
kubectl top nodes → "How much power is the whole building using?"

# Detailed apartment inspection
kubectl describe pod → "Full inspection report of Otago's apartment"
```

## **🛡️ Building Security (Network Security)**

### **🏢 Security Layers**
- **Neighborhood**: VPC (gated community)
- **Building Entrance**: Security groups (access control)
- **Apartment Doors**: TLS/SSL (encrypted locks)
- **Staff Areas**: Private subnets (employees-only zones)

**Think of it like**: A secure office complex with multiple layers of protection.

## **💾 Backup & Recovery (Building Safety)**

### **📋 Emergency Plan**
1. **Apartment Problem**: Kubernetes restarts automatically (like sprinkler system)
2. **Floor Problem**: Auto-scaling replaces resources (like backup generators)
3. **Building Problem**: EKS control plane handles it (like fire department)
4. **Total Disaster**: Redeploy from backup (like rebuilding from blueprints)

**Translation**: Multiple backup systems ensure Otago's "apartment" stays running no matter what.

## **🚀 Future Plans (Building Renovations)**

### **📅 Planned Upgrades**
- **Apartment Upgrade**: Apollo 6.3.4 → 6.4.x (like renovating to modern appliances)
- **Building Systems**: Regular maintenance and updates
- **Security**: Fix the badge system issue
- **Monitoring**: Better security cameras and alert systems

**Think of it like**: Ongoing building improvements to keep everything modern and secure.

---

## **🎯 Key Takeaway**

**Otago UAT** is like having a **well-maintained apartment** in a **secure building** with:
- Reliable utilities (Apollo app running smoothly)
- Good security (authentication working)  
- Maintenance staff (Alex, Dany, Santosh)
- Security cameras (logging system)
- Backup systems (disaster recovery)
- Planned upgrades (version improvements)

When you extract logs, you're essentially **asking the security guard for yesterday's camera footage** from Otago's apartment! 📹