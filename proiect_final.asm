.386
.model flat, stdcall

includelib msvcrt.lib
extern scanf: proc
extern printf: proc
extern fread: proc
extern fwrite: proc
extern fopen: proc
extern fclose: proc
extern exit: proc

public start

.data

msg DB "Key C (0-7) =",0
msg5 DB "Key2 C (0-7) =",0
msg8 DB "descriere op ",0dh,0ah,0
msg6 DB "Fisierul ales este: ",0
msg7 DB "Operatia aleasa este: ",0
msg1 DB "eroare deschidere fisier intrare",0
msg2 DB "eroare deschidere fisier iesire",0
msg3 DB "eroare la scriere",0
msg4 DB "ok %d",0

key DD 0
key2 DD 0
key_op DD 0
formatd DB "%d",0
formats DB "%s",0
buffer DB 0
mode_rb DB "rb",0
mode_write DB "wb",0
file_name_out DB "fisier_out.txt",0
sir DB 256 dup(0)
file_name_in DB 256 dup(0)
sir1 DB 1000 dup(0)
;sir_destinatie DB 256 dup(0)
cont dd 0
buf_size DD 256
file_in DD 0
file_out DD 0


.code
start:

	call meniu
	
	;call fopen
	push offset mode_rb
	push offset file_name_in 
	call fopen
	add esp,8
	test eax,eax
	jz err_open
	mov file_in,eax
	
	push offset mode_write
	push offset file_name_out
	call fopen
	add esp,8
	test eax,eax
	jz err_iesire
	mov file_out,eax
	
	
read_loop:
	push file_in
	push 256 
	push 1 
	push offset sir
	call fread
	add esp,16
	mov cont,eax
	test eax,eax
	jz close_file
	
	mov ecx,key_op
	cmp ecx,1
	jne et2
	call criptare_algoritm1
	jmp write_loop
	
et2:
	cmp ecx,2
	jne et3
	call decriptare_algoritm1
	jmp write_loop
	
et3:
	cmp ecx,3
	jne et4
	call criptare_algoritm2
	jmp write_loop
	
et4:
	cmp ecx,4
	call decriptare_algoritm2
	jmp write_loop

write_loop:
	push file_out
	push cont
	push 1
	push offset sir
	call fwrite
	add esp,16
	cmp eax,cont 
	jnz err_scriere
	cmp eax,buf_size ;daca a scris 256 inseamna ca a citit tot 256 si merge sa citeasca mai departe
	je read_loop
	
close_file:
	push file_in 
	call fclose
	add esp,4
	
	
	
close_file1:
	push file_out 
	call fclose
	add esp,4
	jmp iesire
	
err_open:
	push offset msg1 
	call printf
	add esp,4
	jmp iesire

err_iesire:
	push offset msg2 
	call printf
	add esp,4
	jmp iesire

err_scriere:
	push offset msg3
	call printf
	add esp,4
	jmp iesire

fct:
	push eax
	push ebx
	call printf 
	add esp,8
	ret 

criptare_algoritm1:
	mov esi, offset sir
	mov ecx, cont
	lea edi, [esi+ecx] ; adresa de dupa ultimul caracter
	mov ecx,key
criptare_loop:
	cmp esi,edi
	jge iesire_criptare
	mov al, byte ptr [esi] 
	not al
	inc al
	ror al,cl
	mov byte ptr[esi],al
	inc esi
	jmp criptare_loop
iesire_criptare:
	ret

	
decriptare_algoritm1:
	mov esi, offset sir
	mov ecx, cont
	lea edi, [esi+ecx] 
	mov ecx,key
decriptare_loop:
	cmp esi, edi
	jge iesire_decriptare
	mov al, byte ptr [esi] 
	rol al,cl
	not al
	inc al
	mov byte ptr[esi],al
	inc esi
	jmp decriptare_loop
iesire_decriptare:
	ret

criptare_algoritm2:
	mov esi, offset sir
	mov ecx, cont
	lea edi, [esi+ecx] 
	mov ecx,key
	mov edx,key2
criptare2_loop:
	cmp esi, edi
	jge iesire_decriptare
	
	mov eax, dword ptr [esi]
	not eax
	xor eax,ecx
	mov dword ptr[esi],eax
	add esi,4

	mov eax, dword ptr [esi]
	not eax
	xor eax,edx
	mov dword ptr[esi],eax
	add esi,4
	
	mov ax,word ptr[esi]
	not ax
	mov word ptr[esi],ax	
	add esi,4
	jmp criptare2_loop
iesire_criptare2:
	ret
	
decriptare_algoritm2:
	mov esi, offset sir
	mov ecx, cont
	lea edi, [esi+ecx] 
	mov ecx,key
	mov edx,key2
decriptare2_loop:
	cmp esi, edi
	jge iesire_decriptare
	
	mov eax, dword ptr [esi]
	xor eax,ecx
	not eax
	mov dword ptr[esi],eax
	add esi,4
	
	mov eax, dword ptr [esi]
	xor eax,edx
	not eax
	mov dword ptr[esi],eax
	add esi,4
	
	mov ax,word ptr[esi]
	not ax
	mov word ptr[esi],ax
	add esi,4
	jmp decriptare2_loop
iesire_decriptare2:
	ret

meniu:
	
	push offset msg6
	call printf
	add esp,4
	push offset file_name_in  
	push offset formats
	call scanf 
	add esp,8
	
	push offset msg8 
	call printf
	add esp,4
	
	push offset msg7
	call printf
	add esp,4
	push offset key_op ;&key 
	push offset formatd
	call scanf 
	add esp,8
	
	push offset msg 
	call printf
	add esp,4
	push offset key ;&key 
	push offset formatd
	call scanf ;sa merg pana la 7 maxim
	add esp,8
	
	push offset msg5
	call printf
	add esp,4
	push offset key2 ;&key 
	push offset formatd
	call scanf ;sa merg pana la 7 maxim
	add esp,8
	
	ret
	
	
iesire:
	push 0
	call exit
end start