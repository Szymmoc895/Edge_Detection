.const 
jeden real4 1.0 ;do inkrementowania wartosci w xmmach
minusJeden real4 -1.0
cztery real4 4.0
trzy real4 3.0

.data
temp qword ?

.code
fnSobelFilter proc  

mov rsi, rcx ;adres zrodlowej tablicy do rsi
mov rdi, rdx ;adres tablicy wyjsciowej (z xb i inne chuje ) do rdi

;w r8 jest xKernel
;w r9 jest yKernel

CVTSS2SI r10, xmm0		;stride do r10

shufps xmm0, xmm0, 225  ;zamiana miejscami pierwszej wartosci i drugiej w xmm0
CVTSS2SI r11, xmm0		;byteOffset do r11

movss xmm0, minusJeden	;filterY w xmm0
movss xmm1, minusJeden	;filterX w xmm0

movss xmm2, jeden		;wartosc graniczna obu petli = 1 ->filterOffset

loopY:
	comiss xmm0, xmm2   ;czy filterY = 1
	ja loopYKoniec

	movss xmm1, minusJeden ;przywracanie wartosci filterY=-1

	loopX:
		comiss xmm1, xmm2   ;czy filterX = 1
		ja loopXKoniec		;jezeli wieksze lub = to skocz

		


		;liczenie calOffset
		movss xmm3, xmm1	;filterX do xmm3
		mulss xmm3, cztery	;filterX*4	
		CVTSI2SS xmm4, r10	;konwertowanie int na float i skopiowanie stride do xmm4
		mulss xmm4, xmm0	;filterY(xmm0) * srcData.Stride
		addss xmm3, xmm4	;filterX*4 + filterY(xmm0) * srcData.Stride
		CVTSI2SS xmm5, r11	;byteOffset do r11
		addss xmm5, xmm3	;byteoffset + ....
		CVTTSS2SI rbx, xmm5 ;calcOffset(xmm5) do rbx

		mov r12, [rsi+rbx]	;pixelBuffer[calcOffset]

		;(filterY + filterOffset) *3 + filterX + filterOffset
		movss xmm6, xmm0	;filterY do XMM6
		addss xmm6, xmm2	;filterY + filterOffset
		mulss xmm6, trzy	;(filterY + filterOffset) *3
		addss xmm6, xmm1	;filterX do xmm6
		addss xmm6, xmm2	;filterOffset do xmm6

		CVTTSS2SI rax, xmm6 ;(filterY + filterOffset) *3 + filterX + filterOffset do rax

		;mov r13, [r8+rax]   ;wartość spod xkernel[]
		;neg r13
		VCVTUSI2SS xmm7, [r8+rax]   


		addss xmm1, jeden	;filterX++
		jmp loopX

	loopXKoniec:
		addss xmm0, jeden ;filterY++
		jmp loopY



loopYKoniec:
	;wpisywanie xb, xg... do tablicy wyjsciowej

	ret				;powr鏒 z procedury
fnSobelFilter endp	
end