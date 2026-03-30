RWTexture2D<half4> dst : register(u0);
Texture2D src : register(t0);
cbuffer params : register(b0) {
    float2 offset;
}

[numthreads(16, 16, 1)]
void
map(uint3 dtid : SV_DispatchThreadID) {
    uint w, h;
    src.GetDimensions(w, h);
    if (dtid.x >= w || dtid.y >= h)
        return;

    dst[dtid.xy + uint2(offset)] = src[dtid.xy];
}
