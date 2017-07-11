; Every time r1 is equal to 21381376 increase r13
; The first first 8 bits of r13 controls the 8 leds on the mimas V2
mov #68, r0
mul r0, r0
mul r0, r0
mov #1, r2
loop:
mov #0, r1
sleep:
cmpeq r0, r1
bf sleep
add r2, r1
bt loop
add r2, r13
