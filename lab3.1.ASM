format  PE GUI
entry   start
include 'win32a.inc'

section '.data' data readable writeable

        equation db "z = ((a+b)*c-24)/(a*c-1)",13,10,"a = 20, b = 30, c = 40",13,10,"Вычислить?",13,10,0
        title db "Лабораторная работа №3",0
        solve db "z = %1.5f",0
        par2 db '%1.5f', 13, 10, 0
        tf dq 24.0
        o dq 1.0
        a dq 20.0
        b dq 30.0
        c dq 40.0
        f1 dq 0
        f2 dq 0
        z dq 0
        buffer rb 255

section '.code' code readable executable
start:
        invoke  MessageBox,NULL,equation,title,MB_YESNO
        cmp eax,6
        je findsolve
        cmp eax,7
        je close

findsolve:
        finit
        fld [a]
        fld [b]
        faddp
        fld [c]
        fmulp
        fld [tf]
        fsubp
        fstp qword [f1]

        finit
        fld [a]
        fld [c]
        fmulp
        fld [o]
        fsubp
        fstp qword [f2]

        finit
        fld [f1]
        fld [f2]
        fdivp

        fstp qword [z]
        invoke sprintf,buffer,solve,dword[z],dword[z + 4]
        invoke MessageBox,NULL,buffer,title,MB_OK

close:
        invoke  ExitProcess,0

section '.idata' import data readable writeable

        library kernel32,   'kernel32.dll',\
                user32,     'user32.dll',\
                msvcrt,     'msvcrt.dll'
        import  kernel32,\
                ExitProcess,'ExitProcess'
        import  user32,\
                MessageBox, 'MessageBoxA'
        import  msvcrt,\
                sprintf,    'sprintf'

