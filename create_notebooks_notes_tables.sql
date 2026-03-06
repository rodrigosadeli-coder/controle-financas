-- ============================================================
-- CRIAÇÃO DAS TABELAS NOTEBOOKS E NOTES PARA O BLOCO DE NOTAS
-- Projeto: Finanças Família Pedrosa de Lima
-- Supabase Project: esknlhztamypntxxvxpe
-- Data: 2026-03-05
-- ============================================================

-- ============================================================
-- 1. TABELA NOTEBOOKS (Cadernos)
-- ============================================================
CREATE TABLE IF NOT EXISTS notebooks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),  -- opcional, apenas para auditoria
    name text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- Índice para ordenação por data de criação
CREATE INDEX IF NOT EXISTS idx_notebooks_created_at ON notebooks(created_at DESC);

-- Índice para user_id (auditoria)
CREATE INDEX IF NOT EXISTS idx_notebooks_user_id ON notebooks(user_id);

-- ============================================================
-- 2. TABELA NOTES (Notas)
-- ============================================================
CREATE TABLE IF NOT EXISTS notes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),  -- opcional, apenas para auditoria
    notebook_id uuid NOT NULL REFERENCES notebooks(id) ON DELETE CASCADE,
    title text,
    content text,
    media jsonb DEFAULT '[]'::jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Índice para busca por notebook
CREATE INDEX IF NOT EXISTS idx_notes_notebook_id ON notes(notebook_id);

-- Índice para ordenação por última atualização
CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes(updated_at DESC);

-- Índice para user_id (auditoria)
CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes(user_id);

-- ============================================================
-- 3. TRIGGER PARA UPDATED_AT NA TABELA NOTES
-- (Utiliza função existente: update_updated_at_column)
-- ============================================================

-- Verifica se a função já existe (deve existir no projeto)
-- Caso não exista, crie-a:
-- CREATE OR REPLACE FUNCTION update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = now();
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- Cria o trigger para atualizar updated_at automaticamente
DROP TRIGGER IF EXISTS update_notes_updated_at ON notes;
CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON notes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- 4. HABILITAR RLS (Row Level Security)
-- ============================================================
ALTER TABLE notebooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 5. POLÍTICAS DE ACESSO GLOBAL PARA AUTHENTICATED
-- (Acesso compartilhado: todos os usuários autenticados veem tudo)
-- ============================================================

-- NOTEBOOKS - Políticas de acesso global
DROP POLICY IF EXISTS "notebooks_select_all" ON notebooks;
CREATE POLICY "notebooks_select_all" ON notebooks
    FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "notebooks_insert_all" ON notebooks;
CREATE POLICY "notebooks_insert_all" ON notebooks
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "notebooks_update_all" ON notebooks;
CREATE POLICY "notebooks_update_all" ON notebooks
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "notebooks_delete_all" ON notebooks;
CREATE POLICY "notebooks_delete_all" ON notebooks
    FOR DELETE
    TO authenticated
    USING (true);

-- NOTES - Políticas de acesso global
DROP POLICY IF EXISTS "notes_select_all" ON notes;
CREATE POLICY "notes_select_all" ON notes
    FOR SELECT
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "notes_insert_all" ON notes;
CREATE POLICY "notes_insert_all" ON notes
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

DROP POLICY IF EXISTS "notes_update_all" ON notes;
CREATE POLICY "notes_update_all" ON notes
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "notes_delete_all" ON notes;
CREATE POLICY "notes_delete_all" ON notes
    FOR DELETE
    TO authenticated
    USING (true);

-- ============================================================
-- 6. COMENTÁRIOS NAS TABELAS
-- ============================================================
COMMENT ON TABLE notebooks IS 'Cadernos do Bloco de Notas - acesso compartilhado global';
COMMENT ON TABLE notes IS 'Notas do Bloco de Notas - vinculadas a cadernos com exclusão em cascata';
COMMENT ON COLUMN notebooks.user_id IS 'Opcional: usuário que criou o caderno (apenas auditoria)';
COMMENT ON COLUMN notes.user_id IS 'Opcional: usuário que criou a nota (apenas auditoria)';
COMMENT ON COLUMN notes.notebook_id IS 'FK para notebooks com ON DELETE CASCADE';
COMMENT ON COLUMN notes.media IS 'Array JSON de mídias (imagens em base64)';

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
