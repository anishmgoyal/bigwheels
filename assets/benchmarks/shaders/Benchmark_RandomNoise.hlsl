// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "VsOutput.hlsli"

struct RandomParams
{
    uint32_t Seed;
};

#if defined(__spirv__)
[[vk::push_constant]]
#endif
ConstantBuffer<RandomParams> Random : register(b0);

float random(float2 st, uint32_t seed) {
    float underOne = sin(float(seed) + 0.5f);
    float2 randomVector = float2(15.0f + underOne, 15.0f - underOne);
    return frac(cos(dot(st.xy, randomVector))*40000.0f);
}

float rand_float(uint seed)
{
    const uint state = seed * 747796405u + 2891336453u;
    const uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    //#define FAKE_HASH
    #if defined(FAKE_HASH)
    return ((word >> 22u) ^ word) * (1.0 / 4.0);
    #else
    return ((word >> 22u) ^ word) * (1.0 / 4294967296.0);
    #endif
}

float4 psmain(VSOutputPos input) : SV_TARGET
{
    //float rnd = random(input.position.xy, Random.Seed);
    //return float4(rnd, rnd, rnd, 1.0f);

    const uint pixel_id = uint(input.position.y * 7680 + input.position.x);
    const float red = rand_float(pixel_id);
    const float green = rand_float(pixel_id + 1);
    const float blue = rand_float(pixel_id - 1);

    return float4(red, green, blue, 1.0f);
}