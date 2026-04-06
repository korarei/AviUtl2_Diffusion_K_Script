Texture2D tex : register(t0);
cbuffer params : register(b0) {
    float4 amount;
    float2 seed;
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

inline float4
hash(float4 i) {
    return pcg4d(uint4(i)) / 4294967295.0;
}


float4
rgba2hsla(float4 c) {
    const float4 k = float4(0.0, -rcp(3.0), 2.0 * rcp(3.0), -1.0);
    const float4 p = lerp(float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g));
    const float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    const float d = q.x - min(q.w, q.y);
    const float l = 0.5 * (q.x + min(q.w, q.y));
    const float h = abs(mad(q.w - q.y, rcp(max(6.0 * d, eps)), q.z));
    const float s = d * rcp(max(1.0 - abs(mad(2.0, l, -1.0)), eps));

    return float4(h, s, l, c.a);
}

float4
hsla2rgba(float4 c) {
    const float4 k = float4(1.0, 2.0 * rcp(3.0), rcp(3.0), 3.0);
    const float3 p = abs(frac(c.xxx + k.xyz) * 6.0 - k.www);
    const float3 q = saturate(p - k.xxx);
    return float4(mad(q - 0.5, (1.0 - abs(mad(2.0, c.z, -1.0))) * c.y, c.z), c.a);
}

float4
noise_hsla(float4 pos : SV_Position) : SV_Target {
    float4 src = tex.Load(int3(pos.xy, 0));
    src.rgb *= rcp(max(src.a, eps));

    const float4 r = mad(hash(float4(pos.xy, seed)), 2.0, -1.0) * amount;
    float4 hsla = rgba2hsla(saturate(src));
    hsla.yzw += r.yzw;
    hsla.x = frac(hsla.x + r.x);
    const float4 rgba = hsla2rgba(saturate(hsla));

    return float4(rgba.rgb * rgba.a, rgba.a);
}
