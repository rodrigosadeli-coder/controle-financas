# 💰 Sistema de Gestão Financeira | Financial Management System
### Família Pedrosa de Lima - v2.0 (Supabase Integration)

[Português](#português) | [English](#english)

---

## <a name="português"></a> 🇧🇷 Português

Este documento detalha as atualizações críticas implementadas para garantir a persistência de dados em nuvem e a resiliência offline do sistema.

### 🚀 Novidades da Versão 2.0
* **Correção de Conectividade:** Ajuste na URL do Supabase (remoção de espaços em branco) para restaurar a comunicação com a API.
* **Histórico de Pagamentos:** Implementação da tabela `payment_history` para auditoria de todas as transações.
* **Sincronização Bidirecional:** Lógica aprimorada para garantir que dados gerados offline sejam enviados ao banco assim que a conexão retornar.
* **Automação de Contas:** Criação automática de parcelas e renovação de contas fixas.

### 📖 Guia de Manutenção Técnica
* **Entry Point:** `index.html` (Padrão para servidores Vercel).
* **Database:** PostgreSQL hospedado no Supabase.
* **Sync Logic:** O sistema utiliza `localStorage` como buffer antes de persistir no banco via `upsert`.

---

## <a name="english"></a> 🇺🇸 English

This document details the critical updates implemented to ensure cloud data persistence and the system's offline resilience.

### 🚀 What's New in Version 2.0
* **Connectivity Fix:** Adjusted the Supabase URL (removed trailing spaces) to restore API communication.
* **Payment History:** Implementation of the `payment_history` table for full transaction auditing.
* **Bi-directional Sync:** Enhanced logic to ensure offline data is pushed to the database once the connection is restored.
* **Account Automation:** Automatic creation of installments and renewal for fixed expenses.

### 📖 Technical Maintenance Guide
* **Entry Point:** `index.html` (Standard for Vercel servers).
* **Database:** PostgreSQL hosted on Supabase.
* **Sync Logic:** The system uses `localStorage` as a buffer before persisting to the database via `upsert`.

---

## 🛠️ Comandos de Atualização / Deployment Commands

Sempre que fizer alterações, use esta sequência no terminal:

```bash
# 1. Adicionar mudanças (não esqueça o ponto!)
git add .

# 2. Salvar versão
git commit -m "Update: Versão 2.0 - Integração Completa"

# 3. Enviar para a Vercel/GitHub
git push