-- =====================================================
-- SCRIPT DE INICIALIZACIÓN - SISTEMA LA FAMILIA
-- =====================================================
-- Ejecutar este script en el SQL Editor de tu proyecto
-- nuevo de Supabase para "La Familia".
-- Crea todas las tablas, permisos y storage necesarios.
-- =====================================================

-- 1. TABLA DE CATÁLOGO (Productos)
CREATE TABLE IF NOT EXISTS catalog (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC DEFAULT 0,
    quantity NUMERIC DEFAULT 0,
    min_stock NUMERIC DEFAULT 5,
    cc NUMERIC DEFAULT 0,
    pack_units NUMERIC DEFAULT 1,
    barcode TEXT,
    image TEXT,
    bonus_points NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLA DE SESIONES DE CAJA Y TURNOS
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    cashier TEXT NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    initial_cash NUMERIC DEFAULT 0,
    final_cash NUMERIC DEFAULT 0,
    expected_cash NUMERIC DEFAULT 0,
    difference NUMERIC DEFAULT 0,
    sales_count INTEGER DEFAULT 0,
    declared_total NUMERIC DEFAULT 0,
    last_order_number INTEGER DEFAULT 0,
    notes TEXT,
    stats JSONB DEFAULT '{}'::jsonb,
    cash_breakdown JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABLA DE VENTAS
CREATE TABLE IF NOT EXISTS sales (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    order_number INTEGER,
    items JSONB NOT NULL,
    total_amount NUMERIC NOT NULL,
    payment_method TEXT,
    customer_id TEXT,
    points_redeemed NUMERIC DEFAULT 0,
    cash_received NUMERIC DEFAULT 0,
    card_received NUMERIC DEFAULT 0,
    transfer_received NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABLA DE GASTOS / RETIROS DE CAJA
CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    amount NUMERIC NOT NULL,
    description TEXT,
    method TEXT,
    is_automatic BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABLA DE COMPRAS
CREATE TABLE IF NOT EXISTS purchases (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    date TEXT,
    invoice_number TEXT,
    items JSONB NOT NULL,
    is_historical BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. TABLA DE CLIENTES
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dni TEXT,
    phone TEXT,
    email TEXT,
    points NUMERIC DEFAULT 0,
    history JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. TABLA DE PREMIOS / FIDELIZACIÓN
CREATE TABLE IF NOT EXISTS rewards (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT DEFAULT 'Puntos',
    point_cost NUMERIC NOT NULL,
    stock NUMERIC DEFAULT 0,
    image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. TABLA DE PERSONAL / STAFF
CREATE TABLE IF NOT EXISTS staff_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. LOGS DE STOCK Y HELADOS
CREATE TABLE IF NOT EXISTS stock_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    product_name TEXT,
    category TEXT,
    product_id TEXT,
    quantity_changed NUMERIC,
    new_quantity NUMERIC,
    reason TEXT,
    user_name TEXT DEFAULT 'Admin'
);

CREATE TABLE IF NOT EXISTS ice_cream_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    flavor_name TEXT,
    action TEXT,
    amount NUMERIC,
    user_role TEXT DEFAULT 'admin',
    user_name TEXT DEFAULT 'Admin'
);

-- =====================================================
-- PERMISOS Y SEGURIDAD (Row Level Security abierto para POS)
-- =====================================================
ALTER TABLE catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ice_cream_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Access Catalog" ON catalog FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Sessions" ON sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Sales" ON sales FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Expenses" ON expenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Purchases" ON purchases FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Customers" ON customers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Rewards" ON rewards FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Staff" ON staff_users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Stock Logs" ON stock_logs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Ice Cream Logs" ON ice_cream_logs FOR ALL USING (true) WITH CHECK (true);

-- BUCKET DE IMÁGENES
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public Access Images" ON storage.objects;
CREATE POLICY "Public Access Images" ON storage.objects FOR ALL USING ( bucket_id = 'images' ) WITH CHECK ( bucket_id = 'images' );

-- ÍNDICES DE VELOCIDAD
CREATE INDEX IF NOT EXISTS idx_catalog_category ON catalog(category);
CREATE INDEX IF NOT EXISTS idx_sales_timestamp ON sales(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_started ON sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_customers_dni ON customers(dni);

-- =====================================================

-- =====================================================
-- CATALOGO INICIAL DE PRODUCTOS (SEI TU Y CAFETERIA)
-- =====================================================
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_1', '1/2 de helado', 'Personalizados', 7500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_2', '1/4 de helado', 'Personalizados', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_3', '1kg de helado', 'Personalizados', 13000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_4', 'Affogato', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_5', 'Alfajor Blanco caja x8', 'Linea Hogareña', 12500, 50, 5, 1, '7798138004818') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_6', 'Alfajor de Maizena', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_7', 'Alfajor Helado Blanco Unidad', 'Impulsivos', 1600, 50, 5, 1, '7798138004320') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_8', 'Alfajor Helado Chocolate caja x8', 'Linea Hogareña', 12500, 50, 5, 1, '7798138004801') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_9', 'Alfajor Helado Chocolate Unidad', 'Gastronomía', 1600, 50, 5, 16, '7798138002104') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_10', 'Almendrado caja x8', 'Linea Hogareña', 10500, 50, 5, 6, '7798138004597') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_11', 'Almendrado unidad', 'Gastronomía', 1400, 50, 5, 20, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_12', 'Balde 3L (Americana/DDl/Frutilla)', 'Baldes y potes', 14000, 50, 5, 1, '7798138004665') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_13', 'Balde 3L (Banana/ Flan /Granizado)', 'Baldes y potes', 14000, 50, 5, 1, '7798138004658') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_14', 'Balde 3L (Chocolate/Frutilla/DDl)', 'Baldes y potes', 14000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_15', 'Balde 3L (Tiram/ddl/tram)', 'Baldes y potes', 14000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_16', 'Brownie', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_17', 'porcion torta matilda/ red velvet/ cvhesse cake', 'Tortas', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_18', 'Postre Tricolor caja x8', 'Linea Hogareña', 10500, 50, 5, 6, '7798138000346') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_19', 'Postre Tricolor Unidad', 'Gastronomía', 1400, 50, 5, 20, '7798138002456') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_20', 'Pote 1 Kg', 'Insumos', 0, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_21', 'Pote 1 Kg (Telgopor)', 'Insumos (Bolsas, Vasos, Cucharas)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_22', 'Pote 1/2 Kg', 'Insumos', 0, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_23', 'Pote 1/2 Kg (Telgopor)', 'Insumos (Bolsas, Vasos, Cucharas)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_24', 'Pote 1/4 Kg', 'Insumos', 0, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_25', 'Pote 1/4 Kg (Telgopor)', 'Insumos (Bolsas, Vasos, Cucharas)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_26', 'Pote 750 Americana/Frutilla', 'Baldes y potes', 7500, 50, 5, 8, '7798138004702') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_27', 'Pote 750 Chocolate/Dulce de leche', 'Baldes y potes', 7500, 50, 5, 8, '7798138004696') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_28', 'Pote 750 Crema Cookies', 'Baldes y potes', 7500, 50, 5, 8, '7798138004504') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_29', 'Pote 750 D d leche Granizado', 'Baldes y potes', 7500, 50, 5, 8, '7798138004511') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_30', 'Pote 750 Frutilla a la Crema', 'Baldes y potes', 7500, 50, 5, 8, '7798138004498') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_31', 'Pote 750 Limón', 'Baldes y potes', 7500, 50, 5, 8, '7798138000728') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_32', 'Pote 750 Super Chocolate', 'Baldes y potes', 7500, 50, 5, 8, '7798138004528') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_33', 'POTE CORMILLOT Vai/Choc 360cc', 'Impulsivos', 6000, 50, 5, 12, '7798138005051') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_34', 'Avocado', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_35', 'Balde 3L 4 gustos (Americana/DDl/Chocolate/Frutilla)', 'Baldes y potes', 14000, 50, 5, 1, '7798138004672') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_36', 'Balde 3L Nipote (Granizado/Chocolate/DDl/Flan)', 'Baldes y potes', 14000, 50, 5, 1, '7798138003910') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_37', 'Balde 5L ( Americana/DDL/Frutilla)', 'Baldes y potes', 19500, 50, 5, 1, '7798138002524') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_38', 'Balde 5L (banana, flan y granizado)', 'Baldes y potes', 19500, 50, 5, 1, '7798138004382') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_39', 'Balde 5L 4 gustos (americana/DDL/chocolate/frutilla)', 'Baldes y potes', 19500, 50, 5, 1, '7798138004412') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_40', 'Balde 5L Nipote (Granizado/Chocolate/DDl/Flan)', 'Baldes y potes', 19500, 50, 5, 1, '7798138004573') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_41', 'Banana split', 'Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_42', 'Baño de chocolate', 'Personalizados', 500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_43', 'barra de cereal', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_44', 'Barrita Seichoc banana split', 'Gastronomía', 1600, 50, 5, 1, '7798138003927') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_45', 'Barrita Seichoc banana split caja x8', 'Gastronomía', 12000, 50, 5, 1, '7798138004900') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_46', 'Batido', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_47', 'Bombon Escoces Blanco Unidad', 'Gastronomía', 1700, 50, 5, 24, '7798138002555') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_48', 'Exprimido de naranja', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_49', 'POTE DUBAI', 'Baldes y potes', 6000, 50, 5, 12, '7798138005266') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_50', 'Pote Vegano Chocolate/Vainilla', 'Baldes y potes', 8500, 50, 5, 6, '7798138004856') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_51', 'POWER FRUTOS TROPICALES', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_52', 'Power Manzana', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_53', 'Power muntain blast AZUL', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_54', 'Power UVA', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_55', 'Promo c1 (Café con leche + 2 medialunas)', 'Promos Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_56', 'Promo c10 Exprimido + avocado', 'Promos Cafetería', 6000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_57', 'Promo c11 exprimido + barra de cereal', 'Promos Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_58', 'Promo c12 Exprimido + wafle con helado', 'Promos Cafetería', 5500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_59', 'Promo c13 Milkshake + waffle con helado', 'Promos Cafetería', 6500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_60', 'Promo c14 Milkshake+ brownie con helado', 'Promos Cafetería', 7500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_61', 'Promo c2 (Café con leche + media luna J.Q.)', 'Promos Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_62', 'Promo c3 (Café con leche + 2 Tostadas)', 'Promos Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_63', '5 hispanos bolsa Cafe 1 kg.', 'Cafetería', 54000, 50, 5, 1, '7794520212113') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_64', 'Cookie', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_65', 'LECHE SOLA', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_66', 'Promo c4 (café con leche + tostado J.Q.)', 'Promos Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_67', 'Promo c5 Cappuccino + 2 medialunas', 'Promos Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_68', 'Promo c6 cappuccino + tostado J.Q.', 'Promos Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_69', 'Promo c7 cappuchino italiano + tostado J.Q.', 'Promos Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_70', 'Promo c8 Exprimido de naranja x2', 'Promos Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_71', 'Promo c9 Exprimido + tostado J.Q.', 'Promos Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_72', 'Promo helado 2 1/2 x $14.000', 'Personalizados', 14000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_73', 'Promo helado 2 1/4 x $8.500', 'Personalizados', 8500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_74', 'Promo helado 2 kilos x $24.000', 'Personalizados', 24000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_75', 'Seibom Almendras', 'Impulsivos', 2500, 50, 5, 16, '7798138001893') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_76', 'Seibom Blanco', 'Impulsivos', 2500, 50, 5, 16, '7798138001886') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_77', 'Seibom Cookies', 'Impulsivos', 2500, 50, 5, 16, '7798138004559') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_78', 'Seichoc Caja x8', 'Cajas x10 unidades', 18000, 50, 5, 1, '7798138005204') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_79', 'Seven up', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_80', 'Smoothie Frozen', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_81', 'Spedd Grande 473', 'Pizza y bebidas', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_82', 'Speed chica', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_83', 'SPEED GRANDE', 'Pizza y bebidas', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_84', 'SPEED MINI ZERO AZUCAR', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_85', 'SPEED ZERO ZUGAR', 'Pizza y bebidas', 2800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_86', 'Sprite chica sin azucar 500ml', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_87', 'sprite con azucar 500ML', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_88', 'Sprite en Lata', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_89', 'SuBatido (Vaso)', 'Descartables (Vasos/Envios)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_90', 'Submarino', 'Cafetería', 2700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_91', 'super copa', 'Postres', 6000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_92', 'SUPER TORRE', 'Cafetería', 25000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_93', 'Tarta de coco', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_94', 'Tarta de Ricota', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_95', 'Tarta frutal', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_96', 'Tazon Frutal', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_97', 'Tazon Frutal con Helado', 'Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_98', 'Tiramisu', 'Postres', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_99', 'Torta brownie Porcion', 'Promos Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_100', 'torta cheesecake Porcion', 'Promos Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_101', 'Torta Cookies', 'Tortas', 13000, 50, 5, 6, '7798138004849') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_102', 'Torta Helada Bombón', 'Tortas', 13000, 50, 5, 6, '7798138002302') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_103', 'Torta Isaballa Chocolate/Vainilla', 'Tortas', 13000, 50, 5, 6, '7798138001350') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_104', 'Torta Isabella Frutilla/DDl', 'Tortas', 13000, 50, 5, 6, '7798138001367') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_105', 'Torta Lemon Pie', 'Tortas', 13000, 50, 5, 6, '7798138002319') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_106', 'Torta Marquise frutilla/frutos rojos', 'Postres', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_107', 'Tostadas x2', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_108', 'Tostado de J.Q cheddar', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_109', 'Tostado de J.Q.', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_110', 'Tricolor Cormillot', 'Libres de gluten', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_111', 'AGUA', 'Cafetería', 500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_112', 'alfajor trassens blanco', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_113', 'Alfajor Trassens Negro', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_114', 'Allfajor Jorguito Sin Tacc', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_115', 'Baggio 125 ml manzana', 'Pizza y bebidas', 700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_116', 'baggio 125 ml miltifruta', 'Pizza y bebidas', 700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_117', 'Baggio 125 ml multifruta', 'Pizza y bebidas', 700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_118', 'Baggio 125 ml naranja', 'Pizza y bebidas', 700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_119', 'Baggio 200ml multifruta', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_120', 'Baggio Manzana 200ml', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_121', 'Baggio Naranja 200ml', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_122', 'Bombon escoces choco blanco caja x8', 'Linea Hogareña', 13000, 50, 5, 6, '7798138004832') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_123', 'Bombon Escoces choco negro caja x8', 'Linea Hogareña', 13000, 50, 5, 6, '7798138004825') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_124', 'Bombon Escoces Choco Negro Unidad', 'Gastronomía', 1700, 50, 5, 24, '7798138002470') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_125', 'Bombon Escoces Pistacho caja x8', 'Linea Hogareña', 13000, 50, 5, 1, '7798138004962') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_126', 'Bombon escoces pistacho unidad', 'Gastronomía', 1700, 50, 5, 24, '7798138004979') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_127', 'Bombon suizo caja x8', 'Gastronomía', 11500, 50, 5, 1, '7798138000339') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_128', 'Bombon Suizo unidad', 'Gastronomía', 1500, 50, 5, 1, '7798138002463') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_129', 'Promo c7 Cappuccino con tostadas', 'Cafetería', 5000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_130', 'Tricolor Cormillot Funcional Caja x6', 'Libres de gluten', 14000, 50, 5, 8, '7798138004917') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_131', 'Vasito de Oreo', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_132', 'Vaso Café Chico', 'Descartables (Vasos/Envios)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_133', 'Vaso Café Grande', 'Descartables (Vasos/Envios)', 200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_134', 'Wafles', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_135', 'Wafles con helado', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_136', 'YOGUR/GRANOLA/FRUTAS', 'Postres', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_137', 'Yogurt entero Frutilla', 'Lacteos', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_138', 'Yogurt entero Vainilla', 'Lacteos', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_139', 'Bomboncitos Crema Americana', 'Baldes y potes', 7000, 50, 5, 8, '7798138004610') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_140', 'cucurucho x3 unidades', 'Personalizados', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_141', 'Leche Agregada', 'Cafetería', 500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_142', 'Placer de 500ML Manzana', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_143', '2L Gelato Cookies/Pistacho/Flan', 'Impulsivos', 13000, 50, 5, 1, '7798138005068') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_144', 'AGUA GLON', 'Pizza y bebidas', 1000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_145', 'Alfajor de Jorgito sin gluten', 'Libres de gluten', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_146', 'Alfajor Seichoc', 'Gastronomía', 2500, 50, 5, 16, '7798138005198') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_147', 'Bomboncitos DDL', 'Baldes y potes', 7000, 50, 5, 8, '7798138004634') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_148', 'Bomboncitos Menta', 'Baldes y potes', 7000, 50, 5, 8, '7798138004627') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_149', 'Bomboncitos Pistacho', 'Baldes y potes', 7000, 50, 5, 8, '7798138005143') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_150', 'Botella de agua kalantha', 'Pizza y bebidas', 800, 50, 5, 2, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_151', 'Botella de agua Villa Manaos', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_152', 'Brownie con helado', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_153', 'budin limon/cafè/nueces/naranja', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_154', 'c15 Batido + Tostado de JyQ', 'Cafetería', 6000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_155', 'c16 Milkshake + Tostado de JyQ', 'Cafetería', 6500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_156', 'c17 Smootie Frozen + Tostado JyQ', 'Cafetería', 6500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_157', 'c18 Frapuccino + Tostado JyQ', 'Cafetería', 6500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_158', 'Café calipso', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_159', 'Café con crema', 'Cafetería', 2200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_160', 'Cafe con leche', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_161', 'Café con leche de especialidad', 'Cafetería', 2800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_162', 'Cafe con leche tazon', 'Cafetería', 2800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_163', 'Cafe con leche tazón XL', 'Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_164', 'Cafe cortado', 'Cafetería', 2200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_165', 'Cafe Doppio', 'Cafetería', 2200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_166', 'Café Escocés', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_167', 'Cafe expresso', 'Cafetería', 1600, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_168', 'Cafe Frutal', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_169', 'Café helado', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_170', 'Cafe irlandes', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_171', 'Cafe jarrita', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_172', 'Cafe ristreto', 'Cafetería', 1600, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_173', 'Cappuccino', 'Cafetería', 2900, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_174', 'Cappucino italiano', 'Cafetería', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_175', 'chocoarroz', 'Postres', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_176', 'CHOCOLATADA baggio y choco choco', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_177', 'Chocolatada tazon', 'Cafetería', 2800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_178', 'Chocolatada tazón XL', 'Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_179', 'Chocotorta', 'Postres', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_180', 'Coca cola en Lata', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_181', 'Coca sin azucar', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_182', 'Conito Vimar', 'Postres', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_183', 'Cono 1 bocha', 'Personalizados', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_184', 'Cono 2 bochas', 'Personalizados', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_185', 'Cono 3 bochas', 'Personalizados', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_186', 'Cono Tu Americana', 'Impulsivos', 2500, 50, 5, 14, '7798138002494') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_187', 'Cono Tu DDL', 'Impulsivos', 2500, 50, 5, 14, '7798138002500') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_188', 'COOKIE', 'Cafetería', 700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_189', 'Copa 110 Copita mini', 'Impulsivos', 1300, 50, 5, 24, '7798138003620') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_190', 'Copa 220 Cookie', 'Impulsivos', 2600, 50, 5, 12, '7798138004290') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_191', 'Copa 220 DDL/Chocolate', 'Impulsivos', 2600, 50, 5, 12, '7798138004580') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_192', 'Copa 220 Frutilla/Americana', 'Impulsivos', 2600, 50, 5, 12, '7798138003255') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_193', 'copa de helado con frutas', 'Postres', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_194', 'Copita Mar Acai + Banana', 'Impulsivos', 10000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_195', 'Copita Mar Acai + Frutilla', 'Impulsivos', 10000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_196', 'Copita Mar Acai + Guarana', 'Impulsivos', 10000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_197', 'CROASANT', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_198', 'Cupcake', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_199', 'Delivery', 'Personalizados', 1000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_200', 'Don pedro', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_201', 'dubai bocado', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_202', 'Efectivo a Transferencia', 'Caja', 100, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_203', 'Efectivo a Transferencia', 'Caja', 100, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_204', 'ensalada de fruta', 'Postres', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_205', 'Ensalada de frutas con helado', 'Postres', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_206', 'ENVIO', 'Personalizados', 1000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_207', 'Expreso Nescafé DDL (con leche)', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_208', 'Expresso Bonafide Colombia Equilibrado', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_209', 'Expresso Bonafide Espresso Intenso', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_210', 'Expresso Bonafide Forte Extra Intenso', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_211', 'Expresso Bonafide Selección Suave', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_212', 'Expresso de especialidad', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_213', 'Expresso Martínez Avellana', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_214', 'Expresso Martínez Brasil', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_215', 'Expresso Martínez Colombia', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_216', 'Expresso Martínez Intenso', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_217', 'Expresso Martínez Italiano', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_218', 'Expresso Martínez Lungo', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_219', 'Expresso Martínez Moka', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_220', 'Expresso Martínez Vainilla', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_221', 'Expresso Nescafé Au Lait Skinny (con leche)', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_222', 'Expresso Nescafé Chocolate Kitkat (con leche)', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_223', 'Expresso Starbucks Blonde Expresso', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_224', 'Expresso Starbucks Colombia', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_225', 'Expresso Starbucks Creamy Vainilla', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_226', 'Expresso Starbucks Espresso Roast', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_227', 'Expresso Starbucks House Blend', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_228', 'EXPRIMIDO MINI', 'Pizza y bebidas', 900, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_229', 'Fanta chica', 'Pizza y bebidas', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_230', 'FICHAS', 'Personalizados', 1000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_231', 'Flan casero solo', 'Postres', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_232', 'Flan con crema y ddl', 'Postres', 3500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_233', 'Frambuesas Frutifrozen', 'Impulsivos', 8000, 50, 5, 12, '7798138004450') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_234', 'Frappuccino', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_235', 'Gatorade', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_236', 'GIO Cookies', 'Impulsivos', 8000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_237', 'GIO DOBLE CHOCO', 'Baldes y potes', 8000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_238', 'GIO Frambuesas', 'Baldes y potes', 8000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_239', 'GIO PISTACHO', 'Impulsivos', 8000, 50, 5, 1, '7798352260229') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_240', 'Iced mocca', 'Cafetería', 3200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_241', 'infusiones (te, mate cocido, te saborizados)', 'Cafetería', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_242', 'JUGO TUTTI MANZANA', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_243', 'JUGO TUTTI MULTIFRUTA', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_244', 'JUGO TUTTI NARANJA', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_245', 'JUGO TUTTI UVA', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_246', 'Lagrima', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_247', 'Latte', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_248', 'Latte saborizado', 'Cafetería', 2700, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_249', 'Lemon pie', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_250', 'LEVITE POMELO', 'Pizza y bebidas', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_251', 'Limonada', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_252', 'loncheras seitu', 'Personalizados', 750, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_253', 'Macchiato', 'Cafetería', 2200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_254', 'Manaos 600ml cola', 'Pizza y bebidas', 900, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_255', 'Manaos 600ml lima limón', 'Pizza y bebidas', 900, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_256', 'Manaos 600ml naranja', 'Pizza y bebidas', 900, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_257', 'MATCHA', 'Pizza y bebidas', 2000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_258', 'MATCHA CON LECHE', 'Cafetería', 2500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_259', 'MATCHA DE LIMONADA', 'Cafetería', 4500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_260', 'Medialuna', 'Cafetería', 1000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_261', 'Medialuna de JyQ', 'Cafetería', 1800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_262', 'Milkshake', 'Cafetería', 4000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_263', 'Mini exprimido de naranja', 'Cafetería', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_264', 'Mini torta cookies x unid', 'Gastronomía', 1600, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_265', 'Mini Torta Cookies x8', 'Tortas', 13000, 50, 5, 6, '7798138004894') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_266', 'Mocaccino', 'Cafetería', 2200, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_267', 'Monster Ananá', 'Pizza y bebidas', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_268', 'Monster Energy', 'Pizza y bebidas', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_269', 'Monster Ultra Sunrise', 'Pizza y bebidas', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_270', 'MONSTER ZERO', 'Pizza y bebidas', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_271', 'Muffins', 'Cafetería', 1300, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_272', 'Paleta de Acai', 'Impulsivos', 5600, 50, 5, 1, '754697492531') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_273', 'Palito Bombon', 'Impulsivos', 1300, 50, 5, 24, '7798138002371') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_274', 'Palito Bombon Crocante', 'Impulsivos', 1300, 50, 5, 24, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_275', 'Palito Carita Chocolate/Vain', 'Impulsivos', 1200, 50, 5, 20, '7798138002029') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_276', 'Palito Carita Frutilla/Am', 'Impulsivos', 1200, 50, 5, 20, '7798138002012') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_277', 'Palito Cormillot', 'Libres de gluten', 1700, 50, 5, 24, '7798138005075') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_278', 'Palito de Agua Frutilla', 'Impulsivos', 800, 50, 5, 36, '7798138002210') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_279', 'Palito de Agua Limón', 'Impulsivos', 800, 50, 5, 36, '7798138002326') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_280', 'Palito de Agua Naranja', 'Impulsivos', 900, 50, 5, 24, '7798138004306') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_281', 'Palito de Agua Uva', 'Impulsivos', 800, 50, 5, 36, '7798138002203') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_282', 'Palito extra ácido', 'Impulsivos', 1200, 50, 5, 24, '7798138004887') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_283', 'Palito frisky', 'Impulsivos', 1000, 50, 5, 24, '7798138002852') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_284', 'Palito fruti frozen vegan', 'Impulsivos', 1200, 50, 5, 24, '7798138002357') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_285', 'Palito Giovi Crema Americana', 'Impulsivos', 1000, 50, 5, 24, '7798138002135') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_286', 'Palito Giovi Crema Chocolate', 'Impulsivos', 1000, 50, 5, 24, '7798138002425') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_287', 'Palito Giovi Crema Frutilla', 'Impulsivos', 1000, 50, 5, 24, '7798138002449') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_288', 'Palito Granizado Americana', 'Impulsivos', 1100, 50, 5, 24, '7798138002548') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_289', 'Palito Granizado DDL', 'Impulsivos', 1100, 50, 5, 24, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_290', 'Palito piccole', 'Impulsivos', 900, 50, 5, 24, '7798138003606') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_291', 'Palitos Carita C.cielo/Americana', 'Impulsivos', 1200, 50, 5, 20, '7798138004535') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_292', 'Palitos Sei Dolce (2corazónes)', 'Impulsivos', 3000, 50, 5, 35, '7798138005082') ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_293', 'Paso de los toros pomelo 500ml', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_294', 'Pastafrola', 'Cafetería', 1300, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_295', 'Pebete J.Q', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_296', 'Pebete salame y Q.', 'Cafetería', 3000, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_297', 'Pepsi chica', 'Pizza y bebidas', 1500, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_298', 'Placer de 500ML anana', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_299', 'Placer de 500ML Pomelo', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_300', 'Placer multifruta', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO catalog (id, name, category, price, quantity, min_stock, pack_units, barcode) VALUES ('prod_301', 'Placer Pera', 'Pizza y bebidas', 800, 50, 5, 1, NULL) ON CONFLICT (id) DO NOTHING;
