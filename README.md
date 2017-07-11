# Pipeline CPU
## Description
A 5-stage Pipeline CPU implemented in VHDL for learning purposes.
The processor VHDL files are located in the Code directory.

**This project is still in progress.**
 
## Features
| Item | Feature |
| --- | --- |
| Registers | Sixteen 32-bit registers |
| Instruction Set | 16-bit fixed length. Delayed branch used to deal with controll hazards|
| Pipeline | Five stage pipeline |
| Endianness | Big Endian |

## Registers
There are 14 general registers (Rn) numbered R0-R13 which are 32 bits in length.
Those registers are used to data processing. R14 is used as the status register. R15 used as stack pointer.

|Register Name|
| --- |
|R0-R13|
|R14 - Status Register|
|R15 - Stack Register|

## Instruction Set
The instructions are documented in the file Documents/Instruction Set.csv.
Not all instructions are implemented. All the instructions are 16-bit fixed length.

## Hazards
### Control Hazards
In order to deal with control hazards by definition every branch has a delay slot.
for example lets look at the following code:
```asm
mov #1, r0
mov #0, r1
loop:
b loop
add r0, r1
```
The add instruction always runs before going back to the start of the loop. The delay slot should use for optimization and minimizing code. In case you don't want to run any instruction you should put nop instead.

## Data Hazards
The CPU deals with data hazards and there should be no problem using the same register in consecutive instructions.
