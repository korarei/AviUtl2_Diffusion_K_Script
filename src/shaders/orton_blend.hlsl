#include "hash.hlsli"

// Darken/Lighten groupだけ
Texture2D tex[2] : register(t0);
cbuffer params : register(b0) {
    float intensity;
    float blend_mode;
    float alpha_mode;
    float gamma;
    float should_clamp;
    float should_isolate_glow;
    float seed;
}

static const float eps = 1.0e-4;

inline float4
dissolve(float4 c, float2 p) {
    return float4(c.rgb * rcp(max(c.a, eps)), 1.0) * step(hash(p, float2(seed, 0.0)) + eps, c.a);
}

inline float3
darken(float3 base, float3 src) {
    return min(base, src);
}

inline float3
multiply(float3 base, float3 src) {
    return base * src;
}

inline float3
color_burn(float3 base, float3 src) {
    return lerp(saturate(mad(base - 1.0, rcp(max(src, eps)), 1.0)), 0.0, step(src, 0.0));
}

inline float3
linear_burn(float3 base, float3 src) {
    return base + src - 1.0;
}

inline float3
darker_color(float3 base, float3 src) {
    return lerp(base, src, step(dot(src, 1.0), dot(base, 1.0)));
}

inline float3
lighten(float3 base, float3 src) {
    return max(base, src);
}

inline float3
screen(float3 base, float3 src) {
    return mad(base - 1.0, 1.0 - src, 1.0);
}

inline float3
color_dodge(float3 base, float3 src) {
    return lerp(lerp(min(base * rcp(max(1.0 - src, eps)), 1.0), 1.0, step(1.0, src)), 0.0, step(abs(base), eps));
}

inline float3
linear_dodge(float3 base, float3 src) {
    return base + src;
}

inline float3
lighter_color(float3 base, float3 src) {
    return lerp(src, base, step(dot(src, 1.0), dot(base, 1.0)));
}

float4
blend(float4 pos : SV_Position) : SV_Target {
    const int mode = int(blend_mode);

    float4 src = max(tex[0].Load(int3(pos.xy, 0)), 0.0); // Linear

    if (int(alpha_mode) == 1)
        src = dissolve(src, pos.xy);

    if (mode == -1) {
        src.rgb *= rcp(max(src.a, eps));
        src.rgb = pow(src.rgb, rcp(gamma));
        src.rgb *= src.a;
        return lerp(src, saturate(src), should_clamp);
    }

    float4 base = max(tex[1].Load(int3(pos.xy, 0)), 0.0); // Non-Linear

    if (mode == 0) {
        base.rgb *= rcp(max(base.a, eps));
        base.rgb = pow(base.rgb, gamma);
        base.rgb *= base.a;

        src *= intensity;
        float4 output = max(mad(1.0 - src.a, base, src), 0.0);

        output.rgb *= rcp(max(output.a, eps));
        output.rgb = pow(output.rgb, rcp(gamma));
        output.rgb *= output.a;

        return lerp(output, saturate(output), should_clamp);
    }

    src.rgb *= rcp(max(src.a, eps));
    base.rgb *= rcp(max(base.a, eps));
    src.a *= intensity;
    base.rgb = pow(base.rgb, gamma);

    float3 blended;
    [forcecase]
    switch (mode) {
        case 1:
            blended = darken(base.rgb, src.rgb);
            break;
        case 2:
            blended = multiply(base.rgb, src.rgb);
            break;
        case 3:
            blended = color_burn(base.rgb, src.rgb);
            break;
        case 4:
            blended = linear_burn(base.rgb, src.rgb);
            break;
        case 5:
            blended = darker_color(base.rgb, src.rgb);
            break;
        case 6:
            blended = lighten(base.rgb, src.rgb);
            break;
        case 7:
            blended = screen(base.rgb, src.rgb);
            break;
        case 8:
            blended = color_dodge(base.rgb, src.rgb);
            break;
        case 9:
            blended = linear_dodge(base.rgb, src.rgb);
            break;
        case 10:
            blended = lighter_color(base.rgb, src.rgb);
            break;
        default:
            blended = src.rgb;
            break;
    }

    blended *= src.a * base.a;
    src.rgb *= src.a;
    base.rgb *= base.a;

    float3 rgb = max(mad(1.0 - src.a, base.rgb, mad(1.0 - base.a, src.rgb, blended)), 0.0);
    float a = mad(1.0 - base.a, src.a, base.a);
    rgb *= rcp(max(a, eps));
    rgb = pow(rgb, rcp(gamma));
    rgb *= a;

    const float4 output = float4(rgb, a) * (1.0 + (src.a - 1.0) * should_isolate_glow);

    return lerp(output, saturate(output), should_clamp);
}
