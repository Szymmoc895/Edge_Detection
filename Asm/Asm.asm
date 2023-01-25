.data
data QWORD ?
result QWORD ?
.const
mask_G1 DD -1, 0, 1, -2, 2, -1, 0, 1
mask_G2 DD -2, -1, 0, -1, 1, 0, 1, 2
mask_G3 DD 1, 2, 1, 0, 0, -1, -2, -1
mask_G4 DD 0, 1, 2, -1, 1, -2, -1, 0

jeden real4 1.0
koniecWys real4 834.0

.code
fnSobelFilter proc  

; zapisywanie adres闚 rejestr闚 RBP,RBX, RDI,RSP, w celu zachowania sp鎩noi pami璚i po wykonaniu procedury
push RSP 
push RBP 
push RBX
push RDI

;pobranie i zaiasnie argument闚
;mov R11, qword ptr [RSP + 40]	;sci鉚niecie ze stosu i zachowanie d逝goi wiersza
mov qword ptr[data], RCX		;zachowanie adresu tablicy z danymi wejiowymi w pami璚i
mov qword ptr[result], RDX		;zachowanie adresu tablicy z danymi wyjiowymi w pami璚i

;ustawienie iteratora p皻li pikseli
mov R10, 1

CVTSS2SI r11, xmm0 ;kopiowanie flota z xmm0 do r11 jako int
;mov rsi, rcx	;tablica wejsciowa do rsi
;mov rdi, rdx	;tablica out do rdi

;mov rbx, qword ptr[rsp + 8h] ;do R11 row_size
;mov r11, rbx

;p皻la iteruj鉍a po wierszach


;movd jeden, xmm10
;movd koniecWys,  xmm11

mov rbx, 1
movd xmm0, rbx

mov rbx, 834
movd xmm1, rbx

xor rbx, rbx

height_loop:
comiss xmm10, xmm11
ja koniec 


