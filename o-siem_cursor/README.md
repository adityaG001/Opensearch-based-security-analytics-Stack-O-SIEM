# O-SIEM: OpenSearch Security Information and Event Management Stack

## Project Overview

This is a complete Security Information and Event Management (SIEM) stack built using OpenSearch, designed for log collection, analysis, and security monitoring. The project demonstrates a production-ready SIEM solution using modern containerized technologies.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Log Sources   │    │   Fluent Bit    │    │    Logstash     │
│                 │───▶│   (Log Shipper) │───▶│  (Processing)   │
│ • Sample Logs   │    │                 │    │                 │
│ • Syslog        │    └─────────────────┘    └─────────────────┘
│ • HTTP Input    │                                    │
└─────────────────┘                                    ▼
                                             ┌─────────────────┐
                                             │   OpenSearch    │
                                             │   (Analytics)   │
                                             └─────────────────┘
                                                     │
                                                     ▼
                                             ┌─────────────────┐
                                             │   Dashboards    │
                                             │   (Visualize)   │
                                             └─────────────────┘
```

### Component Details

| Component | Version | Purpose | Ports |
|-----------|---------|---------|-------|
| OpenSearch | 1.3.14 | Data storage & search | 9200 |
| OpenSearch Dashboards | 1.3.14 | Web interface | 5601 |
| Logstash | 7.17.0 | Log processing | 8080, 9600 |
| Fluent Bit | Latest | Log collection | - |
| Syslog-ng | Latest | Syslog server | 514 (UDP), 5151 (TCP) |

## Step-by-Step Setup Guides

### For Developers (Local Development)

#### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available
- Git installed

#### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd o-siem_cursor
   ```

2. **Verify Prerequisites**
   ```bash
   # Check Docker
   docker --version
   docker-compose --version
   
   # Check available memory
   free -h
   ```

3. **Start the Stack**
   ```bash
   # Start all services
   docker-compose up -d
   
   # Check service status
   docker-compose ps
   ```

4. **Verify Installation**
   ```bash
   # Check OpenSearch health
   curl http://localhost:9200/_cluster/health
   
   # Check Dashboards
   curl http://localhost:5601/api/status
   
   # Check Logstash
   curl http://localhost:9600/_node/stats
   ```

5. **Access Services**
   - OpenSearch Dashboards: http://localhost:5601
   - OpenSearch API: http://localhost:9200
   - Logstash HTTP Input: http://localhost:8080

#### Development Workflow

1. **Modify Configurations**
   ```bash
   # Edit Logstash pipeline
   vim config/logstash/logstash.conf
   
   # Edit Fluent Bit config
   vim config/fluent-bit/fluent-bit.conf
   ```

2. **Restart Services**
   ```bash
   # Restart specific service
   docker-compose restart logstash
   
   # Restart all services
   docker-compose down && docker-compose up -d
   ```

3. **View Logs**
   ```bash
   # View all logs
   docker-compose logs -f
   
   # View specific service logs
   docker-compose logs -f logstash
   ```

### For End Users (Installation & Configuration)

#### System Requirements
- Linux/macOS/Windows with Docker support
- 4GB RAM minimum, 8GB recommended
- 10GB free disk space
- Network access for container images

#### Installation Steps

1. **Download and Extract**
   ```bash
   # Download project
   wget <project-url>
   tar -xzf o-siem.tar.gz
   cd o-siem_cursor
   ```

2. **Configure Environment**
   ```bash
   # Create environment file
   cp .env.example .env
   
   # Edit configuration
   vim .env
   ```

3. **Start Services**
   ```bash
   # Start stack
   docker-compose up -d
   
   # Wait for services to be ready
   sleep 30
   ```

4. **Initial Setup**
   ```bash
   # Create initial index pattern
   curl -X PUT "localhost:9200/_template/o-siem-template" \
     -H "Content-Type: application/json" \
     -d @config/opensearch/templates/syslog-template.json
   ```

#### Sending Logs

1. **Via HTTP (Manual Testing)**
   ```bash
   # Send test log
   curl -X POST http://localhost:8080 \
     -H "Content-Type: application/json" \
     -d '{
       "message": "Test log entry",
       "timestamp": "2024-01-15T10:30:00Z",
       "source": "manual-test"
     }'
   ```

