/*last update oldmain*/
;r16 = objeto (# casilla)
;r17 = X objeto
;r18= Y objeto
;r19 = aux 1
;r20 = aux 2
;r21 = aux 3
;r22 = N (casilla en busqueda o N de la secuencia)
;r23 = NDS (Numero de pasos para giro)
;r24 = sector(00 A 01 B)
;r25 = X actual
;r26 = Y actual
;r27 = sentido (abajo 00, arriba 01, derecha 02, izquierda 03,  con el eje ortocentrico en el sector A borde izquierdo)
;r28-19 = aux
;.......
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes / )
;r5 = I/O puerto B (motores)
;***  
.dseg
.def ioa=r2
.def iob=r3
.def bordes=r4
.def motores=r5

.def objn=r16
.def objx=r17
.def objy=r18
.def aux1=r19		             
.def aux2=r20
.def aux3=r21
.def aux4=r22

.cseg 
.include "usb1286def.inc"
.org 0000

;lee la posicion de objeto
;initial setup port
ldi r23,40
ldi r19,0xff
out portc,r19
out portd,r19
out portf,r19
out ddrb,r19
ldi r19,0
out portb,r19
out ddrd,r19
out ddrf,r19
out ddrc,r19
start:;end of initial setup
call getioa
call getiob
ldi r19,0
cp r2,r19
brne starta
cpse r3,r19
jmp startb
rjmp start

startA:;setea la posicion del objeto si esta en sector A
SBRC r2,0
jmp setstartA
inc r19
SBRC r2,1
jmp setstartA
inc r19
SBRC r2,2
jmp setstartA
inc r19
SBRC r2,3
jmp setstartA
inc r19
SBRC r2,4
jmp setstartA
inc r19
SBRC r2,5
jmp setstartA
inc r19
SBRC r2,6
jmp setstartA
inc r19
jmp setstartA

;rutinas para delay de lecturas
getioa:
in ioa,pinc
nop
call wait20
in r7,pinc
nop
cpse ioa,r7
rjmp getioa
ret

getiob:
in iob,pind
nop
call wait20
in r7,pind
nop
cpse iob,r7
rjmp getiob
ret

getbordes:
in bordes,pinf
nop
call wait20
in r7,pinf
nop
cpse bordes,r7
rjmp getbordes
ret
;Rutinas para generar retardos a (20 mhz)
;20ms (7*0.0000005)(256)(26)=0.022seg
waitto:
call wait20
inc r19
cpse r19,r23
rjmp waitto
ret

wait10:
ldi r20,26
jmp wait10A
wait10A:
ldi r21,0xff
subi r20,1
brne wait10B
ret
wait10B:
subi r21,1
breq wait10A
rjmp wait10B 

wait20:
ldi r20,26
jmp wait20A
wait20A:
ldi r21,0xff
subi r20,1
brne wait20B
ret
wait20B:
subi r21,1
nop
nop
nop
breq wait20A
rjmp wait20B 
;30 (9*0.0000005)(256)(26)=0.029seg
wait30:
ldi r20,26
jmp wait30A
wait30A:
ldi r21,0xff
subi r20,1
brne wait30B
ret
wait30B:
subi r21,1
nop
nop
nop
nop
nop
breq wait30A
rjmp wait30B 
;40 (12(0.0000005))(256)(26)=0.039seg
wait40:
ldi r20,26
jmp wait40A
wait40A:
ldi r21,0xff
subi r20,1
brne wait40B
ret
wait40B:
subi r21,1
nop
nop
nop
nop
nop
nop
nop
nop
breq wait40A
rjmp wait40B 

;rutinas de movimiento
pasoizq:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x01
eor motores,aux1
out portb,motores
ldi r19,0
call waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

pasoder:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x04
eor motores,aux1
out portb,motores
ldi r19,0
call waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

pasoatra:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x0a
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

pasoadel:
ldi aux1,0xf0
and motores,aux1
ldi aux1, 0x05
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

parar:
ldi aux1,0xf0
and motores,aux1
out portb,motores
call wait30
ret

startB:;setea la posicion del objeto si esta en sector B
SBRC r3,0
jmp setstartB
inc r19
SBRC r3,1
jmp setstartB
inc r19
SBRC r3,2
jmp setstartB
inc r19
SBRC r3,3
jmp setstartB
inc r19
SBRC r3,4
jmp setstartB
inc r19
SBRC r3,5
jmp setstartB
inc r19
SBRC r3,6
jmp setstartB
inc r19
jmp setstartB

setstartA:
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
rjmp stindi;rutina de solucion de sector

setstartB:
ldi r20,8
add r19,r20
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
rjmp stindi
;fin de rutinas de deteccion de objeto

;obtener las coordenadas xy de una casilla
;el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.
getxy:
ldi r19,0
ldi r20,0
ldi r21,0
rjmp subgetxy

subgetxy:
cpse r19,r22
jmp loopxy
ret
loopxy:
cpi r20,3
breq eqloopxy
inc r20
inc r19
jmp subgetxy 
eqloopxy:
inc r21
ldi r20,0
inc r19
jmp subgetxy
;fin

;obtener el valor actual de una casilla N
;la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en el registro 3
getval:
cpi r22,8
brsh getvalB
jmp getvalA

