# Archibus OnSite — CloudOps Reference Guide

> Maintained by: CloudOps team (Maninder Singh)
> Last updated: March 2026

---

## 1. What Is OnSite?

OnSite is a mobile app (React Native) that lets facility staff inspect and update work orders on the go.

```
[OnSite Mobile App]
       ↓
[Apollo GraphQL Server]  ← the "middle layer" (runs on AWS EKS)
       ↓
[Archibus WebCentral]   ← the "backend" (runs on EC2, Node 3)
```

**Three things must all be healthy for OnSite to work:**
1. The mobile app (iOS/Android)
2. Apollo GraphQL server (EKS pod)
3. WebCentral Node 3 (EC2 instance)

---

## 2. AWS Account

- **Account ID:** `946135482630`
- **SSO Login:** `aws sso login --profile AdministratorAccess-946135482630`
- **SSO Portal:** `spaceiq.awsapps.com`

---

## 3. Apollo GraphQL Servers (EKS)

Apollo is the most important component unique to OnSite. It runs on Kubernetes (EKS).

### Clusters

| Cluster Name | Region | Purpose |
|---|---|---|
| `prod-apollo-cluster-west` | `us-west-2` | **Active cluster — ALL environments** |
| `prod-apollo-cluster` | `us-east-2` | (legacy, unused) |
| `onsite-apollo-cluster-west` | `us-west-2` | Staging (inactive) |
| `onsite-apollo-cluster` | `us-east-2` | Staging (inactive) |

> **Important:** Despite being named "prod", `prod-apollo-cluster-west` serves BOTH prod and UAT namespaces.

### Kubernetes Namespaces

| Namespace | Pods | URL |
|---|---|---|
| `prod` | `apollo-prod-*` (4 pods) | `apollo.archibus.cloud` |
| `uat` | `apollo-uat-*` (2 pods) | `apollo-uat.archibus.cloud` |

### Connect to EKS

```powershell
aws eks update-kubeconfig --region us-west-2 --name prod-apollo-cluster-west --profile AdministratorAccess-946135482630
```

### Useful kubectl Commands

```bash
# List all pods in UAT namespace
kubectl get pods -n uat

# Stream live logs from a UAT pod
kubectl logs -n uat <pod-name> -f

# Check today's error log inside a pod
kubectl exec -n uat <pod-name> -- cat /app/logs/onsite-apollo-error-$(date +%Y-%m-%d)-05.log

# List all log files inside a pod
kubectl exec -n uat <pod-name> -- ls /app/logs/
```

### Quick Apollo Health Check (No AWS needed — public URL)

```powershell
# PowerShell
Invoke-RestMethod -Method POST -Uri "https://apollo-uat.archibus.cloud/" `
  -ContentType "application/json" `
  -Body '{"query":"{ apolloSettings { contractVersion version webCentralVersion } }"}'

# Or curl.exe
curl.exe -X POST https://apollo-uat.archibus.cloud/ -H "Content-Type: application/json" -d "{\"query\":\"{ apolloSettings { contractVersion version webCentralVersion } }\"}"
```

Expected response:
```json
{"data":{"apolloSettings":{"contractVersion":1,"version":"6.x.x","webCentralVersion":"20xx.x"}}}
```

**Per-customer Apollo URLs (UAT):**
- Otago UAT: `https://apollo-otago-uat.archibus.cloud/`
- Default UAT: `https://apollo-uat.archibus.cloud/`

---

## 4. WebCentral Node 3 (EC2 — OnSite API Node)

Every customer has 3 EC2 nodes. **Node 3** is the OnSite API node. All OnSite config lives here.

### Find Node 3 for a Customer

In AWS Console → EC2 → Search: `ArchibusCloud-<customer>-<env>-api`

Example: `ArchibusCloud-otago-uat-api`

### SSH Into Node 3 (SSM — no SSH key needed)

```powershell
aws ssm start-session --target <instance-id> --profile AdministratorAccess-946135482630
```

### Key Config Files on Node 3

All paths are inside the WebCentral webapp directory:
```
/opt/tomcat/webapps/archibus/WEB-INF/config/
```

| File | What It Controls |
|---|---|
| `oidc.properties` | Login / authentication (Azure AD SSO) |
| `context/applications/configservice.properties` | OnSite-specific settings (Apollo URL, client ID, etc.) |
| `push-notification.properties` | Push notification AWS SNS settings |

### configservice.properties — Required Fields

```properties
configService.onsite.clientId=<Azure AD App Client ID>
configService.onsite.issuerUrl=<Azure AD OIDC issuer URL>
configService.onsite.callbackUrl=com.archibus.onsite.auth://callback/
configService.onsite.apolloUrl=https://apollo-<customer>-<env>.archibus.cloud
configService.onsite.notificationServiceUrl=<push notification API Gateway URL>
configService.onsite.notificationServiceApiKey=<API key>
```

