module meta_3(
    input  wire       clock,      
    input  wire       reset,
    input  wire [2:0] chaves, 
	 input  wire        botao_aplicar,    
 
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



// uco
wire [18:0] addr_from_vga_calc;
    wire [16:0] src_addr_from_cpu;
    wire [18:0] dest_addr_from_cpu;
    wire [7:0]  data_from_cpu;
    wire        wren_from_cpu;



// memoria
wire [16:0] address_ori;
wire [16:0] address_fal;

    wire [18:0] dest_mem_addr;
    wire [7:0]  src_mem_data_out;
    wire [7:0]  dest_mem_data_in;
    wire        dest_mem_wren;

wire [7:0]  data_o;

//cpu
wire        cpu_start;
wire        cpu_done;

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







// ==== Memória de original ROM 320x240
    original a_mem (
        .clock(clock_25mhz),
        .address(address_ori),
        .q(data_o)
    );



	 
	 
	 
cpuu2 cpu_2(
.start(cpu_start), //Entrada
.clk(clock_25mhz),

.done(cpu_done),//Ta pronto

.src_mem_addr(src_addr_from_cpu), //Endereço mem ori na uc
.src_mem_data_in(data_o), //dado do endereço

.dest_mem_addr(dest_addr_from_cpu),
.dest_mem_data_out(data_from_cpu), //Dado do end uc

.dest_mem_wr_en(wren_from_cpu), //escrita
);
	 
	 
	 
	 // ==== Memória de falsa ====
memory2 f_mem (
        .clock(clock_25mhz),
        .data(dest_mem_data_in),
        .address(address_fal),
        .wren(dest_mem_wren),
        .q(pixel_data)
    );



uc u_uc (
        .clk(clock_25mhz),
        .reset(reset),
        .chaves(chaves),
        .botao_aplicar(~botao_aplicar),
 
        .addr_from_vga_calc(addr_from_vga_calc),
 
		  .cpu_start(cpu_start), //Cpu
        .cpu_done(cpu_done),
	     .sistema_ocupado(sistema_ocupado),
 
        .src_addr_from_cpu(src_addr_from_cpu),
        .dest_addr_from_cpu(dest_addr_from_cpu),
        .data_from_cpu(data_from_cpu),
        .wren_from_cpu(wren_from_cpu),
 
        .src_mem_addr(address_ori),
        .dest_mem_addr(address_fal), //Addr da mem de exibição
        .dest_mem_data(dest_mem_data_in), //Dado escrita
        .dest_mem_wren(dest_mem_wren)     //Habilita escrita
    );


endmodule