import { test, expect } from '@playwright/test';

test.describe('E-Commerce Platform E2E Tests', () => {
  const baseUrl = 'http://localhost:4200';
  const apiUrl = 'http://localhost:7000';
  
  let customerId: string;
  let productId: string;
  let orderId: string;

  test.beforeAll(async ({ request }) => {
    // Setup test data
    const tenantId = '00000000-0000-0000-0000-000000000001';
    
    // Create Category
    const categoryResponse = await request.post(`${apiUrl}/api/v1/categories`, {
      headers: { 'X-Tenant-Id': tenantId },
      data: {
        name: 'Test Category',
        description: 'Test category for E2E testing'
      }
    });
    const category = await categoryResponse.json();

    // Create Product
    const productResponse = await request.post(`${apiUrl}/api/v1/products`, {
      headers: { 'X-Tenant-Id': tenantId },
      data: {
        name: 'Test Product',
        description: 'A test product for E2E testing',
        sku: 'TEST-E2E-001',
        categoryId: category.id,
        price: 99.99,
        currency: 'USD',
        stockQuantity: 100
      }
    });
    productId = (await productResponse.json()).id;

    // Create Customer
    const customerResponse = await request.post(`${apiUrl}/api/v1/customers`, {
      headers: { 'X-Tenant-Id': tenantId },
      data: {
        email: 'e2e-test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: '1990-01-01'
      }
    });
    customerId = (await customerResponse.json()).id;
  });

  test('Complete Customer Journey', async ({ page }) => {
    // 1. Navigate to Dashboard
    await page.goto(baseUrl);
    await expect(page.locator('h1')).toContainText('Dashboard');

    // 2. View Customer Management
    await page.click('a[href="/customers"]');
    await expect(page.locator('h1')).toContainText('Customers');
    
    // 3. Search for created customer
    await page.fill('input[placeholder="Search customers..."]', 'e2e-test@example.com');
    await page.waitForTimeout(1000);
    
    // Verify customer appears in list
    await expect(page.locator('tbody tr')).toContainText('John Doe');

    // 4. Navigate to Products
    await page.click('a[href="/products"]');
    await expect(page.locator('h1')).toContainText('Products');
    
    // 5. Verify test product exists
    await page.fill('input[placeholder="Search products..."]', 'TEST-E2E-001');
    await page.waitForTimeout(1000);
    await expect(page.locator('tbody tr')).toContainText('Test Product');

    // 6. Navigate to Orders
    await page.click('a[href="/orders"]');
    await expect(page.locator('h1')).toContainText('Orders');
  });

  test('Order Creation Workflow', async ({ page, request }) => {
    const tenantId = '00000000-0000-0000-0000-000000000001';

    // Create order via API
    const orderResponse = await request.post(`${apiUrl}/api/v1/orders`, {
      headers: { 'X-Tenant-Id': tenantId },
      data: {
        customerId: customerId,
        currency: 'USD',
        items: [{
          productId: productId,
          productName: 'Test Product',
          quantity: 2,
          unitPrice: 99.99
        }]
      }
    });
    
    orderId = (await orderResponse.json()).id;
    expect(orderResponse.ok()).toBeTruthy();

    // Navigate to orders page
    await page.goto(`${baseUrl}/orders`);
    
    // Find the created order
    await page.fill('input[placeholder="Search orders..."]', orderId.substring(0, 8));
    await page.waitForTimeout(1000);
    
    // Verify order appears
    await expect(page.locator('tbody tr')).toContainText(orderId.substring(0, 8));
    
    // Click on order to view details
    await page.click(`tbody tr:has-text("${orderId.substring(0, 8)}")`);
    
    // Verify order details page
    await expect(page.locator('h1')).toContainText('Order Details');
    await expect(page.locator('.order-total')).toContainText('$199.98');
  });

  test('Order Status Management', async ({ page, request }) => {
    const tenantId = '00000000-0000-0000-0000-000000000001';

    // Navigate to orders page
    await page.goto(`${baseUrl}/orders`);
    
    // Find the test order
    await page.fill('input[placeholder="Search orders..."]', orderId.substring(0, 8));
    await page.waitForTimeout(1000);
    
    // Confirm order
    await page.click('button:has-text("Confirm")');
    await page.waitForTimeout(1000);
    
    // Verify status changed
    await expect(page.locator('tbody tr')).toContainText('Confirmed');
    
    // Ship order
    await page.click('button:has-text("Ship")');
    await page.waitForTimeout(1000);
    
    // Verify status changed
    await expect(page.locator('tbody tr')).toContainText('Shipped');
  });

  test('Dashboard Analytics', async ({ page }) => {
    await page.goto(`${baseUrl}/dashboard`);
    
    // Verify KPI widgets are displayed
    await expect(page.locator('.kpi-widget')).toHaveCount(4);
    
    // Verify revenue chart is present
    await expect(page.locator('canvas')).toBeVisible();
    
    // Check for data in widgets
    await expect(page.locator('.kpi-widget:has-text("Total Revenue")')).toBeVisible();
    await expect(page.locator('.kpi-widget:has-text("Total Orders")')).toBeVisible();
    await expect(page.locator('.kpi-widget:has-text("Total Customers")')).toBeVisible();
  });

  test('Product Management', async ({ page, request }) => {
    const tenantId = '00000000-0000-0000-0000-000000000001';

    await page.goto(`${baseUrl}/products`);
    
    // Switch to grid view
    await page.click('button[aria-label="Grid view"]');
    
    // Verify grid layout
    await expect(page.locator('.product-grid')).toBeVisible();
    
    // Switch to list view
    await page.click('button[aria-label="List view"]');
    
    // Verify list layout
    await expect(page.locator('table')).toBeVisible();
    
    // Test filtering
    await page.selectOption('select[name="status"]', 'Active');
    await page.waitForTimeout(1000);
    
    // Verify filtered results
    await expect(page.locator('tbody tr .status-badge')).toContainText('Active');
  });

  test('Micro-Frontend Integration', async ({ page }) => {
    // Test that all micro-frontends load correctly
    
    // Customer MF
    await page.goto(`${baseUrl}/customers`);
    await expect(page.locator('h1')).toContainText('Customers');
    
    // Product MF
    await page.goto(`${baseUrl}/products`);
    await expect(page.locator('h1')).toContainText('Products');
    
    // Order MF
    await page.goto(`${baseUrl}/orders`);
    await expect(page.locator('h1')).toContainText('Orders');
    
    // Dashboard MF
    await page.goto(`${baseUrl}/dashboard`);
    await expect(page.locator('h1')).toContainText('Dashboard');
    
    // Verify navigation works between micro-frontends
    await page.click('a[href="/customers"]');
    await page.click('a[href="/products"]');
    await page.click('a[href="/orders"]');
    await page.click('a[href="/dashboard"]');
  });

  test.afterAll(async ({ request }) => {
    // Cleanup test data
    const tenantId = '00000000-0000-0000-0000-000000000001';
    
    if (orderId) {
      await request.delete(`${apiUrl}/api/v1/orders/${orderId}`, {
        headers: { 'X-Tenant-Id': tenantId }
      });
    }
    
    if (customerId) {
      await request.delete(`${apiUrl}/api/v1/customers/${customerId}`, {
        headers: { 'X-Tenant-Id': tenantId }
      });
    }
    
    if (productId) {
      await request.delete(`${apiUrl}/api/v1/products/${productId}`, {
        headers: { 'X-Tenant-Id': tenantId }
      });
    }
  });
});
