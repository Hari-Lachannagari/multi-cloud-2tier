/**
 * API Service - Axios instance for backend API calls
 */
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Error handling interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export const productAPI = {
  // Get all products
  getAll: () => apiClient.get('/products'),
  
  // Get product by ID
  getById: (id) => apiClient.get(`/products/${id}`),
  
  // Get products by category
  getByCategory: (category) => apiClient.get(`/products/category/${category}`),
  
  // Search products
  search: (query) => apiClient.get('/search', { params: { q: query } }),
  
  // Get available products
  getAvailable: () => apiClient.get('/products/stock/available'),
  
  // Get high-rated products
  getHighRated: (minRating = 4.0) => 
    apiClient.get('/products/rating/high', { params: { min_rating: minRating } }),
};

export const categoryAPI = {
  // Get all categories
  getAll: () => apiClient.get('/categories'),
};

export default apiClient;
