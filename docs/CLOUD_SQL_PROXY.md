# Cloud SQL Proxy Setup

## Overview

Cloud SQL Proxy is a tool that allows you to securely connect to your Google Cloud SQL instances without requiring whitelisted IP addresses or configuring SSL certificates. The proxy handles authentication and encryption automatically using your Google Cloud credentials.

## Installation

Cloud SQL Proxy is now integrated into the dev-machine-setup scripts for both macOS and Linux.

### macOS

**Automated Installation:**
```bash
./setup_mac.sh
```
When prompted, select option 4 (Custom selection) and answer "y" when asked to install Cloud SQL Proxy.

**Manual Installation:**
```bash
source macos/packages.sh
install_cloud_sql_proxy
```

### Linux / WSL

**Automated Installation:**
```bash
./setup_linux.sh
```
When prompted, select option 4 (Custom selection) and answer "y" when asked to install Cloud SQL Proxy.

**Manual Installation:**
```bash
source linux/packages.sh
install_cloud_sql_proxy
```

## Verification

After installation, verify it's working:
```bash
cloud-sql-proxy --version
```

## Usage

### Basic Usage

Connect to a Cloud SQL instance:
```bash
cloud-sql-proxy PROJECT:REGION:INSTANCE
```

Example:
```bash
cloud-sql-proxy my-project:us-central1:my-db-instance
```

### With Custom Port

```bash
cloud-sql-proxy PROJECT:REGION:INSTANCE --port 5432
```

### With Unix Socket

```bash
cloud-sql-proxy PROJECT:REGION:INSTANCE --unix-socket /tmp/cloudsql
```

### Multiple Instances

```bash
cloud-sql-proxy \
  project1:region1:instance1 \
  project2:region2:instance2
```

### With Instance Connection Name File

```bash
cloud-sql-proxy --instances-from-file instances.txt
```

## Authentication

Cloud SQL Proxy uses your Google Cloud credentials. Ensure you're authenticated:

```bash
gcloud auth application-default login
```

Or use a service account:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

## Common Connection Strings

Once the proxy is running, you can connect to your database using localhost:

### PostgreSQL
```bash
psql "host=127.0.0.1 port=5432 dbname=mydb user=myuser"
```

### MySQL
```bash
mysql -h 127.0.0.1 -P 3306 -u myuser -p mydb
```

### SQL Server
```bash
sqlcmd -S 127.0.0.1,1433 -U myuser -P mypassword -d mydb
```

## Tips

1. **Run in Background**: Use `&` to run the proxy in the background:
   ```bash
   cloud-sql-proxy PROJECT:REGION:INSTANCE &
   ```

2. **Use with Docker**: Mount the Unix socket to your container:
   ```bash
   docker run -v /tmp/cloudsql:/cloudsql myapp
   ```

3. **Auto-start with systemd** (Linux):
   Create a systemd service for automatic startup (see advanced configuration).

## Troubleshooting

### Connection Refused
- Ensure your GCP credentials are valid
- Check that the instance name is correct
- Verify the instance is running in GCP

### Permission Denied
- Ensure your account has the Cloud SQL Client role
- Check IAM permissions in the GCP Console

### Port Already in Use
- Specify a different port with `--port`
- Check for other services using the default port

## Version Information

- **Current Version**: v2.19.0
- **Supported Architectures**:
  - macOS: darwin.amd64, darwin.arm64
  - Linux: linux.amd64, linux.arm64

## More Information

- [Official Documentation](https://cloud.google.com/sql/docs/mysql/sql-proxy)
- [GitHub Repository](https://github.com/GoogleCloudPlatform/cloud-sql-proxy)
- [Release Notes](https://github.com/GoogleCloudPlatform/cloud-sql-proxy/releases)

## Update

To update to a newer version, simply run the installation function again:

```bash
# macOS
source macos/packages.sh
install_cloud_sql_proxy

# Linux
source linux/packages.sh
install_cloud_sql_proxy
```

The installation script will detect the existing installation and inform you of the current version.
