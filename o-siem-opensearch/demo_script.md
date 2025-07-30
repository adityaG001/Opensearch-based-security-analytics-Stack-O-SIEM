# O-SIEM Demo Script for Internship Guide

## Pre-Demo Setup
1. Ensure the stack is running: `docker-compose ps`
2. Open browser tabs for:
   - OpenSearch Dashboards: http://localhost:5601
   - OpenSearch API: http://localhost:9200

## Demo Flow (15-20 minutes)

### 1. **Project Overview** (2 minutes)
- "This is O-SIEM, a complete Security Information and Event Management stack"
- "Built using OpenSearch, Logstash, Fluent Bit, and Docker"
- "Designed to collect, process, and analyze security logs in real-time"

### 2. **Architecture Walkthrough** (3 minutes)
```bash
# Show running containers
docker-compose ps

# Explain each component:
# - OpenSearch: Data storage and search engine
# - Dashboards: Web interface for visualization
# - Logstash: Log processing pipeline
# - Fluent Bit: Log collection
# - Syslog-ng: Network log reception
```

### 3. **Data Collection Demonstration** (5 minutes)

#### A. Check Current Data
```bash
# Check OpenSearch indices
curl http://localhost:9200/_cat/indices

# Check sample logs
ls -la sample-logs/
```

#### B. Send Test Data
```bash
# Send a test log via HTTP
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Failed password for user admin from 192.168.1.100",
    "timestamp": "2024-01-15T10:30:00Z",
    "source": "demo"
  }'
```

#### C. Verify Data Ingestion
- Open OpenSearch Dashboards
- Go to Discover
- Search for the test log
- Show real-time data flow

### 4. **Security Analysis Features** (5 minutes)

#### A. Failed Login Detection
- Search for "Failed password" events
- Show geographic distribution of attacks
- Demonstrate IP address extraction

#### B. User Session Monitoring
- Search for "session opened" events
- Show user activity patterns
- Demonstrate event correlation

#### C. Threat Hunting
- Search for suspicious IP addresses
- Show GeoIP enrichment
- Demonstrate log filtering and analysis

### 5. **Dashboard Creation** (3 minutes)
- Create a simple visualization
- Show different chart types
- Demonstrate dashboard building
- Show real-time updates

### 6. **Technical Deep Dive** (2 minutes)

#### A. Configuration Files
```bash
# Show key configuration files
cat config/logstash/logstash.conf | head -20
cat docker-compose.yml | head -30
```

#### B. Custom Logstash Build
```bash
# Show custom Dockerfile
cat Dockerfile.logstash

# Explain OpenSearch plugin integration
```

## Key Talking Points

### Technical Achievements
1. **Containerized Architecture**: All services running in Docker containers
2. **Plugin Integration**: Custom Logstash build with OpenSearch output plugin
3. **Multi-format Support**: Handles syslog, JSON, and plain text logs
4. **Real-time Processing**: Live log ingestion and analysis
5. **Security Features**: Failed login detection, IP analysis, GeoIP enrichment

### Problem-Solving Examples
1. **Version Compatibility**: Resolved OpenSearch 2.x and Logstash compatibility
2. **Service Orchestration**: Managed complex service dependencies
3. **Plugin Integration**: Successfully integrated OpenSearch output plugin
4. **Configuration Management**: Complex multi-service configuration

### Learning Outcomes
1. **Docker & Containerization**: Deep understanding of containerized applications
2. **Log Management**: Enterprise-grade log collection and processing
3. **Security Analytics**: SIEM implementation and security monitoring
4. **Data Pipeline Design**: End-to-end data flow architecture
5. **Troubleshooting**: Debugging complex distributed systems

## Demo Commands Reference

### Health Checks
```bash
# Check all services
docker-compose ps

# Check OpenSearch health
curl http://localhost:9200/_cluster/health

# Check Logstash status
curl http://localhost:9600/_node/stats
```

### Data Management
```bash
# List indices
curl http://localhost:9200/_cat/indices

# Search for specific events
curl "http://localhost:9200/o-siem-*/_search?q=failed+password"

# Count total documents
curl http://localhost:9200/o-siem-*/_count
```

### Log Injection
```bash
# Send security event
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Malware detected: trojan.exe from 10.0.0.50",
    "timestamp": "2024-01-15T10:35:00Z",
    "event_type": "malware_detection"
  }'

# Send syslog message
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Jan 15 10:40:00 server sshd[1234]: session opened for user admin",
    "timestamp": "2024-01-15T10:40:00Z",
    "log_type": "syslog"
  }'
```

## Conclusion Points
1. **Complete Solution**: Functional SIEM with all core components
2. **Production Ready**: Containerized, scalable, and well-documented
3. **Learning Value**: Demonstrates modern DevOps and security practices
4. **Extensible**: Easy to add new data sources and features
5. **Professional Quality**: Enterprise-grade implementation

## Questions to Expect
- "How does this scale for production?"
- "What about security and authentication?"
- "How would you add new log sources?"
- "What's the performance like with high volume?"
- "How do you handle data retention?"

## Answers
- **Scaling**: Add more Logstash instances, use multi-node OpenSearch cluster
- **Security**: Enable OpenSearch security plugins, add TLS, implement authentication
- **New Sources**: Modify Fluent Bit config, add new input plugins
- **Performance**: Optimize JVM settings, add more resources, implement caching
- **Retention**: Configure index lifecycle policies, implement data archival 