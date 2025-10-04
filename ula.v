module ula (  
    input  wire        clock,
    input  wire        reset,
    input  wire [9:0]  x_in,        // coordenada de entrada X
    input  wire [9:0]  y_in,        // coordenada de entrada Y
    input  wire [3:0]  op,          // operação (controle de zoom)

    output reg         zoom_done,   // sinal de operação finalizada
    output reg  [16:0] address     // endereço de memória
);
   
    // Parâmetros para offsets
    localparam [9:0] H_OFFSET = 10'd160;
    localparam [9:0] V_OFFSET = 10'd120;
   
    // Limites da tela 320x240
    localparam [9:0] H_MAX = 10'd319;
    localparam [9:0] V_MAX = 10'd239;

    reg [9:0] x_calc, y_calc;
    reg [16:0] address_calc;


    always @(posedge clock or posedge reset) begin
        if (reset) begin
            address   <= 17'd0;
            zoom_done <= 1'b0;
        end else begin
            case (op)
                4'b0001: begin // Zoom in (Vizinho Mais Próximo)
                    x_calc <= ((x_in - H_OFFSET) >> 1) + H_OFFSET;
                    y_calc <= ((y_in - V_OFFSET) >> 1) + V_OFFSET;
                end
                4'b0010: begin // Zoom out (Amostragem)
                    x_calc <= ((x_in - H_OFFSET) << 1) - H_OFFSET;
                    y_calc <= ((y_in - V_OFFSET) << 1) - V_OFFSET;
                end
                default: begin // Normal
                    x_calc <= x_in - H_OFFSET;
                    y_calc <= y_in - V_OFFSET;
                end
            endcase


            if ((x_calc <= H_MAX) && (y_calc <= V_MAX)) begin              
                   address <= y_calc * 320 + x_calc;
            end else begin
                address <= 17'd0;
            end

            zoom_done <= 1'b1;  
        end
    end
endmodule
