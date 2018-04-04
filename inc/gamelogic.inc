CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP 

CheckUpKeyPress PROTO
CheckDownKeyPress PROTO
CheckRightKeyPress PROTO
CheckLeftKeyPress PROTO
CheckSpacePress PROTO
CheckMousePress PROTO

MoveRight PROTO sprite:DWORD
MoveLeft PROTO sprite:DWORD
MoveUp PROTO sprite:DWORD
MoveDown PROTO sprite:DWORD
Jump PROTO sprite:DWORD

ClearScreen PROTO
ClearScreenBG PROTO

CalculateBoundaries PROTO x:DWORD, y:DWORD, bitmap:PTR EECS205BITMAP, rectangle:PTR RECTANGLE
CalculateHorizontalDistance PROTO oneX:DWORD, twoX:DWORD
CalculateVerticalDistance PROTO oneY:DWORD, twoY:DWORD

