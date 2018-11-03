.686
.model flat
extern _ExitProcess@4 : PROC
public _main

.data
	ilosc_dword_bufora	dd 64	; 256*8=2048 ---> 2048/32=64
	bufor		dq 256 dup (?)
.code
_main PROC
	; edi <- rejestr do iterowania po adresach wynikow znajdujacych sie za buforem
	; esi <- rejestr do iterowanie po adresach od poczatku bufora
	; ecx <- ieterator po bitach
	; eax <- trzymanie kolejnych zakodowanych podwojnych slow z bufora
	; ebx <- trymanie kolejnych bitów zdekodowanych
	mov esi, offset bufor ; aby esi wskazywalo na najmlodszy bit bufora
	mov edi, offset bufor + 64 ; do edi przypisuje adres poczatkowy wynikow
ptl:
	mov eax, [esi]
	mov ecx, 31 ; ilosc przesuniec ecx do dekodowania poszczegolnych bitow
ptl_przesuniec:
	dec ecx
	cmp ecx, 0
	jz zapisz_wynik_do_pamieci
	mov eax, [esi]	; zawartosc pod adresem si jest ladowana do eax. esi inkrementowane przy zapisie do wynikow
	shl eax, 1	; aby sprawdzic CF i ponajstarszy bit po przesunieciu
				; po przesunieciu CF=p(n-1) p(n-2) jest najstarzy
	jnc sprawdz_kolejno_0
sprawdz_kolejna_1:
	clc	; czyszcze CF aby sprawdzic najstarszy bit zakodowany bit w eax
	bt eax,31 ; bo eax bylo przesuniete juz. Sprawdzam czy po przesunieciu przedostatni bit takze jest 1
	jnc wynik_dekodowania_0
	bts ebx, 0	; w ebx tymczasowy wynik dekodowania
	shl ebx, 1 ; aby dekodowac kolejne bity ebx przesuwamy w lewo o bit aby na to miejsce zapisac kolejny zdekodowany
	clc	;trzeba wyzerowac aby w dalszym obiegu petli CF nie kolidowalo
	jmp ptl_przesuniec
wynik_dekodowania_0:
	btr ebx, 0
	shl ebx, 1
	jmp ptl_przesuniec
sprawdz_kolejno_0: ; wchodzi tutaj jesli CF=0. Sprawdzam czy najstarszy bit takze jest 0
	clc
	bt eax, 31
	jc wynik_dekodowania_0 ; odwrotnie niz w sprawdz_kolejna_1 bo wynik dekodowania to zanegowany XOR dwóch ostatnich bitow
	bts ebx,0
	shl ebx, 1
	clc
	jmp wynik_dekodowania_0
zapisz_wynik_do_pamieci:
	add edi, 4 ; zwiekszenie adresu bufora o 4 poniewaz operuje na podwojnych slowach (4 bajtach)
	add esi, 4 ; zwiekszenie adresu wynikow dekodowania o 4 poniewaz operuje na podwojnych slowach (4 bajtach)
	cmp esi, offset bufor + 64
	jnz ptl
	nop
	call _ExitProcess@4
_main ENDP
END