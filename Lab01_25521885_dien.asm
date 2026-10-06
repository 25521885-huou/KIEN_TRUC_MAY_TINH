.data
ChuoiHello:  .asciiz "Xin chao MARS"

.text
li $v0,4 
la $a0, ChuoiHello # ChuoiHello la nhan dai dien cho dia chi
syscall 
