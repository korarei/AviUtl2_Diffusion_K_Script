RWTexture2D<half4> dst : register(u0);
Texture2D src : register(t0);
cbuffer params : register(b0) {
    float2 origin;
}

// Countは `(元画像サイズ + 15) / 16` で計算すること
[numthreads(16, 16, 1)]
void
blit(uint3 pos : SV_DispatchThreadID) {
    uint2 size;
    src.GetDimensions(size.x, size.y);
    if (any(pos.xy >= size))
        return;

    dst[pos.xy + uint2(origin)] = src[pos.xy];
}
