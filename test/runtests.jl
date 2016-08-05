using FFTViews
using Base.Test

@testset "ambiguities" begin
    @test isempty(detect_ambiguities(FFTViews, Base, Core))
end

@testset "convolution-shift" begin
    for l in (8,9)
        a = zeros(l)
        v = FFTView(a)
        @test indices(v,1) == 0:l-1
        v[0] = 1
        p = rand(l)
        pfilt = ifft(fft(p).*fft(v))
        @test_approx_eq real(pfilt) p
        v[0] = 0
        v[-1] = 1
        pfilt = ifft(fft(p).*fft(v))
        @test_approx_eq real(pfilt) circshift(p, -1)
        v[-1] = 0
        v[+1] = 1
        pfilt = ifft(fft(p).*fft(v))
        @test_approx_eq real(pfilt) circshift(p, +1)
    end
    for l2 in (8,9), l1 in (8,9)
        a = zeros(l1,l2)
        v = FFTView(a)
        @test indices(v) == (0:l1-1, 0:l2-1)
        p = rand(l1,l2)
        for offset in ((0,0), (-1,0), (0,-1), (-1,-1),
                       (1,0), (0,1), (1,1), (1,-1), (-1,1),
                       (3,-5), (281,-14))
            fill!(a, 0)
            v[offset...] = 1
            pfilt = ifft(fft(p).*fft(v))
            @test_approx_eq real(pfilt) circshift(p, offset)
        end
    end
end

using OffsetArrays

@testset "convolution-offset" begin
    for l2 in (8,9), l1 in (8,9)
        a = OffsetArray(zeros(l1,l2), (-2,-3))
        v = FFTView(a)
        @test indices(v) == (-2:l1-3, -3:l2-4)
        p = rand(l1,l2)
        for offset in ((0,0), (-1,0), (0,-1), (-1,-1),
                       (1,0), (0,1), (1,1), (1,-1), (-1,1),
                       (3,-5), (281,-14))
            fill!(a, 0)
            v[offset...] = 1
            pfilt = ifft(fft(p).*fft(v))
            @test_approx_eq real(pfilt) circshift(p, offset)
        end
    end
end

@testset "vector indexing" begin
    v = FFTView(1:10)
    @test v[-10:15] == [1:10;1:10;1:6]
end

nothing
