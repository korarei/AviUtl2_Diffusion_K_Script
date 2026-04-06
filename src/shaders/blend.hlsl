// Darken/Lighten groupだけ

Texture2D tex[2] : register(t0);
cbuffer params : register(b0) {
    float intensity;
    float blend_mode;
    float alpha_mode;
    float should_clamp;
}

static const float eps = 1.0e-4;

/*
The following function is a modified version of pcg4d function
Original implementation by Mark Jarzynski & Marc Olano
https://github.com/markjarzynski/PCG3D/blob/master/LICENSE
*/

uint4
pcg4d(uint4 v) {
    v = v * 1664525u + 1013904223u;

    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;

    v = v ^ v >> 16u;

    v.x += v.y * v.w;
    v.y += v.z * v.x;
    v.z += v.x * v.y;
    v.w += v.y * v.z;

    return v;
}

inline float
hash(float4 i) {
    const uint4 v = pcg4d(uint4(i));
    return dot(v, 1u) / 4294967295.0;
}

inline float4
dissolve(float4 c, float2 p) {
    return float4(c.rgb * rcp(max(c.a, eps)), 1.0) * step(hash(float4(p, 0.0, 0.0)) + eps, c.a);
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

    float4 src = tex[0].Load(int3(pos.xy, 0));
    float4 base = tex[1].Load(int3(pos.xy, 0));

    if (int(alpha_mode) == 1)
        src = dissolve(src, pos.xy);

    if (mode == 0) {
        src *= intensity;
        const float4 output = mad(1.0 - src.a, base, src);
        return lerp(output, saturate(output), should_clamp);
    }

    src.rgb *= rcp(max(src.a, eps));
    src.a *= intensity;
    base.rgb *= rcp(max(base.a, eps));

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

    const float3 rgb = mad(1.0 - src.a, base.rgb, mad(1.0 - base.a, src.rgb, blended));
    const float a = mad(1.0 - base.a, src.a, base.a);
    const float4 output = float4(rgb, a);

    return lerp(output, saturate(output), should_clamp);
}
