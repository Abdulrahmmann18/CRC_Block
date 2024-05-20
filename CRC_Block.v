module CRC_Block #(parameter SEED = 8'hD8)
(
	input wire DATA,
	input wire ACTIVE,
	input wire CLK,
	input wire RST,
	output reg CRC,
	output reg Valid
);

	reg [7:0] LFSR;
	reg [3:0] shifting_out_counter;
	reg [3:0] Data_in_counter;
	wire feedback;
	assign feedback = LFSR[0] ^ DATA ;

	always @(posedge CLK or negedge RST) begin
		if (~RST) begin
			// reset
			LFSR <= SEED;
			shifting_out_counter <= 4'd0;
			Data_in_counter <= 4'd0;
			Valid <= 1'b0;
			CRC <= 1'b0;
		end
		else if (ACTIVE) begin
			// shifting and xor operation
			Data_in_counter <= Data_in_counter + 1;
			LFSR[7] <= feedback;
			LFSR[6] <= LFSR[7] ^ feedback;
			LFSR[5] <= LFSR[6];
			LFSR[4] <= LFSR[5];
			LFSR[3] <= LFSR[4];
			LFSR[2] <= LFSR[3] ^ feedback;
			LFSR[1] <= LFSR[2];
			LFSR[0] <= LFSR[1]; 
		end
		else if ((shifting_out_counter != 4'd8) && (Data_in_counter == 4'd8)) begin
			// shifting LFSR into CRC output for 8 clock cycles
			shifting_out_counter <= shifting_out_counter + 1;
			Valid <= 1'b1;
			LFSR <= {1'b0, LFSR[7:1]};
			CRC <= LFSR[0];
		end
	end
endmodule