2. **Via Syslog**
   ```bash
   # Send syslog message
   echo "Test syslog message" | nc -u localhost 514
   
   # Send via TCP
   echo "Test TCP syslog" | nc localhost 5151
   ```

3. **File-based Logs**
   ```bash
   # Add logs to sample-logs directory
   echo "New log entry" >> sample-logs/system.log
   
   # Restart Fluent Bit to pick up changes
   docker-compose restart fluentbit
   ```

#### Configuration Options

1. **Modify Log Sources**
   ```bash
   # Edit Fluent Bit configuration
   vim config/fluent-bit/fluent-bit.conf
   
   # Add new input section
   [INPUT]
       Name tail
       Path /path/to/your/logs/*.log
       Tag your-logs
   ```

2. **Custom Log Processing**
   ```bash
   # Edit Logstash pipeline
   vim config/logstash/logstash.conf
   
   # Add new filter for your log format
   if [message] =~ /your-pattern/ {
       grok {
           match => { "message" => "your-grok-pattern" }
       }
   }
   ```

### For Security Analysts (Dashboards & Analysis)

#### Initial Dashboard Setup

1. **Access OpenSearch Dashboards**
   - Open browser: http://localhost:5601
   - No login required (security disabled)

2. **Create Index Pattern**
   ```
   Stack Management → Index Patterns → Create Index Pattern
   Pattern name: o-siem-*
   Time field: @timestamp
   ```

3. **Set as Default**
   - Select the created pattern
   - Click "Set as default index pattern"

#### Creating Visualizations

1. **Failed Login Attempts Chart**
   ```
   Visualize → Create Visualization → Line
   Index: o-siem-*
   Y-axis: Count
   X-axis: Date Histogram (@timestamp)
   Filter: event_type: failed_login
   ```

2. **Top Source IPs**
   ```
   Visualize → Create Visualization → Data Table
   Index: o-siem-*
   Metrics: Count
   Buckets: Split Rows
   Aggregation: Terms
   Field: source_ip
   Size: 10
   ```

3. **Geographic Threat Map**
   ```
   Visualize → Create Visualization → Coordinate Map
   Index: o-siem-*
   Metrics: Count
   Buckets: Geo Coordinates
   Aggregation: Geohash
   Field: geoip.location
   ```

#### Building Dashboards

1. **Security Overview Dashboard**
   ```
   Dashboard → Create Dashboard
   Add visualizations:
   - Failed login attempts over time
   - Top source IPs
   - Geographic threat map
   - Event type distribution
   ```

2. **Threat Hunting Dashboard**
   ```
   Dashboard → Create Dashboard
   Add visualizations:
   - Suspicious IP activity
   - User session monitoring
   - Port scanning detection
   - Data access patterns
   ```

#### Advanced Queries

1. **Search for Failed Logins**
   ```
   Discover → Search: event_type: failed_login
   ```

2. **Find Suspicious IPs**
   ```
   Discover → Search: source_ip: 192.168.1.* AND event_type: failed_login
   ```

3. **Time-based Analysis**
   ```
   Discover → Search: @timestamp:[now-1h TO now] AND log_type: security
   ```

4. **Complex Queries**
   ```
   Discover → Search: 
   (event_type: failed_login OR event_type: user_login) 
   AND source_ip: * 
   AND NOT source_ip: 10.0.0.*
   ```

#### Alerting Setup

1. **Create Alert**
   ```
   Alerting → Create Alert
   Monitor Type: Query
   Index: o-siem-*
   Query: event_type: failed_login AND source_ip: *
   ```

2. **Configure Actions**
   ```
   Action: Email
   Subject: Failed Login Alert
   Body: Failed login detected from {{source_ip}}
   ```

## Sample Log Files and Expected Behavior

### Included Sample Files

| File | Content | Expected Processing |
|------|---------|-------------------|
| `auth.log` | SSH authentication events | Failed login detection, user session tracking |
| `security.log` | JSON security events | Direct JSON parsing, IP extraction |
| `syslog.log` | Standard syslog messages | Syslog parsing, timestamp normalization |
| `system.log` | Linux system events | System event classification |
| `sh_arp_cache_*.log` | Linux audit logs | Audit log parsing, field extraction |

