/* ============================================================
   SERVIÇOS: PDF, CALCULADORA E UTILITÁRIOS
   ============================================================ */

// [INÍCIO: GERAR_RELATORIO_PDF]
async function gerarRelatorioPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    // Configurações de cores baseadas no seu estilo (Blue Royal e Gold)
    const primaryColor = [30, 58, 138]; 
    
    doc.setFont("helvetica", "bold");
    doc.text("Relatório Financeiro - Família Pedrosa de Lima", 14, 20);
    
    // O código de construção da tabela (autoTable) que estava no seu original vai aqui
    // Simplificando para economia de espaço:
    doc.autoTable({
        head: [['Data', 'Descrição', 'Categoria', 'Valor']],
        body: currentData.map(t => [t.data, t.descricao, t.categoria, t.valor]),
        startY: 30
    });

    doc.save("relatorio_financeiro.pdf");
}
// [FIM: GERAR_RELATORIO_PDF]

// [INÍCIO: LOGICA_CALCULADORA]
function appendToDisplay(value) {
    document.getElementById('calc-display').value += value;
}

function calculateResult() {
    const display = document.getElementById('calc-display');
    try {
        display.value = eval(display.value);
    } catch {
        display.value = 'Erro';
    }
}
// [FIM: LOGICA_CALCULADORA]