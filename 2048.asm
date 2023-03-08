.386 
.model flat,stdcall 
option casemap:none 
;include \masm32\include\windows.inc
;include \masm32\include\user32.inc
;include \masm32\include\kernel32.inc
;include \masm32\include\gdi32.inc
;includelib \masm32\lib\user32.lib
;includelib \masm32\lib\kernel32.lib
;includelib \masm32\lib\gdi32.lib
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msvcrt.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
fopen	PROTO C:ptr sbyte,:ptr sbyte
fclose	PROTO C:dword
fprintf PROTO C:dword,:ptr sbyte,:VARARG
fscanf PROTO C:dword,:ptr sbyte,:VARARG
fputc  PROTO C:sbyte, :dword
strcpy	PROTO C:dword, :dword
printf PROTO C :ptr sbyte, :VARARG
sprintf PROTO C :ptr sbyte, :ptr sbyte, :VARARG

RGB macro red,green,blue
	xor eax,eax
	mov ah,blue
	shl eax,8
	mov ah,green
	mov al,red
endm

.DATA                     ; initialized data 
ClassName db "SimpleWinClass",0        ; the name of our window class 
AppName db "My 2048",0        ; the name of our window 
char WPARAM 20h
static db 'static',0
edit db 'edit',0
button db 'button',0
gameEndFlag dd 0
gameWinFlag dd 0
gameContinue dd 0

i dword 0
j dword 0
score dd 0

gameMat dd 0,0,0,0
		dd 0,0,0,0
		dd 0,0,0,0
		dd 0,0,0,0

tmpGameMat  dd 0,0,0,0
			dd 0,0,0,0
			dd 0,0,0,0
			dd 0,0,0,0

historyHigh	DD  0
memoryMap	DD	16*16 DUP(0)					; 固定16个存档位，每个用16个数字代表存档
memoryScore DD  16 DUP(0)						; 存档分数
memoryName	DB	16 DUP('(null)',26 DUP(0))		; 存档名称(最长31个字符，默认为"(null)")
dataPath	DB	'data',0						; 存档路径
; 一些输入输出读写模式串
readMode	DB	'r',0							
writeMode	DB	'w',0
intFormat	DB	'%d',0
strFormat	DB	'%s',0
slotFormat 	DB	'Slot-%d',0
tmpName		DB	'test',0


randData dd 0
max dd 16
dat dd 0
col dd 1
row dd 1
changedW dd 0
changedA dd 0
changedS dd 0
changedD dd 0



.DATA?                ; Uninitialized data 
hInstance HINSTANCE ?        ; Instance handle of our program 
CommandLine LPSTR ? 
hwndHdc HDC ?
hWindow HWND ?
Data byte 10 dup(?)
hGame dd 30 dup(?)
tmpMat dd 16 DUP(?)
overEdge dd ?
exchangeNum dd ?

hdcIDB_BITMAP1 dd ?
hbmIDB_BITMAP1 dd ?
hdcIDB_BITMAP2 dd ?
hbmIDB_BITMAP2 dd ?
hdcIDB_BITMAP3 dd ?
hbmIDB_BITMAP3 dd ?
hdcIDB_BITMAP4 dd ?
hbmIDB_BITMAP4 dd ?
hdcIDB_BITMAP5 dd ?
hbmIDB_BITMAP5 dd ?
hdcIDB_BITMAP6 dd ?
hbmIDB_BITMAP6 dd ?
hdcIDB_BITMAP7 dd ?
hbmIDB_BITMAP7 dd ?
hdcIDB_BITMAP8 dd ?
hbmIDB_BITMAP8 dd ?
hdcIDB_BITMAP9 dd ?
hbmIDB_BITMAP9 dd ?
hdcIDB_BITMAP10 dd ?
hbmIDB_BITMAP10 dd ?
hdcIDB_BITMAP11 dd ?
hbmIDB_BITMAP11 dd ?
hdcIDB_BITMAP12 dd ?
hbmIDB_BITMAP12 dd ?
hdcIDB_BITMAP13 dd ?
hbmIDB_BITMAP13 dd ?
hdcIDB_BITMAP14 dd ?
hbmIDB_BITMAP14 dd ?
hdcIDB_BITMAP15 dd ?
hbmIDB_BITMAP15 dd ?
hdcIDB_BITMAP16 dd ?
hbmIDB_BITMAP16 dd ?
hdcIDB_BITMAP17 dd ?
hbmIDB_BITMAP17 dd ?
hdcIDB_BITMAP18 dd ?
hbmIDB_BITMAP18 dd ?
hdcIDB_BITMAP19 dd ?
hbmIDB_BITMAP19 dd ?
hdcIDB_BITMAP20 dd ?
hbmIDB_BITMAP20 dd ?
hdcIDB_BITMAP21 dd ?
hbmIDB_BITMAP21 dd ?
IDB_BITMAP1 BYTE 'IDB_BITMAP1',0
IDB_BITMAP2 BYTE 'IDB_BITMAP2',0
IDB_BITMAP3 BYTE 'IDB_BITMAP3',0
IDB_BITMAP4 BYTE 'IDB_BITMAP4',0
IDB_BITMAP5 BYTE 'IDB_BITMAP5',0
IDB_BITMAP6 BYTE 'IDB_BITMAP6',0
IDB_BITMAP7 BYTE 'IDB_BITMAP7',0
IDB_BITMAP8 BYTE 'IDB_BITMAP8',0
IDB_BITMAP9 BYTE 'IDB_BITMAP9',0
IDB_BITMAP10 BYTE 'IDB_BITMAP10',0
IDB_BITMAP11 BYTE 'IDB_BITMAP11',0
IDB_BITMAP12 BYTE 'IDB_BITMAP12',0
IDB_BITMAP13 BYTE 'IDB_BITMAP13',0
IDB_BITMAP14 BYTE 'IDB_BITMAP14',0
IDB_BITMAP15 BYTE 'IDB_BITMAP15',0
IDB_BITMAP16 BYTE 'IDB_BITMAP16',0
IDB_BITMAP17 BYTE 'IDB_BITMAP17',0
IDB_BITMAP18 BYTE 'IDB_BITMAP18',0
IDB_BITMAP19 BYTE 'IDB_BITMAP19',0
IDB_BITMAP20 BYTE 'IDB_BITMAP20',0
IDB_BITMAP21 BYTE 'IDB_BITMAP21',0

