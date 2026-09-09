-- ============================================================
-- POLÍTICAS DE EXCLUSÃO (DELETE) PARA O RESETAR
-- Projeto: Finanças Família Pedrosa de Lima
-- Supabase Project: esknlhztamypntxxvxpe
-- ============================================================
--
-- QUANDO RODAR ESTE ARQUIVO
--
-- Só é necessário se, ao usar "RESETAR MÊS ATUAL" ou "RESETAR GERAL",
-- o app exibir a mensagem:
--
--   "N lançamento(s) resistiram à exclusão. A política de acesso (RLS)
--    da tabela transactions provavelmente não permite DELETE."
--
-- Isso significa que o banco aceitou o comando mas não apagou nada,
-- porque a política de segurança em nível de linha (RLS) não autoriza
-- DELETE para o usuário logado.
--
-- COMO RODAR
--   Supabase → SQL Editor → cole este arquivo → Run.
--
-- MODELO DE ACESSO
--   O app é familiar: todos os usuários autenticados veem e administram
--   TODOS os lançamentos. As políticas abaixo seguem exatamente esse
--   mesmo modelo, já usado em notebooks e notes.
-- ============================================================


-- ============================================================
-- 1. TRANSACTIONS - permitir exclusão por qualquer autenticado
-- ============================================================
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "transactions_delete_all" ON transactions;
CREATE POLICY "transactions_delete_all" ON transactions
    FOR DELETE
    TO authenticated
    USING (true);


-- ============================================================
-- 2. PAYMENT_HISTORY - idem
--
-- O reset tolera a falha desta tabela (apaga as transações mesmo
-- assim), mas sem esta política o histórico fica órfão no banco.
-- ============================================================
ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "payment_history_delete_all" ON payment_history;
CREATE POLICY "payment_history_delete_all" ON payment_history
    FOR DELETE
    TO authenticated
    USING (true);


-- ============================================================
-- 3. CONFERÊNCIA
--    Depois de rodar, estas consultas devem listar as políticas criadas.
-- ============================================================
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE tablename IN ('transactions', 'payment_history')
ORDER BY tablename, cmd;

-- Contagem atual (use para conferir o resultado de um RESETAR GERAL:
-- as duas contagens devem ficar em 0)
SELECT
    (SELECT count(*) FROM transactions)    AS transacoes,
    (SELECT count(*) FROM payment_history) AS historico_pagamentos;
