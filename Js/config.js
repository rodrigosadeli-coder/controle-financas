/* ============================================================
   CONFIGURAÇÃO E ESTADOS GLOBAIS
   ============================================================ */

// [INÍCIO: CONFIG_SUPABASE]
const SUPABASE_URL = 'https://sua-url.supabase.co'; // Substitua pela sua URL
const SUPABASE_KEY = 'sua-chave-aqui';             // Substitua pela sua Key
let _supabase;
// [FIM: CONFIG_SUPABASE]

// [INÍCIO: VARIÁVEIS_DE_ESTADO]
let currentData = [];
let pendingData = [];
let currentHistoryData = [];
let editingId = null;
let editingPendingId = null;
// [FIM: VARIÁVEIS_DE_ESTADO]