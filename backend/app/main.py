from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Multi-Cloud E-Commerce API",
    description="Product selling website backend",
    version="1.0.0",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Temporary product catalog
# Later this can be replaced with a database.
products = [
    {
        "id": 1,
        "name": "Wireless Headphones",
        "category": "Electronics",
        "price": 2499,
        "rating": 4.5,
        "stock": 25,
        "image": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
        "description": "Premium wireless headphones with high-quality sound and comfortable ear cushions.",
    },
    {
        "id": 2,
        "name": "Smart Watch",
        "category": "Electronics",
        "price": 3999,
        "rating": 4.4,
        "stock": 18,
        "image": "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
        "description": "Modern smart watch with fitness tracking, notifications and health monitoring.",
    },
    {
        "id": 3,
        "name": "Bluetooth Speaker",
        "category": "Electronics",
        "price": 1799,
        "rating": 4.3,
        "stock": 30,
        "image": "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1",
        "description": "Portable Bluetooth speaker with powerful sound and long battery life.",
    },
    {
        "id": 4,
        "name": "Mechanical Keyboard",
        "category": "Accessories",
        "price": 2999,
        "rating": 4.6,
        "stock": 15,
        "image": "https://images.unsplash.com/photo-1587829741301-dc798b83add3",
        "description": "Mechanical keyboard designed for gaming and professional productivity.",
    },
    {
        "id": 5,
        "name": "Wireless Mouse",
        "category": "Accessories",
        "price": 999,
        "rating": 4.2,
        "stock": 40,
        "image": "https://images.unsplash.com/photo-1527814050087-3793815479db",
        "description": "Ergonomic wireless mouse with accurate tracking and comfortable design.",
    },
    {
        "id": 6,
        "name": "Laptop Backpack",
        "category": "Accessories",
        "price": 1499,
        "rating": 4.5,
        "stock": 22,
        "image": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62",
        "description": "Durable laptop backpack with multiple compartments and water-resistant material.",
    },
]


@app.get("/")
def root():
    return {
        "application": "Multi-Cloud E-Commerce",
        "service": "Product API",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "product-api",
    }


@app.get("/api/products")
def get_products():
    return {
        "count": len(products),
        "products": products,
    }


@app.get("/api/products/{product_id}")
def get_product(product_id: int):
    for product in products:
        if product["id"] == product_id:
            return product

    raise HTTPException(
        status_code=404,
        detail="Product not found",
    )


@app.get("/api/categories")
def get_categories():
    categories = sorted(
        set(product["category"] for product in products)
    )

    return {
        "categories": categories,
    }