.CONST
EmptyText byte ' ',0
szEndTitle byte "Try again?",0
szEndText byte "           You lose!",0
szSlTitle byte "Save & Load",0
szSlText byte "Click 'Abort' to save to this slot,",0aH,"Click 'Retry' to load from this slot,",0aH,"Click 'Ignore' to cancel.",0
szText1 byte "  ———————— 欢迎游玩2048 ————————  ",0
szText2 byte "使用WASD来移动数字块",0
szText3 byte "两个相同的数字块相遇则会合并",0
szText4 byte "直到无法移动为止，你累计的合并分即为最终得分",0
szText5 byte "尝试合并出一个2048，或者向更高的总分发起冲击吧",0
str_slotempty byte "Slot-Empty"
BITMAP1 EQU 101
BITMAP2 EQU 104
BITMAP3 EQU 106
BITMAP4 EQU 107
BITMAP5 EQU 108
BITMAP6 EQU 109
BITMAP7 EQU 110
BITMAP8 EQU 111
BITMAP9 EQU 112
BITMAP10 EQU 113
BITMAP11 EQU 114
BITMAP12 EQU 115
BITMAP13 EQU 116
BITMAP14 EQU 117
BITMAP15 EQU 118
BITMAP16 EQU 119
BITMAP17 EQU 120
BITMAP18 EQU 121
BITMAP19 EQU 122
BITMAP20 EQU 123
BITMAP21 EQU 124

.CODE                ; Here begins our code 

num2byte proc far C uses eax esi ecx,number:dword
;参考大数乘法里的函数 直接移植
	xor eax,eax
	xor edx,edx
	xor ebx,ebx
	;被除数放到eax中
	mov eax,number
	mov ecx,10
	;商为0结束循环
L1:
	;ebx记录number位数
	inc ebx
	;eax/ecx，32位除法，商在eax中，余数在edx中
	idiv ecx
	;余数+‘0’=‘0’-‘9’
	add edx,30H
	;先压栈后续一起处理
	push edx
	;记得清0，32位除法被除数为edx:eax
	xor edx,edx
	;eax为商，商=0表示除尽了
	cmp eax,0
	;大于0继续循环
	jg L1

	;esi=0，表示第esi个字符
	mov esi,0
L2:
	;ebx为之前记录的number位数，每次循环减1，直到为0
	dec ebx
	;将栈中的字符出栈存到eax中
	pop eax
	;结果只为‘0’-‘9’，只在8位寄存器中，无所谓了
	mov byte ptr Data[esi],al
	inc esi
	cmp ebx,0
	jg L2
	
	;循环结束，末尾赋0表示结束
	mov Data[esi],0
	ret

num2byte endp

Generator proc random_seed:DWORD,max_val:DWORD 

                push ecx				;保存寄存器信息
                push edx
                call       GetTickCount ;获取系统时间
                mov        ecx,random_seed
                add        eax,ecx		
                rol        ecx,1
                add        ecx,2551d 
                mov        random_seed,ecx	;初步产生种子

                mov     ecx,32

    crc_bit:    shr        eax,1			;根据eax信息处理随机数
                jnc        loop_crc_bit 
                xor        eax,0edb88320h

    loop_crc_bit:
                loop        crc_bit
                mov         ecx,max_val

				;限定随机数大小，存入randData
                xor         edx,edx ;高16位清空
                div         ecx
                xchg        edx,eax ;余数存入eax
                or          eax,eax
				mov			randData,eax	

				;随机位置生成2，无冲突时跳转
                cmp     gameMat[eax*4],0
                je      inital_mat
				;冲突处理
                mov     ecx,16
                mov     randData,eax
                xor     eax,eax     ;存放tmp指针
                xor     edx,edx     ;存放game指针

    get_emp:    
                cmp     gameMat[edx*4],0
                jne      cmp_ne      ;格子为零
                
                mov     tmpMat[eax*4],edx
                inc     eax
    cmp_ne:         
                inc     edx
                loop    get_emp
                ;eax存放tmp长度

                mov     ecx,eax
                xor     edx,edx
                mov     eax,randData
                div     ecx
                xchg    edx,eax ;eax为tmp指针

                mov     edx,tmpMat[eax*4]
                mov     randData,edx
    inital_mat:
                mov     eax,randData
                mov     gameMat[eax*4],2
                pop edx
                pop ecx
                ret        
Generator Endp

writeDataFile PROC
	local filePtr:dword, writeDataFileTmp:dword
	invoke fopen,offset dataPath,offset writeMode
	mov filePtr, eax 
	invoke fprintf,filePtr, offset intFormat, historyHigh
	mov ecx, 0
writeLoopLabel0:
	push ecx
	mov writeDataFileTmp,ecx
	invoke fputc,10,filePtr
	mov eax,writeDataFileTmp
	shl eax,5
	lea eax,memoryName[eax] 
	invoke fprintf,filePtr, eax
	invoke fputc,' ',filePtr
	mov eax,writeDataFileTmp
	invoke fprintf,filePtr,offset intFormat, memoryScore[eax*4]
	invoke fputc,10,filePtr
	xor ecx,ecx
writeLoopLabel1:
	push ecx
	mov eax,writeDataFileTmp
	shl eax,4
	or eax,ecx
	invoke fprintf,filePtr,offset intFormat,memoryMap[eax*4]
	invoke fputc,' ',filePtr
	pop ecx
	inc ecx
	cmp ecx,16
	jl writeLoopLabel1
	pop ecx
	inc ecx
	cmp ecx,16
	jl  writeLoopLabel0
	invoke fclose, filePtr
	ret
writeDataFile ENDP

;加载已有的数据文件，不需要调用，直接调inidata就行
readDataFile PROC
	local filePtr:dword, readDataFileTmp:dword
	mov filePtr, eax
	invoke fscanf, filePtr, offset intFormat, offset historyHigh
	xor ecx, ecx