> ⚠️ If ALL of these are blank, OnSite is **not configured** for that customer. Treat as environment setup required.

### oidc.properties — Critical Fields

```properties
autoCreateUserAccount=true   ← MUST be true for OnSite to work
usernameClaim=sub            ← or preferred_username (must match Azure AD config)
```

> ⚠️ If `autoCreateUserAccount=false`, any user not pre-created in `afm_users` table will get:
> `Authentication must be not null` error

### Thread Count (Performance)

```properties
# In server.xml or context config:
maxThreads=800  ← target value (was 150 = too low, caused timeouts)
```

---

## 5. Customer Environments — Current Status

### Otago UAT
- **Instance:** `i-0f8b77b19aa4ceb11` (ap-southeast-2)
- **Apollo URL:** `https://apollo-otago-uat.archibus.cloud`
- **Apollo Version:** `6.3.4` (deployed June 2025 — needs upgrade to 6.4.x)
- **WebCentral Version:** `2024.04`
- **Auth Tenant:** Azure AD `a26f49a8-...`
- ⚠️ `autoCreateUserAccount=false` — potential auth failures for new users
- ⚠️ `push-notification.properties` duplicated (appended twice in file)
- ✅ configservice.properties is fully populated
- ✅ maxThreads=800 (fixed by CM-103774)

### RSLQLD UAT
- **Instance:** `i-098879595c3d2b371` (ap-southeast-2)
- **Apollo URL:** Not configured
- ❌ configservice.properties ALL BLANK — OnSite not configured
- ❌ push-notification.properties ALL BLANK

---

## 6. Version Compatibility Matrix

| OnSite App | Apollo Version | WebCentral Version |
|---|---|---|
| 6.4.x | 6.4.x | 2025.02 ✅ (latest) |
| 6.3.x | 6.3.x | 2024.04 ✅ |
| 6.4.x | 6.3.x | 2024.04 ⚠️ (partial — new GraphQL fields missing) |

> If you see: `Cannot query field "mobileApps" on type "User"` → Apollo version is too old for the app version.

---

## 7. Push Notifications

OnSite push notifications use AWS SNS + DynamoDB + Lambda + API Gateway.

**push-notification.properties required fields:**
```properties
pushNotification.workspaceId=<customer>-<env>.archibus.cloud
pushNotification.notificationServiceApiKey=<key>
```

These must be present on **all 3 nodes** (not just Node 3).

---

## 8. Common Issues & Quick Diagnosis

### "Authentication must be not null" on login
→ Check `oidc.properties`: `autoCreateUserAccount` must be `true`

### User can't log in (401 from Apollo logs)
→ Run health check curl on Apollo URL
→ Check Apollo logs: `kubectl logs -n uat <pod> | grep "401"`
→ May be OIDC token rejected at WebCentral — check `oidc.properties`

### OnSite app crashes immediately
→ Run Apollo health check — if no response, Apollo pod is down
→ `kubectl get pods -n uat` — check pod status

### Push notifications not working
→ Check `push-notification.properties` exists and is populated on Node 3
→ Check it's not duplicated (appended twice)

### Slow performance / timeouts
→ Check `maxThreads` in server config — should be `800`, not `150`

### `Cannot query field X on type Y` in Apollo logs
→ Version mismatch: OnSite app is newer than Apollo
→ Apollo needs to be upgraded

---

## 9. Who Does What (Ticket Routing)

| Task | Owner |
|---|---|
| Apollo EKS deployment / upgrade | **Alex Plotkin** |
| WAR deployment to Node 3 | **Dany Silva** |
| EC2 / infrastructure config | **Santosh Prasad** |
| Log retrieval (SSM) | **Alex Plotkin** |
| Mobile app release / Allbound | **Alex Plotkin** |
| Push notification config | **Santosh Prasad** |
| Auth / OIDC config | **Dany Silva** |

---

## 10. Useful Confluence Pages

| Topic | Page ID |
|---|---|
| OnSite Architecture | `2607251590` |
| OnSite Deployment (Typical) | `3760390151` |
| OnSite Deployment (Config) | `2144272657` |
| OnSite Notifications | `2214330628` |
| Component Compatibility Matrix | `3371106324` |
| AWS Deployment (Apollo/EKS) | `2168226157` |

Access via: `https://eptura.atlassian.net/wiki/pages/<page-id>`

---

## 11. Jira — Useful JQL Filters

```
# All open OnSite tickets
project = CM AND labels = OnSite AND status != Done ORDER BY created DESC

# Apollo deployment tickets
project = CM AND labels = OnSite AND summary ~ "Apollo" ORDER BY created DESC

# OnSite tickets assigned to Alex
project = CM AND labels = OnSite AND assignee = "Alex Plotkin" ORDER BY created DESC
```
