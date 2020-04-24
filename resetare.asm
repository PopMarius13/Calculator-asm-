reset macro
local bucla10 , bucla11 , bucla12
	mov eax , 0
	
	mov lenStaVal , eax
	mov lenStaOpe , eax
	
	mov ecx, lenghtExp
	mov edi , 0
	bucla10:
		mov expresie[edi] , al
		inc edi
	loop bucla10
	mov lenghtExp , eax
endm