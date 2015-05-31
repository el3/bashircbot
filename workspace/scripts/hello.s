 .section .rodata

hello_str: .ascii "Hello, World!
"

 .section .text
 .globl _start
_start: movl $4, %eax
 movl $1, %ebx
 movl $hello_str, %ecx
 movl $14, %edx
 int $0x80

 movl $1, %eax
 xorl %ebx, %ebx
 int $0x80
