popOp macro
	push ecx 
	
	mov eax , lenStaOpe
	dec eax
	mov lenStaOpe , eax
	
	pop ecx
endm

pushOp macro
	mov bl , [expresie + ecx]
	push ecx
	
	mov eax , lenStaOpe
	mov stackOpe[eax] , bl
	inc eax
	mov lenStaOpe , eax
		
	pop ecx
endm

popVal macro
	push ecx 
	push eax
	
	mov eax , lenStaVal
	sub eax , 4
	mov lenStaVal , eax
	
	pop eax
	pop ecx
endm

pushVal macro
	push ecx
	
	mov eax , lenStaVal
	mov esi , eax
	mov stackVal[esi] , ebx
	add eax , 4
	mov lenStaVal , eax
		
	pop ecx
endm