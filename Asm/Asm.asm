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

pxor xmm8, xmm8
pxor xmm9, xmm9
pxor xmm10, xmm10
pxor xmm11, xmm11
pxor xmm12, xmm12
pxor xmm13, xmm13

loopY:
	comiss xmm0, xmm2   ;czy filterY = 1
	ja loopYKoniec

	movss xmm1, minusJeden ;przywracanie wartosci filterY=-1

	loopX:
		comiss xmm1, xmm2   ;czy filterX = 1
		ja loopXKoniec		;jezeli wieksze lub = to skocz
		xor rbx, rbx
		xor rax, rax
		pxor xmm14, xmm14
		pxor xmm7, xmm7
		xor r13, r13

		;liczenie calOffset
		movss xmm3, xmm1	;filterX do xmm3
		mulss xmm3, cztery	;filterX*4	
		CVTSI2SS xmm4, r10	;konwertowanie int na float i skopiowanie stride do xmm4
		mulss xmm4, xmm0	;filterY(xmm0) * srcData.Stride
		addss xmm3, xmm4	;filterX*4 + filterY(xmm0) * srcData.Stride
		CVTSI2SS xmm5, r11	;byteOffset do r11
		addss xmm5, xmm3	;byteoffset + ....
		CVTTSS2SI rbx, xmm5 ;calcOffset(xmm5) do rbx

		xor rcx, rcx
		mov cl, [rsi+rbx]	;pixelBuffer[calcOffset]->liczba od 0-255 (cl jest 8bit, nie potrzebujemy więcej)

		;(filterY + filterOffset) *3 + filterX + filterOffset
		movss xmm6, xmm0	;filterY do XMM6
		addss xmm6, xmm2	;filterY + filterOffset
		mulss xmm6, trzy	;(filterY + filterOffset) *3
		addss xmm6, xmm1	;filterX do xmm6
		addss xmm6, xmm2	;filterOffset do xmm6
		mulss xmm6, cztery	;mnozenie

		CVTTSS2SI rax, xmm6 ;(filterY + filterOffset) *3 + filterX + filterOffset do rax
		

		;----------------w XMM8 wartośc xb
		mov r13, [r8+rax]   ;wartość spod xkernel[]		
		movd xmm7, r13		;przeniesienie do r13
		CVTSI2SS xmm14, rcx	;pixelBuffer do xmm14
		mulss xmm14, xmm7	;pixelBuffer[calcOffset] * xKernel[]
		addss xmm8, xmm14	;

		;-----------------xg
		mov cl, [rsi+rbx+1] ;pixelBuffer[calcOffset+1]
		CVTSI2SS xmm14, rcx
		mulss xmm14, xmm7
		addss xmm9, xmm14
		
		
		;----------------xr
		mov cl, [rsi+rbx+2] ;pixelBuffer[calcOffset+1]
		CVTSI2SS xmm14, rcx
		mulss xmm14, xmm7
		addss xmm10, xmm14
		
		
		;----------------yb
		mov cl, [rsi+rbx]
		mov r13, [r9+rax]   ;wartość spod ykernel[]	w r9 adres yKernel
		movd xmm7, r13		;przeniesienie do r13
		CVTSI2SS xmm14, rcx	;pixelBuffer do xmm14
		mulss xmm14, xmm7	;pixelBuffer[calcOffset] * xKernel[]
		addss xmm11, xmm14	;
		
		;----------------yg
		mov cl, [rsi+rbx+1]
		movd xmm7, r13		;przeniesienie do r13
		CVTSI2SS xmm14, rcx	;pixelBuffer do xmm14
		mulss xmm14, xmm7	;pixelBuffer[calcOffset] * xKernel[]
		addss xmm12, xmm14	;
		
		;----------------yr
		mov cl, [rsi+rbx+2]
		movd xmm7, r13		;przeniesienie do r13
		CVTSI2SS xmm14, rcx	;pixelBuffer do xmm14
		mulss xmm14, xmm7	;pixelBuffer[calcOffset] * xKernel[]
		addss xmm13, xmm14	;


		;mov rax, rcx		;pixelBuffer[calcOffset] do r12
		;imul rax, r13		;pixelBuffer[calcOffset] * xKernel[]
		;movd xmm7, rax


		addss xmm1, jeden	;filterX++
		jmp loopX

	loopXKoniec:
		addss xmm0, jeden ;filterY++
		jmp loopY



loopYKoniec:
	;wpisywanie xb, xg... do tablicy wyjsciowej

	;---xb
	;CVTTSS2SI
	CVTTSS2SI rax, xmm8
	mov [rdi],rax 

	CVTTSS2SI rax, xmm9
	mov [rdi+4], rax

	CVTTSS2SI rax, xmm10
	mov [rdi+8], rax 

	CVTTSS2SI rax, xmm11
	mov [rdi+12], rax 

	CVTTSS2SI rax, xmm12
	mov [rdi+16], rax 

	CVTTSS2SI rax, xmm13
	mov [rdi+20], rax 

	ret				;powr鏒 z procedury
fnSobelFilter endp	
end