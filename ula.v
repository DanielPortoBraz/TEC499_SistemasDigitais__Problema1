module ula (  
    input  wire        clock,
    input  wire        reset,
    input  wire [9:0]  x_in,        // coordenada de entrada X
    input  wire [9:0]  y_in,        // coordenada de entrada Y
    input  wire [2:0]  op,          // operação (controle de zoom)
    input  wire [1:0]  zoom_factor, // fator de zoom (0x, 2x, 4x, 8x)

    output reg         zoom_done,   // sinal de operação finalizada
    output reg  [9:0]  x_out,       // coordenada de saída X
    output reg  [9:0]  y_out,
    output reg  [16:0] address      // endereço de memória
);
    
    // Parâmetros para offsets
    localparam [9:0] H_OFFSET = 10'd160;
    localparam [9:0] V_OFFSET = 10'd120;
    
    // Limites da tela 320x240
    localparam [9:0] H_MAX = 10'd319;
    localparam [9:0] V_MAX = 10'd239;

    reg [9:0] x_calc, y_calc;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            x_out    <= 10'd0;
            y_out    <= 10'd0;
            address  <= 17'd0;
            zoom_done <= 1'b0;
        end else begin
            case (op)
                3'b010: begin // Zoom in (genérico)
                    x_calc <= ((x_in - H_OFFSET) >> zoom_factor)  + 10'd80; 
                    y_calc <= ((y_in - V_OFFSET) >> zoom_factor)  + 10'd80;
                end
                3'b100: begin // Zoom out (genérico)
                    x_calc <= ((x_in << zoom_factor) - H_OFFSET) - (10'd320 << (zoom_factor-1));
                    y_calc <= ((y_in << zoom_factor) - V_OFFSET) - (10'd320 << (zoom_factor-1));
                end
                default: begin // Normal
                    x_calc <= x_in - H_OFFSET;
                    y_calc <= y_in - V_OFFSET;
                end
            endcase

            // Atualiza saídas
            x_out <= x_calc;
            y_out <= y_calc;

            if ((x_calc <= H_MAX) && (y_calc <= V_MAX))
                address <= y_calc * 320 + x_calc;
            else
                address <= 17'd0;

            zoom_done <= 1'b1;   
        end
    end
endmodule
