using Printf

function generateCordicAngles(NSTAGES, PhaseWidth, verbose::Bool=false)
    verbose ? println("\nGenerating Cordic LUT...") : 0;
    x = zeros(NSTAGES-1)
    x_norm = zeros(UInt16,NSTAGES-1)
    for k = 1:(NSTAGES-1)
        x[k] = atan(1,2^(k))
        x_norm[k] =  trunc(UInt16,x[k]/(2*π) * ((2^16)))
        verbose ? @printf("% 3d | % -12.7f % -7d 0x%-x\n", k, x[k]*(180/pi), x_norm[k],x_norm[k]) : 0;
    end
    return x_norm
end

function calculateCordicGain(NSTAGES, PhaseWidth, verbose::Bool=false)
    verbose ? println("\nCalculating Cordic Gain...") : 0;
    gain = 1.0
    for k = 1:(NSTAGES-1)
        dgain = sqrt(1+1/2^(2*k))
        gain = gain*dgain
    end
    verbose ? @printf("scalar gain,\tinvgain scaled\t(hex)\n") : 0;
    verbose ? @printf("%.5f,\t%d,\t\t(0x%x)\n\n", gain,trunc(2^(PhaseWidth)/gain),trunc(2^(PhaseWidth)/gain)) : 0;
    return gain
end