getvalB:
call getiob
ldi r20,8
ldi r19,0
SBRC r3,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,6
ldi r19,1
cp r22,r20
breq retgeval
ldi r19,0
SBRC r3,7
ldi r19,1
jmp retgeval
retgeval:
ret
getvalA:
call getioa
ldi r20,0
ldi r19,0
SBRC r2,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,6
ldi r19,1
cp r22,r20
breq retgeval
ldi r19,0
SBRC r2,7
ldi r19,1
jmp retgeval

;Deduce el sector de arranque, el sentido y setea el x y y del carro para cuando esta solo en la pista (INDIVIDUAL)
stindiAA:
cp r22,objn
breq retgeval
call getxy
mov r25,r20
mov r26,r21
pop r0
pop r0
jmp deducir

stindiBB:
ldi r20,8
add r20,r22
cp r20,objn
breq retgeval
mov r22,r20
call getxy
mov r25,r20
mov r26,r21
pop r0
pop r0
jmp deducir
;mover hasta encender una casilla dentro del tablero en mi sector

stindiA:
call pasoadel
call getioa
mov r25,r2
cpi r25,0
breq stindiA
ldi r22,0
SBRC r25,0
call stindiAA
inc r22
SBRC r25,1
call stindiAA
inc r22
SBRC r25,2
call stindiAA
inc r22
SBRC r25,3
call stindiAA
inc r22
SBRC r25,4
call stindiAA
inc r22
SBRC r25,5
call stindiAA
inc r22
SBRC r25,6
call stindiAA
inc r22
SBRC r25,7
call stindiAA
rjmp stindia

stindiB:
call pasoadel
call getiob
mov r30,r3
cpi r30,0
breq stindiB
ldi r22,0
SBRC r30,0
call stindibb
inc r22
SBRC r30,1
call stindibb
inc r22
SBRC r30,2
call stindibb
inc r22
SBRC r30,3
call stindibb
inc r22
SBRC r30,4
call stindibb
inc r22
SBRC r30,5
call stindibb
inc r22
SBRC r30,6
call stindibb
inc r22
sbrc r30,7
call stindibb
rjmp stindib

;mueve hacia adelante hasta que se encienda un borde
stindi:
call pasoadel
call getbordes
mov aux4,r4
andi aux4,0x03
cpi aux4,0
breq stindi
;suponiendo que el borde del sector A entra por el bit 0 y que el del b entra por el bit 1...
cpi aux4,2
breq setsecB
rjmp setseca

setsecA:
ldi r24,0
ldi r27,0
rjmp stindia

setsecB:
ldi r24,1
ldi r27,1
rjmp stindib
;fin

;dadas las coordenadas xy guardadas en los registros r20 y r21 respectivamente, guarda el numero de esa casilla en r22
getNxy:
ldi r22,4
mul r22,r21
mov r22,r0
add r22,r20
ret
;fin

moverright:
breq retre
rjmp moveright

retre:
ret

turnleft:
call pasoder
jmp fordward

moverleft:
dec r25
cpi r27,2
breq reverse
cpi r27,3
breq fordward
cpi r27,0
ldi r27,3
breq turnleft
jmp turnright

GOBACK:
ldi r31,1
cpse r24,r31
jmp backA
jmp backB

moveright:
inc r25
cpi r27,2
breq fordward
cpi r27,3
breq reverse
cpi r27,0
ldi r27,2
breq turnright
jmp turnleft

RutSel:
cp r18,r26
brlo moverdown
brne moverup
cp r17,r25
brlo moverleft
call moverright
mov r22,r16
call getval
cpi r19,0
breq GOBACK
jmp fordward

moverdown:
dec r26
cpi r27,0
breq reverse
cpi r27,1
breq fordward
cpi r27,2
ldi r27,1
breq turnleft
jmp turnright

reverse:
call pasoatra
jmp reverse

fordward:
call pasoadel
mov r22,r16
call getval
cpi r19,0
breq GOBACK
mov r20,r25
mov r21,r26
call getNxy
call getval
cpi r19,1
breq deducir
jmp fordward

turnright:
call pasoizq
jmp fordward

moverup:
inc r26
cpi r27,0
breq fordward
cpi r27,1
breq reverse
cpi r27,2
ldi r27,0
breq turnright
jmp turnleft

deducir:
call parar
mov r22,r16
call getval
ldi r20,0
cpse r19,r20
jmp RutSel
jmp GOBACK
;fin rutinas deducir

gostop:
call parar
jmp gostop

backA:
call getbordes
mov r31,r4
sbrc r31,0
jmp gostop
sbrs r27,1
call pasoatra
sbrs r27,1
rjmp backa
ldi r30,2
ldi r29,3
cpse r27,r30
call pasoizq
cpse r27,r29
call pasoder
ldi r27,0
rjmp backa

backB:
call getbordes
mov r31,r4
sbrc r31,1
jmp gostop
sbrs r27,1
call pasoatra
sbrs r27,1
rjmp backb
ldi r30,2
ldi r29,3
cpse r27,r30
call pasoder
cpse r27,r29
call pasoizq
ldi r27,1
rjmp backb
;fin