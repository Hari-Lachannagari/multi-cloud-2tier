"""
Category routes - API endpoints for category operations
"""
from fastapi import APIRouter
from app.services.product_service import ProductService

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("", response_description="List of all categories")
def get_categories(products):
    """Get all available categories"""
    service = ProductService(products)
    categories = service.get_categories()
    return {
        "count": len(categories),
        "categories": categories,
    }