readLoopLabel0:
	mov eax,ecx
	shl eax,5
	add eax, offset memoryName
	push ecx
	mov readDataFileTmp,ecx
	invoke fscanf,filePtr, offset strFormat, eax
	mov eax,readDataFileTmp
	shl eax,2
	add eax,offset memoryScore
	invoke fscanf,filePtr, offset intFormat, eax
	xor ecx, ecx
	mov eax,readDataFileTmp
	shl eax,4
readLoopLabel1:
	mov esi,eax
	or esi, ecx
	shl esi,2
	add esi,offset memoryMap
	push ecx
	push eax
	invoke fscanf,filePtr, offset intFormat,esi
	pop eax
	pop ecx
	inc ecx
	cmp ecx,16
	jl readLoopLabel1
	pop ecx
	inc ecx
	cmp ecx,16
	jl readLoopLabel0
	invoke fclose, filePtr
	ret
readDataFile ENDP

;初始化数据，若有数据文件则加载，否则新建。
iniData PROC
	local filePtr:dword
	invoke fopen,offset dataPath,offset readMode
.if eax == 0
	call writeDataFile
.endif
	call readDataFile	
	ret
iniData ENDP

;加载第id个存档(只有16个存档位,id从0到15)
loadData PROC  id:dword
	mov eax,id
	mov ecx,memoryScore[eax*4]
	mov score,ecx
	shl eax,6
	xor ecx,ecx
loadLoopLabel0:
	mov edx, memoryMap[eax][ecx*4]
	mov gameMat[ecx*4],edx
	inc ecx
	cmp ecx,16
	jl loadLoopLabel0
	ret
loadData ENDP

;将当前存档存放到第id个，且存档名称以name指针开头的字符串，最长31个字符，只能为字母或数字
;注意 这只是写入内存，并没有写入文件，写入文件需要调用writeDataFile函数
saveDataIntoMemory PROC id:dword,namePtr:dword
	mov eax,id
	mov ecx,score
	mov memoryScore[eax*4],ecx
	shl eax,6
;存地图
	xor ecx,ecx
L7:
	mov edx, gameMat[ecx*4]
	mov memoryMap[eax][ecx*4], edx
	inc ecx
	cmp ecx,16
	jl L7
;存名字
	mov eax,id
	shl eax,5
	add eax,offset memoryName
	invoke strcpy, eax, namePtr
	ret
saveDataIntoMemory ENDP


InitGame proc far C uses eax esi ecx edx,hWnd
	;字体
	local hFont:HFONT ;一个句柄，相当于表示内存中的一个字体对象，可即用
	local logfont:LOGFONT ;一个结构，用来逻辑上表达一个字体
	invoke RtlZeroMemory,addr logfont,sizeof logfont ;定义新字体
	mov logfont.lfCharSet,GB2312_CHARSET
	mov logfont.lfHeight,-40
	mov logfont.lfWeight,FW_BOLD
	invoke CreateFontIndirect,addr logfont
	mov hFont,eax

	;操作说明栏
	invoke CreateWindowEx,NULL,offset edit,offset szText1,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,100,465,360,15,\
	hWnd,16,hInstance,NULL
	MOV hGame[64],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText2,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,100,480,360,15,\
	hWnd,17,hInstance,NULL
	mov hGame[68],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText3,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,100,495,360,15,\
	hWnd,18,hInstance,NULL
	mov hGame[72],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText4,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,100,510,360,15,\
	hWnd,19,hInstance,NULL
	mov hGame[76],eax
	invoke CreateWindowEx,NULL,offset edit,offset szText5,\
	WS_CHILD or WS_VISIBLE OR WS_DISABLED,100,525,360,15,\
	hWnd,20,hInstance,NULL
	mov hGame[80],eax
	
	;存档按钮
	invoke CreateWindowEx,NULL,offset button,offset str_slotempty,\
	WS_CHILD or WS_VISIBLE,500,100,120,60,\
	hWnd,21,hInstance,NULL
	mov hGame[84],eax
	invoke CreateWindowEx,NULL,offset button,offset str_slotempty,\
	WS_CHILD or WS_VISIBLE,500,200,120,60,\
	hWnd,22,hInstance,NULL
	mov hGame[88],eax
	invoke CreateWindowEx,NULL,offset button,offset str_slotempty,\
	WS_CHILD or WS_VISIBLE,500,300,120,60,\
	hWnd,23,hInstance,NULL
	mov hGame[92],eax
	invoke CreateWindowEx,NULL,offset button,offset str_slotempty,\
	WS_CHILD or WS_VISIBLE,500,400,120,60,\
	hWnd,24,hInstance,NULL
	mov hGame[96],eax

	;1
	mov edx,0
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,100
	mov eax,100
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,0
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;2
	mov edx,1
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,190
	mov eax,100
    .IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,1
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;3
	mov edx,2
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,280
	mov eax,100
	.IF Data[0] =='0'
		
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,2
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;4
	mov edx,3
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,370
	mov eax,100
	.IF Data[0] =='0'
		
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,3
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;5
	mov edx,4
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,100
	mov eax,190
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,4
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;6
	mov edx,5
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,190
	mov eax,190
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,5
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;7
	mov edx,6
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,280
	mov eax,190
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,6
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;8
	mov edx,7
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,370
	mov eax,190
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,7
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;9
	mov edx,8
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,100
	mov eax,280
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,8
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;10
	mov edx,9
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,190
	mov eax,280
	.IF Data[0] =='0'
		
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,9
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;11
	mov edx,10
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,280
	mov eax,280
	.IF Data[0] =='0'
		
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,10
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;12
	mov edx,11
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,370
	mov eax,280
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,11
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;13
	mov edx,12
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,100
	mov eax,370
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,12
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;14
	mov edx,13
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,190
	mov eax,370
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,13
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;15
	mov edx,14
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,280
	mov eax,370
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,14
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;16
	mov edx,15
	invoke num2byte,dword ptr gameMat[edx*4]
	mov ecx,370
	mov eax,370
	.IF Data[0] =='0'
		invoke CreateWindowEx,NULL,offset static,offset EmptyText,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\  
		hWnd,edx,hInstance,NULL  
	.else
		invoke CreateWindowEx,NULL,offset static,offset Data,\
		WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,ecx,eax,90,90,\ 
		hWnd,edx,hInstance,NULL  
	.endif
	mov edx,15
		;存储窗口句柄，句柄返回值在eax中
	mov hGame[edx*4],eax
		;调用SendMessage改变字体
	invoke SendMessage,eax,WM_SETFONT,hFont,1

	;score
	mov edx,16
	invoke num2byte,score
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE or WS_DISABLED,120,50,100,30,\  
	hWnd,edx,hInstance,NULL  
	mov edx,16
	mov hGame[edx*4],eax
	
	;最高分
	invoke num2byte,historyHigh
	invoke CreateWindowEx,NULL,offset edit,offset Data,\
	WS_CHILD or WS_VISIBLE or SS_CENTER or WS_BORDER or SS_CENTERIMAGE,510,50,100,30,\
	hWnd,20,hInstance,NULL
	mov hGame[100],eax
	;
	xor eax,eax
	ret

