EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF asteroid_000:EECS205BITMAP
EXTERNDEF rick:EECS205BITMAP
EXTERNDEF rick_up:EECS205BITMAP
EXTERNDEF rick_left:EECS205BITMAP
EXTERNDEF rick_right:EECS205BITMAP
EXTERNDEF morty:EECS205BITMAP
EXTERNDEF morty_right:EECS205BITMAP
EXTERNDEF morty_left:EECS205BITMAP
EXTERNDEF neutrino_bomb:EECS205BITMAP
EXTERNDEF background_1:EECS205BITMAP
EXTERNDEF ground:EECS205BITMAP
EXTERNDEF laser:EECS205BITMAP

DrawMortys PROTO 
CheckAlive PROTO startAddr: DWORD, offset_:DWORD
CheckKeyPress PROTO
DrawRick PROTO
DrawPlatforms PROTO
UpdateSpritePosition PROTO sprite:DWORD
UpdateMortyData PROTO startAddr: DWORD, offset_:DWORD
CheckOnGround PROTO sprite:DWORD
CheckAirborne PROTO sprite:DWORD
InitLaser PROTO 
DrawProjectiles PROTO
UpdateProjectilePosition PROTO index_:DWORD
KillSprite PROTO sprite:DWORD
CheckHit PROTO startAddr: DWORD, offset_:DWORD
UpdateProjectileData PROTO index_:DWORD
CreateNewLaser PROTO
CheckMortyHit PROTO index_:DWORD
UpdateProjectileStatus PROTO index_:DWORD
UpdateMortyPosition PROTO sprite:DWORD
DrawScore PROTO
CheckRickHit PROTO
UpdateRickData PROTO
InitMortys PROTO
CheckOnPlatform PROTO sprite:DWORD