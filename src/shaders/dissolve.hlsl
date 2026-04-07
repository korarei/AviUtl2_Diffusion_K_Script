Texture2D tex : register(t0);
cbuffer params : register(b0) {
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

inline float
hash(float4 i) {
    const uint4 v = pcg4d(uint4(i));
    return dot(v, 1u) / 4294967295.0;
}

float4
dissolve(float4 pos : SV_Position) : SV_Target {
    const float4 src = tex.Load(int3(pos.xy, 0));
    return float4(src.rgb * rcp(max(src.a, eps)), 1.0) * step(hash(float4(pos.xy, seed)) + eps, src.a);
}
