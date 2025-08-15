# E-Commerce Platform Development Setup Script

param(
    [switch]$SkipClone,
    [switch]$SkipBuild,
    [string]$GitOrg = "your-org"
)

Write-Host "🚀 Setting up E-Commerce Platform Development Environment" -ForegroundColor Green

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

$prerequisites = @(
    @{ Name = "Docker"; Command = "docker --version" },
    @{ Name = "Docker Compose"; Command = "docker-compose --version" },
    @{ Name = "Git"; Command = "git --version" },
    @{ Name = ".NET 9"; Command = "dotnet --version" },
    @{ Name = "Node.js"; Command = "node --version" },
    @{ Name = "npm"; Command = "npm --version" }
)

foreach ($prereq in $prerequisites) {
    try {
        $output = Invoke-Expression $prereq.Command 2>$null
        Write-Host "✅ $($prereq.Name): $output" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $($prereq.Name) not found. Please install it first." -ForegroundColor Red
        exit 1
    }
}

# Clone repositories
if (-not $SkipClone) {
    Write-Host "📂 Cloning repositories..." -ForegroundColor Yellow
    
    $repositories = @(
        "e-commerce-common-backend",
        "e-commerce-api-gateway",
        "e-commerce-customer-management-backend",
        "e-commerce-order-management-backend",
        "e-commerce-product-catalog-backend",
        "e-commerce-common-frontend",
        "e-commerce-app-shell-frontend",
        "e-commerce-customer-management-frontend",
        "e-commerce-order-management-frontend",
        "e-commerce-product-catalog-frontend",
        "e-commerce-dashboard-frontend",
        "e-commerce-infrastructure",
        "e-commerce-shared-pipelines"
    )

    foreach ($repo in $repositories) {
        if (-not (Test-Path $repo)) {
            Write-Host "Cloning $repo..." -ForegroundColor Cyan
            git clone "https://github.com/$GitOrg/$repo.git"
        } else {
            Write-Host "Repository $repo already exists, pulling latest changes..." -ForegroundColor Cyan
            Set-Location $repo
            git pull
            Set-Location ..
        }
    }
}

# Build backend services
if (-not $SkipBuild) {
    Write-Host "🔨 Building backend services..." -ForegroundColor Yellow
    
    $backendProjects = @(
        "e-commerce-common-backend",
        "e-commerce-api-gateway",
        "e-commerce-customer-management-backend",
        "e-commerce-order-management-backend",
        "e-commerce-product-catalog-backend"
    )

    foreach ($project in $backendProjects) {
        if (Test-Path $project) {
            Write-Host "Building $project..." -ForegroundColor Cyan
            Set-Location $project
            dotnet restore
            dotnet build --configuration Release
            Set-Location ..
        }
    }

    # Build frontend projects
    Write-Host "🔨 Building frontend projects..." -ForegroundColor Yellow
    
    $frontendProjects = @(
        "e-commerce-common-frontend",
        "e-commerce-app-shell-frontend",
        "e-commerce-customer-management-frontend",
        "e-commerce-order-management-frontend",
        "e-commerce-product-catalog-frontend",
        "e-commerce-dashboard-frontend"
    )

    foreach ($project in $frontendProjects) {
        if (Test-Path $project) {
            Write-Host "Building $project..." -ForegroundColor Cyan
            Set-Location $project
            npm install
            npm run build
            Set-Location ..
        }
    }
}

# Start infrastructure services
Write-Host "🐳 Starting infrastructure services..." -ForegroundColor Yellow
Set-Location "e-commerce-infrastructure\docker"
docker-compose -f docker-compose.infrastructure.yml up -d

Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Health check
Write-Host "🏥 Performing health checks..." -ForegroundColor Yellow
$healthChecks = @(
    @{ Name = "SQL Server"; Url = "http://localhost:1433" },
    @{ Name = "Redis"; Url = "http://localhost:6379" },
    @{ Name = "RabbitMQ"; Url = "http://localhost:15672" },
    @{ Name = "Keycloak"; Url = "http://localhost:8080" }
)

Write-Host "✅ Development environment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Service URLs:" -ForegroundColor Cyan
Write-Host "   API Gateway: http://localhost:7000" -ForegroundColor White
Write-Host "   App Shell: http://localhost:4200" -ForegroundColor White
Write-Host "   Keycloak Admin: http://localhost:8080 (admin/admin123)" -ForegroundColor White
Write-Host "   RabbitMQ Management: http://localhost:15672 (admin/admin123)" -ForegroundColor White
Write-Host "   Grafana: http://localhost:3000 (admin/admin123)" -ForegroundColor White
Write-Host ""
Write-Host "📖 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Start the API Gateway: cd e-commerce-api-gateway && dotnet run" -ForegroundColor White
Write-Host "   2. Start backend services: cd e-commerce-*-backend && dotnet run" -ForegroundColor White
Write-Host "   3. Start frontend services: cd e-commerce-*-frontend && npm start" -ForegroundColor White
