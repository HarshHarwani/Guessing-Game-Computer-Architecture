`timescale 1ns / 1ps
module project2(clock, switches, buttons, leds, cathods, anodes);
	
	input  clock;
	input [7:0] switches;
	input [3:0] buttons;

	output reg [7:0] leds = 8'b00000000;
	output reg [7:0] cathods;
	output reg [3:0] anodes;

	// Variables to Maintain the clock count
	integer count = 0;
	integer myCount = 0;
	
	// Player 1 => 0
	// Player 2 => 1
	integer player = 1'b0;
	
	//default message has to be shown to the players
	integer initialMessage = 1'b1;
	
	// temp variabled for cathodes
	integer b3 = 8'b11111111;
	integer b2 = 8'b11111111;
	integer b1 = 8'b11111111;
	integer b0 = 8'b11111111;
	
	//number entered by player-1
	integer secretValue0 = 0;
	integer secretValue1 = 0;
	integer secretValue2 = 0;
	integer secretValue3 = 0;
	
	//guesses entered by player-2
	integer guessValue0 = 0;
	integer guessValue1 = 0;
	integer guessValue2 = 0;
	integer guessValue3 = 0;
	
	reg slow_clock; 
	
	//variable to validate the guess , it decides whether it is equal low or high
	integer validating = 0;
	
	//various flag variables
	integer flag = 0;
	integer playerflag=0;
	integer guesses = 0;
	integer flag_guesses = 1'b1;
	
	
	//creating slow clock and blinking led's in case of win.
	always @(posedge clock)
	begin
		create_slow_clock(clock, slow_clock); 
		leds=switches;
		if(validating == 1)
			begin
				// Winning Code - Led Blink
				if(myCount < 2500000)
				begin
					leds = 8'b11111111;
				end
				else if(myCount < 5000000)
				begin
					leds = 8'b00000000;
				end
				else
				begin
					myCount = 0;
				end
				myCount = myCount + 1;
				end
	end
	always @(posedge slow_clock)
	begin
		if(validating != 0)
		begin
			flag = 1;
		end
		else
		begin
			flag = 0;
		end
		
		//increasing the guess when comparision is made
		if(switches[4] == 1)
				begin
					if(flag_guesses == switches[4])
					begin
						guesses = guesses + switches[4];
						flag_guesses = 1'b0;
					end
				end
			
		if(flag == 1)
		begin
			//win case
			if(validating == 1)
			begin
				// display num of guesses
				b3 = 8'b11111111;
				b2 = 8'b11111111;
				b1 = 8'b11111111;
				
				// ASSUMPTION: There are no more than 15 guesses
				case(guesses)
				0: b0 = 8'b 11000000; 
				1: b0 = 8'b 11111001;
				2: b0 = 8'b 10100100;
				3: b0 = 8'b 10110000;
				4: b0 = 8'b 10011001;
				5: b0 = 8'b 10010010;
				6: b0 = 8'b 10000010;
				7: b0 = 8'b 11111000;
				8: b0 = 8'b 10000000;
				9: b0 = 8'b 10010000;
				10: b0 = 8'b 10001000;
				11: b0 = 8'b 10000011;
				12: b0 = 8'b 11000110;
				13: b0 = 8'b 10100001;
				14: b0 = 8'b 10000110;
				15: b0 = 8'b 10001110;
				default: b0 = 8'b 11111111;
				endcase
			end
			else if(validating == 2)
			begin
				// Low case
				//"2LO"
				b3 = 8'b11111111;
				b2 = 8'b10100100;
				b1 = 8'b11000111;
				b0 = 8'b11000000;
			end
			else
			begin
				// High case
				//" 2HI"
				b3 = 8'b11111111;
				b2 = 8'b10100100;
				b1 = 8'b10001001;
				b0 = 8'b11001111;
			end
			if(switches[4] == 0 && switches[5] == 1 && validating != 1)
			begin
				//to give player 2 another chance.
				initialMessage = 0;
				validating = 0;
				flag_guesses = 1'b1;
			end
		end
		else
		begin
			if(switches[4] == 1 && player == 1)
			begin
				//guesses the correct value
				if(guessValue0 == secretValue0 && guessValue1 == secretValue1 &&
					guessValue2 == secretValue2 && guessValue3 == secretValue3)
				begin
					validating = 1;
				end
				else if((secretValue3 > guessValue3) ||
						 (secretValue3 == guessValue3 && 
						  secretValue2 > guessValue2) ||
						 (secretValue3 == guessValue3 &&
						  secretValue2 == guessValue2 &&
						  secretValue1 > guessValue1) ||
						 (secretValue3 == guessValue3 &&
						  secretValue2 == guessValue2 &&
						  secretValue1 == guessValue1 &&
						  secretValue0 > guessValue0)
						 )
				begin
					// Low Guess
					validating = 2;
				end
				else
				begin
					// High Guess
					validating = 3;
				end
			end
			
			//condition where the value gets latched.
			if(switches[5] != player)
			begin
				secretValue0 = guessValue0;
				secretValue1 = guessValue1;
				secretValue2 = guessValue2;
				secretValue3 = guessValue3;
				
				guessValue0 = 0;
				guessValue1 = 0;
				guessValue2 = 0;
				guessValue3 = 0;
				
				initialMessage = 1;
			end
			
			// to show PL-1 and Pl-2 based on which player is selected.
			if(initialMessage == 1)
			begin
				b3 = 8'b10001100;
				b2 = 8'b11000111;
				b1 = 8'b11111111;
				
				if(switches[5] == 1'b0)
				begin
					// If switch 5 is in low position
					// Set to player 1
					player = 0;
					b0 = 8'b11111001;
					playerflag=1;
				end
				else
				begin
					// Else set player 2
					player = 1;
					b0 = 8'b10100100;
					playerflag=1;
				end
			end
			if(switches[3:0] != 0 || playerflag==0)
			begin
				// When first time we make the changes to the sliders
				if(initialMessage == 1)
				begin

					initialMessage = 0;
					playerflag=0;
					
					b0 = 8'b11000000;
					b1 = 8'b11000000;
					b2 = 8'b11000000;
					b3 = 8'b11000000;
				end
				else
				begin
			case (buttons)
			 4'b1000: // Button 3 pressed
			 begin
				case(switches)
				6'b000000: guessValue3=4'b0000; 
				6'b000001: guessValue3=4'b0001; 
				6'b000010: guessValue3=4'b0010; 
				6'b000011: guessValue3=4'b0011; 
				6'b000100: guessValue3=4'b0100; 
				6'b000101: guessValue3=4'b0101; 
				6'b000110: guessValue3=4'b0110; 
				6'b000111: guessValue3=4'b0111; 
				6'b001000: guessValue3=4'b1000; 
				6'b001001: guessValue3=4'b1001; 
				6'b001010: guessValue3=4'b1010; 
				6'b001011: guessValue3=4'b1011; 
				6'b001100: guessValue3=4'b1100; 
				6'b001101: guessValue3=4'b1101; 
				6'b001110: guessValue3=4'b1110; 
				6'b001111: guessValue3=4'b1111;
				6'b100000: guessValue3=4'b0000; 
				6'b100001: guessValue3=4'b0001; 
				6'b100010: guessValue3=4'b0010; 
				6'b100011: guessValue3=4'b0011; 
				6'b100100: guessValue3=4'b0100; 
				6'b100101: guessValue3=4'b0101; 
				6'b100110: guessValue3=4'b0110; 
				6'b100111: guessValue3=4'b0111; 
				6'b101000: guessValue3=4'b1000; 
				6'b101001: guessValue3=4'b1001; 
				6'b101010: guessValue3=4'b1010; 
				6'b101011: guessValue3=4'b1011; 
				6'b101100: guessValue3=4'b1100; 
				6'b101101: guessValue3=4'b1101; 
				6'b101110: guessValue3=4'b1110; 
				6'b101111: guessValue3=4'b1111;
				endcase
			 end // Button 2 pressed
			 4'b0100: begin 
			 	case(switches)
				6'b000000: guessValue2=4'b0000; 
				6'b000001: guessValue2=4'b0001; 
				6'b000010: guessValue2=4'b0010; 
				6'b000011: guessValue2=4'b0011; 
				6'b000100: guessValue2=4'b0100; 
				6'b000101: guessValue2=4'b0101; 
				6'b000110: guessValue2=4'b0110; 
				6'b000111: guessValue2=4'b0111; 
				6'b001000: guessValue2=4'b1000; 
				6'b001001: guessValue2=4'b1001; 
				6'b001010: guessValue2=4'b1010; 
				6'b001011: guessValue2=4'b1011; 
				6'b001100: guessValue2=4'b1100; 
				6'b001101: guessValue2=4'b1101; 
				6'b001110: guessValue2=4'b1110; 
				6'b001111: guessValue2=4'b1111;
				6'b100000: guessValue2=4'b0000; 
				6'b100001: guessValue2=4'b0001; 
				6'b100010: guessValue2=4'b0010; 
				6'b100011: guessValue2=4'b0011; 
				6'b100100: guessValue2=4'b0100; 
				6'b100101: guessValue2=4'b0101; 
				6'b100110: guessValue2=4'b0110; 
				6'b100111: guessValue2=4'b0111; 
				6'b101000: guessValue2=4'b1000; 
				6'b101001: guessValue2=4'b1001; 
				6'b101010: guessValue2=4'b1010; 
				6'b101011: guessValue2=4'b1011; 
				6'b101100: guessValue2=4'b1100; 
				6'b101101: guessValue2=4'b1101; 
				6'b101110: guessValue2=4'b1110; 
				6'b101111: guessValue2=4'b1111;
				endcase
			 
			 end // Button 1 pressed
			 4'b0010: begin
			 case(switches)
				6'b000000: guessValue1=4'b0000; 
				6'b000001: guessValue1=4'b0001; 
				6'b000010: guessValue1=4'b0010; 
				6'b000011: guessValue1=4'b0011; 
				6'b000100: guessValue1=4'b0100; 
				6'b000101: guessValue1=4'b0101; 
				6'b000110: guessValue1=4'b0110; 
				6'b000111: guessValue1=4'b0111; 
				6'b001000: guessValue1=4'b1000; 
				6'b001001: guessValue1=4'b1001; 
				6'b001010: guessValue1=4'b1010; 
				6'b001011: guessValue1=4'b1011; 
				6'b001100: guessValue1=4'b1100; 
				6'b001101: guessValue1=4'b1101; 
				6'b001110: guessValue1=4'b1110; 
				6'b001111: guessValue1=4'b1111;
				6'b100000: guessValue1=4'b0000; 
				6'b100001: guessValue1=4'b0001; 
				6'b100010: guessValue1=4'b0010; 
				6'b100011: guessValue1=4'b0011; 
				6'b100100: guessValue1=4'b0100; 
				6'b100101: guessValue1=4'b0101; 
				6'b100110: guessValue1=4'b0110; 
				6'b100111: guessValue1=4'b0111; 
				6'b101000: guessValue1=4'b1000; 
				6'b101001: guessValue1=4'b1001; 
				6'b101010: guessValue1=4'b1010; 
				6'b101011: guessValue1=4'b1011; 
				6'b101100: guessValue1=4'b1100; 
				6'b101101: guessValue1=4'b1101; 
				6'b101110: guessValue1=4'b1110; 
				6'b101111: guessValue1=4'b1111;
				endcase
			 
			 end // Button 0 pressed
			 4'b0001: begin 
			 case(switches)
				6'b000000: guessValue0=4'b0000; 
				6'b000001: guessValue0=4'b0001; 
				6'b000010: guessValue0=4'b0010; 
				6'b000011: guessValue0=4'b0011; 
				6'b000100: guessValue0=4'b0100; 
				6'b000101: guessValue0=4'b0101; 
				6'b000110: guessValue0=4'b0110; 
				6'b000111: guessValue0=4'b0111; 
				6'b001000: guessValue0=4'b1000; 
				6'b001001: guessValue0=4'b1001; 
				6'b001010: guessValue0=4'b1010; 
				6'b001011: guessValue0=4'b1011; 
				6'b001100: guessValue0=4'b1100; 
				6'b001101: guessValue0=4'b1101; 
				6'b001110: guessValue0=4'b1110; 
				6'b001111: guessValue0=4'b1111;
				6'b100000: guessValue0=4'b0000; 
				6'b100001: guessValue0=4'b0001; 
				6'b100010: guessValue0=4'b0010; 
				6'b100011: guessValue0=4'b0011; 
				6'b100100: guessValue0=4'b0100; 
				6'b100101: guessValue0=4'b0101; 
				6'b100110: guessValue0=4'b0110; 
				6'b100111: guessValue0=4'b0111; 
				6'b101000: guessValue0=4'b1000; 
				6'b101001: guessValue0=4'b1001; 
				6'b101010: guessValue0=4'b1010; 
				6'b101011: guessValue0=4'b1011; 
				6'b101100: guessValue0=4'b1100; 
				6'b101101: guessValue0=4'b1101; 
				6'b101110: guessValue0=4'b1110; 
				6'b101111: guessValue0=4'b1111;
				endcase
			 end  
	endcase	
					end
				case(guessValue0)
				4'b0000: b0 = 8'b11000000;
				4'b0001: b0 = 8'b11111001;
				4'b0010: b0 = 8'b10100100;
				4'b0011: b0 = 8'b10110000;
				4'b0100: b0 = 8'b10011001;
				4'b0101: b0 = 8'b10010010;
				4'b0110: b0 = 8'b10000010;
				4'b0111: b0 = 8'b11111000;
				4'b1000: b0 = 8'b10000000;
				4'b1001: b0 = 8'b10010000;
				4'b1010: b0 = 8'b10001000;
				4'b1011: b0 = 8'b10000011;
				4'b1100: b0 = 8'b11000110;
				4'b1101: b0 = 8'b10100001;
				4'b1110: b0 = 8'b10000110;
				4'b1111: b0 = 8'b10001110;
				default: b0 = 8'b11000000;
				endcase
				
				case(guessValue1)
				4'b0000: b1 = 8'b11000000;
				4'b0001: b1 = 8'b11111001;
				4'b0010: b1 = 8'b10100100;
				4'b0011: b1 = 8'b10110000;
				4'b0100: b1 = 8'b10011001;
				4'b0101: b1 = 8'b10010010;
				4'b0110: b1 = 8'b10000010;
				4'b0111: b1 = 8'b11111000;
				4'b1000: b1 = 8'b10000000;
				4'b1001: b1 = 8'b10010000;
				4'b1010: b1 = 8'b10001000;
				4'b1011: b1 = 8'b10000011;
				4'b1100: b1 = 8'b11000110;
				4'b1101: b1 = 8'b10100001;
				4'b1110: b1 = 8'b10000110;
				4'b1111: b1 = 8'b10001110;
				default: b1 = 8'b11000000;
				endcase
				
				case(guessValue2)
				4'b0000: b2 = 8'b11000000;
				4'b0001: b2 = 8'b11111001;
				4'b0010: b2 = 8'b10100100;
				4'b0011: b2 = 8'b10110000;
				4'b0100: b2 = 8'b10011001;
				4'b0101: b2 = 8'b10010010;
				4'b0110: b2 = 8'b10000010;
				4'b0111: b2 = 8'b11111000;
				4'b1000: b2 = 8'b10000000;
				4'b1001: b2 = 8'b10010000;
				4'b1010: b2 = 8'b10001000;
				4'b1011: b2 = 8'b10000011;
				4'b1100: b2 = 8'b11000110;
				4'b1101: b2 = 8'b10100001;
				4'b1110: b2 = 8'b10000110;
				4'b1111: b2 = 8'b10001110;
				default: b2 = 8'b11000000;
				endcase
				
				case(guessValue3)
				4'b0000: b3 = 8'b11000000;
				4'b0001: b3 = 8'b11111001;
				4'b0010: b3 = 8'b10100100;
				4'b0011: b3 = 8'b10110000;
				4'b0100: b3 = 8'b10011001;
				4'b0101: b3 = 8'b10010010;
				4'b0110: b3 = 8'b10000010;
				4'b0111: b3 = 8'b11111000;
				4'b1000: b3 = 8'b10000000;
				4'b1001: b3 = 8'b10010000;
				4'b1010: b3 = 8'b10001000;
				4'b1011: b3 = 8'b10000011;
				4'b1100: b3 = 8'b11000110;
				4'b1101: b3 = 8'b10100001;
				4'b1110: b3 = 8'b10000110;
				4'b1111: b3 = 8'b10001110;
				default: b3 = 8'b11000000;
				endcase
			end
		end
		case (anodes)  //strobing logic
		 4'b 1101: anodes=4'b 1110;
		 4'b 1011: anodes=4'b 1101;
		 4'b 1110: anodes=4'b 0111;
		 4'b 0111: anodes=4'b 1111;
       4'b 1111: anodes=4'b 1011; 
		 default: anodes=4'b 1111;
		 endcase
		 case (anodes) //assign value of the switch to the respective anode.
		 4'b1110: cathods=b3;
		 4'b1101: cathods=b2;
		 4'b1011: cathods=b1;
		 4'b0111: cathods=b0;
		 endcase
		 end
task create_slow_clock;
	 input clock;
	 inout slow_clock;
	 integer count;
	 begin
	 if (count > 25000)
	 begin
	 count=0;
	 slow_clock = ~slow_clock;
	 end
	 count = count+1;
	 end
 endtask 
 
endmodule

// EOF