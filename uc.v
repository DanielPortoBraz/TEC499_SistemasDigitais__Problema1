module uc (
    input  wire        clk,
    input  wire [7:0]  pc,
    input  wire [7:0]  pixel_in,
    input  wire [9:0]  img_x_in,   // vindo da ULA
    input  wire [9:0]  img_y_in,   // vindo da ULA
    output reg  [9:0]  next_x,
    output reg  [9:0]  next_y,
    output reg  [2:0]  ch,
    output reg  [16:0] address,
    output reg  [9:0]  img_x,
    output reg  [9:0]  img_y,
    output reg  [7:0]  pixel_out
);

    // Instruction memory (ROM simples)
    always @(*) begin
        case (pc)
            8'd0: begin next_x = 10'd50;  next_y = 10'd60;  ch = 3'b000; end
            8'd1: begin next_x = 10'd100; next_y = 10'd80;  ch = 3'b010; end
            8'd2: begin next_x = 10'd150; next_y = 10'd120; ch = 3'b100; end
            default: begin next_x = 10'd0; next_y = 10'd0;  ch = 3'b000; end
        endcase
    end

    // Cálculo do endereço
    always @(*) begin
        if (img_x_in < 320 && img_y_in < 240)
            address = img_y_in * 320 + img_x_in;
        else
            address = 0;
    end

    // Register bank (armazenamento sincronizado)
    always @(posedge clk) begin
        img_x     <= img_x_in;
        img_y     <= img_y_in;
        pixel_out <= pixel_in;
    end

endmodule
