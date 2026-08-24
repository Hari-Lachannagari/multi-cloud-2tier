/**
 * ProductCard Component - Reusable product display card
 */
import React from 'react';
import { FiShoppingCart, FiHeart } from 'react-icons/fi';
import { AiFillStar } from 'react-icons/ai';

export default function ProductCard({ product, onAddToCart, onLike }) {
  const [isLiked, setIsLiked] = React.useState(false);

  const handleLike = () => {
    setIsLiked(!isLiked);
    if (onLike) onLike(product.id);
  };

  const handleAddToCart = () => {
    if (onAddToCart) onAddToCart(product);
  };

  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-xl transition-shadow p-4 h-full flex flex-col">
      {/* Product Image */}
      <div className="relative h-48 bg-gray-200 rounded-lg overflow-hidden mb-4">
        <img
          src={product.image}
          alt={product.name}
          className="w-full h-full object-cover hover:scale-105 transition-transform"
          onError={(e) => {
            e.target.src = 'https://via.placeholder.com/300?text=Product';
          }}
        />
        <button
          className={`absolute top-2 right-2 p-2 rounded-full ${
            isLiked ? 'bg-red-500' : 'bg-white'
          }`}
          onClick={handleLike}
        >
          <FiHeart
            size={20}
            color={isLiked ? 'white' : 'red'}
            fill={isLiked ? 'white' : 'none'}
          />
        </button>
      </div>

      {/* Product Info */}
      <div className="flex-grow">
        <p className="text-xs text-gray-500 mb-1">{product.category}</p>
        <h3 className="font-bold text-lg mb-2 line-clamp-2">{product.name}</h3>
        <p className="text-sm text-gray-600 mb-3 line-clamp-2">{product.description}</p>

        {/* Rating */}
        <div className="flex items-center gap-1 mb-3">
          <AiFillStar className="text-yellow-400" />
          <span className="text-sm font-semibold">{product.rating}</span>
        </div>
      </div>

      {/* Price and Stock */}
      <div className="border-t pt-3">
        <div className="flex justify-between items-center mb-3">
          <span className="text-2xl font-bold text-blue-600">₹{product.price}</span>
          <span
            className={`text-sm font-semibold ${
              product.stock > 0 ? 'text-green-600' : 'text-red-600'
            }`}
          >
            {product.stock > 0 ? `${product.stock} in stock` : 'Out of stock'}
          </span>
        </div>

        {/* Add to Cart Button */}
        <button
          onClick={handleAddToCart}
          disabled={product.stock === 0}
          className={`w-full py-2 px-4 rounded-lg font-semibold flex items-center justify-center gap-2 transition ${
            product.stock > 0
              ? 'bg-blue-600 text-white hover:bg-blue-700'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          <FiShoppingCart size={18} />
          Add to Cart
        </button>
      </div>
    </div>
  );
}
