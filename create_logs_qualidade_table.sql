-- =====================================================
-- Script para criar a tabela logs_qualidade
-- Executar no Supabase SQL Editor
-- =====================================================

-- Remove a tabela se existir (cuidado em produção!)
-- DROP TABLE IF EXISTS logs_qualidade;

-- Cria a tabela logs_qualidade
CREATE TABLE IF NOT EXISTS logs_qualidade (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    funcao_nome TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('positivo', 'negativo')),
    latencia_ms NUMERIC,
    mensagem_erro TEXT,
    dispositivo TEXT,
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- Adiciona comentários na tabela
COMMENT ON TABLE logs_qualidade IS 'Tabela para armazenar logs de qualidade e performance do sistema';
COMMENT ON COLUMN logs_qualidade.funcao_nome IS 'Nome da função que foi executada e monitorada';
COMMENT ON COLUMN logs_qualidade.status IS 'Resultado da execução: positivo (sucesso) ou negativo (erro)';
COMMENT ON COLUMN logs_qualidade.latencia_ms IS 'Tempo de execução em milissegundos';
COMMENT ON COLUMN logs_qualidade.mensagem_erro IS 'Mensagem de erro quando status é negativo';
COMMENT ON COLUMN logs_qualidade.dispositivo IS 'Tipo de dispositivo: Mobile ou Desktop';
COMMENT ON COLUMN logs_qualidade.data_hora IS 'Data e hora do registro do log';
COMMENT ON COLUMN logs_qualidade.user_id IS 'ID do usuário que executou a ação (opcional)';

-- Cria índices para melhor performance nas consultas
CREATE INDEX IF NOT EXISTS idx_logs_qualidade_data_hora ON logs_qualidade(data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_logs_qualidade_funcao ON logs_qualidade(funcao_nome);
CREATE INDEX IF NOT EXISTS idx_logs_qualidade_status ON logs_qualidade(status);
CREATE INDEX IF NOT EXISTS idx_logs_qualidade_user ON logs_qualidade(user_id);

-- Habilita Row Level Security
ALTER TABLE logs_qualidade ENABLE ROW LEVEL SECURITY;

-- Política: Usuários autenticados podem inserir logs
CREATE POLICY "logs_qualidade_insert" ON logs_qualidade
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Política: Usuários autenticados podem ver todos os logs (para relatórios)
CREATE POLICY "logs_qualidade_select" ON logs_qualidade
    FOR SELECT TO authenticated
    USING (true);

-- =====================================================
-- INSTRUÇÕES DE USO:
-- 
-- 1. Execute este script no Supabase SQL Editor
-- 2. Após criar a tabela, altere no index.html:
--    const LOGS_QUALIDADE_HABILITADOS = true;
-- 
-- A tabela registrará automaticamente métricas de:
-- - Performance das funções (latência)
-- - Status de sucesso/erro
-- - Dispositivo do usuário
-- - Timestamp de cada operação
-- =====================================================
