module ula (
    input  wire [9:0] x_in,   // coordenada de entrada X
    input  wire [9:0] y_in,   // coordenada de entrada Y
    input  wire [2:0] op,     // operação (controle de zoom)
    output reg  [9:0] x_out,  // coordenada de saída X
    output reg  [9:0] y_out
);

    always @(*) begin
        case (op)
            3'b010: begin
                x_out = x_in >> 1;   // zoom out
                y_out = y_in >> 1;
            end
            3'b100: begin
                x_out = x_in << 1;   // zoom in
                y_out = y_in << 1;
            end
            default: begin
                x_out = x_in;        // normal
                y_out = y_in;
            end
        endcase
    end

endmodule
