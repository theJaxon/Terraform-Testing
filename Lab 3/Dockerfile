FROM jenkins/jenkins
USER root
WORKDIR /home/
RUN pwd && ls && \
    wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip && \
    pwd && ls && \
    unzip terraform_0.12.24_linux_amd64.zip && \
    pwd && ls && \
    rm terraform_0.12.24_linux_amd64.zip && \
    mv terraform /bin/

EXPOSE 8080