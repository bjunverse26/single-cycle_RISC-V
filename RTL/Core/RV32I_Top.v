module RV32I_Top(
    input clk,
    input reset_btn,
    output dummy_out
);

wire reset_n;

wire [31:0] instr;
wire [31:0] read_data;
wire [31:0] instr_addr;
wire        data_mem_write;
wire        data_mem_read;
wire [31:0] data_mem_addr;
wire [1:0]  store_type;
wire [2:0]  load_type;
wire [31:0] write_data;

assign reset_n = ~reset_btn;

reg [31:0] sink;
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) sink <= 32'd0;
    else sink <= sink ^ instr ^ instr_addr ^ read_data ^ data_mem_addr ^ write_data
                 ^ {30'd0, data_mem_write, data_mem_read};
end

assign dummy_out = sink[0];

(* DONT_TOUCH = "TRUE" *) RV32I_Core u_core (
    .clk(clk),
    .reset_n(reset_n),
    .instr(instr),
    .read_data(read_data),
    .instr_addr(instr_addr),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .data_mem_addr(data_mem_addr),
    .store_type(store_type),
    .load_type(load_type),
    .write_data(write_data)
);

(* DONT_TOUCH = "TRUE" *) Instruction_Memory #(
    .MEM_INIT_FILE("program.mem")
) u_imem (
    .instr_addr(instr_addr),
    .instr(instr)
);

(* DONT_TOUCH = "TRUE" *) Data_Memory u_dmem (
    .clk(clk),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .data_mem_addr(data_mem_addr),
    .store_type(store_type),
    .load_type(load_type),
    .write_data(write_data),
    .read_data(read_data)
);

endmodule