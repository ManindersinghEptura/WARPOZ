# Otago UAT Environment - Advanced Technical Details

> Deep dive into Otago UAT cluster architecture, infrastructure, and operational details

## **Cluster Architecture Overview**

### **EKS Cluster Configuration**
```yaml
Cluster: prod-apollo-cluster
Region: us-east-2 (Ohio)
Kubernetes Version: 1.32
Platform Version: eks.36
VPC: vpc-0873184cb92e9f173
Authentication Mode: API_AND_CONFIG_MAP
Logging: Disabled for all log types
OIDC Identity Provider: Enabled
```

### **Network Infrastructure**
- **Subnets**: 6 subnets across multiple availability zones
- **Load Balancer**: `prod-apollo-604503780.us-east-2.elb.amazonaws.com`
- **Public Endpoint Access**: Enabled
- **Private Endpoint Access**: Disabled
- **Security Groups**: Configured for cluster communication

## **Otago UAT Namespace Details**

### **Namespace: otago-uat**
```bash
# Namespace metadata
kubectl describe namespace otago-uat
```

### **Pod Configuration**
```yaml
Pod Name: apollo-otago-uat-79545b5c95-pnsxr
Container: apollo-otago-uat
Image: Apollo GraphQL Server (version 6.3.4 - needs upgrade to 6.4.x)
Restart Policy: Always
Status: Running (295+ days uptime)
```

### **Resource Allocation**
```yaml
CPU Requests: [Check via kubectl describe pod]
Memory Requests: [Check via kubectl describe pod]  
CPU Limits: [Check via kubectl describe pod]
Memory Limits: [Check via kubectl describe pod]
```

## **Application Stack**

### **Apollo GraphQL Server**
- **Version**: 6.3.4 (deployed June 2025)
- **Needs Upgrade**: to 6.4.x for latest OnSite app compatibility
- **Contract Version**: 1
- **WebCentral Integration**: Version 2024.04

### **Service Endpoints**
```bash
# Internal service
Service Name: apollo-otago-uat-service
Port: 4000 (internal container port)
NodePort: 30330 (node exposure)
Service IP: 80 (external service)

# External URLs
Apollo UAT: https://apollo-otago-uat.archibus.cloud/
Health Check: POST with GraphQL query { apolloSettings { version } }
```

### **Load Balancer Configuration**
```yaml
Type: Application Load Balancer (ALB)
DNS: apollo-otago-uat.archibus.cloud
Target: prod-apollo-604503780.us-east-2.elb.amazonaws.com
SSL/TLS: Configured
Health Checks: Enabled
```

## **Backend Infrastructure**

### **WebCentral Node 3 (EC2)**
```yaml
Purpose: OnSite API Node for Otago UAT
Instance Type: [Check in AWS Console]
Instance ID: i-0f8b77b19aa4ceb11
Region: ap-southeast-2 (Sydney - Otago's region)
Status: Running
```

### **Configuration Files on Node 3**
```bash
Base Path: /opt/tomcat/webapps/archibus/WEB-INF/config/

# Key configuration files:
├── oidc.properties                    # Authentication settings
├── context/applications/
│   └── configservice.properties      # OnSite-specific settings
└── push-notification.properties      # Push notification config
```

### **Critical Configuration Values**
```properties
# configservice.properties
configService.onsite.clientId=<Azure AD App Client ID>
configService.onsite.issuerUrl=<Azure AD OIDC issuer URL>
configService.onsite.callbackUrl=com.archibus.onsite.auth://callback/
configService.onsite.apolloUrl=https://apollo-otago-uat.archibus.cloud
configService.onsite.notificationServiceUrl=<push notification URL>
configService.onsite.notificationServiceApiKey=<API key>

# oidc.properties
autoCreateUserAccount=false  # ⚠️ ISSUE: Should be true for OnSite
usernameClaim=sub           # Or preferred_username
maxThreads=800              # ✅ FIXED: Was 150, now optimized
```

## **Authentication & Authorization**

### **Azure AD Integration**
```yaml
Tenant: a26f49a8-... (Otago's Azure AD tenant)
Authentication Method: OIDC (OpenID Connect)
Token Validation: JWT tokens from Azure AD
User Creation: Manual (autoCreateUserAccount=false)
```

### **Known Authentication Issues**
- **Issue**: `autoCreateUserAccount=false` causes "Authentication must be not null" errors
- **Impact**: New users not pre-created in `afm_users` table fail to login
- **Resolution**: Set `autoCreateUserAccount=true`

## **Logging Architecture**

### **Log File Structure**
```bash
Pod Path: /app/logs/
Pattern: onsite-apollo-{type}-YYYY-MM-DD-HH.log[.gz]

# Log Types:
├── onsite-apollo-error-*        # Error logs (troubleshooting)
├── onsite-apollo-application-*  # Application logs (general activity)
└── audit-*.json                # Kubernetes audit logs
```

### **Log Rotation**
- **Compression**: Older logs compressed with gzip (.gz)
- **Recent Logs**: Current/recent logs remain uncompressed (.log)
- **Retention**: [Check cluster policy - appears to be 30+ days]
- **Timezone**: UTC (Coordinated Universal Time)

### **Log Volume Analysis**
```bash
# Typical log sizes (from recent analysis):
onsite-apollo-error-2026-03-23-01.log: 539 bytes (light usage)
onsite-apollo-error-2026-03-11-20.log.gz: ~20KB (compressed)

# Peak hours analysis:
Hours 20-22 UTC = 2pm-4pm MDT (typical business hours)
```

## **Version Compatibility Matrix**

