;doar un fisier in care salvam secvente din cod
;stergeam uneori secvente ca sa vad daca acolo imi 'pusca' programul
;il las daca cumva trebuie sa fac modificari :D

bucla3:
		mov eax , 0
		mov ebx , lenStaOpe
		cmp eax , ebx
		je iesire3
		
		mov esi , lenStaVal
		sub esi , 4
		mov ebx , stackVal[esi]
		sub esi , 4
		popVal 
		mov eax , stackVal[esi]
		add esi , 4
		popVal
		mov lenStaVal , esi
		
		calVal
		
		mov ebx , eax
		
		pushVal
		popOp
		
	jmp bucla3
	iesire3: