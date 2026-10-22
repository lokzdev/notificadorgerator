@echo off
setlocal
echo ==============================================
echo   Compilando Notificador Custom (APK)
echo ==============================================

set "JAVA_HOME=C:\Program Files\Java\jdk-17"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "GRADLE_BAT=C:\Users\menor\.gradle\wrapper\dists\gradle-8.2-bin\bbg7u40eoinfdyxsxr3z4i7ta\gradle-8.2\bin\gradle.bat"

if not exist "%GRADLE_BAT%" (
    echo [ERRO] Binario do Gradle nao encontrado.
    pause
    exit /b 1
)

echo Usando JDK 17: %JAVA_HOME%
echo Usando Android SDK: C:\Android\Sdk
echo.

call "%GRADLE_BAT%" assembleDebug --no-daemon

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==============================================
    echo   [SUCESSO] APK COMPILADO COM SUCESSO!
    echo   Local: app\build\outputs\apk\debug\app-debug.apk
    echo ==============================================
    explorer.exe "app\build\outputs\apk\debug"
) else (
    echo.
    echo [ERRO] Ocorreu uma falha durante a compilacao.
)

pause
