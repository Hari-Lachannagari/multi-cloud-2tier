"""
Product routes - API endpoints for product operations
"""
from fastapi import APIRouter, HTTPException, Query
from typing import List
from app.services.product_service import ProductService

router = APIRouter(prefix="/products", tags=["products"])


def get_product_service(products) -> ProductService:
    """Get product service instance"""
    return ProductService(products)


@router.get("", response_description="List of all products")
def list_products(products):
    """Get all products"""
    service = get_product_service(products)
    return {
        "count": service.get_product_count(),
        "products": service.get_all_products(),
    }


@router.get("/{product_id}", response_description="Product details")
def get_product(product_id: int, products):
    """Get a product by ID"""
    service = get_product_service(products)
    product = service.get_product_by_id(product_id)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@router.get("/category/{category}", response_description="Products in category")
def get_products_by_category(category: str, products):
    """Get all products in a specific category"""
    service = get_product_service(products)
    result = service.get_products_by_category(category)
    if not result:
        raise HTTPException(status_code=404, detail=f"No products found in category: {category}")
    return {
        "category": category,
        "count": len(result),
        "products": result,
    }


@router.get("/search", response_description="Search results")
def search_products(q: str = Query(..., min_length=1), products):
    """Search products by name or description"""
    service = get_product_service(products)
    results = service.search_products(q)
    return {
        "query": q,
        "count": len(results),
        "products": results,
    }


@router.get("/stock/available", response_description="Products in stock")
def get_available_products(products):
    """Get all products currently in stock"""
    service = get_product_service(products)
    available = service.get_products_in_stock()
    return {
        "count": len(available),
        "products": available,
    }


@router.get("/rating/high", response_description="High rated products")
def get_high_rated_products(min_rating: float = Query(4.0, ge=0, le=5), products):
    """Get products with high ratings"""
    service = get_product_service(products)
    rated = service.get_high_rated_products(min_rating)
    return {
        "min_rating": min_rating,
        "count": len(rated),
        "products": rated,
    }
