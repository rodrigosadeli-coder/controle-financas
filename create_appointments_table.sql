-- ============================================================
-- CRIAÇÃO DA TABELA DE COMPROMISSOS E ALERTAS (CONFIGURAÇÃO MANUAL)
-- Projeto: Finanças Família Pedrosa de Lima
-- Supabase Project: esknlhztamypntxxvxpe
-- ============================================================

-- Tabela de Compromissos com Alertas Configuráveis
CREATE TABLE IF NOT EXISTS appointments (
    id text PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id),
    description text NOT NULL,
    date date NOT NULL,
    time text,
    persistence text NOT NULL DEFAULT 'startup_hourly', -- 'once', 'startup_hourly', 'hourly', 'half_hourly', 'daily', 'until_completed'
    notes text,
    alert boolean NOT NULL DEFAULT true,
    status text NOT NULL DEFAULT 'pending', -- 'pending', 'completed'
    last_alert_timestamp bigint,
    last_alert_date text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Índices para buscas eficientes
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_created_at ON appointments(created_at DESC);

-- Habilitar Row Level Security (RLS)
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso Global Compartilhado entre a família
DROP POLICY IF EXISTS "appointments_select_all" ON appointments;
CREATE POLICY "appointments_select_all" ON appointments
    FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "appointments_insert_all" ON appointments;
CREATE POLICY "appointments_insert_all" ON appointments
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "appointments_update_all" ON appointments;
CREATE POLICY "appointments_update_all" ON appointments
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "appointments_delete_all" ON appointments;
CREATE POLICY "appointments_delete_all" ON appointments
    FOR DELETE
    TO authenticated
    USING (true);
