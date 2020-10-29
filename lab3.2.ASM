format  PE GUI
entry   start
include 'win32a.inc'

section '.data' data readable writeable

        class db 'FASMWIN32',0
        title db 'Лабораторная работа №3',0
        classb db 'BUTTON',0
        classe db 'EDIT',0
        classs db 'STATIC',0
        textb1 db 'Вычислить',0
        textb2 db 'Очистить',0
        textg db "z = ((a+b)*c-24)/(a*c-1)",13,10,0
        texts db '0',0
        textc db 'Очистить все',0
        errtxt db 'Ошибка',0
        la db 'A',0
        lb db 'B',0
        lc db 'C',0
        lz db 'Z',0
        solve db "%1.5f",0
        par2 db '%1.5f', 13, 10, 0
        tf dq 24.0
        o dq 1.0
        a dq 0
        b dq 0
        c dq 0
        f1 dq 0
        f2 dq 0
        z dq 0
        buffer rb 255
        hwna dd ?
        hwnb dd ?
        hwnc dd ?
        hwnd dd ?
        hwnde dd ?
        hwnds dd ?
        hwndc dd ?
        text rb 100
        ta rb 100
        tb rb 100
        tc rb 100

        wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,class

        msg MSG

section '.code' code readable executable

start:
        invoke GetModuleHandle,0
        mov [wc.hInstance],eax
        invoke LoadIcon,0,IDI_APPLICATION
        mov [wc.hIcon],eax
        invoke LoadCursor,0,IDC_ARROW
        mov [wc.hCursor],eax
        invoke RegisterClass,wc
        cmp eax,0
        je error

        invoke CreateWindowEx,0,class,title,WS_VISIBLE+WS_SYSMENU,128,128,256,210,0,0,[wc.hInstance],0
        cmp eax,0
        je error
        mov [hwnd],eax

msg_loop:
        invoke GetMessage,msg,0,0,0
        cmp eax,0
        je end_loop
        invoke TranslateMessage,msg
        invoke DispatchMessage,msg
        jmp msg_loop

error:
        invoke MessageBox,0,errtxt,0,MB_ICONERROR+MB_OK

end_loop:
        invoke ExitProcess,[msg.wParam]

proc WindowProc hwnd,wmsg,wparam,lparam
        push ebx esi edi
        cmp [wmsg],WM_CREATE
        je .wmcreate
        cmp [wmsg],WM_COMMAND
        je .wmcommand
        cmp [wmsg],WM_DESTROY
        je .wmdestroy

        .defwndproc:
                invoke DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
                jmp .finish

        .wmcreate:
                invoke CreateWindowEx,0,classb,textb1,WS_VISIBLE+WS_CHILD+BS_PUSHBUTTON+WS_TABSTOP,20,130,100,40,[hwnd],1001,[wc.hInstance],0 ;Создает кнопку копировать
                invoke CreateWindowEx,0,classb,textb2,WS_VISIBLE+WS_CHILD+BS_PUSHBUTTON+WS_TABSTOP,130,130,100,40,[hwnd],1002,[wc.hInstance],0 ;Создает кнопку очистить
                invoke CreateWindowEx,0,classe,texts, WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL,30,30,200,20,[hwnd],1003,[wc.hInstance],0 ;Создает область ввода
                mov [hwna],eax ;Сохраняем дескриптор области ввода
                invoke CreateWindowEx,0,classe,texts, WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL,30,50,200,20,[hwnd],1003,[wc.hInstance],0 ;Создает область ввода
                mov [hwnb],eax ;Сохраняем дескриптор области ввода
                invoke CreateWindowEx,0,classe,texts, WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL,30,70,200,20,[hwnd],1003,[wc.hInstance],0 ;Создает область ввода
                mov [hwnc],eax ;Сохраняем дескриптор области ввода
                invoke CreateWindowEx,0,classe,0,WS_VISIBLE+WS_CHILD+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL+ES_READONLY,30,100,200,20,[hwnd],1004,[wc.hInstance],0 ;Создает область вывода
                mov [hwnds],eax ;Сохраняем дескриптор области вывода
                invoke CreateWindowEx,0,classs,textg,WS_VISIBLE+WS_CHILD,10,10,256,20,[hwnd],1006,[wc.hInstance],0 ;Создает надпись
                invoke CreateWindowEx,0,classs,la,WS_VISIBLE+WS_CHILD,10,30,20,20,[hwnd],1006,[wc.hInstance],0 ;Создает надпись A
                invoke CreateWindowEx,0,classs,lb,WS_VISIBLE+WS_CHILD,10,50,20,20,[hwnd],1006,[wc.hInstance],0 ;Создает надпись B
                invoke CreateWindowEx,0,classs,lc,WS_VISIBLE+WS_CHILD,10,70,20,20,[hwnd],1006,[wc.hInstance],0 ;Создает надпись C
                invoke CreateWindowEx,0,classs,lz,WS_VISIBLE+WS_CHILD,10,100,20,20,[hwnd],1006,[wc.hInstance],0 ;Создает надпись Z
                invoke SetFocus,[hwna] ;Фокус на области ввода
                jmp .finish

        .wmcommand:
                cmp [wparam],1001
                je .findsolve
                cmp [wparam],1002
                je .clear
                jmp .finish

        .findsolve:
                invoke SendMessage,[hwna],WM_GETTEXT,100,ta
                invoke SendMessage,[hwnb],WM_GETTEXT,100,tb
                invoke SendMessage,[hwnc],WM_GETTEXT,100,tc

                finit
                cinvoke atof, ta
                fstp qword [a]
                cinvoke atof, tb
                fstp qword [b]
                cinvoke atof, tc
                fstp qword [c]

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

                invoke SendMessage,[hwnds],WM_SETTEXT,0,buffer
                jmp .finish

        .clear:
                invoke SendMessage,[hwnds],WM_SETTEXT,0,0
                invoke SendMessage,[hwndc],BM_GETCHECK,0,0
                cmp eax,BST_CHECKED
                jne .finish
                invoke SendMessage,[hwna],WM_SETTEXT,0,0
                invoke SendMessage,[hwndc],BM_SETCHECK,BST_UNCHECKED,0
                jmp .finish

        .wmdestroy:
                invoke PostQuitMessage,0
                mov eax,0

        .finish:
                pop edi esi ebx
                ret
endp

section '.idata' import data readable writeable

        library kernel32,'KERNEL32.DLL',\
                user32,'USER32.DLL',\
                msvcrt,'msvcrt.dll'
        import  msvcrt,\
                sprintf,    'sprintf',\
                atof, 'atof'
        include 'api\kernel32.inc'
        include 'api\user32.inc'
