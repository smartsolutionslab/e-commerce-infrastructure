# Comprehensive Testing Script for E-Commerce Platform

param(
    [switch]$SkipUnitTests,
    [switch]$SkipIntegrationTests,
    [switch]$SkipE2ETests,
    [switch]$SkipPerformanceTests,
    [switch]$SkipSecurityTests
)

Write-Host "🧪 Running Comprehensive E-Commerce Platform Tests" -ForegroundColor Green

$ErrorActionPreference = "Continue"
$testResults = @{
    UnitTests = $false
    IntegrationTests = $false
    E2ETests = $false
    PerformanceTests = $false
    SecurityTests = $false
}

# Unit Tests
if (-not $SkipUnitTests) {
    Write-Host "`n📋 Running Unit Tests..." -ForegroundColor Yellow
    
    $backendServices = @(
        "../../e-commerce-customer-management-backend",
        "../../e-commerce-order-management-backend", 
        "../../e-commerce-product-catalog-backend"
    )
    
    $allUnitTestsPassed = $true
    
    foreach ($service in $backendServices) {
        Write-Host "Testing $service..." -ForegroundColor Cyan
        Set-Location $service
        
        $result = dotnet test --configuration Release --logger "console;verbosity=detailed" --collect:"XPlat Code Coverage"
        if ($LASTEXITCODE -ne 0) {
            $allUnitTestsPassed = $false
            Write-Host "❌ Unit tests failed for $service" -ForegroundColor Red
        } else {
            Write-Host "✅ Unit tests passed for $service" -ForegroundColor Green
        }
        
        Set-Location "../../e-commerce-infrastructure/scripts"
    }
    
    $testResults.UnitTests = $allUnitTestsPassed
}

# Integration Tests
if (-not $SkipIntegrationTests) {
    Write-Host "`n🔗 Running Integration Tests..." -ForegroundColor Yellow
    
    # Start test containers
    Write-Host "Starting test infrastructure..." -ForegroundColor Cyan
    Set-Location "../docker"
    docker-compose -f docker-compose.test.yml up -d
    Start-Sleep -Seconds 30
    
    # Run integration tests
    $integrationTestsPassed = $true
    
    foreach ($service in $backendServices) {
        Write-Host "Integration testing $service..." -ForegroundColor Cyan
        Set-Location "../../$service"
        
        $result = dotnet test --configuration Integration --filter "Category=Integration"
        if ($LASTEXITCODE -ne 0) {
            $integrationTestsPassed = $false
            Write-Host "❌ Integration tests failed for $service" -ForegroundColor Red
        }
    }
    
    # Cleanup
    Set-Location "../e-commerce-infrastructure/docker"
    docker-compose -f docker-compose.test.yml down
    Set-Location "../scripts"
    
    $testResults.IntegrationTests = $integrationTestsPassed
}

# E2E Tests
if (-not $SkipE2ETests) {
    Write-Host "`n🌐 Running E2E Tests..." -ForegroundColor Yellow
    
    # Start full environment
    Write-Host "Starting full test environment..." -ForegroundColor Cyan
    .\start-dev.ps1
    Start-Sleep -Seconds 60
    
    # Run Playwright tests
    Set-Location "../tests/e2e"
    npm install
    $result = npx playwright test
    
    if ($LASTEXITCODE -eq 0) {
        $testResults.E2ETests = $true
        Write-Host "✅ E2E tests passed" -ForegroundColor Green
    } else {
        Write-Host "❌ E2E tests failed" -ForegroundColor Red
    }
    
    Set-Location "../../scripts"
    
    # Stop environment
    Write-Host "Stopping test environment..." -ForegroundColor Cyan
    .\stop-dev.ps1
}

# Performance Tests
if (-not $SkipPerformanceTests) {
    Write-Host "`n⚡ Running Performance Tests..." -ForegroundColor Yellow
    
    # Start performance test environment
    .\start-dev.ps1
    Start-Sleep -Seconds 60
    
    # Run k6 load tests
    Set-Location "../tests/performance"
    $result = k6 run load-test.js
    
    if ($LASTEXITCODE -eq 0) {
        $testResults.PerformanceTests = $true
        Write-Host "✅ Performance tests passed" -ForegroundColor Green
    } else {
        Write-Host "❌ Performance tests failed" -ForegroundColor Red
    }
    
    Set-Location "../../scripts"
    .\stop-dev.ps1
}

# Security Tests
if (-not $SkipSecurityTests) {
    Write-Host "`n🔒 Running Security Tests..." -ForegroundColor Yellow
    
    # OWASP ZAP Security Testing
    Write-Host "Running OWASP ZAP scan..." -ForegroundColor Cyan
    
    .\start-dev.ps1
    Start-Sleep -Seconds 60
    
    # Run ZAP baseline scan
    docker run -t owasp/zap2docker-stable zap-baseline.py -t http://host.docker.internal:7000
    
    if ($LASTEXITCODE -eq 0) {
        $testResults.SecurityTests = $true
        Write-Host "✅ Security tests passed" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Security tests found issues" -ForegroundColor Yellow
    }
    
    .\stop-dev.ps1
}

# Test Results Summary
Write-Host "`n📊 Test Results Summary" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

foreach ($test in $testResults.GetEnumerator()) {
    $status = if ($test.Value) { "✅ PASSED" } else { "❌ FAILED" }
    $color = if ($test.Value) { "Green" } else { "Red" }
    Write-Host "$($test.Key): $status" -ForegroundColor $color
}

$overallSuccess = $testResults.Values -notcontains $false
if ($overallSuccess) {
    Write-Host "`n🎉 All tests passed! Platform is ready for deployment." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n💥 Some tests failed. Please review and fix issues before deployment." -ForegroundColor Red
    exit 1
}
