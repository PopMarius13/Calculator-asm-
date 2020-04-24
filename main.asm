.386
.model flat, stdcall 

includelib msvcrt.lib

extern exit: proc
extern printf: proc
extern gets: proc
extern strcmp: proc
extern strlen: proc
extern strchr: proc

include creareNumar.asm
include pushPop.asm
include calculator.asm
include resetare.asm

public start

.data
;--------------variabilele pentru expresie

expresie DB 200 dup(0)			
lenghtExp DD 0
rezExp DD 0

;--------------stivele

stackVal DD 200 dup(0)
lenStaVal DD 0
stackOpe DB 200 dup(0)
lenStaOpe DD 0

;--------------cifrele

numere DB "00123456789ABCDEFabcdef" , 0
lunNum DD 22

;---------------formaturile

format1 DB "Introduceti o expresie:", 13 , 10 , 0
format2 DB "%s" , 0
format3 DB "%X" , 13 , 10 , 0
format4 DB "%X  %d", 13 , 10 , 0
format5 DB "%X" , 13 , 10 ,0

;--------------variabila cu valoarea exit pentru verificare 
exitt DB "exit"
.code

;---------------------------------------------------procedura(putea fi si macro) isdigit -------------------------------------------------------------

isdigit PROC		; o functie care verifica daca caracterul este cifra ( inclusiv ABCDEFabcedf)----se pune in eax 1 daca este cifra si 0 in caz contrar

	mov bl , [expresie + ecx]  ;punem in bl valoare pe care vrem sa o verificam
	push ecx		;salval valoarea lui ecx in stiva
	
	mov ecx , lunNum  ;punem lungimea vectorului nostru de cifre declarat mai sus
	
	bucla:		;aceasta bucla verifica daca se regaseste in vectorul de cifre si in caz afirmativ se duce la eticheta iesire
		mov dl , [numere + ecx]
		cmp dl , bl 	
		je iesire	
	loop bucla
	
	mov eax , 0  ;daca iesim din bucla (ecx devine 0) atunci punem in eax pe 0
	jmp noo  ;sarim peste iesire
	
	iesire:
	mov eax , 1		;daca am ajuns aici, inseamna ca este cifra si punem in eax pe 1
	
	noo:
	
	pop ecx  ;realocam valoarea anterioara lui ecx
	ret 0
isdigit ENDP

;-----------------------------------------------procedura evaluator expresie--------------------------------------------------------------------------------

