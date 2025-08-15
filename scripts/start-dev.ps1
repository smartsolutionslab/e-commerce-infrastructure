# Complete Development Environment Startup Script

Write-Host "🚀 Starting E-Commerce Development Environment" -ForegroundColor Green

# Start Infrastructure Services
Write-Host "`n📦 Starting Infrastructure Services..." -ForegroundColor Yellow
Set-Location "../docker"
docker-compose -f docker-compose.infrastructure.yml up -d

Write-Host "⏳ Waiting for infrastructure services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Start Backend Services
Write-Host "`n🔧 Starting Backend Services..." -ForegroundColor Yellow

# Start Customer Service
Write-Host "Starting Customer Management Service..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-customer-management-backend/src/E-Commerce.CustomerManagement.Api'; dotnet run"

# Start Product Service
Write-Host "Starting Product Catalog Service..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-product-catalog-backend/src/E-Commerce.ProductCatalog.Api'; dotnet run"

# Start Order Service
Write-Host "Starting Order Management Service..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-order-management-backend/src/E-Commerce.OrderManagement.Api'; dotnet run"

Write-Host "⏳ Waiting for backend services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Start API Gateway
Write-Host "Starting API Gateway..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-api-gateway/src/E-Commerce.ApiGateway'; dotnet run"

Write-Host "⏳ Waiting for API Gateway to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Start Frontend Services
Write-Host "`n🌐 Starting Frontend Services..." -ForegroundColor Yellow

# Start App Shell
Write-Host "Starting App Shell..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-app-shell-frontend'; npm start"

# Start Customer Frontend
Write-Host "Starting Customer Management Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-customer-management-frontend'; npm start"

# Start Product Frontend
Write-Host "Starting Product Catalog Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-product-catalog-frontend'; npm start"

# Start Order Frontend
Write-Host "Starting Order Management Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-order-management-frontend'; npm start"

# Start Dashboard Frontend
Write-Host "Starting Dashboard Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "cd '../../e-commerce-dashboard-frontend'; npm start"

Write-Host "`n✅ Development Environment Started!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Available Services:" -ForegroundColor Cyan
Write-Host "   App Shell:           http://localhost:4200" -ForegroundColor White
Write-Host "   API Gateway:         http://localhost:7000" -ForegroundColor White
Write-Host "   Customer Service:    http://localhost:7001" -ForegroundColor White
Write-Host "   Product Service:     http://localhost:7002" -ForegroundColor White
Write-Host "   Order Service:       http://localhost:7003" -ForegroundColor White
Write-Host ""
Write-Host "   Customer Frontend:   http://localhost:4201" -ForegroundColor White
Write-Host "   Product Frontend:    http://localhost:4202" -ForegroundColor White
Write-Host "   Order Frontend:      http://localhost:4203" -ForegroundColor White
Write-Host "   Dashboard Frontend:  http://localhost:4204" -ForegroundColor White
Write-Host ""
Write-Host "   Keycloak:           http://localhost:8080 (admin/admin123)" -ForegroundColor White
Write-Host "   RabbitMQ:           http://localhost:15672 (admin/admin123)" -ForegroundColor White
Write-Host "   Grafana:            http://localhost:3000 (admin/admin123)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to stop all services..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Stop Services
Write-Host "`n🛑 Stopping Services..." -ForegroundColor Red
Get-Process | Where-Object {$_.ProcessName -eq "dotnet" -or $_.ProcessName -eq "node"} | Stop-Process -Force
docker-compose -f docker-compose.infrastructure.yml down
