#!/bin/bash
set -e

# Create export folder
mkdir -p exports

# Download Postman collection and environment
echo "Downloading Postman files..."
curl -s -X GET "https://api.getpostman.com/collections/$COLLECTION_ID" -H "X-Api-Key: $API_KEY" -o exports/collection.json
curl -s -X GET "https://api.getpostman.com/environments/$ENVIRONMENT_ID" -H "X-Api-Key: $API_KEY" -o exports/environment.json

# Run Newman tests
echo "Running Newman tests..."
newman run exports/collection.json -e exports/environment.json -r allure,htmlextra \
  --reporter-htmlextra-export $REPORT_FILE \
  --iteration-count $ITERATION_COUNT || true

# Generate Allure Report
if [ -d "allure-results" ] && [ "$(ls -A allure-results)" ]; then
  echo "Generating Allure report..."
  allure generate ./allure-results --clean -o allure-report
else
  echo "No allure-results found. Creating placeholder."
  mkdir -p allure-report
  echo "<html><body><h2>No Allure data</h2></body></html>" > allure-report/index.html
fi

# Timestamp
IST_TIME=$(TZ='Asia/Kolkata' date '+%d-%m-%Y_%H:%M')
TIMESTAMP="${IST_TIME}_$(date +%s)"
echo "Generated timestamp: $TIMESTAMP"

# Clone gh-pages branch
rm -rf gh-pages-temp
git clone --depth 1 --branch gh-pages https://x-access-token:$TOKEN_GITHUB@github.com/$REPO gh-pages-temp

mkdir -p gh-pages-temp/reports/Allure_Report/$TIMESTAMP
mkdir -p gh-pages-temp/reports/Html/$TIMESTAMP

cp -r allure-report/* gh-pages-temp/reports/Allure_Report/$TIMESTAMP/
cp $REPORT_FILE gh-pages-temp/reports/Html/$TIMESTAMP/

cp .github/reports-style.css gh-pages-temp/reports/reports-style.css

# Update index.html
cd gh-pages-temp/reports
# (Copy your full index.html generation script here)
cd ../..
cd gh-pages-temp
git config user.name "GitHub Runner"
git config user.email "runner@example.com"
git add .
git commit -m "Add test reports for $TIMESTAMP"
git push origin gh-pages
