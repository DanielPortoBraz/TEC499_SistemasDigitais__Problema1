module register_bank (
    input  wire        clk,
    input  wire [9:0]  img_x_in,
    input  wire [9:0]  img_y_in,
    input  wire [16:0] address_in,
    input  wire [7:0]  pixel_in,   // valor do pixel lido
    output reg  [9:0]  img_x_out,
    output reg  [9:0]  img_y_out,
    output reg  [16:0] address_out,
    output reg  [7:0]  pixel_out
);

    always @(posedge clk) begin
        img_x_out   <= img_x_in;
        img_y_out   <= img_y_in;
        address_out <= address_in;
        pixel_out   <= pixel_in;
    end

endmodule
