pragma circom 2.1.6;

template first_concrete_u128() {
    signal input in[8];
    signal output out[8];

}

template mds_multiply_freq() {
    signal input in[8];


}

template fft4_real() {
    signal input in[4];
    signal output out[];
}

template fft2_real() {
    signal input in[2];
    signal output out[2];

    // [(x[0] as i64 + x[1] as i64), (x[0] as i64 - x[1] as i64)]
}

template block1() {
    signal input x[2];
    signal input y[2];
    signal output out[2];
}

template block2() {
    signal input x[4];
    signal input y[4];
    signal output out[4];
}

template block3() {
    signal input x[2];
    signal input y[2];
    signal output out[2];
}

template ifft4_real_unreduced() {
    signal input y[4];
    signal input out[4];
}

template ifft2_real_unreduced() {
    signal input y[2];
    signal output out[2];
}

template bars_u128() {
    signal input in[8];
    signal input out[8];

}

template bricks_u128() {
    signal input in[8];
    signal input out[8];
}

template bar_u64() {
    signal input limb;
    signal output out;
}

template concrete_u128() {
    signal input state_u128[8];
    signal input round_constants[8];
    signal input out[8];
}

template mds_multiply_with_rc_u128() {
    signal input state[8];
    signal input round_constants[8];
}

function instantiate_rc() {
    var ROUND_CONSTANTS[6][8] = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0]
    ];
    return ROUND_CONSTANTS;
}

template Monolith() {
    signal input in[8];
    signal output out[8];
    
    signal after_fc_state[8];
    signal rc_state[19][8]; // 3 * 6 + 1

    component fc_u128 = first_concrete_u128();
    fc_u128.in <== state;
    after_fc_state <== fc_u128.out;

    rc_state[0] <== after_fc_state;

    var rcs = instantiate_rc();
    for(var i = 0; i < 6; i++) {
        component brs_u128 = bars_u128();
        brs_u128.in <== rc_state[i * 3];
        rc_state[i * 3 + 1] <== brs_u128.out;

        component brks_u128 = bricks_u128();
        brks_u128.in <== rc_state[i * 3 + 1];
        rc_state[i * 3 + 2] <== brks_u128.out;

        component crt_u128 = concrete_u128();
        crt_u128.state_u128 <== rc_state[i * 3 + 2];
        crt_u128.round_constants <== rcs[i];
        rc_state[i * 3 + 3] <== crt_u128.out;
    }

    signal bs_state[8];
    component brs_u128 = bars_u128();
    brs_u128.in <== rc_state[18];
    bs_state <== brs_u128.out;

    signal brks_state[8];
    component brks = bricks_u128();
    brks.in <== bs_state;
    brks.out ==> brks_state;

    signal fst_state[8];
    component fst_c = first_concrete_u128();
    fst_c.in <== brks_state;
    fst_state <== fst_c.out;
}

component main = Monolith();