| OnSite App | Apollo Version | WebCentral Version | Status |
|------------|----------------|-------------------|---------|
| 6.4.x | 6.4.x | 2025.02 | ✅ Latest (target) |
| 6.3.x | 6.3.x | 2024.04 | ✅ Current (Otago) |
| 6.4.x | 6.3.x | 2024.04 | ⚠️ Partial (upgrade needed) |

### **Upgrade Path for Otago**
```mermaid
Current: Apollo 6.3.4 + WebCentral 2024.04
    ↓
Target: Apollo 6.4.x + WebCentral 2025.02
```

## **Monitoring & Health Checks**

### **Health Check Endpoint**
```bash
# GraphQL health check
curl -X POST https://apollo-otago-uat.archibus.cloud/ \
  -H "Content-Type: application/json" \
  -d '{"query":"{ apolloSettings { contractVersion version webCentralVersion } }"}'

# Expected response:
{
  "data": {
    "apolloSettings": {
      "contractVersion": 1,
      "version": "6.3.4",
      "webCentralVersion": "2024.04"
    }
  }
}
```

### **Common Error Patterns**
```bash
# Version mismatch errors:
"Cannot query field 'mobileApps' on type 'User'"
→ Apollo version too old for OnSite app version

# Authentication errors:
"Authentication must be not null"
→ autoCreateUserAccount=false issue

# Performance issues:
HTTP 503 / Timeouts
→ Check maxThreads setting (should be 800)
```

## **Operational Procedures**

### **Log Extraction Commands**
```bash
# Connect to cluster
aws eks update-kubeconfig --name prod-apollo-cluster --region us-east-2 --profile AdministratorAccess-946135482630

# Find current pod
kubectl get pods -n otago-uat | grep apollo

# Extract compressed logs
kubectl exec -it apollo-otago-uat-79545b5c95-pnsxr -n otago-uat -- zcat /app/logs/onsite-apollo-error-2026-03-11-20.log.gz > error.log

# Extract uncompressed logs
kubectl exec -it apollo-otago-uat-79545b5c95-pnsxr -n otago-uat -- cat /app/logs/onsite-apollo-error-2026-03-23-01.log > error.log
```

### **Troubleshooting Access**
```bash
# SSH to Node 3 (no SSH keys needed)
aws ssm start-session --target i-0f8b77b19aa4ceb11 --profile AdministratorAccess-946135482630

# Check configuration files
sudo cat /opt/tomcat/webapps/archibus/WEB-INF/config/oidc.properties
sudo cat /opt/tomcat/webapps/archibus/WEB-INF/config/context/applications/configservice.properties
```

## **Push Notifications**

### **Infrastructure Components**
- **AWS SNS**: Simple Notification Service
- **DynamoDB**: Notification tracking
- **Lambda Functions**: Processing logic  
- **API Gateway**: REST endpoints

### **Configuration Issues**
```properties
# push-notification.properties (on all 3 nodes)
pushNotification.workspaceId=otago-uat.archibus.cloud
pushNotification.notificationServiceApiKey=<key>

# Known Issue: File duplicated (appended twice)
# Resolution: Clean up duplicate entries
```

## **Performance Optimization**

### **Thread Pool Configuration**
```xml
<!-- server.xml or context config -->
<Connector maxThreads="800" />  <!-- ✅ FIXED: Was 150 -->
```

### **Resource Monitoring**
```bash
# Pod resource usage
kubectl top pod apollo-otago-uat-79545b5c95-pnsxr -n otago-uat

# Node resource usage  
kubectl top nodes

# Detailed resource analysis
kubectl describe pod apollo-otago-uat-79545b5c95-pnsxr -n otago-uat
```

## **Security Considerations**

### **Network Security**
- **VPC**: Isolated network environment
- **Security Groups**: Controlled ingress/egress
- **TLS/SSL**: Encrypted communications
- **Private Subnets**: Backend components isolated

### **Authentication Security**
- **Azure AD OIDC**: Enterprise authentication
- **JWT Tokens**: Secure token-based auth
- **Role-Based Access**: Kubernetes RBAC
- **AWS IAM**: Cloud resource permissions

## **Disaster Recovery**

### **Backup Strategy**
- **EKS Cluster**: Managed service with AWS backup
- **Configuration**: Store in version control
- **Data**: WebCentral database backups
- **Logs**: Retained for analysis period

### **Recovery Procedures**
1. **Pod Recovery**: Kubernetes automatic restart
2. **Node Recovery**: EKS node group auto-scaling  
3. **Cluster Recovery**: EKS control plane resilience
4. **Application Recovery**: Redeploy from CI/CD pipeline

## **Key Contacts & Responsibilities**

| Component | Primary Owner | Backup |
|-----------|---------------|--------|
| Apollo EKS deployment/upgrade | Alex Plotkin | CloudOps Team |
| WAR deployment to Node 3 | Dany Silva | - |
| EC2/infrastructure config | Santosh Prasad | - |
| Log retrieval/analysis | Alex Plotkin | CloudOps Team |
| Push notification config | Santosh Prasad | - |
| Authentication/OIDC | Dany Silva | - |

## **Future Roadmap**

### **Planned Upgrades**
- **Apollo**: 6.3.4 → 6.4.x (compatibility with latest OnSite app)
- **WebCentral**: 2024.04 → 2025.02 (latest features)
- **EKS**: Regular Kubernetes version updates
- **Configuration**: Fix autoCreateUserAccount setting

### **Optimization Opportunities**
- **Logging**: Implement structured logging
- **Monitoring**: Add Prometheus/Grafana
- **Alerting**: CloudWatch alarms for critical metrics
- **Security**: Regular security assessments