### Sample Log Entries

1. **Authentication Logs**
   ```
   Failed password for user admin from 192.168.1.100
   session opened for user john by (uid=0)
   ```

2. **Security Events (JSON)**
   ```json
   {
     "event_type": "malware_detection",
     "message": "Malware detected: trojan.exe",
     "source_ip": "10.0.0.50",
     "timestamp": "2024-01-15T10:30:00Z"
   }
   ```

3. **Syslog Messages**
   ```
   Jan 15 10:30:00 server sshd[1234]: Accepted password for user admin
   Jan 15 10:31:00 server kernel: [12345] Firewall blocked connection from 192.168.1.200
   ```

### Expected Processing Results

1. **Failed Login Detection**
   - Extracts username and source IP
   - Adds `event_type: failed_login`
   - Performs GeoIP lookup on source IP

2. **User Session Monitoring**
   - Extracts username and session details
   - Adds `event_type: user_login`
   - Tracks session lifecycle

3. **Security Event Correlation**
   - Parses JSON security events
   - Extracts threat indicators
   - Enriches with geographic data

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Services Won't Start

**Problem**: `docker-compose up` fails
```bash
# Check Docker status
docker info

# Check available resources
free -h
df -h

# Check port conflicts
netstat -tulpn | grep :9200
netstat -tulpn | grep :5601
```

**Solution**:
```bash
# Stop conflicting services
sudo systemctl stop elasticsearch
sudo systemctl stop kibana

# Increase Docker memory
# Edit Docker Desktop settings or docker daemon config
```

#### 2. OpenSearch Won't Start

**Problem**: OpenSearch container exits
```bash
# Check logs
docker-compose logs opensearch

# Check memory settings
docker-compose exec opensearch cat /proc/meminfo
```

**Solution**:
```bash
# Increase JVM heap size
vim config/opensearch/jvm.options
# Change: -Xms512m -Xmx512m to -Xms1g -Xmx1g

# Restart service
docker-compose restart opensearch
```

#### 3. No Logs Appearing

**Problem**: Logs not showing in OpenSearch
```bash
# Check indices
curl http://localhost:9200/_cat/indices

# Check Logstash pipeline
curl http://localhost:9600/_node/stats/pipeline
```

**Solution**:
```bash
# Check Fluent Bit logs
docker-compose logs fluentbit

# Verify log files exist
ls -la sample-logs/

# Restart Fluent Bit
docker-compose restart fluentbit
```

#### 4. Dashboards Not Accessible

**Problem**: Can't access http://localhost:5601
```bash
# Check service status
docker-compose ps dashboards

# Check logs
docker-compose logs dashboards
```

**Solution**:
```bash
# Clear browser cache
# Try incognito/private mode

# Check network connectivity
curl http://localhost:5601/api/status

# Restart service
docker-compose restart dashboards
```

#### 5. Logstash Pipeline Errors

**Problem**: Logstash processing errors
```bash
# Check Logstash logs
docker-compose logs logstash

# Test configuration
docker-compose exec logstash bin/logstash -t
```

**Solution**:
```bash
# Fix configuration syntax
vim config/logstash/logstash.conf

# Restart Logstash
docker-compose restart logstash
```

### Performance Issues

#### High Memory Usage
```bash
# Check memory usage
docker stats

# Optimize JVM settings
vim config/opensearch/jvm.options
# Set heap to 50% of available memory

# Optimize Logstash
vim docker-compose.yml
# Adjust LS_JAVA_OPTS
```

#### Slow Query Performance
```bash
# Check index size
curl http://localhost:9200/_cat/indices?v

# Optimize index settings
curl -X PUT "localhost:9200/o-siem-*/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index":{"number_of_replicas":0}}'
```

### Network Issues

#### Container Communication
```bash
# Check network
docker network ls
docker network inspect o-siem_cursor_o-siem-network

# Test connectivity
docker-compose exec logstash ping opensearch
docker-compose exec fluentbit ping logstash
```

