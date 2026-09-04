-- =========================================================================
-- Database Schema Definition: Online Retail Ecosystem
-- Target Dialect: PostgreSQL / ANSI SQL
-- =========================================================================

-- 1. Create Schema
CREATE SCHEMA IF NOT EXISTS online_retail;

-- =========================================================================
-- 2. Create Tables
-- =========================================================================

-- Table: Users
-- Stores application user and customer profiles
CREATE TABLE online_retail.users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: Products
-- Stores catalog items available for purchase
CREATE TABLE online_retail.products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table: Orders
-- Tracks transactions made by users
CREATE TABLE online_retail.orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) 
        REFERENCES online_retail.users(user_id) 
        ON DELETE RESTRICT
);

-- Table: Order Items
-- Junction table mapping products to orders (Many-to-Many)
CREATE TABLE online_retail.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) 
        REFERENCES online_retail.orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) 
        REFERENCES online_retail.products(product_id) 
        ON DELETE RESTRICT
);

-- =========================================================================
-- 3. Performance & Optimization Indexes
-- =========================================================================
CREATE INDEX idx_users_email ON online_retail.users(email);
CREATE INDEX idx_products_sku ON online_retail.products(sku);
CREATE INDEX idx_orders_user ON online_retail.orders(user_id);