loop_row:

	;oblicznie adresu w danych wejiowych
	mov RAX, R11				;pobranie d逝goi wiersza
	mul R8						;wymno瞠nie przez iterator wierasza - wyznaczenia indeksu piksela
	add RAX, qword ptr[data]	;wyznaczenie adresu w tablicy danych wejiowych
	mov RBX, RAX				;zapisanie aktualnego adresu w RBX

	;p皻la iteruj鉍a po pikselach w wierszu
	loop_pixel:		
		inc RBX						;inkrementacja adresu przetwarzanego piksela
		
		;ζdowanie pikseli s零iaduj鉍ych z obecnie przetwarzanym
		mov r12, RBX				;przes豉nie dresu przetwarzanego piksela do r12
		sub r12, R11				;odj璚ie d逝goi wiersza
		dec r12						;dekrementacja adresu piksela

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		;poni窺za cz�� kodu ma na celu dwie rzeczy - konwersj� z 8-bitowego na 32-bitowe
		;s這wo oraz za豉dowanie dw鏂h pikseli jednoczeie na stos

		mov CL, byte ptr[r12]		;pobranie wartoi piksela [0, 0] do CL						
		inc r12						;inkrementacja adresu piksela
		mov AL, byte ptr[r12]		;pobranie wartoi piksela [0, 1] do AL
		rol RCX, 32					;przesuniecie wartoi piksela [0, 0] do g鏎nej cz瘰cie rejestru RCX - przesuni璚ie w lewo o 32
		add RAX, RCX				;dodanie obu rejestr闚 - g鏎na cz�� RAX - piksel [0, 0], EAX - [0, 1]		
		push RAX					;wys豉nie na stos
		
		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc r12						;inkrementacja adresu piksela
		mov CL, byte ptr[r12]		;pobranie wartoi piksela [0, 2] do CL

		sub r12, 2					;zmiana adresu do odczytu dancyh wejiowych
		add r12, R11				;jeden wiersz dalej, dwa piksele wczeiej

		mov AL, byte ptr[r12]		;pobranie wartoi piksela [1, 0] do AL
		rol RCX, 32					;przesuniecie wartoi piksela [0, 2] do g鏎nej cz瘰cie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr闚 - g鏎na cz�� RAX - piksel [0, 2], EAX - [1, 0]
		push RAX					;wys豉nie na stos

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		add r12, 2					;dwukrotna inkrementacja adresu piksela - piksel [1, 1] jest pomijany, poniewa� zawsze jest mno穎ny przez 0
		mov CL, byte ptr[r12]		;pobranie wartoi piksela [1, 2] do CL
		sub r12, 2					;zmiana adresu do odczytu dancyh wejiowych
		add r12, R11				;jeden wiersz dalej, dwa piksele wczeiej

		mov AL, byte ptr[r12]		;pobranie wartoi piksela [2, 0] do AL
		rol RCX, 32					;przesuniecie wartoi piksela [1, 2] do g鏎nej cz瘰cie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr闚 - g鏎na cz�� RAX - piksel [1, 2], EAX - [2, 0]
		push RAX								

		xor RAX, RAX				;zerowanie RAX
		xor RCX, RCX				;zerowanie RCX

		inc r12						;inkrementacja adresu piksela
		mov CL, byte ptr[r12]		;pobranie wartoi piksela [2, 1] do CL
		inc r12						;inkrementacja adresu piksela
		mov AL, byte ptr[r12]		;pobranie wartoi piksela [2, 2] do AL
		rol RCX, 32					;przesuniecie wartoi piksela [2, 1] do g鏎nej cz瘰cie rejestru RCX
		add RAX, RCX				;dodanie obu rejestr闚 - g鏎na cz�� RAX - piksel [2, 1], EAX - [2, 2]
		push RAX					;wys豉nie na stos

		;豉dowanie danych masek do rejestr闚 XMM

		movups XMM0, xmmword ptr[mask_G1]		;pobranie dolnej po這wy sta造ch odpowiadaj鉍ym masce G1 do rejestru XMM0 - 4 razy s這wo 32 bitowa liczba sta這przecinkowa
		movups XMM1, xmmword ptr[mask_G1 + 16]	;pobranie g鏎nej po這wy sta造ch odpowiadaj鉍ym masce G1 do rejestru XMM1
		movups XMM2, xmmword ptr[mask_G2]		;pobranie dolnej po這wy sta造ch odpowiadaj鉍ym masce G2 do rejestru XMM2
		movups XMM3, xmmword ptr[mask_G2 + 16]	;pobranie g鏎nej po這wy sta造ch odpowiadaj鉍ym masce G2 do rejestru XMM3
		movups XMM4, xmmword ptr[mask_G3]		;pobranie dolnej po這wy sta造ch odpowiadaj鉍ym masce G3 do rejestru XMM4
		movups XMM5, xmmword ptr[mask_G3 + 16]	;pobranie g鏎nej po這wy sta造ch odpowiadaj鉍ym masce G3 do rejestru XMM5
		movups XMM6, xmmword ptr[mask_G4]		;pobranie dolnej po這wy sta造ch odpowiadaj鉍ym masce G4 do rejestru XMM6
		movups XMM7, xmmword ptr[mask_G4 + 16]	;pobranie g鏎nej po這wy sta造ch odpowiadaj鉍ym masce G4 do rejestru XMM7
		
		;sciaganie ze stosu wartoi pikseli do rejestr闚 XMM - maski odpowiednio dostosowane do kolejki LIFO!

		movups XMM9, xmmword ptr[RSP]		;sci鉚ni璚ie ze stosu dolnej po這wy wartoi pikseli do rejestru XMM9
		add RSP, 16							;korekta wska積ika stosu - 16 bajt闚 sci鉚niete ze stosu
		movups XMM8, xmmword ptr[RSP]		;sci鉚ni璚ie ze stosu dolnej po這wy wartoi pikseli do rejestru XMM9
		add RSP, 16							;korekta wska積ika stosu - 16 bajt闚 sci鉚niete ze stosu

		;wektorowe mno瞠nie masek i wartoi pikseli przy uzyciu rozkaz闚 z roszerzenia SSE 4.1

		PMULLD XMM0, XMM8		;dolna po這wa maski G1 razy dolna po這wa pikseli
		PMULLD XMM1, XMM9		;g鏎a po這wa maski G1 razy g鏎a po這wa pikseli
		PMULLD XMM2, XMM8		;dolna po這wa maski G2 razy dolna po這wa pikseli
		PMULLD XMM3, XMM9		;g鏎a po這wa maski G2 razy g鏎a po這wa pikseli
		PMULLD XMM4, XMM8		;dolna po這wa maski G3 razy dolna po這wa pikseli
		PMULLD XMM5, XMM9		;g鏎a po這wa maski G3 razy g鏎a po這wa pikseli
		PMULLD XMM6, XMM8		;dolna po這wa maski G4 razy dolna po這wa pikseli
		PMULLD XMM7, XMM9		;g鏎a po這wa maski G4 razy g鏎a po這wa pikseli


		xor RCX, RCX			;zerowanie rejestru RCX - tutaj przechowywana bedzie suma kwadrat闚

		;wys豉nie na stos wynik闚 mno瞠nia maski G1

		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM0		;wys豉nie na stos dolnej po這wy wyniku
		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM1		;wys豉nie na stos g鏎nej po這wy wyniku

		;sumowanie kolejnych wynik闚 mno瞠nia z mask� G1

		xor EAX, EAX						;zerowanie rejestru EAX
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 2. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 3. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 4. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 5. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 6. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 7. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 			
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 8. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 					

		mul RAX								;kwadrat sumy wynik闚 - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys豉nie na stos wynik闚 mno瞠nia maski G2

		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM2		;wys豉nie na stos dolnej po這wy wyniku
		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM3		;wys豉nie na stos g鏎nej po這wy wyniku

		;sumowanie kolejnych wynik闚 mno瞠nia z mask� G2

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 2. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 3. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 4. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 5. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 6. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 7. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 8. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 

		mul RAX								;kwadrat sumy wynik闚 - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys豉nie na stos wynik闚 mno瞠nia maski G3

		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM4		;wys豉nie na stos dolnej po這wy wyniku
		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM5		;wys豉nie na stos g鏎nej po這wy wyniku

		;sumowanie kolejnych wynik闚 mno瞠nia z mask� G3

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 2. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 3. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 4. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 5. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 6. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 7. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 8. wyniku mno瞠nia i dodanie go do EAX
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 

		mul RAX								;kwadrat sumy wynik闚 - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		;wys豉nie na stos wynik闚 mno瞠nia maski G4

		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM6		;wys豉nie na stos dolnej po這wy wyniku
		sub RSP, 16							;korekta wskaika stosu - 16 bajt闚 wys豉ne na stos
		movups  xmmword ptr[RSP], XMM7		;wys豉nie na stos g鏎nej po這wy wyniku

		;sumowanie kolejnych wynik闚 mno瞠nia z mask� G4

		xor EAX, EAX						;zerowanie rejestru EAX	
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 
		add EAX, dword ptr[RSP]				;sci鉚niecie ze stosu 1. wyniku mno瞠nia i dodanie go do EAX	
		add RSP, 4							;korekta wska積ika stosu - 4 bajty sci鉚niete ze stosu 

		mul RAX								;kwadrat sumy wynik闚 - RAX razy RAX
		add RCX, RAX						;dodanie wyniku do RCX

		push RCX							;wys豉nie wyniku na stos

		;obliczanie pierwiastka sumy kwadrat闚 wynik闚 mno瞠nia przez maski

		xor RAX, RAX					;zerowanie rejestru RAX
		;movsd XMM4, qword ptr[RSP]		;sci鉚ni璚ie ze stosu wyniku do rejestru XMM4

		CVTSI2SS xmm4, qword ptr[RSP]		

		add RSP, 8						;korekta stosu - 8 bajt闚 sci鉚ni皻ych ze stosu
		
		;VCVTQQ2PD XMM4, XMM4			;konwersja liczb sta這przecinkowych na zmiennoprzecinkowe (rozkaz AVX512)
		sqrtsd XMM4, XMM4				;obliczenie pierwiastka kwadratowego
		CVTTSS2SI  RCX, XMM4			;zamiana wyniku na liczb� zmiennoprzecinkow� i wys豉nie do RCX

		cmp RCX, 255					;oor闚nanie z 255 w celu dokonania ewentualnej korekty
		jg correction_too_high			;jei wi瘯sze - korekta
		cmp RCX, 0						;por闚nanie z 0 w celu dokonania ewentualnej korekty
		jl correction_too_low			;jei mniejsze - korekta
		jmp save						;jei w zakresie skok do zapisu

		;korekta w razie przepe軟ienia
		correction_too_high:			
		MOV RCX, 255					;korekta wyniku na warto 255
		jmp save						;skok do zapisu
		;korekrta w razie niedope軟ienia
		correction_too_low:				;korekta wyniku na warto 0
		MOV RCX, 0

		;zapisanie wyniku

		save:
		;obliczenie adresu zapisu
		mov RAX, R8			;przes豉nie do RAX indeksu wiersza
		mul R11				;przemno瞠nie indeksu wiersza przez d逝go wiersza
		add RAX, R10		;dodanie indeksu piksela
		mov r13, 3			;za豉dowanie 3 do r13
		mul r13				;przemno瞠nie indeksu w tablicy wejiowej razy 3 w celu otrzymania indeksu w tablicy wyiowej (pikselowi w tablicy wejiowej odpowiadaj� trzy bajty w tablicy wyjiowej-  po jednym na ka盥y kana�)
		
		add RAX, qword ptr [result] ;dodanie adresu pocz靖ku talicy wynikowej

		mov byte ptr[RAX], CL		;przes豉nie wyniku (kana� B)
		mov byte ptr[RAX + 1], CL	;przes豉nie wyniku (kana� G)
		mov byte ptr[RAX + 2], CL	;przes豉nie wyniku (kana� R)
		mov byte ptr[RAX + 3], CL	;przes豉nie wyniku (kana� A)


		inc R10						;inkrementacja iteratora p皻li pikseli w wierszu

		cmp R10, R11				;warunek konca p皻li pikseli w wierszu
		je loop_pixel_end			;je瞠li r闚ne skok do instrukcji ko鎍a p皻li
		jmp loop_pixel				;skok do pocz靖ku p皻li
		loop_pixel_end:				;koniec wykonywania p皻li
			mov R10, 1				;ustawienie iteratora p皻li pikseli w wierszu na 1
	inc R8					;inkrementacja iteratora wierszy
	cmp R8, R9				;warunek konca p皻li wierszy
	je loop_end				;je瞠li r闚ne skok do instrukcji ko鎍a p皻li
	jmp loop_row			;skok do pocz靖ku p皻li
	loop_end:
		addss xmm10, jeden
		jmp height_loop

	;koniec p皻li po wierszach - zako鎍zenie procedury

	koniec:
		pop RDI			;przywr鏂enie ze stosu wartoi rejestru RDI
		pop RBX			;przywr鏂enie ze stosu wartoi rejestru RBX
		pop RBP			;przywr鏂enie ze stosu wartoi rejestru RBP
		pop RSP			;przywr鏂enie ze stosu wartoi rejestru RSP
		
		;mov rax, rdi

		ret				;powr鏒 z procedury
fnSobelFilter endp	
end