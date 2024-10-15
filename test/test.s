main:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      zero,-20(s0)
        j       .L2
.L4:
        lw      a4,-20(s0)
        addi    a5,s0,-32
        slli    a4,a4,2
        add     a5,a4,a5
        lw      a4,0(a5)
        lw      a3,-20(s0)
        addi    a5,s0,-44
        slli    a3,a3,2
        add     a5,a3,a5
        lw      a5,0(a5)
        ble     a4,a5,.L3
        lw      a4,-20(s0)
        addi    a5,s0,-32
        slli    a4,a4,2
        add     a5,a4,a5
        lw      a4,0(a5)
        lw      a3,-20(s0)
        addi    a5,s0,-44
        slli    a3,a3,2
        add     a5,a3,a5
        sw      a4,0(a5)
.L3:
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        li      a5,65536
        blt     a4,a5,.L4
        li      a5,0
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra