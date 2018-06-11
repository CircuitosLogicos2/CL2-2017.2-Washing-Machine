module washing_machine(
		input CLOCK_27, /*KEY, tirar o key do pin planner*/ //Clock
		output reg [3:0] LEDG, //bomba_agua = 1000, modo_agitar = 0100, modo_centrifugar = 0001, modo_girar = 0010
		input wire [1:0] SW, //controle de modos
		output [17:0] LEDR,		//led de teste
		/*output segA, segB, segC, segD, segE, segF, segG, segDP*/);  //usado para teste e visualização do contador que controla
																	  //o contador que muda de estado

	
	integer contador = 0;	//contador que gerencia os estados
	integer jaContou;	//variavel que assegura que o contador não incrementa varias vezes por conta da velocidade do clock
	reg flag = 0;		//flag para zerar o contador
	
	reg [23:0] cnt;									//cnt é um contador que funciona como prescaler
	always @(posedge CLOCK_27) cnt <= cnt+24'h1;
	wire cntovf = &cnt;

						//Dando Set no contador baseado no clock interno
	reg [3:0] UNI;		//UNI eh um contador que conta de 0 a 9
	always @(posedge CLOCK_27) begin		
		if(cntovf) UNI = (UNI==4'h9 ? 4'h0 : UNI+4'h1);	//incrementa o uni ou zera se seu valor for 9
	end													//essa variação acontece num tempo próximo de 1 segundo
	
	/*
	reg [7:0] SevenSeg;
	always @(*)	 begin
	case(UNI)
		4'h0: SevenSeg = 8'b11111100;			
		4'h1: SevenSeg = 8'b01100000;			//usado apenas para teste e não interfere em nada no funcionamento
		4'h2: SevenSeg = 8'b11011010;			//do circuito
		4'h3: SevenSeg = 8'b11110010;
		4'h4: SevenSeg = 8'b01100110;
		4'h5: SevenSeg = 8'b10110110;
		4'h6: SevenSeg = 8'b10111110;
		4'h7: SevenSeg = 8'b11100000;
		4'h8: SevenSeg = 8'b11111110;
		4'h9: SevenSeg = 8'b11110110;
		default: SevenSeg = 8'b00000000;
	endcase
	end

	assign {segA, segB, segC, segD, segE, segF, segG, segDP} = ~SevenSeg;
	*/

	reg [1:0] modo; 	//variavel que guarda o modo da maquina de lavar
	
	parameter modo_espera = 0, limpeza_padrao = 1, limpeza_rapida = 2;	 //modos
	
	always @ (posedge CLOCK_27) begin	//selecao de modo
		case (SW[1:0])
			2'b00:
			begin
				modo <= modo_espera;	//maquina em espera
			end
			2'b01: 
			begin
				modo <= limpeza_padrao;		//ciclo completo
			end
			2'b10: 
			begin
				modo <= limpeza_rapida;		//ciclo simplificado
			end
			/*2'b11:						//caso de erro
			begin
				LEDR = 18b'000000000000000001;	//sinal de erro que indica que os dois modos não podem estar ativos ao mesmo tempo
				modo <= modo_espera;
			end*/
		endcase
	end
	
	always@ (posedge CLOCK_27) begin //controle do contador que gerencia os estados
		if(UNI == 4'h0)				//zera o jaContou quando UNI chega em 0 para o contador ir para a próxima etapa
			jaContou = 0;

		if (UNI == 4'h9 && ((SW == 2'b01) || (SW == 2'b10)) && jaContou == 0) begin		//incrementa o contador
			contador = contador + 1;
			jaContou = 1;
		end

		if (SW == 2'b00)	//se os dois switchs estiverem desligados, o contador que gerencia os estados não incrementa
			contador = 0;

	end
	
	
	always @ (posedge CLOCK_27) begin 	//funcionalidade
		case (modo)
			modo_espera:
			begin
				LEDG = 4'b0000;
			end
							//contador:
			limpeza_padrao:	//espera = 0, encher = 1, agitar = 2, tempo = 3, agitar2 = 4, esvaziar = 5, centrifugar = 6, fim = 7
			begin
				//espera >> encher
				if(contador == 1) begin
					//printar ENCHER no display LCD
					LEDG = 4'b1000;
				end
				
				//enchendo >> modo agitar
				if (contador == 2) begin
					//printar AGITAR no display LCD
					LEDG = 4'b0100;	
				end

				//agitar >> tempo
				if (contador == 3) begin
					//printar DE MOLHO no display LCD
					LEDG = 4'b0010;
				end

				//tempo >> agitar2
				if (contador == 4) begin
					//printar AGITAR2 no display LCD
					LEDG = 4'b0100;
				
				end

				//agitar2 >> esvaziar
				if (contador == 5) begin
					//printar ESVAZIAR no display LCD
					LEDG = 4'b0000;
				end

				//esvaziar >> centrifugar
				if (contador == 6) begin
					//printar CENTRIFUGAR no display LCD
					LEDG = 4'b0001;
				end

				//centrifugar >> fim
				if (contador == 7) begin
					//printar FIM no display LCD
					LEDG = 4'b1111;
				end

			end
							//contador:
			limpeza_rapida:	//espera = 0, encher = 1, agitar = 2, esvaziar = 3, centrifugar = 4, fim = 5
				begin
					//espera >> encher
					if(contador == 1) begin
						//printar ENCHER no display LCD
						LEDG = 4'b1000;
					end

					//enchendo >> modo agitar
					if (contador == 2) begin
						//printar AGITAR no display LCD
						LEDG = 4'b0100;
					end

					//agitar >> esvaziar
					if (contador == 3) begin
							//printar ESVAZIAR no display LCD
							LEDG = 4'b0000;
					end
					
					//esvaziar >> centrifugar
					if (contador == 4) begin
						//printar CENTRIFUGAR no display LCD
						LEDG = 4'b0001;
					end

					//centrifugar >> fim
					if (contador == 5) begin
						//printar FIM no display LCD
						LEDG = 4'b1111;
					end

				end
		endcase
	end
endmodule 