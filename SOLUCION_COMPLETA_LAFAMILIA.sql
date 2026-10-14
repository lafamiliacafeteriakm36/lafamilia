-- ========================================================
-- SCRIPT DEFINITIVO DE PERMISOS Y TABLAS PARA LA FAMILIA
-- Proyecto Supabase: bhqauxajwpcrfznxatzz
-- Ejecutar en: Supabase -> SQL Editor -> New Query -> Run
-- ========================================================

-- 1. TABLAS PRINCIPALES (Creacion segura si no existen)
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sales (
    id TEXT PRIMARY KEY,
    session_id TEXT,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    total NUMERIC NOT NULL,
    payment_method TEXT NOT NULL,
    cashier TEXT NOT NULL,
    order_number INTEGER,
    client_name TEXT,
    client_dni TEXT,
    notes TEXT,
    is_split BOOLEAN DEFAULT FALSE,
    payments JSONB,
    billing_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    session_id TEXT,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    category TEXT,
    cashier TEXT,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS purchases (
    id TEXT PRIMARY KEY,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    supplier TEXT NOT NULL,
    invoice_number TEXT,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    total NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dni TEXT UNIQUE,
    phone TEXT,
    email TEXT,
    points NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLAS DE EMPLEADOS, VALES Y FINANZAS
CREATE TABLE IF NOT EXISTS employees (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    role TEXT DEFAULT 'cajero',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS debts (
    id TEXT PRIMARY KEY,
    employee_id TEXT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP WITH TIME ZONE,
    session_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS recurring_expenses (
    id TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    frequency TEXT DEFAULT 'monthly',
    category TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS envelopes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target_amount NUMERIC DEFAULT 0,
    current_amount NUMERIC DEFAULT 0,
    category TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id TEXT PRIMARY KEY,
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}'::jsonb,
    user_name TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PERMISOS TOTALES (Desbloquear RLS para el POS local)
ALTER TABLE catalog DISABLE ROW LEVEL SECURITY;
ALTER TABLE sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE purchases DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE employees DISABLE ROW LEVEL SECURITY;
ALTER TABLE debts DISABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE envelopes DISABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;

GRANT ALL ON catalog TO anon, authenticated;
GRANT ALL ON sessions TO anon, authenticated;
GRANT ALL ON sales TO anon, authenticated;
GRANT ALL ON expenses TO anon, authenticated;
GRANT ALL ON purchases TO anon, authenticated;
GRANT ALL ON customers TO anon, authenticated;
GRANT ALL ON employees TO anon, authenticated;
GRANT ALL ON debts TO anon, authenticated;
GRANT ALL ON recurring_expenses TO anon, authenticated;
GRANT ALL ON envelopes TO anon, authenticated;
GRANT ALL ON audit_logs TO anon, authenticated;
