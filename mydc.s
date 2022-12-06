### --------------------------------------------------------------------
### mydc.s
### Full name: Minh Quang Nguyen
### Student ID: 20190723
### Desk Calculator (dc)
### --------------------------------------------------------------------

	.equ   ARRAYSIZE, 20
	.equ   EOF, -1
	.equ   OFFSET, 4
	.equ   RAND_MAX, 1024

	.equ	zero, 48
	.equ	nine, 57
	.equ	negative, 95
	.equ	positive, 0
	
	.equ	plus, 43
	.equ	minus, 45
	.equ	product, 42
	.equ	quotient, 47
	.equ	remainder, 37
	.equ	expo,	94
	
	.equ	q, 113
	.equ 	p, 112
	.equ	f, 102
	.equ	c, 99
	.equ	d, 100
	.equ	r, 114
	.equ	x, 120
	.equ	y, 121
	
	
.section ".rodata"
	
printout:
        .asciz  "%d\n"
        
stackEmpty:
	.asciz "dc: stack empty\n"
	
scanfFormat:
	.asciz "%s"
### --------------------------------------------------------------------

        .section ".data"

### --------------------------------------------------------------------

        .section ".bss"
buffer:
        .skip  ARRAYSIZE
indexbuff:
        .skip  4
        
sign:
	.skip 	4
	
exIndex:
	.skip	4
exCount:
	.skip	4
exBase:
	.skip	4
	
top:
	.skip	4

### --------------------------------------------------------------------

	.section ".text"

	## -------------------------------------------------------------
	## int main(void)
	## Runs desk calculator program.  Returns 0.
	## -------------------------------------------------------------

	.globl  main
	.type   main,@function

main:
        pushl   %ebp
        movl    %esp, %ebp

input:

	## dc number stack initialized. %esp = %ebp
	
	## scanf("%s", buffer)
	pushl	$buffer
	pushl	$scanfFormat
	call    scanf
	addl    $8, %esp

	## check if user input EOF
	cmp	$EOF, %eax
	je	quit
	
	## initialize global variable
	movl 	$0, indexbuff
	movl	$positive, sign
	movl	$0, %ecx

check:	
	##if(buffer[index] == NULL) goto addnum;
	##if(!isdigit(buffer[index])) 
	##	goto isoper;
	##else goto isdigit;
	
	movl 	indexbuff, %eax
	movb 	buffer(%eax), %al
	cmpb	$0, %al
	je	addnum
	cmpb	$zero, %al
	jb 	isoper
	cmpb	$nine, %al
	jg 	isoper

isdigit:
	## else
	## ecx = 10*ecx + buffer[index];

	imul 	$10, %ecx
	subb	$zero, %al
	addl	%eax, %ecx
	incl 	indexbuff
	jmp 	check
	
addnum:
	## stack.push(ecx)
	cmpl	$negative, sign
	je	addnegativenum
	pushl	%ecx
	jmp 	input

addnegativenum:
	#push  ecx-= 2*ecx = -ecx
	movl	%ecx, %eax
	subl	%eax, %ecx
	subl	%eax, %ecx
	pushl	%ecx
	jmp	input

isoper: 
	## if(indexbuff != 0) goto input
	cmpl	$0, indexbuff
	jne	input
	
	cmpl	$negative, %eax
	je 	.negative
	
	## if(buffer[1]) goto input
	incl	indexbuff
	movl	indexbuff, %ebx
	movb	buffer(%ebx), %bl
	cmpb	$0, %bl
	jne	input
	
	## if(buffer[0] == '+') goto plus;
	cmpl 	$plus, %eax
	je 	.plus
	
	cmpl	$minus, %eax
	je	.minus
	
	cmpl	$product, %eax
	je	.product
	
	cmpl	$quotient, %eax
	je	.quotient
	
	cmpl	$remainder, %eax
	je	.remainder
	
	cmpl	$expo, %eax
	je	.expo
	
	cmpl	$q, %eax
	je	quit
	
	cmpl	$p, %eax
	je 	print
	
	cmpl	$f, %eax
	je	.f
	
	cmpl	$c, %eax
	je	.c
	
	cmpl	$d, %eax
	je	.d
	
	cmpl	$r, %eax
	je	.r
	
	cmpl	$x, %eax
	je 	.x
	
	cmpl	$y, %eax
	je	.y
	
	jmp 	input

.negative:
	#if (buffer[1] == NULL) goto input;
	#sign = negative; goto check;
	incl	indexbuff
	movl	indexbuff, %ebx
	movb	buffer(%ebx), %bl
	cmpb	$0, %bl
	je	input
	movl	$negative, sign
	jmp 	check
	
.plus:
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush	
	## b = stack.pop()
	## res = a+b
	popl	%eax
	addl	%ecx, %eax
	pushl 	%eax
	jmp input
	
