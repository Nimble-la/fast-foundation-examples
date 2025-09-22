#!/bin/bash
yum update -y
yum install -y httpd

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
# Configure httpd to run on custom port
sed -i "s/Listen 80/Listen 8080/" /etc/httpd/conf/httpd.conf

# Create simple index page
cat << EOF > /var/www/html/index.html
<h1>Welcome to ${app_name}</h1>
<p>Instance ID: \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
<p>This instance is load balanced via ALB and managed by Terraform!</p>
EOF

# Create health check endpoint
echo '{"status": "healthy"}' > /var/www/html/health

systemctl start httpd
systemctl enable httpd
