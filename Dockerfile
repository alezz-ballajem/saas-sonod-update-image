FROM amazonlinux:2023

ARG TERRAFORM_VERSION=1.8.0

# Install system dependencies
RUN dnf update -y \
    && dnf install -y --allowerasing \
        bash \
        jq \
        unzip \
        curl \
        less \
        groff \
        glibc \
    && dnf clean all

# Install PostgreSQL 17
RUN rpm --import https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL \
    && echo "[pgdg17]" > /etc/yum.repos.d/pgdg.repo \
    && echo "name=PostgreSQL 17 for RHEL/CentOS 9 - x86_64" >> /etc/yum.repos.d/pgdg.repo \
    && echo "baseurl=https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-9-x86_64" >> /etc/yum.repos.d/pgdg.repo \
    && echo "enabled=1" >> /etc/yum.repos.d/pgdg.repo \
    && echo "gpgcheck=1" >> /etc/yum.repos.d/pgdg.repo \
    && echo "gpgkey=https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL" >> /etc/yum.repos.d/pgdg.repo \
    && dnf install -y postgresql17 \
    && dnf clean all

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/terraform \
    && rm -f /tmp/terraform.zip