.minus:
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush
	## b = stack.pop()
	## res = a-b
	popl	%eax
	subl	%ecx, %eax
	pushl 	%eax
	jmp input
		
.product:
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush	
	## b = stack.pop()
	## res = a*b
	popl	%eax
	imul	%ecx
	pushl 	%eax
	jmp input
	
.quotient:	#float point exception
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush
	## b = stack.pop()
	## res = a/b
	movl	$0, %edx
	popl	%eax
	idiv	%ecx
	pushl 	%eax
	jmp input
	
.remainder:
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush
	## b = stack.pop()
	## res = a%b
	movl	$0, %edx
	popl	%eax
	idiv 	%ecx
	pushl 	%edx
	jmp input
	
.expo:
	## if ( stack.peek() == NULL)
	cmpl 	%esp, %ebp
	je 	stackempty
	## a = stack.pop()
	## if (stack.peek() == NULL)
	popl	%ecx
	cmpl	%esp, %ebp
	je 	stackemptywithpush	
	## b = stack.pop()
	## res = a^b
	popl	%ebx
	movl	%ebx, exBase
	movl	$1, %eax
	movl	%ecx, exCount
	movl	$0, exIndex
	
.expoLoop:
	#for(Index<exCount) ecx = ecx*Base; incl Index;
	movl	exCount, %ecx
	cmpl	exIndex, %ecx
	je	.expoFin
	imull	exBase
	incl	exIndex
	jmp 	.expoLoop
	
.expoFin:
	pushl	%eax
	jmp 	input
	
.f:
	movl	%esp, %eax
.fFin:
	cmpl	%eax, %ebp
	je	input
	
	movl	%eax, %ebx
	pushl	(%eax)
	pushl	$printout
	call 	printf
	addl	$8, %esp
	movl	%ebx, %eax
	addl	$OFFSET, %eax
	jmp 	.fFin

.c:
	#while(stack.peek()) stack.pop();
	cmpl	%esp, %ebp
	je	input
	addl	$OFFSET, %esp
	jmp	.c

.d:	
	#if(stack.peek()) eax = stack.pop();
	#stack.push(eax); stack.push(eax);
	cmpl	%esp, %ebp
	je	stackempty
	popl	%eax
	pushl	%eax
	pushl	%eax
	jmp	input
	
.r:
	#if(stack.peek()) ecx = stack.pop();
	#else goto empty
	#if(stack.peek()) eax = stack.pop();
	#else goto emptywithpush
	#stack.push(ecx); stack.push(eax);
	cmpl	%esp, %ebp
	je 	stackempty
	popl	%ecx
	cmpl 	%esp, %ebp
	je 	stackemptywithpush
	popl	%eax
	pushl	%ecx
	pushl	%eax
	jmp 	input

.x:
	# srand(time(NULL))
	pushl	$0
	call	time
	addl	$4, %esp
	pushl	%eax
	call	srand
	addl	$4, %esp
	push	%eax
	call 	rand
	addl	$4, %esp
	
	# edx = rand() % 1024
	movl	$0, %edx
	movl	$RAND_MAX, %ecx
	idiv	%ecx
	pushl	%edx
	jmp	input
	
.y:	
	#	if(!stack.peek()) continue;
	#	a = stack.pop()
	#	if(a<=1) push(a) continue;
	#	int b =a;
	#	while(1) {
	#		if(is.prime(b)) push b, return;
	#		b--;
	#	}
	cmpl	%esp, %ebp
	je	input
	popl	%eax
	movl	%eax, top
	pushl	%eax
	jmp	.yisPrime

.yNext:
	decl	top

.yisPrime:
	movl	top, %eax
	cmpl	$1, %eax
	jle	input
	movl	$2, %ecx

.ycheckPrime:
	#while(top%ecx) ecx++; if(top==ecx) goto Found;
	#if(top%ecx ==0) goto foundPrime;
	movl	$0, %edx
	div	%ecx
	cmpl	$0, %edx
	je	.yNext
	incl	%ecx
	cmpl	%ecx, top
	je	.yfoundPrime
	movl	top, %eax
	jmp	.ycheckPrime
	
.yfoundPrime:
	pushl	top
	jmp 	input
	

print:		
        ## printf("%d\n")
        cmpl	%esp, %ebp
        je 	stackempty
        pushl   $printout
        call    printf
        addl    $4, %esp
        jmp 	input
        
   	
stackempty:
	## printf("stack empty\n");
	pushl 	$stackEmpty
	call 	printf
	addl	$4, %esp
	jmp 	input
	     
stackemptywithpush:
	## printf("stack empty\n"); push ecx;
	movl	%ecx, %ebx
	pushl 	$stackEmpty
	call 	printf
	addl 	$4, %esp
	movl	%ebx, %ecx
	jmp	addnum

quit:	
	## return 0
	movl    $0, %eax
	movl    %ebp, %esp
	popl    %ebp
	ret
