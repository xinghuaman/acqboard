*SPICE lpf_mfb_bias.trans.sp trans analysis of MFB lpf with 2.5V bias to 
* turn a +/- 2.5V signal into a 0-5 v signal and LPF with a single op-amp


.tran 10ms 1s 0s 1ms


vin 1 0 sin (0V 2.5V 10Hz)
vb 5 0 1.25
R1 1 2 15.5k
C2 2 0 0.047u
R2 2 4 15.5k
R3 2 3 3.48k
C1 3 4 0.01u
eopamp 4 0 opamp 5 3 

.options post

.end