InitGame endp

SetNewGame proc far C uses eax esi ecx edx
	
	mov ecx,16
	mov esi,0
L1:
	mov gameMat[esi*4],0
	inc esi
	loop L1

	;初始化各个值
	mov gameEndFlag,0
	mov gameWinFlag,0
	mov gameContinue,0
	mov score,0

	;gameMat随机生成两个值
	INVOKE Generator,dat,max
	INVOKE Generator,dat,max
	ret

SetNewGame endp

UpdataGame proc far C uses eax esi ecx edx,hWnd
	LOCAL hDc:HDC
	LOCAL hBm
	mov i,0
.while i<16
	mov edx,i
	;设置控件中的值
	.if gameMat[edx*4] == 0
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP18,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP18,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP18,hbmIDB_BITMAP18
		invoke LoadBitmap,hInstance,BITMAP18
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP18,eax
		invoke PatBlt,hdcIDB_BITMAP18,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP18,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP18 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP18 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 2
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP3,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP3,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP3,hbmIDB_BITMAP3
		invoke LoadBitmap,hInstance,BITMAP3
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP3,eax
		invoke PatBlt,hdcIDB_BITMAP3,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP3,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP3 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP3 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 4
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP4,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP4,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP4,hbmIDB_BITMAP4
		invoke LoadBitmap,hInstance,BITMAP4
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP4,eax
		invoke PatBlt,hdcIDB_BITMAP4,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP4,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP4 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP4 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 8
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP5,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP5,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP5,hbmIDB_BITMAP5
		invoke LoadBitmap,hInstance,BITMAP5
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP5,eax
		invoke PatBlt,hdcIDB_BITMAP5,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP5,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP5 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP5 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 16
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP6,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP6,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP6,hbmIDB_BITMAP6
		invoke LoadBitmap,hInstance,BITMAP6
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP6,eax
		invoke PatBlt,hdcIDB_BITMAP6,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP6,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP6 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP6 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 32
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP7,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP7,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP7,hbmIDB_BITMAP7
		invoke LoadBitmap,hInstance,BITMAP7
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP7,eax
		invoke PatBlt,hdcIDB_BITMAP7,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP7,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP7 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP7 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 64
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP8,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP8,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP8,hbmIDB_BITMAP8
		invoke LoadBitmap,hInstance,BITMAP8
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP8,eax
		invoke PatBlt,hdcIDB_BITMAP8,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP8,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP8 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP8 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 128
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP9,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP9,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP9,hbmIDB_BITMAP9
		invoke LoadBitmap,hInstance,BITMAP9
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP9,eax
		invoke PatBlt,hdcIDB_BITMAP9,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP9,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP9 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP9 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 256
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP10,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP10,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP10,hbmIDB_BITMAP10
		invoke LoadBitmap,hInstance,BITMAP10
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP10,eax
		invoke PatBlt,hdcIDB_BITMAP10,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP10,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP10 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP10 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 512
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP11,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP11,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP11,hbmIDB_BITMAP11
		invoke LoadBitmap,hInstance,BITMAP11
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP11,eax
		invoke PatBlt,hdcIDB_BITMAP11,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP11,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP11 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP11 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 1024
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP12,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP12,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP12,hbmIDB_BITMAP12
		invoke LoadBitmap,hInstance,BITMAP12
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP12,eax
		invoke PatBlt,hdcIDB_BITMAP12,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP12,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP12 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP12 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 2048
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP13,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP13,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP13,hbmIDB_BITMAP13
		invoke LoadBitmap,hInstance,BITMAP13
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP13,eax
		invoke PatBlt,hdcIDB_BITMAP13,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP13,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP13 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP13 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 4096
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP14,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP14,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP14,hbmIDB_BITMAP14
		invoke LoadBitmap,hInstance,BITMAP14
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP14,eax
		invoke PatBlt,hdcIDB_BITMAP14,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP14,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP14 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP14 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 8192
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP15,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP15,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP15,hbmIDB_BITMAP15
		invoke LoadBitmap,hInstance,BITMAP15
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP15,eax
		invoke PatBlt,hdcIDB_BITMAP15,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP15,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP15 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP15 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 16384
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP16,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP16,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP16,hbmIDB_BITMAP16
		invoke LoadBitmap,hInstance,BITMAP16
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP16,eax
		invoke PatBlt,hdcIDB_BITMAP16,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP16,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP16 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP16 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 32768
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP17,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP17,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP17,hbmIDB_BITMAP17
		invoke LoadBitmap,hInstance,BITMAP17
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP17,eax
		invoke PatBlt,hdcIDB_BITMAP17,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP17,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP17 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP17 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.elseif gameMat[edx*4] == 65536
		invoke GetDC,hGame[edx*4]
        mov hDc,eax
		invoke CreateCompatibleDC,hDc
		mov hdcIDB_BITMAP20,eax
		invoke CreateCompatibleBitmap, hDc,90,90
		mov hbmIDB_BITMAP20,eax
		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP20,hbmIDB_BITMAP20
		invoke LoadBitmap,hInstance,BITMAP20
		mov hBm,eax
		invoke CreatePatternBrush,hBm ;创建画刷
		push eax
		invoke SelectObject,hdcIDB_BITMAP20,eax
		invoke PatBlt,hdcIDB_BITMAP20,0,0,90,90,PATCOPY
		pop eax
		invoke DeleteObject,eax ;删除画刷
		invoke BitBlt,hDc,0,0,90,90,hdcIDB_BITMAP20,0,0,SRCCOPY ;传输绘制
		invoke DeleteDC,hdcIDB_BITMAP20 ;删除DC
		invoke DeleteObject,hbmIDB_BITMAP20 ;删除位图
		invoke ReleaseDC,hGame[edx*4],hDc
	.endif

	mov eax,i
	add eax,1
	mov i,eax
