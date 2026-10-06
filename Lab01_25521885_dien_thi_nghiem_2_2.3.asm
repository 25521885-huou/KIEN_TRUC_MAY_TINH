# ===================================================================
# CHÚ THÍCH VAI TRÒ CÁC THANH GHI $s*:
# $s0: Lưu số kWh tiêu thụ do người dùng nhập (x)
# $s1: Lưu tổng tiền điện tính được (sum)
# $s2: Lưu chỉ số bậc hiện tại (i: 0 -> 5)
# $s3: Lưu số kWh còn lại chưa tính tiền (rem_kwh)
# ===================================================================

.data
    # Đơn giá 6 bậc với a = 5 (Đơn giá gốc + 20*5 = +100)
    gia_bac:    .word 1700, 1760, 2050, 2600, 2950, 3100
    
    # Dung lượng kWh tối đa của từng bậc
    km_bac:     .word 50, 50, 100, 100, 100, 0x7FFFFFFF
    
    # Các chuỗi thông báo theo đúng quy định đặc tả
    prompt:     .asciiz "Nhap so kwh (0..9999) : "
    err_msg:    .asciiz "Gia tri khong hop le, nhap lai.\n"
    res_msg:    .asciiz "Tien dien: "
    unit_msg:   .asciiz " dong\n"

.text
main:
input_loop:
    # 1. Nhập số kWh tiêu thụ
    li $v0, 4
    la $a0, prompt
    syscall
    
    li $v0, 5
    syscall
    move $s0, $v0               # $s0 = x

    # 2. Kiểm tra miền giá trị (0 <= x <= 9999) bằng đúng 1 lệnh so sánh & 1 lệnh nhánh
    sltiu $t0, $s0, 10000
    bne $t0, $zero, valid_input # Nếu hợp lệ (0 <= x <= 9999) -> Chuyển sang tính tiền

    # Nhập không hợp lệ -> In thông báo lỗi và lặp lại bước nhập
    li $v0, 4
    la $a0, err_msg
    syscall
    j input_loop

valid_input:
    # 3. Khởi tạo biến tính tiền điện
    li $s1, 0                   # $s1 = sum = 0
    li $s2, 0                   # $s2 = i = 0
    move $s3, $s0               # $s3 = rem_kwh = x

loop_bac:
    beq $s3, $zero, print_result
    bge $s2, 6, print_result
    
    sll $t0, $s2, 2             # offset = i * 4
    lw $t1, gia_bac($t0)        # $t1 = gia[i]
    lw $t2, km_bac($t0)         # $t2 = dinhmuc[i]
    
    ble $s3, $t2, calc_last_step
    
    # Trường hợp rem_kwh > dinhmuc[i]
    mul $t3, $t1, $t2
    add $s1, $s1, $t3
    sub $s3, $s3, $t2
    addi $s2, $s2, 1
    j loop_bac

calc_last_step:
    # Nấc cuối cùng (rem_kwh <= dinhmuc[i])
    mul $t3, $t1, $s3
    add $s1, $s1, $t3

print_result:
    # In đúng khuôn: Tien dien: <so tien> dong
    li $v0, 4
    la $a0, res_msg
    syscall
    
    li $v0, 1
    move $a0, $s1
    syscall
    
    li $v0, 4
    la $a0, unit_msg
    syscall

end_program:
    li $v0, 10
    syscall