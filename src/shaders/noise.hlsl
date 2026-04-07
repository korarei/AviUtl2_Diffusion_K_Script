Texture2D tex : register(t0);
cbuffer params : register(b0) {
    float2 seed;
    float amount;
    float color;
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

inline float4
hash(float4 i) {
    return pcg4d(uint4(i)) / 4294967295.0;
}

float4
noise(float4 pos : SV_Position) : SV_Target {
    float4 src = tex.Load(int3(pos.xy, 0));
    src.rgb *= rcp(max(src.a, eps));

    const float4 r = (hash(float4(pos.xy, seed)) - 0.5) * amount;
    [forcecase]
    switch (int(color)) {
        case 0:
            src.rgb += r.rrr;
            break;
        case 1:
            src.rgb += r.rgb;
            break;
        case 2:
            src.rgb += r.rgb;
            src.a = saturate(src.a + r.a);
            break;
        default:
            break;
    }

    const float4 output = float4(src.rgb * src.a, src.a);
    return lerp(output, saturate(output), should_clamp);
}