.endw

	invoke num2byte,score
	INVOKE SetWindowText,hGame[64],offset Data

	xor eax,eax
	ret

UpdataGame endp

moveW proc far C uses eax ebx ecx edx esi
	;初始化是否能移动的判断变量
	MOV changedW,0
	;初始化循环起点
	mov ecx,4
	mov col,ecx
	mov row,1
w:	
	;循环到下一方向4个方块的判断起点进行判断
	mov col,ecx
	mov row,1

	jmp w_trav

w_end:
	;在同一方向结束循环，走向下一个方向的4个方块的判断
	loop w

	ret
w_trav:
	;保存比较数
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4]
	mov ebx,eax

	;同一方向的四个位置进行循环判断
	cmp row,1
	je w_merge

	cmp row,2
	je w_fore

	cmp row,3
	je w_fore

	cmp row,4
	je w_fore

	jmp w_trav

w_mov:
	;跳转到下一列4方块的判断
	inc row
	cmp row,5
	jb w_trav

	jmp w_end

w_merge:
	;判断是否为0，若为0则跳过判断
	cmp edx,0
	je w_mov

	add ebx,4
	;判断是否跨行比较，若跨行比较则进行下一个同方向的方块的判断
	cmp ebx,16
	jae w_mov

	;是否与本位方块进行比较
	cmp eax,ebx
	je w_merge

	;若在合并方向上寻找到0，则继续探索是否有可合并方块
	cmp gameMat[ebx*4],0
	je w_merge
	;若在合并方向上寻找到相同数字方块，则转入合并函数
	cmp gameMat[ebx*4],edx
	je w_equ

	jmp w_mov

w_equ:
	;若判断遇到相等数字方块，则进行合并
	imul edx,2
	;
	mov esi,eax
	mov eax,score
	add eax,edx
	mov score,eax
	mov eax,esi
	;
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedW,edx
	mov edx,exchangeNum

	jmp w_mov

w_fore:
	;向反方向探索，若遇到0则进行移动
	cmp edx,0
	je w_mov
	mov ebx,eax
	sub ebx,4
	
	cmp gameMat[ebx*4],0
	je w_zero

	jmp w_merge

w_zero:
	;遇到0后移动方块
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0
	
	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedW,edx
	mov edx,exchangeNum
    
	mov eax,ebx
	sub ebx,4
	;边界检测
	cmp ebx,4000
	ja w_merge
	;若前方仍有零，继续进行判断
	cmp gameMat[ebx*4],0
	je w_zero

	jmp w_merge
moveW endp

moveD proc far C uses eax ebx ecx edx esi
	;初始化是否能移动的判断变量
	mov changedD,0
	;初始化循环起点
	mov ecx,4
	mov col,ecx
	mov row,4

d:
	;循环到下一方向4个方块的判断起点进行判断
	mov row,ecx
	mov col,4

	jmp d_trav

d_end:
	;在同一方向结束循环，走向下一个方向的4个方块的判断
	loop d

	ret
d_trav:
	;保存比较数
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4]
	mov ebx,eax

	;同一方向的四个位置进行循环判断
	cmp col,4
	je d_merge

	cmp col,3
	je d_fore

	cmp col,2
	je d_fore

	cmp col,1
	je d_fore

	jmp d_trav
d_mov:
	;跳转到下一列4方块的判断
	dec col
	cmp col,0
	ja d_trav

	jmp d_end
d_merge:
	;判断是否为0，若为0则跳过判断
	cmp edx,0
	je d_mov

	dec ebx
	;判断是否跨行比较，若跨行比较则进行下一个同方向的方块的判断
	mov overEdge,eax
	mov eax,row
	dec eax
	imul eax,4
	dec eax
	cmp eax,ebx
	je d_mov
	mov eax,overEdge

	;是否与本位方块进行比较
	cmp eax,ebx
	je d_merge

	;若在合并方向上寻找到0，则继续探索是否有可合并方块
	cmp gameMat[ebx*4],0
	je d_merge

	;若在合并方向上寻找到相同数字方块，则转入合并函数
	cmp gameMat[ebx*4],edx
	je d_equ

	jmp d_mov

d_equ:
	;若判断遇到相等数字方块，则进行合并
	imul edx,2
	;
	mov esi,eax
	mov eax,score
	add eax,edx
	mov score,eax
	mov eax,esi
	;

	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedD,edx
	mov edx,exchangeNum

	jmp d_mov
d_fore:
	;向反方向探索，若遇到0则进行移动
	cmp edx,0
	je d_mov
	mov ebx,eax
	inc ebx

	cmp gameMat[ebx*4],0
	je d_zero

	jmp d_merge
d_zero:
	;遇到0后移动方块
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedD,edx
	mov edx,exchangeNum
    
	mov eax,ebx
	inc ebx

	;边界检测
	mov overEdge,ebx
	mov ebx,row
	imul ebx,4
	cmp overEdge,ebx
	je d_merge
	mov ebx,overEdge

	;若前方仍有零，继续进行判断
	cmp gameMat[ebx*4],0
	je d_zero

	jmp d_merge
moveD endp

moveA proc far C uses eax ebx ecx edx esi
	;初始化是否能移动的判断变量
	mov changedA,0
	;初始化循环起点
	mov ecx,4
	mov row,ecx
	mov col,1
a:
	;循环到下一方向4个方块的判断起点进行判断
	mov row,ecx
	mov col,1

	jmp a_trav

a_end:
	loop a

	ret