evaluatorExp PROC  ;aceasta procedura ne va simplifica expresia, pana la o expresie care se poate calcula operatie cu operatie

	cmp ecx , lenghtExp		;vedem daca ecx a ajung egal cu lenghtExp, in caz afirmativ iesim la eticheta final unde se
	JE final  				;incheie procedura

	mov al , ' '		;punem caracterul spatiu in al
	cmp al , [expresie + ecx]		; se verifica daca caracterul la care suntem este spatiu , in caz afirmativ
	je continue						;  se trece la urmatorul caracter
	
	mov al , '='		;punem caracterul = in al
	cmp al , [expresie + ecx] 	;se verifica daca caracterul la care suntem este = , in caz afirmativ se icheie procedura
	je final
	
	
	mov al , '('
	cmp al , [expresie + ecx]	;se verifica daca caracterul la care suntem este ( , in caz afirmativ se pune pe stiva operanzilor
	jne salt1
	
		pushOp  ;am facut un macro care pune pe stiva de operanzi un caracter , macroul de afla in fisierul pushPop.asm
		jmp continue	;sarim direct la eticheta continue unde se va apela din nou procedura dupa incrementarea lui ecx

	salt1:
	
	
	call isdigit	; verificam daca caracterul este numar prin apelarea proceduri isdigit
	
	cmp eax , 0
	JE salt2
	
		creareNumar	;apelam macroul creareNumar din fisierul creareNumar.asm, care efectiv creaza un numar in ebx cu toate cifrele consecutive pe care le gaseste
		pushVal		;am facut un macro in fisierul pushPop.asm care pune pe stiva o valoare
		jmp continue	;sarim direct la eticheta continue unde se va apela din nou procedura dupa incrementarea lui ecx
	
	salt2:
	
	mov al , ')'	;punem in al caracterul )
	cmp al , [expresie + ecx]	;se verifica daca caracterul la care suntem este ), in caz afirmativ se efectueaza toate 
	jne salt3					;operatile pana se intalneste ( 
		
		bucla1:
			mov edi , lenStaOpe  ; punem in edi lungimea stivei operanzilor
			dec edi
			
			mov eax , 0		;verificam daca stiva de operati este goala, in caz afirmativ iesim din bucla
			mov ebx , lenStaOpe
			cmp eax , ebx
			je iesire1
			
			mov al , '('		; se verifica daca am ajuns la ( , in caz afirmativ iesim din bucla
			cmp al , stackOpe[edi]		
			je iesire1
			
			mov esi , lenStaVal		;se pune in esi lungimea stivei de valori
			sub esi , 4		;scadem 4 doarece stiva de valori este pe DD
			mov ebx , stackVal[esi]	;punem in ebx prima valoare din stiva
			sub esi , 4		;scadem iar 4
			popVal 			;apelam macroul popVal din pushPop.asm, care ne scoate un element din stiva de valori
			mov eax , stackVal[esi]		;punem in eax , a doua valoare din stiva (practic prima deoarece pe cealalta deja am scoso
			popVal	;apelam iar popVal
			
			calVal;apelam macroul calVal care ne efectueaza operatia in functie de ebx, eax si varful stivei de operazi, se regasesti in fisierul calculator.asm
			
			mov ebx , eax		;punem rezultatul (eax) in ebx
			pushVal			;apelam pushVal care se afla in pushPop.asm si care ne pune o valoare pe stiva de valori
			
			popOp		;eliminam varful stivei de la operanzi 
			
		jmp bucla1
		iesire1:
		
		mov eax , 0			;se verifica daca stiva operanzilor este goala (daca cumva nu am avut un '(' ) , in caz afirmativ nu mai apelam popOp
		mov ebx , lenStaOpe
		cmp eax , ebx
		JE salt4
			popOp		; se scoate de pe stiva operanzilor valoarea (
		salt4:
		
		jmp continue  ;sarim direct la eticheta continue unde se va apela din nou procedura dupa incrementarea lui ecx
	salt3:
	
	; daca am ajuns aici, inseamna ca avem un caracter egal cu + sau - sau * sau /
	
	bucla2:		;bucla efectueaza toate operatile care au prioritate , sau toate daca se pot efectua	
		mov eax , 0		;verificam daca stiva operanzilor este goala, inseamna ca nu efectuam nici o operatie
		mov ebx , lenStaOpe
		cmp eax , ebx
		je iesire2
		
		mov eax , 4			;verificam daca avem cel putin doua elemente pe stiva, in caz negativ se iese din bucla
		mov ebx , lenStaVal
		cmp eax , ebx
		ja iesire2
		
		ordinOpe		;in fisierul calculator.asm exista macroul ordinOpe care verifica daca operatia la care suntem se poate sau nu efectua 
		cmp eax , 0		;adica daca are sau nu prioritate
		je iesire2
		
		mov esi , lenStaVal ;se pune in esi lungimea stivei de valori
		sub esi , 4  ; scadem 4 doarece stiva de valori este pe DD
		mov ebx , stackVal[esi]  ;punem in ebx prima valoare din stiva
		sub esi , 4   ;scadem iar 4
		popVal    ;apelam macroul popVal din pushPop.asm, care ne scoate un element din stiva de valori
		mov eax , stackVal[esi]   ;punem in eax , a doua valoare din stiva (practic prima deoarece pe cealalta deja am scoso
		popVal  ;apelam iar popVal
		
		calVal ;apelam macroul calVal care ne efectueaza operatia in functie de ebx, eax si varful stivei de operazi, se regasesti in fisierul calculator.asm
		
		mov ebx , eax  ;punem rezultatul (eax) in ebx
		pushVal  ;apelam pushVal care se afla in pushPop.asm si care ne pune o valoare pe stiva de valori
		
		popOp  ;eliminam varful stivei de la operanzi  (+-/*)
		
	jmp bucla2
	iesire2:
	
	pushOp		;punem noul operand 
	
	continue:
	
	inc ecx		;incrementam ecx
	call evaluatorExp		;apelam din nou procedura evaluatorExp
	
	final:
	ret 0
evaluatorExp ENDP

;----------------------------------------------------calcul-------------------------------------------------------------------

calcul PROC

	push offset expresie	; calculam lungimea expresiei cu strlen  si o punem in lenghtExp
	call strlen
	add esp , 4
	mov lenghtExp , eax
	
	mov ecx , 0		;punem in ecx pe 0
	call evaluatorExp  ; apelam o procedura care evalueaza expresia si ne pune elementele pe stive sau face calculul
	
	bucla3:		;aceasta bucla termina operatile neefectuate in evaluatorExp
	
		mov eax , 0
		mov ebx , lenStaOpe		;se verifica daca stiva operanzilor este goala , in caz afirmativ se iese din bucla
		cmp eax , ebx
		je iesire3
		
		mov eax , 4
		mov ebx , lenStaVal		;se verifica daca avem cel putin 2 valori in stiva operanzilor, in caz negativ se iese din bucla
		cmp eax , ebx
		je iesire3
		
		mov esi , lenStaVal ;se pune in esi lungimea stivei de valori
		sub esi , 4  ; scadem 4 doarece stiva de valori este pe DD
		mov ebx , stackVal[esi]  ;punem in ebx prima valoare din stiva
		sub esi , 4   ;scadem iar 4
		popVal    ;apelam macroul popVal din pushPop.asm, care ne scoate un element din stiva de valori
		mov eax , stackVal[esi]   ;punem in eax , a doua valoare din stiva (practic prima deoarece pe cealalta deja am scoso
		popVal  ;apelam iar popVal
		
		calVal ;apelam macroul calVal care ne efectueaza operatia in functie de ebx, eax si varful stivei de operazi, se regasesti in fisierul calculator.asm
		
		mov ebx , eax  ;punem rezultatul (eax) in ebx
		pushVal  ;apelam pushVal care se afla in pushPop.asm si care ne pune o valoare pe stiva de valori
		
		popOp  ;eliminam varful stivei de la operanzi  (+-/*)
		
	jmp bucla3
	iesire3:
	
	mov eax , 0		;punem in eax pe 0
	mov ebx , lenStaOpe		;punem in ebx lungimea stivei de operanzi
	cmp eax , ebx			;vedem daca mai exista operanzi in stiva
	je iesire4
		;in caz afirmativ se va efectua calculul cu valoara din stiva valorilor si rezultatul expresiei anterioare
		mov esi , 0
		mov eax , rezExp		;punem in eax rezultatul expresiei anterioare
		mov ebx , stackVal[0]	;in ebx varful stivei de valori
		popVal					;scoatem vf stivei de valori
		calVal					;calculam rezultatul
		mov ebx , eax			;mutam in ebx
		pushVal					;il punem pe stiva de valori
		popOp					;golim stiva de operanzi
		
	iesire4:

;aici se afiseaza rezultatul si se goleste stiva de valori	
	push ecx
	mov esi ,  0
	mov eax , stackVal[esi]
	mov rezExp , eax
	push eax
	push offset format5
	call printf
	add esp , 8
	pop ecx 

	popVal
	
	ret 0
calcul ENDP



;--------------------------------------------main------------------------------------------------------------------------------



start:
	
	calculator:
	
	push offset format1			;afisam Introduceti o expresie:
	call printf
	add esp , 4
	
	push offset expresie		;cititm expresia
	call gets
	add esp , 4
	
	push offset expresie		;verificam daca utilizatorul doreste sa inchida calculatorul
	push offset exitt			
	call strcmp
	add esp , 8					;in caz afirmativ se sare la eticheta finish
	cmp eax , 0
	jz finish	
	
	call calcul				;apelam procedura care ne efectueaza calculul	si afiseaza rezultatul
	
	reset					;resetam stivele si expresia , functia se afla in fisierul resetare.asm
	
	jmp calculator			;bucla infinita pentru introducerea expresilor

	finish:
	
	push 0
	call exit
end start
