DEFINES         ;{
#define         BUFSIZE         0x20
                IF  (BUFSIZE&(BUFSIZE-1))
                    ERROR "BUFSIZE MUST BE A POWER OF 2"
                ENDIF
#define         MSGBUFSIZE      0x10
                IF  (MSGBUFSIZE&(MSGBUFSIZE-1))
                    ERROR "MSGBUFSIZE MUST BE A POWER OF 2"
                ENDIF

; caulculates baudrate when BRGH = 1, adjust for rounding errors (XTAL_FREQ / (16 * BaudRate)) - 0.5
#define         CALC_HIGH_BAUD(BaudRate)    (XTAL_FREQ + .8 * BaudRate) / (.16 * BaudRate) - .1;

		; caulculates timer1 delay when prescale is 1:4, postscale is 1:4
;#define         CALC_TIMER(TickTime)    (0xFFFF - ((TickTime * XTAL_FREQ) / .32000)) + .1
#define		CALC_TIMER(TickTime)	(XTAL_FREQ / .64 / TickTime) - .1

#define         prescale_Mode   0
#define         output          1
#define         input           2
#define         devID1          3
#define         delay           4
#define         devID2          5

#define         BYTE0       0
#define         BYTE1       1
#define         BYTE2       2
#define         BYTE3       3
#define         BYTE4       4
#define         STATE       5

; modes for parameter eeprom
; mode 0 - 1 exit
; mode 1 - 4 passthrough
; mode 2 - 2 always off
; mode 3 - 2 always on
; mode 4 - 4 toggle light
; mode 5 - 4 light toogle dual outputs
; mode 6 - 5 two stage light (output1: 1st stage output1+2 2nd stage)
; mode 7 - 1 nop
; mode 8 - 5 retriggerable timer
; mode 9 - 5 blinker
; mode a - 1 nop
; mode b - 1 nop
; mode c - 1 nop
; mode d - 6 awning (output1: on/off output2: open/close)
; mode e - 6 blind (output1: on/off output2: up/down
; mode f - 6 window (output1: up output2: down)

; prescale+mode | output | input | device1 | delay(opt) | device2


;*******************************************************************************
; message format: 3 bytes (except time and config answer messages)
                         ;+-------+
                         ;| byte0 |
#define STARTBYTE   0x00 ;| 0x00  |
                         ;+-------+-------+-------+-------+------+
                         ;| byte1 | byte2 | byte3 | byte4 | done |
#define CMDOFF      0x01 ;| 0x01  | ID    |       |       |  ok  | power off all outputs on device
                         ;| 0x01  | 0xFF  |       |       |  ok  | power off global
#define CMDRESET    0x02 ;| 0x02  | ID    |       |       |  ok  | reset device ID
                         ;| 0x02  | 0xFF  |       |       |  ok  | reset devices global
#define CMDACK      0x03 ;| 0x03  | ID    |       |       |  ok  | ACK
#define CMDID       0x04 ;| 0x04  | ID    |       |       |  ok  | poll for existence device ID

#define CMDOWR      0x05 ;| 0x05  | ID    | lbyte | hbyte |  ok  | write outputs on device ID
#define CMDIRD      0x06 ;| 0x06  | ID    |       |       |  ok  | read inputs on device ID
#define CMDORD      0x07 ;| 0x07  | ID    |       |       |  ok  | read outputs on device ID
#define CMDIOANS    0x08 ;| 0x08  | ID    | lbyte | hbyte |  ok  | 2 bytes read inputs answer

#define CMDTSET     0x09 ;| 0x09  | ID    |       |       |  ok  | write time of device ID
                         ;| 0x09  | 0xFF  |       |       |  ok  | write time global
#define CMDTGET     0x0A ;| 0x0A  | ID    |       |       |  ok  | read time of device ID
#define CMDTGACK    0x0B ;| 0x0B  | ID    |       |       |  ok  | 5 bytes read time answer

#define CMDCGET     0x0C ;| 0x0C  | ID    |       |       |  ok  | read configuration of device ID
#define CMDCGACK    0x0D ;| 0x0D  | ID    |       |       |  ok  | 255 bytes read configuration answer
#define CMDCSET     0x0E ;| 0x0E  | ID    |       |       |  ok  | 256 bytes write configuration of device ID
#define CMDNEEDCFG  0x0F ;| 0x0F  | 0xFF  |       |       |      | need config (after pressing key)

#define CMDPEDGE    0x10 ;| 0x1Y  | ID    |       |       |  ok  | positive edge on input Y on device ID

#define CMDNEDGE    0x20 ;| 0x2Y  | ID    |       |       |  ok  | negative edge on input Y on device ID

#define CMDSOFF     0x40 ;| 0x4Y  | ID    |       |       |  ok  | blinds up/windows close/lights off output Y on device ID
#define CMDGOFF     0x50 ;| 0x5G  | GG    |       |       | XXXX | blinds up/windows close/lights off group GGG
#define CMDAOFF     0x5F ;| 0x5F  | 0x01  |       |       |  ok  | lights off global (byte2 is bitmask)
                         ;| 0x5F  | 0x02  |       |       |  ok  | blinds up global (byte2 is bitmask)
                         ;| 0x4F  | 0x04  |       |       |  ok  | windows close global (byte2 is bitmask)
                         ;| 0x5F  | 0x08  |       |       |  ok  | awning close global (byte2 is bitmask)

#define CMDSON      0x60 ;| 0x6Y  | ID    |       |       |  ok  | blinds down/windows open/lights on output Y on device ID
#define CMDGON      0x70 ;| 0x7G  | GG    |       |       | XXXX | blinds down/windows open/lights on group GGG
#define CMDAON      0x7F ;| 0x7F  | 0x01  |       |       |  ok  | lights on global (byte2 is bitmask)
                         ;| 0x7F  | 0x02  |       |       |  ok  | blinds down global (byte2 is bitmask)
                         ;| 0x7F  | 0x04  |       |       |  ok  | windows open global (byte2 is bitmask)
                         ;| 0x7F  | 0x08  |       |       |  ok  | awning open global (byte2 is bitmask)

#define CMDOC       0x80 ;| 0x8Y  | ID    |       |       |  ok  | clear output Y on device ID
#define CMDOS       0x90 ;| 0x9Y  | ID    |       |       |  ok  | set output Y on device ID
#define CMDO        0xA0 ;| 0xAY  | ID    |       |       |  ok  | read output Y on device ID
#define CMDI        0xB0 ;| 0xBY  | ID    |       |       |  ok  | read input Y on device ID

                         ; TODO ### blind down inhibit (single)
                         ; TODO ### window open inhibit (single)
;}
