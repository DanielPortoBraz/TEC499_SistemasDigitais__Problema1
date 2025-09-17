module cpu (
    input  wire      clk_in,
    input  wire [9:0] next_x,   // coordenada VGA X
    input  wire [9:0] next_y,   // coordenada VGA Y
    input  wire [2:0] ch,       // controle de zoom
    output reg  [9:0] img_x,    // coordenada processada X
    output reg  [9:0] img_y,    // coordenada processada Y
    output reg  [16:0] address  // endereco da memoria
);
    
    // Parâmetros para os offsets
    localparam [9:0] H_OFFSET = 10'd160;
    localparam [9:0] V_OFFSET = 10'd120;
    
    // Parâmetros para os limites da tela de 320x240
    localparam [9:0] H_MAX = 10'd319;
    localparam [9:0] V_MAX = 10'd239;
    
    always @(*) begin
        
        // Use as coordenadas originais para a lógica de seleção
        case (ch)
            3'b010: begin // Deslocamento para o centro (zoom out de 2x)
                // Subtrai os offsets para mover a imagem e divide por 2
                img_x = (next_x - H_OFFSET) >> 1; // 320 -> 160
                img_y = (next_y - V_OFFSET) >> 1; // 240 -> 120
            end
            3'b100: begin // Zoom in (4x)
                // Multiplica as coordenadas por 4 (na tela) e depois subtrai o offset.
                img_x = (next_x << 1) - H_OFFSET;
                img_y = (next_y << 1) - V_OFFSET;
            end
            default: begin // Modo normal (sem offset ou zoom)
                img_x = next_x - H_OFFSET;
                img_y = next_y - V_OFFSET;
            end
        endcase

        // Calcula o endereço da memória se as coordenadas resultantes
        // estiverem dentro dos limites da imagem de 320x240
        if ((img_x <= H_MAX) && (img_y <= V_MAX)) begin
            address = img_y * 320 + img_x;
        end else begin
            address = 0; // Endereço de fallback para a borda
        end
    end

endmodule