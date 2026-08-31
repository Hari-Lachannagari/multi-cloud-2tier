```javascript
/**
 * API Service - Backend API communication
 */

import axios from 'axios';

// Use the same-origin /api path.
// Nginx proxies /api requests to the backend container.
const API_BASE_URL = '/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Product APIs
export const productAPI = {
  getAll: () => apiClient.get('/products'),

  getById: (id) => apiClient.get(`/products/${id}`),

  getByCategory: (category) =>
    apiClient.get(`/products/category/${category}`),

  search: (query) =>
    apiClient.get('/products/search', {
      params: { q: query },
    }),

  getAvailable: () =>
    apiClient.get('/products/stock/available'),

  getHighRated: (minRating = 4.0) =>
    apiClient.get('/products/rating/high', {
      params: { min_rating: minRating },
    }),
};

// Category APIs
export const categoryAPI = {
  getAll: () => apiClient.get('/categories'),
};

export default apiClient;
```
