calVal macro
local no , no1 , no2 , no3 , iesiCalVal
									;se verifica pe rand daca avem adunare scadere inmultire sau impartire si se efectueaza
	mov edi , lenStaOpe				;rezultatul va fi pus in eax
	dec edi
	push eax
	
	mov al , '+'
	cmp al , stackOpe[edi]
	jne no1
		pop eax
		add eax , ebx
		jmp iesiCalVal
	no1:
	
	mov al , '-'
	cmp al , stackOpe[edi]
	jne no2
		pop eax
		sub eax , ebx
		jmp iesiCalVal
	no2:
	
	mov al , '*'
	cmp al , stackOpe[edi]
	jne no
		pop eax
		mul ebx
		jmp iesiCalVal	
	
	no:
	
	mov al , '/'
	cmp al , stackOpe[edi]
	jne no3
		pop eax
		mov edx , 0
		div ebx
		jmp iesiCalVal	
	no3:
	mov eax , 0
	iesiCalVal:
	
endm


ordinOpe macro
local efectuare , noEfect 
	mov eax , 1
	
	mov edi , ecx				;se verifica daca avem de pus in stiva ( , atunci nu se efectueaza (eax devine 0)
	mov dl , '('
	cmp dl , stackOpe[edi]
	je noEfect
	
	mov edi , lenStaOpe			; se pune in edi indicele varfului stivei de operanzi
	dec edi
	
	mov dl , '*'				;se verifica daca avem pe stiva inmultire, in caz afirmativ se efectueaza (ramane in eax 1)
	cmp dl , stackOpe[edi]
	je efectuare
	
	mov dl , '/'				;se verifica daca avem pe stiva impartire, in caz afirmativ se efectueaza  (ramane in eax 1)
	cmp dl , stackOpe[edi]
	je efectuare
	
	mov dl , '('			
	cmp dl , stackOpe[edi]
	je  noEfect
	
	mov edi , ecx				;daca avem de pus in stiva + , se poate efectua ce este pe stiva deja
	mov dl , '+'
	cmp dl , [expresie + edi]
	je efectuare
	
	mov dl , '-'				;daca avem de pus in stiva - , se poate efectua ce este pe stiva deja
	cmp dl , [expresie + edi]
	je efectuare
	
	noEfect:
	
	mov eax , 0
	
	efectuare:
endm 