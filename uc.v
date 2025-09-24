module uc (
    input wire clock, // Clock do CPU
    input wire reset, // Reset síncrono
    input wire zoom_done, // Sinal de finalização da operação
    input wire [22:0] instruction, // Instrução recebida da memória (FIFO)

    output reg wr_ins, // Sinal de escrita p/ FIFO
    output reg pc_count, // Sinal de leitura (incremento do PC/FIFO)

    output reg [2:0] ch,
    output reg [9:0] next_x,
    output reg [9:0] next_y
);

    // Definição dos estados
    parameter S_FETCH = 3'b000; // Buscar instrução (escrita/leitura FIFO)
    parameter S_DECODE = 3'b001; // Decodificar campos da instrução
    parameter S_EXECUTE = 3'b010; // Executar operação (espera zoom_done)
    parameter S_WRITE = 3'b011; // Concluir ciclo (volta ao FETCH)

    reg [2:0] state, next_state;

    // FSM sequencial
    always @(posedge clock or posedge reset) begin
        if (reset)
            state <= S_FETCH;
        else
            state <= next_state;
    end

    // FSM combinacional
    always @(*) begin
        // Valores padrão
        wr_ins = 0;
        pc_count = 0;
        ch = 3'b000;
        next_x = 10'b0;
        next_y = 10'b0;
        next_state = state;

        case (state)
            // ========================
            // Estado 1: Fetch
            // ========================
            S_FETCH: begin
                wr_ins = 1; // pede escrita na FIFO
                pc_count = 1; // pede leitura (incrementa PC)
                next_state = S_DECODE;
            end

            // ========================
            // Estado 2: Decode
            // ========================
            S_DECODE: begin
                {ch, next_x, next_y} = instruction; // separa os campos
                next_state = S_EXECUTE;
            end

            // ========================
            // Estado 3: Execute
            // ========================
            S_EXECUTE: begin
                if (zoom_done)
                    next_state = S_WRITE;
            end

            // ========================
            // Estado 4: Write
            // ========================
            S_WRITE: begin
                next_state = S_FETCH;
            end

            default: next_state = S_FETCH;
        endcase
    end

endmodule