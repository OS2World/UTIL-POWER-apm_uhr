
var
  zaehler:word;
begin
  for zaehler:=1 to 65535 do
    asm
      mov ah,$2c
      {mov ah,$30}
      int $21
    end;
end.