module main(
    input  wire       clock,      
    input  wire       reset,
    input  wire [3:0] chaves,  
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

    // ==== PLL para clock de 100 MHz (CPU/ULA) ====
    wire clock_100mhz;
    pll_100mhz pll_100mhz_inst (
        .refclk   (clock),   
        .rst      (1'b0),    
        .outclk_0 (clock_100mhz),
        .locked   ()
    );

    // ==== Sinais VGA ====
    wire [9:0] next_x;
    wire [9:0] next_y;

    // ==== Interconexão CPA <-> MEM ====
    wire [16:0] address;

    // ==== CPA: UC + ULA integrada ====
    cpa u_cpa (
        .clk_in(~clock_100mhz),
        .instruction({chaves, next_x, next_y}),
        .address(address)
    );

    // ==== Memória primária (fonte da imagem) ====
    wire [7:0] pixel_data_u1;
    memory u1_mem (
        .clock(~clock_25mhz),
        .data(8'd0),
        .address(address),
        .wren(1'b0), // somente leitura
        .q(pixel_data_u1)
    );

    // ==== Memória secundária (framebuffer 320x240) ====
    reg [16:0] write_addr;
    reg        frame_ready;
    wire [7:0] pixel_data_u2;
    wire [16:0] vga_addr;

    memory u2_mem (
        .clock(~clock_25mhz),
        .data(pixel_data_u1),
        .address(frame_ready ? vga_addr : write_addr),
        .wren(~frame_ready), // enquanto não estiver pronto, escreve
        .q(pixel_data_u2)
    );

    localparam TOTAL_PIXELS = 320*240;

    always @(posedge clock_25mhz or posedge reset) begin
        if (reset) begin
            write_addr  <= 0;
            frame_ready <= 0;
        end else if (!frame_ready) begin
            write_addr <= write_addr + 1;
            if (write_addr == TOTAL_PIXELS-1)
                frame_ready <= 1;
        end
    end

    // ==== Controlador VGA ====
    vga_module u_vga (
        .clock(~clock_25mhz),
        .color_in(pixel_data_u2),
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

    assign vga_addr = next_y * 320 + next_x;

endmodule
