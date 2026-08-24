"""
Product service - Business logic for product operations
"""
from typing import List, Optional, Dict, Any
from app.config import settings


class ProductService:
    """Service for handling product operations"""
    
    def __init__(self, products: List[Dict[str, Any]]):
        """Initialize with product list"""
        self.products = products
        self.cache = {} if settings.enable_caching else None
    
    def get_all_products(self) -> List[Dict[str, Any]]:
        """Get all products"""
        return self.products
    
    def get_product_by_id(self, product_id: int) -> Optional[Dict[str, Any]]:
        """Get product by ID"""
        for product in self.products:
            if product["id"] == product_id:
                return product
        return None
    
    def get_products_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get all products in a category"""
        return [p for p in self.products if p["category"].lower() == category.lower()]
    
    def get_categories(self) -> List[str]:
        """Get all unique categories"""
        return sorted(set(p["category"] for p in self.products))
    
    def search_products(self, query: str) -> List[Dict[str, Any]]:
        """Search products by name or description"""
        query_lower = query.lower()
        return [
            p for p in self.products
            if query_lower in p["name"].lower() or 
               query_lower in p["description"].lower()
        ]
    
    def get_products_in_stock(self) -> List[Dict[str, Any]]:
        """Get all products with stock > 0"""
        return [p for p in self.products if p["stock"] > 0]
    
    def get_high_rated_products(self, min_rating: float = 4.0) -> List[Dict[str, Any]]:
        """Get products with rating >= min_rating"""
        return [p for p in self.products if p["rating"] >= min_rating]
    
    def add_product(self, product: Dict[str, Any]) -> Dict[str, Any]:
        """Add a new product"""
        new_id = max([p["id"] for p in self.products]) + 1
        product["id"] = new_id
        self.products.append(product)
        return product
    
    def update_product_stock(self, product_id: int, quantity: int) -> Optional[Dict[str, Any]]:
        """Update product stock"""
        product = self.get_product_by_id(product_id)
        if product:
            product["stock"] = quantity
            return product
        return None
    
    def get_product_count(self) -> int:
        """Get total product count"""
        return len(self.products)
    
    def get_products_by_price_range(self, min_price: int, max_price: int) -> List[Dict[str, Any]]:
        """Get products within price range"""
        return [
            p for p in self.products
            if min_price <= p["price"] <= max_price
        ]
