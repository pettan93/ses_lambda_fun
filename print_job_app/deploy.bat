@echo off
setlocal enabledelayedexpansion

:: Define variables
set IMAGE_NAME=print-job-app
set IMAGE_TAG=latest
if not defined DOCKER_REGISTRY set DOCKER_REGISTRY=docker.io
if not defined REPOSITORY_NAME set REPOSITORY_NAME=pettan93

:: Check if Docker is running
docker info > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Docker is not running or you don't have permission to use it
    exit /b 1
)

:: Set full image name
set FULL_IMAGE_NAME=%DOCKER_REGISTRY%/%REPOSITORY_NAME%/%IMAGE_NAME%:%IMAGE_TAG%

:: Tag the image for the repository
echo Tagging image as: %FULL_IMAGE_NAME%
docker tag %IMAGE_NAME%:%IMAGE_TAG% %FULL_IMAGE_NAME%
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to tag the image
    exit /b %ERRORLEVEL%
)

:: Push the image to the repository
echo Pushing image to repository...
docker push %FULL_IMAGE_NAME%
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to push the image
    exit /b %ERRORLEVEL%
)

echo Deploy completed successfully!
echo Your image is now available at: %FULL_IMAGE_NAME%

endlocal 