module ula ( 
    input  wire        clock,
    input  wire [9:0]  x_in,      // coordenada de entrada X
    input  wire [9:0]  y_in,      // coordenada de entrada Y
    input  wire [2:0]  op,        // operação (controle de zoom)

    output wire        zoom_done, // sinal de operação finalizada
    output reg  [9:0]  x_out,     // coordenada de saída X
    output reg  [9:0]  y_out,
    output reg  [16:0] address    // endereço de memória
);
    
    // Parâmetros para offsets
    localparam [9:0] H_OFFSET = 10'd160;
    localparam [9:0] V_OFFSET = 10'd120;
    
    // Limites da tela 320x240
    localparam [9:0] H_MAX = 10'd319;
    localparam [9:0] V_MAX = 10'd239;

    // Operação sempre finaliza em 1 ciclo (combinacional)
    assign zoom_done = 1'b1;
    
    always @(*) begin
        case (op)
            3'b010: begin // Zoom out 2x
                x_out = (x_in - H_OFFSET) >> 1; 
                y_out = (y_in - V_OFFSET) >> 1;
            end
            3'b100: begin // Zoom in 2x
                x_out = (x_in << 1) - H_OFFSET;
                y_out = (y_in << 1) - V_OFFSET;
            end
            default: begin // Normal
                x_out = x_in - H_OFFSET;
                y_out = y_in - V_OFFSET;
            end
        endcase

        // Calcula endereço válido
        if ((x_out <= H_MAX) && (y_out <= V_MAX))
            address = y_out * 320 + x_out;
        else
            address = 17'hA979; // fallback
    end

endmodule