#### Port Conflicts
```bash
# Find conflicting processes
sudo lsof -i :9200
sudo lsof -i :5601
sudo lsof -i :8080

# Kill conflicting processes
sudo kill -9 <PID>
```

## Security Hardening Tips

### Basic Security Measures

#### 1. Enable Authentication

**OpenSearch Security**
```bash
# Edit OpenSearch configuration
vim config/opensearch/opensearch.yml

# Add security settings
plugins.security.disabled: false
plugins.security.ssl.http.enabled: true
plugins.security.ssl.transport.enabled: true
```

**Create Users**
```bash
# Access OpenSearch Dashboards
# Go to Security → Internal Users → Create
# Create admin user with appropriate roles
```

#### 2. Enable TLS/SSL

**Generate Certificates**
```bash
# Create certificates directory
mkdir -p config/opensearch/certs

# Generate self-signed certificates
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

**Configure TLS**
```bash
# Update OpenSearch configuration
vim config/opensearch/opensearch.yml

# Add SSL settings
plugins.security.ssl.http.enabled: true
plugins.security.ssl.http.pemcert_filepath: cert.pem
plugins.security.ssl.http.pemkey_filepath: key.pem
```

#### 3. Network Security

**Firewall Configuration**
```bash
# Allow only necessary ports
sudo ufw allow 5601/tcp  # Dashboards
sudo ufw allow 9200/tcp  # OpenSearch API
sudo ufw deny 514/udp    # Syslog (if not needed externally)
```

**Docker Network Security**
```bash
# Create isolated network
docker network create --driver bridge --internal o-siem-internal

# Update docker-compose.yml to use internal network
networks:
  o-siem-internal:
    driver: bridge
    internal: true
```

#### 4. Access Control

**IP Whitelisting**
```bash
# Configure nginx reverse proxy
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        allow 192.168.1.0/24;
        deny all;
        proxy_pass http://localhost:5601;
    }
}
```

**API Rate Limiting**
```bash
# Configure rate limiting in nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

location /api/ {
    limit_req zone=api burst=20 nodelay;
    proxy_pass http://localhost:9200;
}
```

#### 5. Data Protection

**Encryption at Rest**
```bash
# Enable disk encryption
sudo cryptsetup luksFormat /dev/sdb1
sudo cryptsetup luksOpen /dev/sdb1 encrypted-data

# Mount encrypted volume
sudo mount /dev/mapper/encrypted-data /var/lib/docker/volumes/
```

**Backup Strategy**
```bash
# Create backup script
vim backup-siem.sh

#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/siem/$DATE"

# Backup OpenSearch data
docker-compose exec opensearch tar czf - /usr/share/opensearch/data > $BACKUP_DIR/opensearch-data.tar.gz

# Backup configurations
tar czf $BACKUP_DIR/configs.tar.gz config/

# Cleanup old backups (keep 7 days)
find /backup/siem -type d -mtime +7 -exec rm -rf {} \;
```

#### 6. Monitoring and Alerting

**Security Monitoring**
```bash
# Monitor failed login attempts
curl -X POST "localhost:9200/_watcher/watch/failed-logins" \
  -H "Content-Type: application/json" \
  -d '{
    "trigger": {"schedule": {"interval": "1m"}},
    "input": {"search": {"request": {"indices": ["o-siem-*"], "body": {"query": {"term": {"event_type": "failed_login"}}}}}},
    "actions": {"email_admin": {"email": {"to": "admin@company.com", "subject": "Failed Login Alert"}}}
  }'
```

**Audit Logging**
```bash
# Enable audit logging
vim config/opensearch/opensearch.yml

# Add audit settings
plugins.security.audit.type: internal_opensearch
plugins.security.audit.config.enabled: true
plugins.security.audit.config.audit_request_body: true
```

### Production Checklist

- [ ] Enable authentication and authorization
- [ ] Configure TLS/SSL certificates
- [ ] Set up firewall rules
- [ ] Implement backup strategy
- [ ] Configure monitoring and alerting
- [ ] Set up log rotation and retention
- [ ] Implement network segmentation
- [ ] Regular security updates
- [ ] Access control and user management
- [ ] Audit logging enabled

## Prerequisites

- Docker and Docker Compose
- At least 4GB RAM available
- Ports 5601, 9200, 514, 5151, 8080 available

## Step-by-Step Setup Guides

### For Developers (Local Development)

#### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available
- Git installed

#### Setup Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd o-siem_cursor
   ```

