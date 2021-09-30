using Printf
include("cordic_params.jl")

 # !!! don't change these !!!
const PhaseWidth = 16
const XYWidth    = 16

# place-holder until I know how to do custom BWs
const phase_t   = UInt16;
const xy_t      = Int16;
const exy_t     = Int32;

function cordic(N_stages, i_xval::xy_t,   i_yval::xy_t,   i_phi::phase_t, verbose::Bool=false)
    """
    CORDIC Module 
    """    
    # phase constants            
    TWOPI       ::phase_t   = 2^(PhaseWidth)-1
    PI          ::phase_t   = TWOPI>>1
    HALFPI      ::phase_t   = TWOPI>>2
    QUARTERPI   ::phase_t   = TWOPI>>3

    e_xval = exy_t(i_xval)
    e_yval = exy_t(i_yval)
    oct    = trunc(UInt8,i_phi>>(PhaseWidth-3))

    xv = zeros(exy_t,N_stages)
    yv = zeros(exy_t,N_stages)
    ph = zeros(phase_t,N_stages)
    cordic_lut = generateCordicAngles(N_stages,PhaseWidth)
    verbose ? @printf("\nInput Params:\noct=%d\ne_xval=%d\te_yval=%d\ni_phi=%.3f\n\n",
                        oct,e_xval,e_yval,i_phi*(360/2^16)) : 0;
    if (oct == 0) | (oct == 7) # 0..45, 315..360
        # No Change
        xv[1] = e_xval
        yv[1] = e_yval
        ph[1] = i_phi 
    elseif (oct == 1) # 45..90
        xv[1] = -e_yval
        yv[1] = e_xval
        ph[1] =  i_phi - HALFPI 
    elseif (oct == 2) # 90..135
        xv[1] = -e_yval
        yv[1] =  e_xval
        ph[1] =  i_phi - HALFPI
    elseif (oct == 3) # 135..180
        xv[1] = -e_xval
        yv[1] = -e_yval
        ph[1] = i_phi + PI
    elseif (oct == 4) # 180..225
        xv[1] = -e_xval
        yv[1] = -e_yval
        ph[1] = i_phi + PI
    elseif (oct == 5)  # 225..270
        xv[1] = e_yval
        yv[1] = -e_xval
        ph[1] = i_phi + HALFPI
    elseif (oct == 6) # 270..315
        xv[1] = e_yval
        yv[1] = -e_xval
        ph[1] = i_phi + HALFPI 
    else
        println("Uh Oh! \n Invalid octet found.")
    end

    verbose ? @printf("\nTranslated Params:\ne_xval=%d\te_yval=%d\nxv[1]=%d\tyv[1]=%d\nph[1]=%d\n\n",
                        e_xval,e_yval, xv[1], yv[1],ph[1]*(360/2^16)) : 0;
    verbose ? @printf(" % 3s % 3s  % 15s  % 15s % 15s |  % 7s  % 7s % 7s | % 7s \n", "n,",
                      "+/-,", "xv_f,", "yv_f,", "ph_f", "xv_d,", "yv_d,", "ph_f", "tan(θ_k)") : 0;
    verbose ? @printf("%3d, %3d, % 15.6f, % 15.6f, % 15.6f | %7d, %7d, %7u | % 7u\n",
    0, (ph[1]>>>15), xv[1]/((2^15)-1), yv[1]/((2^15)-1), ph[1]*(360/2^16),
    xv[1], yv[1], ph[1], 0 ) : 0;

    for i=1:(N_stages-1)
        if (ph[i]>>>(PhaseWidth-1))==1
            xv[i+1] = xv[i] + (yv[i]>>i)
            yv[i+1] = yv[i] - (xv[i]>>i)
            ph[i+1] = ph[i] + cordic_lut[i]
        else
            xv[i+1] = xv[i] - (yv[i]>>i)
            yv[i+1] = yv[i] + (xv[i]>>i)
            ph[i+1] = ph[i] - cordic_lut[i]
        end
        verbose ? @printf("%3d, %3d, % 15.6f, % 15.6f, % 15.6f | %7d, %7d, %7u | % 7u\n",
                    i,(ph[i]>>>(PhaseWidth-1)), xv[i+1]/(2^(15)-1), yv[i+1]/(2^(15)-1), ph[i+1]*(360/2^16),
                    xv[i+1], yv[i+1], ph[i+1], cordic_lut[i] ) : 0;
    end
    return (xv[N_stages], yv[N_stages], ph[N_stages])
end