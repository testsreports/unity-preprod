FROM node:18

RUN apt-get update && \
    apt-get install -y default-jre curl unzip && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g newman newman-reporter-htmlextra newman-reporter-allure

RUN curl -o allure.tgz -L https://github.com/allure-framework/allure2/releases/download/2.24.0/allure-2.24.0.tgz && \
    tar -xzf allure.tgz && \
    mv allure-2.24.0 /opt/allure && \
    ln -s /opt/allure/bin/allure /usr/bin/allure && \
    allure --version

WORKDIR /app
COPY . .

CMD ["bash", "run.sh"]
