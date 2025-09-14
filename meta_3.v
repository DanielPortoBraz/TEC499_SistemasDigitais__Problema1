module meta_3(
    input  wire       clock,      
    input  wire       reset,
    input  wire [2:0] chaves,   
    output wire       hsync,
    output wire       vsync,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue,
    output wire       sync,
    output wire       clk,
    output wire       blank
);

    // ==== Divisor de clock para gerar 25 MHz ====
    wire clock_25mhz;
    divisor u_divisor (
        .q(clock),
        .clock_25mhz(clock_25mhz)
    );

    // ==== Sinais VGA ====
    wire [9:0] next_x;
    wire [9:0] next_y;

    // ==== Interconexão CPU <-> Memória ====
    wire [16:0] address;
    wire [7:0]  pixel_data;
    wire [9:0]  img_x, img_y;

    // ==== CPU (com ULA integrada) ====
    cpu u_cpu (
        .clk_in(clock_25mhz),
        .next_x(next_x),
        .next_y(next_y),
        .ch(chaves),
        .img_x(img_x),
        .img_y(img_y),
        .address(address)
    );

    // ==== Memória de imagem ====
    memory2 u_mem (
        .clock(clock),
        .data(8'd0),
        .address(address),
        .wren(1'b0),
        .q(pixel_data)
    );

    // ==== Controlador VGA ====
    vga_module u_vga (
        .clock(clock_25mhz),
        .color_in(pixel_data), // envia pixel lido
        .next_x(next_x),
        .next_y(next_y),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .sync(sync),
        .clk(clk),
        .blank(blank)
    );

endmodule

