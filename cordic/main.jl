include("cordic.jl")


generateCordicAngles(12,16,false)
g=calculateCordicGain(12,16,false)

for j = 0:8
    ( x, y,  p) = cordic( 12, Int16((2^15)-1), Int16(0), trunc(UInt16,((2^16)-1)*(45*j)/360), false )
    @printf("%d %.4f %.4f\n",(45*j),(1/g)*x/((2^15)-1),(1/g)*y/((2^15)-1))
end