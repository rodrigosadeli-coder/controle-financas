/* ============================================================
   INTERFACE (UI): MODAIS E EXIBIÇÃO DE DADOS
   ============================================================ */

// [INÍCIO: ATUALIZAR_TELA_PRINCIPAL]
function updateUI(data) {
    const total = data.reduce((acc, item) => acc + (item.tipo === 'receita' ? item.valor : -item.valor), 0);
    const visor = document.getElementById('saldo-total');
    
    if(visor) {
        visor.textContent = `R$ ${total.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`;
        visor.style.color = total >= 0 ? '#D4AF37' : '#ff4d4d';
    }
    renderTable(data);
}
// [FIM: ATUALIZAR_TELA_PRINCIPAL]

// [INÍCIO: CONTROLE_DE_MODAIS]
function openAddModal() {
    document.getElementById('addModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('addModal').style.display = 'none';
    editingId = null; // Reseta edição ao fechar
}
// [FIM: CONTROLE_DE_MODAIS]

// [INÍCIO: NOTIFICAÇÕES]
function showNotification(msg, type = 'success') {
    // Código para criar o balão de alerta na tela
    console.log(`[${type}] ${msg}`);
}
// [FIM: NOTIFICAÇÕES]