2. **Verify Prerequisites**
   ```bash
   # Check Docker
   docker --version
   docker-compose --version
   
   # Check available memory
   free -h
   ```

3. **Start the Stack**
   ```bash
   # Start all services
   docker-compose up -d
   
   # Check service status
   docker-compose ps
   ```

4. **Verify Installation**
   ```bash
   # Check OpenSearch health
   curl http://localhost:9200/_cluster/health
   
   # Check Dashboards
   curl http://localhost:5601/api/status
   
   # Check Logstash
   curl http://localhost:9600/_node/stats
   ```

5. **Access Services**
   - OpenSearch Dashboards: http://localhost:5601
   - OpenSearch API: http://localhost:9200
   - Logstash HTTP Input: http://localhost:8080

#### Development Workflow

1. **Modify Configurations**
   ```bash
   # Edit Logstash pipeline
   vim config/logstash/logstash.conf
   
   # Edit Fluent Bit config
   vim config/fluent-bit/fluent-bit.conf
   ```

2. **Restart Services**
   ```bash
   # Restart specific service
   docker-compose restart logstash
   
   # Restart all services
   docker-compose down && docker-compose up -d
   ```

3. **View Logs**
   ```bash
   # View all logs
   docker-compose logs -f
   
   # View specific service logs
   docker-compose logs -f logstash
   ```

### For End Users (Installation & Configuration)

#### System Requirements
- Linux/macOS/Windows with Docker support
- 4GB RAM minimum, 8GB recommended
- 10GB free disk space
- Network access for container images

#### Setup Steps

1. **Download and Extract**
   ```bash
   # Download project
   wget <project-url>
   tar -xzf o-siem.tar.gz
   cd o-siem_cursor
   ```

2. **Configure Environment**
   ```bash
   # Create environment file
   cp .env.example .env
   
   # Edit configuration
   vim .env
   ```

3. **Start Services**
   ```bash
   # Start stack
   docker-compose up -d
   
   # Wait for services to be ready
   sleep 30
   ```

4. **Initial Setup**
   ```bash
   # Create initial index pattern
   curl -X PUT "localhost:9200/_template/o-siem-template" \
     -H "Content-Type: application/json" \
     -d @config/opensearch/templates/syslog-template.json
   ```

#### Sending Logs

1. **Via HTTP (Manual Testing)**
   ```bash
   # Send test log
   curl -X POST http://localhost:8080 \
     -H "Content-Type: application/json" \
     -d '{
       "message": "Test log entry",
       "timestamp": "2024-01-15T10:30:00Z",
       "source": "manual-test"
     }'
   ```

2. **Via Syslog**
   ```bash
   # Send syslog message
   echo "Test syslog message" | nc -u localhost 514
   
   # Send via TCP
   echo "Test TCP syslog" | nc localhost 5151
   ```

3. **File-based Logs**
   ```bash
   # Add logs to sample-logs directory
   echo "New log entry" >> sample-logs/system.log
   
   # Restart Fluent Bit to pick up changes
   docker-compose restart fluentbit
   ```

#### Configuration Options

1. **Modify Log Sources**
   ```bash
   # Edit Fluent Bit configuration
   vim config/fluent-bit/fluent-bit.conf
   
   # Add new input section
   [INPUT]
       Name tail
       Path /path/to/your/logs/*.log
       Tag your-logs
   ```

2. **Custom Log Processing**
   ```bash
   # Edit Logstash pipeline
   vim config/logstash/logstash.conf
   
   # Add new filter for your log format
   if [message] =~ /your-pattern/ {
       grok {
           match => { "message" => "your-grok-pattern" }
       }
   }
   ```

### For Security Analysts (Dashboards & Analysis)

#### Initial Dashboard Setup

1. **Access OpenSearch Dashboards**
   - Open browser: http://localhost:5601
   - No login required (security disabled)

2. **Create Index Pattern**
   ```
   Stack Management → Index Patterns → Create Index Pattern
   Pattern name: o-siem-*
   Time field: @timestamp
   ```

