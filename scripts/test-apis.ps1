# E-Commerce Platform API Testing Script

param(
    [string]$BaseUrl = "https://localhost:7000",
    [string]$TenantId = "00000000-0000-0000-0000-000000000001"
)

Write-Host "🧪 Testing E-Commerce Platform APIs" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl" -ForegroundColor Cyan
Write-Host "Tenant ID: $TenantId" -ForegroundColor Cyan

$headers = @{
    "Content-Type" = "application/json"
    "X-Tenant-Id" = $TenantId
}

# Test API Gateway Health
Write-Host "`n📊 Testing API Gateway Health..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/health" -Method Get
    Write-Host "✅ API Gateway Health: OK" -ForegroundColor Green
} catch {
    Write-Host "❌ API Gateway Health: FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Test Customer API
Write-Host "`n👥 Testing Customer API..." -ForegroundColor Yellow
try {
    $customerData = @{
        email = "test@example.com"
        firstName = "John"
        lastName = "Doe"
        dateOfBirth = "1990-01-01"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/customers" -Method Post -Body $customerData -Headers $headers
    Write-Host "✅ Customer Creation: OK" -ForegroundColor Green
    $customerId = $response.id
    
    # Get Customer
    $customer = Invoke-RestMethod -Uri "$BaseUrl/api/v1/customers/$customerId" -Method Get -Headers $headers
    Write-Host "✅ Customer Retrieval: OK" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Customer API: FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Test Product API
Write-Host "`n📦 Testing Product API..." -ForegroundColor Yellow
try {
    # Create Category first
    $categoryData = @{
        name = "Electronics"
        description = "Electronic products"
    } | ConvertTo-Json

    $categoryResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/categories" -Method Post -Body $categoryData -Headers $headers
    $categoryId = $categoryResponse.id
    
    # Create Product
    $productData = @{
        name = "Test Product"
        description = "A test product"
        sku = "TEST-001"
        categoryId = $categoryId
        price = 99.99
        currency = "USD"
        stockQuantity = 100
    } | ConvertTo-Json

    $productResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/products" -Method Post -Body $productData -Headers $headers
    Write-Host "✅ Product Creation: OK" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Product API: FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Test Order API
Write-Host "`n📋 Testing Order API..." -ForegroundColor Yellow
try {
    $orderData = @{
        customerId = $customerId
        currency = "USD"
        items = @(
            @{
                productId = $productResponse.id
                productName = "Test Product"
                quantity = 2
                unitPrice = 99.99
            }
        )
    } | ConvertTo-Json -Depth 3

    $orderResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/orders" -Method Post -Body $orderData -Headers $headers
    Write-Host "✅ Order Creation: OK" -ForegroundColor Green
    
    # Confirm Order
    $confirmResponse = Invoke-RestMethod -Uri "$BaseUrl/api/v1/orders/$($orderResponse.id)/confirm" -Method Put -Headers $headers
    Write-Host "✅ Order Confirmation: OK" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Order API: FAILED" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🎉 API Testing Complete!" -ForegroundColor Green
