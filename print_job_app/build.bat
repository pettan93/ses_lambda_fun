@echo off
setlocal enabledelayedexpansion

:: Define variables
set IMAGE_NAME=print-job-app
set IMAGE_TAG=latest

:: Build the Docker image
echo Building Docker image: %IMAGE_NAME%:%IMAGE_TAG%
docker build -t %IMAGE_NAME%:%IMAGE_TAG% .

if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker build failed
    exit /b %ERRORLEVEL%
)

echo Build completed successfully!
echo To run the container, use:
echo docker run -p 5000:5000 %IMAGE_NAME%:%IMAGE_TAG%

endlocal 