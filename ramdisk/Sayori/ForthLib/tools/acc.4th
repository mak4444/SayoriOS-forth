CR .(   ACCEPT_CO LOAD )

\- BLANK	: BLANK  ( addr len -- )		BL FILL ;
\- BOUNDS	: BOUNDS ( addr len -- addr+len addr )	OVER + SWAP ;
\- U>= : U>= U< INVERT ;
\- U<= : U<= U> INVERT ;
\- VIEW-SIZE 0x40000 CONSTANT VIEW-SIZE
\- VSHRIFT@ 14 CONSTANT VSHRIFT@
\- TRUE  -1 CONSTANT TRUE

\- CLIPBOARD  VIEW-SIZE CELL+ ALLOCATE THROW VALUE CLIPBOARD
\- COLS 80 VALUE COLS
\- ROWS 38 VALUE ROWS

\- SHIFT+	: SHIFT+ $100 OR ;
\- CTL+		: CTL+   $200 OR ;
\- ALT+		: ALT+   $400 OR ;


[IFNDEF] LPLACE
: LPLACE         ( addr len dest -- )
	2DUP 2>R
	CELL+ SWAP MOVE
	2R> ! ;
[THEN]

[IFNDEF] H.R
: H.R           ( n1 n2 -- )    \ display n1 as a hex number right
                                \ justified in a field of n2 characters
                BASE @ >R HEX >R
                0 <# #S #> R> OVER - 0 MAX SPACES TYPE
                R> BASE ! ;
[THEN]

\- LCOUNT : LCOUNT   CELL+ DUP CELL- @ ; 
\- CLIPBOARD! : CLIPBOARD! ( adr len -- )	CLIPBOARD LPLACE ;
\- CLIPBOARD@ : CLIPBOARD@ ( -- adr len )	CLIPBOARD LCOUNT ;
\- CLIPBOARD# : CLIPBOARD# ( -- len )		CLIPBOARD @ ;
\- CLIPBOARD? : CLIPBOARD? ( -- len )		CLIPBOARD @ ;

[IFNDEF] STATUS.

0 VALUE  STSYV

\- SETY : SETY ( y -- )  GETXY DROP SWAP SETXY ;
\- SETX : SETX ( x -- )  GETXY NIP SETXY ;
\- GETY : GETY ( -- y )  GETXY NIP ;
\- GETX : GETX ( -- x )  GETXY DROP ;
\- SP0 : SP0 S0 ;
\- ID_SHIFT@ 0 VALUE ID_SHIFT@

: STS.
 COLOR@
\ CCOUT{ CR ." STS.CL@=" DUP H. }CCOUT
 >R 
 GETXY 2>R
 $3F COLOR! 
 STSYV  SETY
  DEPTH IF
    SP@ 
 BEGIN CR COLS 1- 8 -  SETX
	GETY  ROWS  4 -  U>
	IF  ."     ..." -1
	ELSE	DUP @  8 H.R CELL+  
		DUP  SP0 @  U>=
	THEN
 UNTIL DROP
 ELSE   CR COLS 1- $B -  SETX ." steck empty"
 THEN
 2R> SETXY
 R>
\ CCOUT{ ." STS.CL!=" DUP H. }CCOUT
 COLOR!
;

: STATUS.
 COLOR@
\ CCOUT{ CR ." STATUS@=" DUP H. }CCOUT
 >R
 $2F COLOR!
\   GET-ORDER ." Context: "
\  0 ?DO ( DUP .) VOC-NAME. SPACE LOOP
  ." Current: " GET-CURRENT VOC-NAME.
  ."  B=" BASE @ DECIMAL DUP . BASE !
 DEPTH IF  $4F COLOR! THEN
  ."  DEPTH="  DEPTH .
 $2F COLOR!

    SP@ 
 BEGIN
	DUP  SP0 @  U< DUP
	IF	COLS  $D - GETX  U> 0=
	   IF  ." ..."  DROP 0 THEN
	THEN
 WHILE
	DUP @ H. ( 8 H.R ) CELL+  
 REPEAT DROP

\+ DUTYFILENAME CR  DUTYFILENAME COUNT  $50 UMIN TYPE
 GETY TO  STSYV

 R>
\ CCOUT{  ." STATUS!=" DUP H. }CCOUT

 COLOR!
;
[THEN]

\ ROMENDBIG

: ACC_INSERT ( ADDR ADDR1 -- ADDR ADDR1 )
  2DUP U> 0= IF BREAK
   GETXY 2>R
  2DUP - >R DUP DUP 1+ R@ MOVE
   DUP R>  TYPE  1 EMIT
  2R> SETXY
;

: ACC_DELETE ( ADDR ADDR1 -- ADDR ADDR1 )
  2DUP U> 0= IF BREAK
   GETXY 2>R
  2DUP - >R DUP 1+ OVER R@ MOVE
   DUP R>
\   GETXY 2>R
\ 1 1 SETXY DUP . 2DUP TYPE ." $"
\  2R> SETXY
 TYPE 2 EMIT 3 EMIT
  2R> SETXY
;

: ACC_EMIT (  SA EA  addr c --  SA EA  addr+1 ) 
  >R
  ACC_INSERT   
  R@ EMIT 
  R> OVER C! 1+ ;

