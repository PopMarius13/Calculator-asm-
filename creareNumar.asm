creareNumar macro
local salt4 , notCif , notLitM , fin 
	mov ebx , 0  ;fixam pe ebx cu 0

	salt4:
	mov esi , ecx

	mov eax , ebx		;inmultim cu 16 de fiecare data cand mai adaugam o cifra
	mov edx , 16
	mul edx
	mov ebx , eax

	mov eax , 0			
	mov al , expresie[esi] ;salvam cifra care trebuie pusa in eax
	

	cmp eax , 60		;verificam daca este intre 0-9
	ja notCif
		sub eax , 48
		jmp fin
	notCif:

	cmp eax , 95		;verificam daca este intre A-F
	ja notLitM
		sub eax , 55
		jmp fin
	notLitM:
					;daca am ajuns aici este intre a - f
	sub eax , 87
	fin:
									;pentru fiecare varianta am scazut valoarea corespunzatoare
	add ebx , eax					;mutam rezultatul in ebx
	inc ecx							;incrementam ecx pentru a verifica urmatorul caracter

	push ebx						;salvam valoarea lui ebx
	call isdigit					;apelam isdigit
	pop ebx
	
	cmp eax , 0					;verificam daca este cifra, in caz afirmativ se repeta operatile
	JNE salt4
	
	dec ecx
endm