a_trav:
	;保存比较数
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4]
	mov ebx,eax

	;同一方向的四个位置进行循环判断
	cmp col,1
	je a_merge

	cmp col,2
	je a_fore

	cmp col,3
	je a_fore

	cmp col,4
	je a_fore

	jmp a_trav

a_mov:
	;跳转到下一行4方块的判断
	inc col
	cmp col,5
	jb a_trav

	jmp a_end
a_merge:
	;判断是否为0，若为0则跳过判断
	cmp edx,0
	je a_mov

	inc ebx
	;判断是否跨行比较，若跨行比较则进行下一个同方向的方块的判断
	mov overEdge,eax
	mov eax,row
	imul eax,4
	cmp eax,ebx
	je a_mov
	mov eax,overEdge

	;是否与本位方块进行比较
	cmp eax,ebx
	je a_merge

	;若在合并方向上寻找到0，则继续探索是否有可合并方块
	cmp gameMat[ebx*4],0
	je a_merge

	;若在合并方向上寻找到相同数字方块，则转入合并函数
	cmp gameMat[ebx*4],edx
	je a_equ

	jmp a_mov

a_equ:
	;若判断遇到相等数字方块，则进行合并
	imul edx,2
	;
	mov esi,eax
	mov eax,score
	add eax,edx
	mov score,eax
	mov eax,esi
	;
	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedA,edx
	mov edx,exchangeNum
    
	jmp a_mov

a_fore:
	;向反方向探索，若遇到0则进行移动
	cmp edx,0
	je a_mov
	mov ebx,eax
	dec ebx
	
	cmp gameMat[ebx*4],0
	je a_zero

	jmp a_merge

a_zero:
	;遇到0后移动方块
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

	;对是否能进行移动标志位进行更新
	mov exchangeNum,edx
	mov edx,1
	mov changedA,edx
	mov edx,exchangeNum

	mov eax,ebx
	dec ebx

	;边界检测
	mov overEdge,ebx
	mov ebx,row
	dec ebx
	imul ebx,4
	dec ebx
	cmp overEdge,ebx
	je a_merge
	mov ebx,overEdge

	;若前方仍有零，继续进行判断
	cmp gameMat[ebx*4],0
	je a_zero

	jmp a_merge
moveA endp

moveS proc far C uses eax ebx ecx edx esi
	;初始化是否能移动的判断变量
	mov changedS,0

	;初始化循环起点
	mov ecx,4
	mov row,ecx
	mov col,4


s:
	;循环到下一方向4个方块的判断起点进行判断
	mov col,ecx
	mov row,4

	jmp s_trav

s_end:
	;在同一方向结束循环，走向下一个方向的4个方块的判断
	loop s

	ret
s_trav:
	;保存比较数
	imul eax,row,4
	add eax,col
	sub eax,5
	mov edx,gameMat[eax*4]
	mov ebx,eax

	;同一方向的四个位置进行循环判断
	cmp row,4
	je s_merge

	cmp row,3
	je s_fore

	cmp row,2
	je s_fore

	cmp row,1
	je s_fore

	jmp s_trav
s_mov:
	;跳转到下一列4方块的判断
	dec row
	cmp row,0
	ja s_trav

	jmp s_end

s_merge:
	;判断是否为0，若为0则跳过判断
	cmp edx,0
	je s_mov

	sub ebx,4

	;判断是否跨行比较，若跨行比较则进行下一个同方向的方块的判断
	cmp ebx,400
	jae s_mov
	
	;是否与本位方块进行比较
	cmp eax,ebx
	je s_merge

	;若在合并方向上寻找到0，则继续探索是否有可合并方块
	cmp gameMat[ebx*4],0
	je s_merge

	;若在合并方向上寻找到相同数字方块，则转入合并函数
	cmp gameMat[ebx*4],edx
	je s_equ

	jmp s_mov
