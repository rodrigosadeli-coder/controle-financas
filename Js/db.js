/* ============================================================
   CAMADA DE DADOS: OPERAÇÕES SUPABASE (CRUD)
   ============================================================ */

// [INÍCIO: INICIALIZAR_BANCO]
async function initSupabase() {
    try {
        _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
        await monitorar();
        setupRealtimeSubscription();
        console.log("Supabase conectado com sucesso!");
    } catch (error) {
        console.error("Erro na inicialização:", error);
    }
}
// [FIM: INICIALIZAR_BANCO]

// [INÍCIO: BUSCAR_DADOS_MONITORAR]
async function monitorar() {
    const { data, error } = await _supabase
        .from('transacoes')
        .select('*')
        .order('data', { ascending: false });

    if (error) {
        console.error('Erro ao buscar dados:', error);
        return;
    }
    currentData = data;
    updateUI(data); // Esta função será chamada no ui.js
}
// [FIM: BUSCAR_DADOS_MONITORAR]

// [INÍCIO: GUARDAR_TRANSACAO]
async function saveTransaction(obj) {
    let result;
    if (editingId) {
        result = await _supabase.from('transacoes').update(obj).eq('id', editingId);
        editingId = null;
    } else {
        result = await _supabase.from('transacoes').insert([obj]);
    }

    if (result.error) throw result.error;
    return result;
}
// [FIM: GUARDAR_TRANSACAO]

// [INÍCIO: APAGAR_TRANSACAO]
async function deleteTransaction(id) {
    const { error } = await _supabase.from('transacoes').delete().eq('id', id);
    if (error) throw error;
    await monitorar();
}
// [FIM: APAGAR_TRANSACAO]