Texture2D tex : register(t0);
SamplerState smp : register(s0);
cbuffer params : register(b0) {
    float2 weight;
    float2 seed;
    float amount;
}

struct PS_Input {
    float4 pos : SV_Position;
    float2 uv : TEXCOORD;
};

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

float2
box_muller(float2 p) {
    const float4 u = pcg4d(uint4(p, seed)) / 4294967295.0;
    const float r = sqrt(-2.0 * log(u.x));
    const float t = 6.28318530718 * u.y;
    return r * float2(cos(t), sin(t));
}

float4 scatter(PS_Input input) : SV_Target {
    float2 size;
    tex.GetDimensions(size.x, size.y);

    const float2 offset = box_muller(input.pos.xy) * rcp(size) * amount * rcp(20.0);
    return tex.Sample(smp, mad(weight, offset, input.uv));
}
