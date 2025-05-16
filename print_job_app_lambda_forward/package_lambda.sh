#!/bin/bash

# Exit on any error
set -e

echo "Creating package directory..."
rm -rf package
mkdir -p package

echo "Installing dependencies to package directory..."
pip install requests -t ./package

echo "Creating deployment package..."
cd package
zip -r ../lambda.zip .
cd ..

echo "Adding Lambda function to the package..."
zip -g lambda.zip lambda_function.py

echo "Package created successfully as lambda.zip!"
echo "Package size: $(du -h lambda.zip | cut -f1)" 