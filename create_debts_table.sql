-- ============================================================
-- CRIAÇÃO DA TABELA DE DÍVIDAS EM ABERTO (CONTROLE GERENCIAL)
-- Projeto: Finanças Família Pedrosa de Lima
-- Supabase Project: esknlhztamypntxxvxpe
-- ============================================================

-- Tabela de Dívidas em Aberto
-- IMPORTANTE: Esta funcionalidade é puramente de controle gerencial e 
-- não interage com saldo líquido, receitas ou despesas dos meses.

CREATE TABLE IF NOT EXISTS debts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),
    partition_id integer NOT NULL DEFAULT 1,
    name text NOT NULL,
    amount numeric(12, 2) NOT NULL DEFAULT 0,
    status text NOT NULL DEFAULT 'em_pagamento', -- 'em_pagamento', 'em_negociacao', 'estacionada'
    initial_amount numeric(12, 2),
    total_amount numeric(12, 2),
    installments integer,
    installment_value numeric(12, 2),
    current_amount numeric(12, 2),
    observation text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Índices para consultas eficientes
CREATE INDEX IF NOT EXISTS idx_debts_partition_id ON debts(partition_id);
CREATE INDEX IF NOT EXISTS idx_debts_status ON debts(status);
CREATE INDEX IF NOT EXISTS idx_debts_created_at ON debts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_debts_user_id ON debts(user_id);

-- Trigger para atualização automática da coluna updated_at
DROP TRIGGER IF EXISTS update_debts_updated_at ON debts;
CREATE TRIGGER update_debts_updated_at
    BEFORE UPDATE ON debts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Habilitar Row Level Security (RLS)
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso Global para Usuários Autenticados
-- Acesso compartilhado para todos os membros da família

DROP POLICY IF EXISTS "debts_select_all" ON debts;
CREATE POLICY "debts_select_all" ON debts
    FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "debts_insert_all" ON debts;
CREATE POLICY "debts_insert_all" ON debts
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "debts_update_all" ON debts;
CREATE POLICY "debts_update_all" ON debts
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "debts_delete_all" ON debts;
CREATE POLICY "debts_delete_all" ON debts
    FOR DELETE
    TO authenticated
    USING (true);
