@echo off
setlocal enabledelayedexpansion

echo Creating package directory...
if exist package rmdir /s /q package
mkdir package

echo Installing dependencies to package directory...
pip install requests -t ./package

echo Creating deployment package...
cd package
powershell Compress-Archive -Path * -DestinationPath ..\lambda.zip -Force
cd ..

echo Adding Lambda function to the package...
powershell Compress-Archive -Path lambda_function.py -Update -DestinationPath lambda.zip

echo Package created successfully as lambda.zip!
for %%I in (lambda.zip) do echo Package size: %%~zI bytes

endlocal 