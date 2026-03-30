Texture2D tex : register(t0);
cbuffer params : register(b0) {
    float2 threshold;
    float softness;
    float invert;
}

static const float eps = 1.0e-4;

float4
mask(float4 pos : SV_Position) : SV_Target {
    const float4 src = tex.Load(int3(pos.xy, 0));
    const float lum = dot(src.rgb * rcp(max(src.a, eps)), float3(0.3, 0.59, 0.11));
    const float m0 = smoothstep(threshold.x - softness, threshold.x + softness, lum);
    const float m1 = smoothstep(threshold.y + softness, threshold.y - softness, lum);
    const float m = m0 * m1;
    return src * lerp(m, 1.0 - m, invert);
}