3. **Set as Default**
   - Select the created pattern
   - Click "Set as default index pattern"

#### Creating Visualizations

1. **Failed Login Attempts Chart**
   ```
   Visualize → Create Visualization → Line
   Index: o-siem-*
   Y-axis: Count
   X-axis: Date Histogram (@timestamp)
   Filter: event_type: failed_login
   ```

2. **Top Source IPs**
   ```
   Visualize → Create Visualization → Data Table
   Index: o-siem-*
   Metrics: Count
   Buckets: Split Rows
   Aggregation: Terms
   Field: source_ip
   Size: 10
   ```

3. **Geographic Threat Map**
   ```
   Visualize → Create Visualization → Coordinate Map
   Index: o-siem-*
   Metrics: Count
   Buckets: Geo Coordinates
   Aggregation: Geohash
   Field: geoip.location
   ```

#### Building Dashboards

1. **Security Overview Dashboard**
   ```
   Dashboard → Create Dashboard
   Add visualizations:
   - Failed login attempts over time
   - Top source IPs
   - Geographic threat map
   - Event type distribution
   ```

2. **Threat Hunting Dashboard**
   ```
   Dashboard → Create Dashboard
   Add visualizations:
   - Suspicious IP activity
   - User session monitoring
   - Port scanning detection
   - Data access patterns
   ```

#### Advanced Queries

1. **Search for Failed Logins**
   ```
   Discover → Search: event_type: failed_login
   ```

2. **Find Suspicious IPs**
   ```
   Discover → Search: source_ip: 192.168.1.* AND event_type: failed_login
   ```

3. **Time-based Analysis**
   ```
   Discover → Search: @timestamp:[now-1h TO now] AND log_type: security
   ```

4. **Complex Queries**
   ```
   Discover → Search: 
   (event_type: failed_login OR event_type: user_login) 
   AND source_ip: * 
   AND NOT source_ip: 10.0.0.*
   ```

#### Alerting Setup

1. **Create Alert**
   ```
   Alerting → Create Alert
   Monitor Type: Query
   Index: o-siem-*
   Query: event_type: failed_login AND source_ip: *
   ```