: ACC_LEFT (  SA EA A --  SA EA A' )
 >R OVER R>  TUCK U<
 IF 1- GETXY SWAP 1- SWAP SETXY THEN ;

: ACC_HOME (  SA EA A --  SA EA SA )
  SWAP >R
  OVER -  >R
    GETXY SWAP R> - SWAP SETXY    \  0 ?DO 8 EMIT LOOP
  R> OVER
;

: ACC_TYPE (  SA EA A  addr len -- SA EA A1 )
  BOUNDS  DO I C@  ACC_EMIT LOOP ;

: ACC_END  (  SA EA A --  SA EA A' )
  >R
  DUP >R   \ SA EA
  BEGIN 1- 2DUP U<= IF DUP C@ BL <> 
		ELSE TRUE
		THEN
  UNTIL 1+
  R> SWAP \  SA EA A'
  DUP R> -
  GETXY -ROT + SWAP SETXY
;

[IFNDEF] LAST_STP_PULL
1 5 LSHIFT CONSTANT ACC_NUM
\ CREATE	LAST_STP_PULL 0x101 ACC_NUM * ALLOT
VARIABLE LAST_STP_PULL 0x101 ACC_NUM * ALLOT
	 LAST_STP_PULL 0x101 ACC_NUM * ERASE
[THEN]

VARIABLE COUNT_STP 

: LAST_STP ( -- addr )
 LAST_STP_PULL COUNT_STP @ ACC_NUM 1- AND 0x101 * + ;

: GET_LAST_STP  (  SA EA A --  SA  EA` A` )
 ACC_HOME 
 2DUP - BLANK \
 >R
 LAST_STP COUNT COLS 1- 1- UMIN 2DUP TYPE
 >R OVER R> R@ UMIN CMOVE R> \ DROP DUP
 OVER  LAST_STP C@ +
  ACC_INSERT
;

: DO1B
  CASE
	EXKEY_LEFT	OF ACC_LEFT  ENDOF
	EXKEY_RIGHT	OF  GETXY SWAP 1+ SWAP SETXY 1+ ENDOF
	EXKEY_UP		OF -1 COUNT_STP +! GET_LAST_STP    ENDOF
	EXKEY_DOWN	OF  1 COUNT_STP +! GET_LAST_STP    ENDOF
	EXKEY_HOME	OF ACC_HOME
\  KEY? 0=	IF BREAK
\			KEY DUP [CHAR] ~ <> IF ACC_EMIT BREAK DROP
		 ENDOF
	EXKEY_DELETE	OF ACC_DELETE  ENDOF
	EXKEY_END	OF ACC_END	 ENDOF
	EXKEY_F1		OF S" HELP" EVALUATE ENDOF
	$92 OF          \  CTRL INS
[IFDEF] CLIPBOARD!
 2 PICK \ SA EA A SA
 2DUP - \ SA EA A SA A-SA 
 CLIPBOARD!
[THEN]
  ENDOF
[IFDEF] ID_SHIFT@
	EXKEY_INSERT OF  \ imsert 
	ID_SHIFT@
	IF CLIPBOARD? IF CLIPBOARD@ ( 80 UMIN ) ACC_TYPE THEN
	ELSE	\ CURSOR% @ 5 U< VSHRIFT@ AND 3 OR CURSOR% ! 
	THEN

	ENDOF
[THEN]
\+ EVALUATE	'E' CTL+  OF >R 2>R S" REE" EVALUATE		2R> R> ENDOF \ Ctl F4
\   0xE0 ACC_EMIT ACC_EMIT 0
 ENDCASE ;

: ACCEPTG2_ ( c-ar +n1 -- c-addr EA A )
\   GETXY NIP COLS 1- - NEGATE UMIN
	COLS 1- 1- UMIN
   2DUP BLANK
   OVER + 1- OVER      \ SA EA A
   BEGIN
\ CURSOR
	 KEY          \ SA EA A C
\ ." {"  DUP H. ." }"
     DUP 0xA = OVER 0xD = OR 0= 
   WHILE
        CASE
	DUP $FF ANDC	IF DO1B   ENDOF
	8	OF ACC_LEFT ACC_DELETE ENDOF
\+ STS.	$13	OF 2>R >R STS. R> 2R> ENDOF
	$1B	OF 2DROP DUP DUP EXIT ENDOF
\+ EVALUATE	'O' CTL+ OF  S" NC" EVALUATE ENDOF \ Ctr-O
               ACC_EMIT
              0 ENDCASE  OVER UMIN \ SA EA A
   REPEAT                         \ SA EA A C
   DROP
;

: ACCEPTG2 ( c-addr +n1 -- +n2 ) \ 94
  ACCEPTG2_
  ACC_END NIP
  OVER - DUP IF 2DUP  LAST_STP $!  1 COUNT_STP +! THEN
  NIP CR
;

: ACCEPT_CO ( c-addr +n1 -- +n2 ) \ 94

 2>R
 GETXY 2>R
 0 0 SETXY $50  SPACES  $50  SPACES
 0 0 SETXY
  STATUS.
 2R> SETXY
 2R> 

  ACCEPTG2
;

\- KEYBOARD_ECHO  #define KEYBOARD_ECHO 1

: CO \ TOGGG
  0 KEYBOARD_ECHO KEYBCTL
 ['] ACCEPT_CO TO ACCEPT ;

: LASTSTP: 0 PARSE
  2DUP + 1- C@ BL U<= IF 1- THEN 
  2DUP + 1- C@ BL U<= IF 1- THEN 
 LAST_STP $!  1 COUNT_STP +! ;

\ ' ACCEPT2 TO ACCEPT

\ S"  BL PARSE <<<<NOR_MEMORY_ADRESS1>>>>  NOR_MEMORY_ADRESS1 RAM2NOR"  LAST_STP $!  1 COUNT_STP +!

S" BANK_REST"  LAST_STP $!  1 COUNT_STP +!


