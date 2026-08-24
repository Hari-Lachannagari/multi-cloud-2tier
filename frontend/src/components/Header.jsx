/**
 * Header Component - Navigation and branding
 */
import React from 'react';
import { FiSearch, FiShoppingCart, FiMenu, FiX } from 'react-icons/fi';
import { Link } from 'react-router-dom';

export default function Header({ cartCount = 0, onSearch, categories = [] }) {
  const [isMenuOpen, setIsMenuOpen] = React.useState(false);
  const [searchQuery, setSearchQuery] = React.useState('');

  const handleSearch = (e) => {
    e.preventDefault();
    if (onSearch && searchQuery.trim()) {
      onSearch(searchQuery);
    }
  };

  return (
    <header className="bg-white shadow-md sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4">
        {/* Main Header */}
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold">E</span>
            </div>
            <span className="font-bold text-xl hidden sm:block">ECommerce</span>
          </Link>

          {/* Search Bar */}
          <form onSubmit={handleSearch} className="flex-1 mx-4 hidden sm:flex">
            <div className="flex w-full bg-gray-100 rounded-lg">
              <input
                type="text"
                placeholder="Search products..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 px-4 py-2 bg-transparent outline-none"
              />
              <button
                type="submit"
                className="px-4 py-2 text-gray-600 hover:text-blue-600"
              >
                <FiSearch size={20} />
              </button>
            </div>
          </form>

          {/* Right Actions */}
          <div className="flex items-center gap-4">
            <Link to="/cart" className="relative">
              <FiShoppingCart size={24} className="cursor-pointer hover:text-blue-600" />
              {cartCount > 0 && (
                <span className="absolute top-0 right-0 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                  {cartCount}
                </span>
              )}
            </Link>

            {/* Mobile Menu Button */}
            <button
              className="sm:hidden"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
            >
              {isMenuOpen ? <FiX size={24} /> : <FiMenu size={24} />}
            </button>
          </div>
        </div>

        {/* Mobile Search */}
        <div className="sm:hidden pb-4">
          <form onSubmit={handleSearch} className="flex">
            <input
              type="text"
              placeholder="Search..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 px-3 py-2 bg-gray-100 rounded-l-lg outline-none text-sm"
            />
            <button
              type="submit"
              className="px-3 py-2 bg-blue-600 text-white rounded-r-lg"
            >
              <FiSearch size={18} />
            </button>
          </form>
        </div>

        {/* Category Navigation */}
        <nav className="border-t border-gray-200">
          <div className={`flex flex-col sm:flex-row gap-2 sm:gap-6 py-3 ${isMenuOpen ? 'block' : 'hidden sm:flex'}`}>
            <Link to="/" className="text-gray-700 hover:text-blue-600 font-medium text-sm">
              All Products
            </Link>
            {categories.map((category) => (
              <Link
                key={category}
                to={`/category/${category}`}
                className="text-gray-700 hover:text-blue-600 font-medium text-sm"
              >
                {category}
              </Link>
            ))}
          </div>
        </nav>
      </div>
    </header>
  );
}
