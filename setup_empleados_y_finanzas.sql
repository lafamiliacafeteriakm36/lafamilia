-- =====================================================
-- TABLAS DE EMPLEADOS, FINANZAS Y GASTOS (LA FAMILIA)
-- =====================================================

-- 1. TABLA DE EMPLEADOS (Personal, vales, cuenta corriente)
CREATE TABLE IF NOT EXISTS employees (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    active BOOLEAN DEFAULT true,
    records JSONB DEFAULT '[]'::jsonb,
    profile JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for employees" ON employees;
CREATE POLICY "Allow all for employees" ON employees FOR ALL USING (true) WITH CHECK (true);

-- 2. TABLA DE DEUDAS Y PROVEEDORES
CREATE TABLE IF NOT EXISTS debts (
    id TEXT PRIMARY KEY,
    supplier TEXT NOT NULL,
    amount NUMERIC NOT NULL DEFAULT 0,
    paid NUMERIC NOT NULL DEFAULT 0,
    due_date DATE,
    invoice_number TEXT,
    notes TEXT,
    payments JSONB DEFAULT '[]'::jsonb,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for debts" ON debts;
CREATE POLICY "Allow all for debts" ON debts FOR ALL USING (true) WITH CHECK (true);

-- 3. TABLA DE GASTOS FIJOS
CREATE TABLE IF NOT EXISTS recurring_expenses (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    amount NUMERIC NOT NULL DEFAULT 0,
    due_day INTEGER,
    category TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE recurring_expenses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for recurring_expenses" ON recurring_expenses;
CREATE POLICY "Allow all for recurring_expenses" ON recurring_expenses FOR ALL USING (true) WITH CHECK (true);

-- 4. TABLA DE SOBRES
CREATE TABLE IF NOT EXISTS envelopes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    balance NUMERIC NOT NULL DEFAULT 0,
    history JSONB DEFAULT '[]'::jsonb,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE envelopes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for envelopes" ON envelopes;
CREATE POLICY "Allow all for envelopes" ON envelopes FOR ALL USING (true) WITH CHECK (true);

-- 5. TABLA DE AUDITORIA
CREATE TABLE IF NOT EXISTS audit_logs (
    id TEXT PRIMARY KEY,
    action TEXT NOT NULL,
    details TEXT,
    cashier TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for audit_logs" ON audit_logs;
CREATE POLICY "Allow all for audit_logs" ON audit_logs FOR ALL USING (true) WITH CHECK (true);
