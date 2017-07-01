# Pipeline CPU
## Description
A 5-stage Pipeline CPU implemented in VHDL for learning purposes.
The processor VHDL files are located in the Code directory.

**This project is still in progress.**
 
## Features
| Item | Feature |
| --- | --- |
| Registers | Sixteen 32-bit registers |
| Instruction Set | 16-bit fixed length Delayed branch used to deal with controll hazards|
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
