module instruction_memory (
    input  wire [7:0] pc,        // endereço da instrução (Program Counter)
    output reg  [9:0] next_x,
    output reg  [9:0] next_y,
    output reg  [2:0] ch
);

    always @(*) begin
        case (pc)
            8'd0: begin next_x = 10'd50;  next_y = 10'd60;  ch = 3'b000; end
            8'd1: begin next_x = 10'd100; next_y = 10'd80;  ch = 3'b010; end
            8'd2: begin next_x = 10'd150; next_y = 10'd120; ch = 3'b100; end
            default: begin next_x = 10'd0; next_y = 10'd0;  ch = 3'b000; end
        endcase
    end

endmodule
