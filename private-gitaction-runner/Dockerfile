FROM ubuntu:22.04

# Avoid interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install core tools: curl, git, jq, unzip, docker CLI, etc.
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    unzip \
    software-properties-common \
    docker.io \
    sudo \
    gnupg \
    lsb-release \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform


# Install Node.js (LTS version)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \ 
    unzip awscliv2.zip && \
    sudo ./aws/install
    
# Create non-root user for GitHub runner.
RUN useradd -m -s /bin/bash runner && \
    usermod -aG docker runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/runner

# Download GitHub Actions runner
RUN curl -s https://api.github.com/repos/actions/runner/releases/latest \
  | jq -r '.assets[] | select(.name | test("linux-x64")) | .browser_download_url' \
  | xargs curl -LO && \
  tar xzf actions-runner-linux-x64-*.tar.gz && \
  rm actions-runner-linux-x64-*.tar.gz

# Fix work directory permissions for non-root runner
RUN mkdir -p /home/runner/_work && chown -R runner:runner /home/runner
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown -R runner:runner /home/runner

# Switch to non-root user
USER runner

ENTRYPOINT ["/entrypoint.sh"]
