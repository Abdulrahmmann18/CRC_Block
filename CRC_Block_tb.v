module CRC_Block_tb();

	// parameters
	parameter TEST_CASES = 10;
	parameter CLK_PERIOD = 100;

	// signal declaration
	reg DATA_tb;
	reg ACTIVE_tb;
	reg CLK_tb;
	reg RST_tb;
	wire CRC_tb;
	wire Valid_tb;

	// clock generation block
	initial begin
		CLK_tb = 0;
		forever 
			#(CLK_PERIOD/2) CLK_tb = ~CLK_tb;
	end

	// DUT Instantiation
	CRC_Block DUT
	(
		.DATA(DATA_tb),
		.ACTIVE(ACTIVE_tb),
		.CLK(CLK_tb),
		.RST(RST_tb),
		.CRC(CRC_tb),
		.Valid(Valid_tb)
	);


	reg [7:0] DATA_REG [TEST_CASES-1:0];
	reg [7:0] EXP_OUT [TEST_CASES-1:0];

	integer i, n, m;
	// initial block
	
	reg [7:0] CRC_REG_out;
	initial begin
		
		// Read Input Files
		$readmemh("DATA_h.txt", DATA_REG);
		$readmemh("Expec_Out_h.txt", EXP_OUT);
		
		// initialize
		initialize();

		// rst
		RST_TASK();
		
		// shifting data in then check output
		for (n=0; n<TEST_CASES; n=n+1) begin
			Transmit_DATA_IN(DATA_REG[n]);
			SHIFT_CRC_OUT(CRC_REG_out);
			check_output(EXP_OUT[n], CRC_REG_out);
			RST_TASK();
		end
		$stop;
	end
	
	

	/* *************************************************************************** */
	// tasks 
	// RST Task
	
	
	task RST_TASK;
		begin
			RST_tb = 0;
			#(2*CLK_PERIOD)
			RST_tb = 1; 
		end
	endtask

	// Initialize
	task initialize;
		begin
			DATA_tb = 1'b0;
			ACTIVE_tb = 1'b0;
		end	
	endtask

	// shifting and xoring operation
	task Transmit_DATA_IN;
		input [7:0] DATA_BYTE;
		begin
			ACTIVE_tb = 1'b1;
			for (i=0; i<8; i=i+1) begin
				@(negedge CLK_tb)
				DATA_tb = DATA_BYTE[i];
			end
			@(negedge CLK_tb)
			ACTIVE_tb = 1'b0;
		end	
	endtask

	// shifting LSFR OUT 
	task SHIFT_CRC_OUT;
		output [7:0] CRC_REG;
		begin
			@(posedge Valid_tb)
			for (m=0; m<8; m=m+1) begin
				@(negedge CLK_tb)
				CRC_REG[m] = CRC_tb;								
			end
		end
	endtask

	// check output

	task check_output;
		input [7:0] exp_output;
		input [7:0] CRC_OUT;
		
		begin
			if (CRC_OUT == exp_output) begin
				$display("test case is passed");
			end
			else begin
				$display("test case is failled");
			end
		end
	endtask
	/* *************************************************************************** */
	

endmodule