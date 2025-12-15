FROM amazon/aws-cli:2.15.30

ARG TERRAFORM_VERSION=1.8.0

RUN yum update -y \
    && yum install -y \
        bash \
        jq \
        postgresql \
        unzip \
        curl \
    && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/terraform \
    && rm -f /tmp/terraform.zip \
    && yum clean all \
    && rm -rf /var/cache/yum

