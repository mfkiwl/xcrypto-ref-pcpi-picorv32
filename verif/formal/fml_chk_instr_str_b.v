//
// SCARV Project
// 
// University of Bristol
// 
// RISC-V Cryptographic Instruction Set Extension
// 
// Reference Implementation
// 
// 

`include "fml_common.vh"

`VTX_CHECKER_MODULE_BEGIN(instr_str_b)

wire [31:0] sb_addr = `RS1 + `RS2;

wire [ 1:0] src_byte = dec_arg_b0;

// Select which data from the CPR we should be writing to memory.
wire [ 7:0] sb_wdata = 
    {src_byte} == 2'b00 ? `CRD[ 7: 0] :
    {src_byte} == 2'b01 ? `CRD[15: 8] :
    {src_byte} == 2'b10 ? `CRD[23:16] :
    {src_byte} == 2'b11 ? `CRD[31:24] :
                          0           ;

//
// str_b
//
`VTX_CHECK_INSTR_BEGIN(str_b) 

    // Make sure it never gives the wrong error code.
    `VTX_ASSERT(vtx_instr_result != SCARV_COP_INSN_LD_ERR);
    `VTX_ASSERT(vtx_instr_result != SCARV_COP_INSN_BAD_LAD);
    `VTX_ASSERT(vtx_instr_result != SCARV_COP_INSN_BAD_SAD);

    if(vtx_instr_result == SCARV_COP_INSN_SUCCESS) begin
    
        // If the instruction succeeds, check it wrote the right data

        `VTX_ASSERT(vtx_mem_cen_0  == 1'b1);
        `VTX_ASSERT(vtx_mem_wen_0  == 1'b1);
        `VTX_ASSERT(vtx_mem_addr_0 == {sb_addr[31:2],2'b00});

        if(sb_addr[1:0] == 2'b00) begin
            `VTX_ASSERT(vtx_mem_wdata_0[ 7: 0] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0001);
        end else if(sb_addr[1:0] == 2'b01) begin
            `VTX_ASSERT(vtx_mem_wdata_0[15: 8] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0010);
        end else if(sb_addr[1:0] == 2'b10) begin
            `VTX_ASSERT(vtx_mem_wdata_0[23:16] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0100);
        end else if(sb_addr[1:0] == 2'b11) begin
            `VTX_ASSERT(vtx_mem_wdata_0[31:24] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b1000);
        end

    end else if(vtx_instr_result == SCARV_COP_INSN_ST_ERR) begin
        
        // Transaction should have started correctly.
        `VTX_ASSERT(vtx_mem_cen_0  == 1'b1);
        `VTX_ASSERT(vtx_mem_wen_0  == 1'b1);
        `VTX_ASSERT(vtx_mem_addr_0 == {sb_addr[31:2],2'b00});

        if(sb_addr[1:0] == 2'b00) begin
            `VTX_ASSERT(vtx_mem_wdata_0[ 7: 0] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0001);
        end else if(sb_addr[1:0] == 2'b01) begin
            `VTX_ASSERT(vtx_mem_wdata_0[15: 8] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0010);
        end else if(sb_addr[1:0] == 2'b10) begin
            `VTX_ASSERT(vtx_mem_wdata_0[23:16] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b0100);
        end else if(sb_addr[1:0] == 2'b11) begin
            `VTX_ASSERT(vtx_mem_wdata_0[31:24] == sb_wdata);
            `VTX_ASSERT(vtx_mem_ben_0          == 4'b1000);
        end

    end

    // Never causes writeback to GPRS
    `VTX_ASSERT_WEN_IS_CLEAR

`VTX_CHECK_INSTR_END(str_b)

`VTX_CHECKER_MODULE_END
