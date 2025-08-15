import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp up
    { duration: '1m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 100 }, // Ramp up to 100
    { duration: '2m', target: 100 },  // Stay at 100
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete within 500ms
    errors: ['rate<0.1'],             // Error rate must be below 10%
  },
};

const BASE_URL = 'http://localhost:7000';
const TENANT_ID = '00000000-0000-0000-0000-000000000001';

export function setup() {
  // Create test data
  const headers = {
    'Content-Type': 'application/json',
    'X-Tenant-Id': TENANT_ID,
  };

  // Create category
  const categoryPayload = JSON.stringify({
    name: 'Load Test Category',
    description: 'Category for load testing'
  });

  const categoryResponse = http.post(`${BASE_URL}/api/v1/categories`, categoryPayload, { headers });
  const categoryId = JSON.parse(categoryResponse.body).id;

  // Create product
  const productPayload = JSON.stringify({
    name: 'Load Test Product',
    description: 'Product for load testing',
    sku: `LOAD-TEST-${Date.now()}`,
    categoryId: categoryId,
    price: 99.99,
    currency: 'USD',
    stockQuantity: 1000
  });

  const productResponse = http.post(`${BASE_URL}/api/v1/products`, productPayload, { headers });
  const productId = JSON.parse(productResponse.body).id;

  // Create customer
  const customerPayload = JSON.stringify({
    email: `loadtest-${Date.now()}@example.com`,
    firstName: 'Load',
    lastName: 'Test',
    dateOfBirth: '1990-01-01'
  });

  const customerResponse = http.post(`${BASE_URL}/api/v1/customers`, customerPayload, { headers });
  const customerId = JSON.parse(customerResponse.body).id;

  return { categoryId, productId, customerId };
}

export default function(data) {
  const headers = {
    'Content-Type': 'application/json',
    'X-Tenant-Id': TENANT_ID,
  };

  // Test scenarios
  const scenarios = [
    () => testGetCustomers(),
    () => testGetProducts(),
    () => testGetOrders(),
    () => testCreateOrder(data),
    () => testGetDashboard(),
  ];

  // Randomly select a scenario
  const scenario = scenarios[Math.floor(Math.random() * scenarios.length)];
  scenario();

  sleep(1);
}

function testGetCustomers() {
  const response = http.get(`${BASE_URL}/api/v1/customers`, {
    headers: { 'X-Tenant-Id': TENANT_ID }
  });

  const success = check(response, {
    'customers endpoint status is 200': (r) => r.status === 200,
    'customers response time < 500ms': (r) => r.timings.duration < 500,
  });

  errorRate.add(!success);
}

function testGetProducts() {
  const response = http.get(`${BASE_URL}/api/v1/products`, {
    headers: { 'X-Tenant-Id': TENANT_ID }
  });

  const success = check(response, {
    'products endpoint status is 200': (r) => r.status === 200,
    'products response time < 500ms': (r) => r.timings.duration < 500,
  });

  errorRate.add(!success);
}

function testGetOrders() {
  const response = http.get(`${BASE_URL}/api/v1/orders`, {
    headers: { 'X-Tenant-Id': TENANT_ID }
  });

  const success = check(response, {
    'orders endpoint status is 200': (r) => r.status === 200,
    'orders response time < 500ms': (r) => r.timings.duration < 500,
  });

  errorRate.add(!success);
}

function testCreateOrder(data) {
  const orderPayload = JSON.stringify({
    customerId: data.customerId,
    currency: 'USD',
    items: [{
      productId: data.productId,
      productName: 'Load Test Product',
      quantity: 1,
      unitPrice: 99.99
    }]
  });

  const response = http.post(`${BASE_URL}/api/v1/orders`, orderPayload, {
    headers: {
      'Content-Type': 'application/json',
      'X-Tenant-Id': TENANT_ID,
    }
  });

  const success = check(response, {
    'create order status is 201': (r) => r.status === 201,
    'create order response time < 1000ms': (r) => r.timings.duration < 1000,
  });

  errorRate.add(!success);
}

function testGetDashboard() {
  // Simulate dashboard data requests
  const endpoints = [
    '/api/v1/dashboard/metrics',
    '/api/v1/dashboard/revenue',
    '/api/v1/dashboard/orders-stats'
  ];

  endpoints.forEach(endpoint => {
    const response = http.get(`${BASE_URL}${endpoint}`, {
      headers: { 'X-Tenant-Id': TENANT_ID }
    });

    const success = check(response, {
      [`${endpoint} response time < 300ms`]: (r) => r.timings.duration < 300,
    });

    errorRate.add(!success);
  });
}

export function teardown(data) {
  // Cleanup test data
  const headers = { 'X-Tenant-Id': TENANT_ID };

  if (data.customerId) {
    http.del(`${BASE_URL}/api/v1/customers/${data.customerId}`, null, { headers });
  }
  
  if (data.productId) {
    http.del(`${BASE_URL}/api/v1/products/${data.productId}`, null, { headers });
  }
  
  if (data.categoryId) {
    http.del(`${BASE_URL}/api/v1/categories/${data.categoryId}`, null, { headers });
  }
}