2. **Configure Actions**
   ```
   Action: Email
   Subject: Failed Login Alert
   Body: Failed login detected from {{source_ip}}
   ```

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd o-siem_cursor
   ```

2. **Start the stack:**
   ```bash
   docker-compose up -d
   ```

3. **Import Dashboards (Optional but Recommended):**
   ```bash
   # Make the script executable
   chmod +x scripts/import_dashboards.sh
   
   # Import pre-configured dashboards
   ./scripts/import_dashboards.sh
   ```

4. **Ingest Sample Logs (Optional):**
   ```bash
   # Make the script executable
   chmod +x scripts/ingest_sample_logs.sh
   
   # Ingest sample logs for testing
   ./scripts/ingest_sample_logs.sh
   ```

5. **Access the services:**
   - OpenSearch Dashboards: http://localhost:5601
   - OpenSearch API: http://localhost:9200
   - Logstash HTTP Input: http://localhost:8080
   - Syslog endpoint: localhost:514 (UDP) or localhost:5151 (TCP)

## Importing Dashboards and Ingesting Logs

### Importing Pre-configured Dashboards

The project includes pre-configured dashboards and visualizations that provide immediate value for security analysis. These dashboards are stored in the `dashboards/o-siem-dashboards.ndjson` file.

#### Automatic Import (Recommended)

1. **Using the provided script:**
   ```bash
   # Make the script executable
   chmod +x scripts/import_dashboards.sh
   
   # Import dashboards
   ./scripts/import_dashboards.sh
   ```

2. **Verify import:**
   - Open OpenSearch Dashboards: http://localhost:5601
   - Navigate to Dashboard → Saved Objects
   - You should see imported dashboards and visualizations

#### Manual Import

If the script doesn't work, you can import manually:

1. **Access OpenSearch Dashboards:**
   - Open http://localhost:5601 in your browser

2. **Import saved objects:**
   ```
   Stack Management → Saved Objects → Import
   Select file: dashboards/o-siem-dashboards.ndjson
   Click Import
   ```

3. **Verify imported objects:**
   - Check Dashboard section for new dashboards
   - Check Visualize section for new visualizations
   - Check Discover section for saved searches

### Ingesting Sample Logs

The project includes sample log files for testing and demonstration purposes. These logs are located in the `sample-logs/` directory.

#### Automatic Ingestion (Recommended)

1. **Using the provided script:**
   ```bash
   # Make the script executable
   chmod +x scripts/ingest_sample_logs.sh
   
   # Ingest all sample logs
   ./scripts/ingest_sample_logs.sh
   ```

2. **Verify ingestion:**
   ```bash
   # Check if logs are indexed
   curl http://localhost:9200/_cat/indices
   
   # Search for ingested logs
   curl "http://localhost:9200/o-siem-*/_search?pretty"
   ```

#### Manual Ingestion

You can also ingest logs manually:

1. **Send individual log entries:**
   ```bash
   # Send a test log via HTTP
   curl -X POST http://localhost:8080 \
     -H "Content-Type: application/json" \
     -d '{
       "message": "Failed password for user admin from 192.168.1.100",
       "timestamp": "2024-01-15T10:30:00Z",
       "source": "manual-test"
     }'
   ```

2. **Send logs from files:**
   ```bash
   # Send logs from a specific file
   while IFS= read -r line; do
     curl -s -X POST http://localhost:8080 \
       -H "Content-Type: application/json" \
       -d "{\"message\": \"$line\"}"
   done < sample-logs/auth.log
   ```

3. **Send via syslog:**
   ```bash
   # Send syslog message
   echo "Test syslog message" | nc -u localhost 514
   
   # Send via TCP
   echo "Test TCP syslog" | nc localhost 5151
   ```

#### Sample Log Files Included

The following sample log files are included for testing:

| File | Description | Content Type |
|------|-------------|--------------|
| `auth.log` | SSH authentication events | Failed login attempts, successful logins |
| `security.log` | Security events in JSON format | Malware detection, threat alerts |
| `syslog.log` | Standard syslog messages | System events, kernel messages |
| `system.log` | Linux system events | System logs, service events |
| `sh_arp_cache_*.log` | Linux audit logs | Audit trail, system calls |

#### Expected Results After Ingestion

After ingesting the sample logs, you should see:

1. **Indexed Data:**
   - Logs indexed in OpenSearch with pattern `o-siem-YYYY.MM.DD`
   - Parsed fields including `source_ip`, `event_type`, `message`
   - GeoIP enrichment for IP addresses

2. **Available Visualizations:**
   - Failed login attempts over time
   - Top source IPs by activity
   - Geographic threat map
   - Event type distribution

3. **Searchable Data:**
   - All log messages searchable via Discover
   - Structured fields for filtering and analysis
   - Time-based queries supported

### Troubleshooting Import/Ingestion

#### Dashboard Import Issues

1. **Script fails:**
   ```bash
   # Check if OpenSearch Dashboards is running
   curl http://localhost:5601/api/status
   
   # Check if the dashboard file exists
   ls -la dashboards/o-siem-dashboards.ndjson
   
   # Try manual import via web interface
   ```

2. **Dashboards not appearing:**
   - Clear browser cache
   - Check browser console for errors
   - Verify OpenSearch Dashboards version compatibility

#### Log Ingestion Issues

1. **Script fails:**
   ```bash
   # Check if Logstash is running
   curl http://localhost:9600/_node/stats
   
   # Check Logstash logs
   docker-compose logs logstash
   
   # Verify HTTP input is accessible
   curl http://localhost:8080
   ```

2. **Logs not appearing in OpenSearch:**
   ```bash
   # Check indices
   curl http://localhost:9200/_cat/indices
   
   # Check Logstash pipeline
   curl http://localhost:9600/_node/stats/pipeline
   
   # Restart Logstash if needed
   docker-compose restart logstash
   ```

## Sample Log Files and Expected Behavior

### Included Sample Files

| File | Content | Expected Processing |
|------|---------|-------------------|
| `auth.log` | SSH authentication events | Failed login detection, user session tracking |
| `security.log` | JSON security events | Direct JSON parsing, IP extraction |
| `syslog.log` | Standard syslog messages | Syslog parsing, timestamp normalization |
| `system.log` | Linux system events | System event classification |
| `sh_arp_cache_*.log` | Linux audit logs | Audit log parsing, field extraction |

### Sample Log Entries

1. **Authentication Logs**
   ```
   Failed password for user admin from 192.168.1.100
   session opened for user john by (uid=0)
   ```

2. **Security Events (JSON)**
   ```json
   {
     "event_type": "malware_detection",
     "message": "Malware detected: trojan.exe",
     "source_ip": "10.0.0.50",
     "timestamp": "2024-01-15T10:30:00Z"
   }
   ```

3. **Syslog Messages**
   ```
   Jan 15 10:30:00 server sshd[1234]: Accepted password for user admin
   Jan 15 10:31:00 server kernel: [12345] Firewall blocked connection from 192.168.1.200
   ```

### Expected Processing Results

1. **Failed Login Detection**
   - Extracts username and source IP
   - Adds `event_type: failed_login`
   - Performs GeoIP lookup on source IP

2. **User Session Monitoring**
   - Extracts username and session details
   - Adds `event_type: user_login`
   - Tracks session lifecycle

3. **Security Event Correlation**
   - Parses JSON security events
   - Extracts threat indicators
   - Enriches with geographic data

## Configuration

### Log Sources
The stack is configured to collect logs from:
- Sample log files in `sample-logs/` directory:
  - `auth.log`: Authentication events
  - `security.log`: Security-related events (JSON format)
  - `syslog.log`: System log messages
  - `system.log`: General system events
  - `sh_arp_cache_*.log`: Linux audit logs
- Syslog messages via syslog-ng
- HTTP endpoints for manual log injection

### Log Processing
Logstash processes logs through:
- **Input**: HTTP input on port 8080 for manual testing and Fluent Bit data
- **Filter**: Pattern matching, parsing, and enrichment
  - Linux audit log parsing
  - Syslog message parsing
  - JSON log processing
  - Security event detection
  - Failed login attempt identification
  - User session monitoring
  - IP address extraction and GeoIP lookup
- **Output**: Indexing to OpenSearch with daily rotation (`o-siem-YYYY.MM.dd`)

### Security Features
- Failed login detection and classification
- User session monitoring
- IP address extraction for threat hunting
- Audit log parsing and correlation
- GeoIP enrichment for geographic analysis

## Sample Data

The project includes sample log files for testing:
- `auth.log`: SSH authentication events
- `security.log`: Security events in JSON format
- `syslog.log`: Standard syslog messages
- `system.log`: Linux system events
- `sh_arp_cache_*.log`: Linux audit trail logs

## Monitoring and Analysis

### OpenSearch Dashboards
Access the web interface to:
- Create visualizations and dashboards
- Search and filter logs
- Set up alerts and monitoring
- Analyze security events

### API Access
Use the OpenSearch REST API for:
- Direct log queries
- Index management
- Custom integrations

### Manual Log Injection
Send test logs via HTTP:
```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Failed password for user admin from 192.168.1.100",
    "timestamp": "2024-01-15T10:30:00Z",
    "source": "demo"
  }'
```

## Development and Customization

### Adding New Log Sources
1. Update Fluent Bit configuration in `config/fluent-bit/fluent-bit.conf`
2. Add new input plugins as needed
3. Restart the fluentbit service

### Custom Log Processing
1. Modify Logstash pipeline in `config/logstash/logstash.conf`
2. Add new filter plugins for specific log formats
3. Restart the logstash service

### Extending the Stack
- Add additional data sources (databases, APIs)
- Implement custom alerting rules
- Integrate with external security tools

## Performance Considerations

- **Resource allocation**: Adjust memory settings in docker-compose.yml
- **Index management**: Configure index lifecycle policies
- **Scaling**: Add more Logstash instances for high-volume environments

## Future Enhancements

- Integration with threat intelligence feeds
- Machine learning-based anomaly detection
- Advanced correlation rules
- Automated incident response workflows

---

**Note**: This project is designed for educational and development purposes. Production deployments require additional security hardening and configuration. 