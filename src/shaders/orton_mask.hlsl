#include "input.hlsli"

Texture2D tex[2] : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float2 threshold;
    float softness;
    float channel;
    float should_invert;
    float should_load_mask;
    float exposure;
    float brightness;
    float contrast;
    float gamma;
}

static const float eps = 1.0e-4;
static const float3 y = float3(0.3, 0.59, 0.11);

// Non-Linear -> Linear
float4
mask(PS_Input input) : SV_Target {
    float4 src = max(tex[0].Load(int3(input.pos.xy, 0)), 0.0);
    src.rgb *= rcp(max(src.a, eps));
    src.rgb = pow(src.rgb, gamma);

    const float lum = dot(src.rgb, y);
    const float m0 = smoothstep(threshold.x - softness, threshold.x + softness, lum);
    const float m1 = smoothstep(threshold.y + softness, threshold.y - softness, lum);

    float4 mask = tex[1].Sample(smp, input.uv);
    mask.rgb *= rcp(max(mask.a, eps));
    const float m2 = saturate(lerp(dot(mask.rgb, y), mask.a, channel));

    const float m = m0 * m1 * (1.0 + (m2 - 1.0) * should_load_mask);

    src.rgb = ldexp(src.rgb, exposure);
    src.rgb = max(mad(src.rgb, 1.0 + contrast, mad(contrast, -0.5, brightness)), 0.0);

    return float4(src.rgb * src.a, src.a) * lerp(m, 1.0 - m, should_invert);
}