s_equ:
	;若判断遇到相等数字方块，则进行合并
	imul edx,2
	;
	mov esi,eax
	mov eax,score
	add eax,edx
	mov score,eax
	mov eax,esi
	;

	mov gameMat[eax*4],edx
	mov gameMat[ebx*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedS,edx
	mov edx,exchangeNum

	jmp s_mov

s_fore:
	;向反方向探索，若遇到0则进行移动
	cmp edx,0
	je s_mov
	mov ebx,eax
	add ebx,4

	cmp gameMat[ebx*4],0
	je s_zero

	jmp s_merge
s_zero:
	;遇到0后移动方块
	mov gameMat[ebx*4],edx
	mov gameMat[eax*4],0

	;对是否能进行移动标志位进行更新
    mov exchangeNum,edx
	mov edx,1
	mov changedS,edx
	mov edx,exchangeNum

	mov eax,ebx
	add ebx,4
	;边界检测
	cmp ebx,16 
	jae s_merge

	;若前方仍有零，继续进行判断
	cmp gameMat[ebx*4],0
	je s_zero
	jmp s_merge

moveS endp

EndCheck proc
    push    ecx
    push    edx
	push score
	mov ecx,16
	mov esi,0
L1:
	push gameMat[esi*4]
	;保存当前游戏局面
	pop tmpGameMat[esi*4]
	inc esi
	loop L1

	;调用向上移动，检测是否可以移动
	invoke moveW

	mov ecx,16
	mov esi,0
	;复原
L2:
	push tmpGameMat[esi*4]
	pop gameMat[esi*4]
	inc esi
	loop L2

	;向左
	invoke moveA
	;同上，复原
	mov ecx,16
	mov esi,0
L3:
	push tmpGameMat[esi*4]
	pop gameMat[esi*4]
	inc esi
	loop L3
	invoke moveS

	;复原
	mov ecx,16
	mov esi,0
L4:
	push tmpGameMat[esi*4]
	pop gameMat[esi*4]
	inc esi
	loop L4
	invoke moveD

	;复原
	mov ecx,16
	mov esi,0
L5:
	push tmpGameMat[esi*4]
	pop gameMat[esi*4]
	inc esi
	loop L5

	;eax清0
	xor eax,eax

	;eax=changeW+changeS+changeA+changeD
    mov eax,changedW
    add eax,changedS
    add eax,changedA
	add eax,changedD

	;若eax不等于0，则表示游戏还可以向某一方向移动，游戏不结束
    cmp eax,0
    jne end_node

	;反之游戏结束
    mov eax,1
    mov gameEndFlag,eax
    
	;还原
end_node:
	pop score
    pop edx
    pop ecx

    ret

EndCheck Endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD ;参数为已得到的应用程序句柄
    LOCAL wc:WNDCLASSEX                                            ; create local variables on stack 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 

    mov   wc.cbSize,SIZEOF WNDCLASSEX                   ; fill values in members of wc 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc ;指针 指向窗口
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc							;注册窗口类
    invoke CreateWindowEx,NULL,\							;建立窗口
                ADDR ClassName,\ 
                ADDR AppName,\ 
                WS_OVERLAPPEDWINDOW,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                800,\ 
                600,\ 
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 
    mov   hwnd,eax 

    invoke ShowWindow, hwnd,SW_SHOWDEFAULT               ;显示窗口
    invoke UpdateWindow, hwnd                                 ;刷新窗口客户区
	invoke UpdataGame,hwnd       ;关键点，已InitGame且已触发WM_PAINT，绘制初始矩阵

	;循环：消息获取和处理
    .WHILE TRUE                                                         ; Enter message loop 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
   .ENDW 
    mov     eax,msg.wParam                                            ; return exit code in eax 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM ;窗口过程
    LOCAL hDc:HDC
	LOCAL hBm
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    .IF uMsg==WM_DESTROY                           ; if the user closes our window 
        invoke PostQuitMessage,NULL             ; quit our application 

    .elseif uMsg==WM_PAINT ;绘制客户区
        invoke BeginPaint,hWnd,ADDR ps

		;加载位图
		invoke GetDC, hWnd ;获取窗口DC，DC即device context，设备上下文/设备内容，用于绘图的数据结构
        mov hDc,eax

		;创建兼容窗口DC的缓存DC
		invoke CreateCompatibleDC,hDc ;兼容性DC，位图1
		mov hdcIDB_BITMAP1,eax
		invoke CreateCompatibleDC,hDc ;兼容性DC，位图2
		mov hdcIDB_BITMAP2,eax
		invoke CreateCompatibleDC,hDc ;兼容性DC，位图19
		mov hdcIDB_BITMAP19,eax

		;创建位图缓存
		invoke CreateCompatibleBitmap, hDc,150,80 ;兼容性位图，位图1
		mov hbmIDB_BITMAP1,eax
		invoke CreateCompatibleBitmap, hDc,90,60 ;兼容性位图，位图2
		mov hbmIDB_BITMAP2,eax
		invoke CreateCompatibleBitmap, hDc,90,60 ;兼容性位图，位图2
		mov hbmIDB_BITMAP19,eax

		;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
		invoke SelectObject,hdcIDB_BITMAP1,hbmIDB_BITMAP1

		;--------------------------开始处理位图1--------------------------
		;载入位图到位图句柄中
		invoke LoadBitmap,hInstance,BITMAP1
		mov hBm,eax

		;创建画刷，图案为该位图
		invoke CreatePatternBrush,hBm
		push eax

		;用该画刷填充缓存DC
		invoke SelectObject,hdcIDB_BITMAP1,eax

		;按照PATCOPY的方式，PATCOPY是将指定的模式拷贝到目标位图中
		;PatBlt使用当前指定设备环境中的画刷eax绘制给定的矩形区域
		invoke PatBlt,hdcIDB_BITMAP1,0,0,150,80,PATCOPY
		pop eax

		;删除画刷
		invoke DeleteObject,eax

		;在主窗口DC上传输绘制缓存DC
		invoke BitBlt,hDc,300,15,150,80,hdcIDB_BITMAP1,0,0,SRCCOPY

		;--------------------------类似处理位图2--------------------------
		invoke LoadBitmap,hInstance,BITMAP2
		mov hBm,eax
		invoke SelectObject,hdcIDB_BITMAP2,hbmIDB_BITMAP2
		invoke CreatePatternBrush,hBm
		push eax
		invoke SelectObject,hdcIDB_BITMAP2,eax
		invoke PatBlt,hdcIDB_BITMAP2,0,0,90,60,PATCOPY
		pop eax
		invoke DeleteObject,eax
		invoke BitBlt,hDc,127,0,90,60,hdcIDB_BITMAP2,0,0,SRCCOPY

		;--------------------------类似处理位图19--------------------------
		invoke LoadBitmap,hInstance,BITMAP19
		mov hBm,eax
		invoke SelectObject,hdcIDB_BITMAP19,hbmIDB_BITMAP19
		invoke CreatePatternBrush,hBm
		push eax
		invoke SelectObject,hdcIDB_BITMAP19,eax
		invoke PatBlt,hdcIDB_BITMAP19,0,0,90,60,PATCOPY
		pop eax
		invoke DeleteObject,eax
		invoke BitBlt,hDc,515,0,90,45,hdcIDB_BITMAP19,0,0,SRCCOPY

		invoke DeleteDC,hdcIDB_BITMAP1 ;删除缓存DC1
		invoke DeleteDC,hdcIDB_BITMAP2 ;删除缓存DC2
		invoke DeleteDC,hdcIDB_BITMAP19 ;删除缓存DC19
		invoke DeleteObject,hbmIDB_BITMAP1 ;删除位图1
		invoke DeleteObject,hbmIDB_BITMAP2 ;删除位图2
		invoke DeleteObject,hbmIDB_BITMAP19 ;删除位图19
		invoke ReleaseDC,hWnd,hDc ;释放DC

        invoke EndPaint,hWnd,ADDR ps
    .elseif uMsg==WM_CHAR
		mov edx,wParam
        		.if edx == 'W' || edx == 'w'
			
			invoke moveW
			
			.IF changedW == 1
				invoke Generator,dat,max
			.endif
			
			INVOKE UpdataGame,hWnd
		
		.elseif edx == 'S' || edx == 's'
			invoke moveS
			
			.IF changedS == 1
				invoke Generator,dat,max
			.endif
			
			INVOKE UpdataGame,hWnd
		
		.elseif edx =='A' || edx == 'a'
			
			invoke moveA
			
			.IF changedA == 1
				invoke Generator,dat,max
			.endif
			
			INVOKE UpdataGame,hWnd
		
		.elseif edx == 'D' || edx == 'd'

			invoke moveD
			
			.IF changedD == 1
				invoke Generator,dat,max
			.endif
			
			INVOKE UpdataGame,hWnd
		.endif

		
		;尝试更新最高分
		mov ebx,esi
		mov eax,score
		.if eax>=historyHigh
			mov historyHigh,eax
			invoke num2byte,eax
			invoke SetWindowText,hGame[100],offset Data

			;新纪录！改变BEST图标
			invoke GetDC,hWnd
			mov hDc,eax
			invoke CreateCompatibleDC,hDc
			mov hdcIDB_BITMAP21,eax
			invoke CreateCompatibleBitmap, hDc,90,60
			mov hbmIDB_BITMAP21,eax
			;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
			invoke SelectObject,hdcIDB_BITMAP21,hbmIDB_BITMAP21
			invoke LoadBitmap,hInstance,BITMAP21
			mov hBm,eax
			invoke CreatePatternBrush,hBm ;创建画刷
			push eax
			invoke SelectObject,hdcIDB_BITMAP21,eax
			invoke PatBlt,hdcIDB_BITMAP21,0,0,90,60,PATCOPY
			pop eax
			invoke DeleteObject,eax ;删除画刷
			invoke BitBlt,hDc,515,0,90,45,hdcIDB_BITMAP21,0,0,SRCCOPY ;传输绘制
			invoke DeleteDC,hdcIDB_BITMAP21 ;删除DC
			invoke DeleteObject,hbmIDB_BITMAP21 ;删除位图
			invoke ReleaseDC,hWnd,hDc
		.endif

		invoke EndCheck
		.if gameEndFlag==1 
			invoke MessageBox,hWindow,offset szEndText,offset szEndTitle,MB_OK
			.if eax == IDOK
				invoke SetNewGame

				;重置BEST图标
				invoke GetDC,hWnd
				mov hDc,eax
				invoke CreateCompatibleDC,hDc
				mov hdcIDB_BITMAP19,eax
				invoke CreateCompatibleBitmap, hDc,90,60
				mov hbmIDB_BITMAP19,eax
				;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
				invoke SelectObject,hdcIDB_BITMAP19,hbmIDB_BITMAP19
				invoke LoadBitmap,hInstance,BITMAP19
				mov hBm,eax
				invoke CreatePatternBrush,hBm ;创建画刷
				push eax
				invoke SelectObject,hdcIDB_BITMAP19,eax
				invoke PatBlt,hdcIDB_BITMAP19,0,0,90,60,PATCOPY
				pop eax
				invoke DeleteObject,eax ;删除画刷
				invoke BitBlt,hDc,515,0,90,45,hdcIDB_BITMAP19,0,0,SRCCOPY ;传输绘制
				invoke DeleteDC,hdcIDB_BITMAP19 ;删除DC
				invoke DeleteObject,hbmIDB_BITMAP19 ;删除位图
				invoke ReleaseDC,hWnd,hDc

				invoke UpdataGame,hWnd
			.endif
		.endif

	.elseif uMsg==WM_COMMAND
		mov ebx,wParam
		.if ebx>=21 && ebx<=24
			invoke MessageBox,hWindow,offset szSlText,offset szSlTitle,MB_ABORTRETRYIGNORE
			.if eax == IDABORT
				invoke sprintf,offset tmpName,offset slotFormat,score
				invoke SetWindowText,hGame[ebx*4],offset tmpName
				add ebx,-21
				invoke saveDataIntoMemory,ebx,offset tmpName
				invoke writeDataFile
			.elseif eax == IDRETRY
				add ebx,-21
				invoke loadData, ebx

				;重置BEST图标
				invoke GetDC,hWnd
				mov hDc,eax
				invoke CreateCompatibleDC,hDc
				mov hdcIDB_BITMAP19,eax
				invoke CreateCompatibleBitmap, hDc,90,60
				mov hbmIDB_BITMAP19,eax
				;将上两步的设备内容句柄[hdc]与位图句柄[hbm]绑定
				invoke SelectObject,hdcIDB_BITMAP19,hbmIDB_BITMAP19
				invoke LoadBitmap,hInstance,BITMAP19
				mov hBm,eax
				invoke CreatePatternBrush,hBm ;创建画刷
				push eax
				invoke SelectObject,hdcIDB_BITMAP19,eax
				invoke PatBlt,hdcIDB_BITMAP19,0,0,90,60,PATCOPY
				pop eax
				invoke DeleteObject,eax ;删除画刷
				invoke BitBlt,hDc,515,0,90,45,hdcIDB_BITMAP19,0,0,SRCCOPY ;传输绘制
				invoke DeleteDC,hdcIDB_BITMAP19 ;删除DC
				invoke DeleteObject,hbmIDB_BITMAP19 ;删除位图
				invoke ReleaseDC,hWnd,hDc

				invoke UpdataGame, hWnd
			.endif
		.endif

    .elseif uMsg==WM_CREATE
		invoke iniData
        invoke InitGame,hWnd
		invoke SetWindowText,hGame[84],offset memoryName[0]
		invoke SetWindowText,hGame[88],offset memoryName[32]
		invoke SetWindowText,hGame[92],offset memoryName[64]
		invoke SetWindowText,hGame[96],offset memoryName[96]

    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; Default message processing 
        ret 
    .ENDIF 

    xor eax,eax 
    ret 
WndProc endp 



start: 
	invoke GetModuleHandle, NULL            ; get the instance handle of our program. 
                                                                       ; Under Win32, hmodule==hinstance mov hInstance,eax 
	mov hInstance,eax 
	invoke SetNewGame
	;invoke GetCommandLine                        ; get the command line. You don't have to call this function IF 
                                                                       ; your program doesn't process the command line. 
	;mov CommandLine,eax 
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT        ; call the main function 
	invoke ExitProcess, eax                           ; quit our program. The exit code is returned in eax from WinMain. 

end start 