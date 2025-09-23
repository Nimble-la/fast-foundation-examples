#!/bin/bash
yum update -y
yum install -y httpd

# Configure httpd to run on custom port
sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf

# Get instance ID for the HTML page
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Create simple index page
cat << EOF > /var/www/html/index.html
<h1>Welcome to example-app</h1>
<p>This instance is load balanced via ALB and managed by Terragrunt!</p>
EOF

# Create health check endpoint
echo '{"status": "healthy"}' > /var/www/html/health

systemctl start httpd
systemctl enable httpd