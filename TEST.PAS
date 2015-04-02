(*$G+,N+*)
(*$E-*) (* ohne XXX87-EMU *)
uses crt,dos;

const
  frequenz:double=1193180/$10000;
var
  dos_stunde,dos_minute,dos_sekunde,dos_hundertstel:word;
  bios_stunde,bios_minute,bios_sekunde:byte;
  cmos_stunde,cmos_minute,cmos_sekunde:byte;
  seg40_stunde,seg40_minute,seg40_sekunde,seg40_hundertstel:byte;
  seg40_wert:longint absolute $0040:$006c;
  seg40_wert_kopie:double;

function bcd(b:byte):byte;assembler;
  asm
    mov si,ax
    mov al,ss:[b]
    mov ah,0
    shl ax,4
    shr al,4
    aad 10
  end;

function cmos(i:byte):byte;
  begin
    port[$70]:=i;
    cmos:=port[$71];
  end;

begin
  repeat
    gettime(dos_stunde,dos_minute,dos_sekunde,dos_hundertstel);
    asm
      mov ah,$02
      int $1a
      mov bios_stunde,ch
      mov bios_minute,cl
      mov bios_sekunde,dh
    end;

    cmos_stunde :=cmos(4);
    cmos_minute :=cmos(2);
    cmos_sekunde:=cmos(0);

    seg40_wert_kopie :=seg40_wert/frequenz;

    seg40_stunde     :=round(trunc(seg40_wert_kopie/60/60));
    seg40_wert_kopie :=seg40_wert_kopie-60*60*(seg40_stunde +0.0);

    seg40_minute     :=round(trunc(seg40_wert_kopie/60));
    seg40_wert_kopie :=seg40_wert_kopie-60*   (seg40_minute +0.0);

    seg40_sekunde    :=round(trunc(seg40_wert_kopie));
    seg40_wert_kopie :=seg40_wert_kopie-      (seg40_sekunde+0.0);

    seg40_hundertstel:=round(trunc(seg40_wert_kopie*100));
    (* sehr ungenau .... da frequenz nur 6 zuverl„ssige Ziffern hat *)


    writeln('DOS  =',dos_stunde      :2,'.',dos_minute      :2,'.',dos_sekunde      :2,',',dos_hundertstel  :2,'  ',
            'SEG40÷',seg40_stunde    :2,'.',seg40_minute    :2,'.',seg40_sekunde    :2,',',seg40_hundertstel:2,'  ',
            'BIOS =',bcd(bios_stunde):2,'.',bcd(bios_minute):2,'.',bcd(bios_sekunde):2,',',  '??'             ,'  ',
            'CMOS =',bcd(cmos_stunde):2,'.',bcd(cmos_minute):2,'.',bcd(cmos_sekunde):2,',',  '??'             ,'  ');
  until keypressed;
end.
