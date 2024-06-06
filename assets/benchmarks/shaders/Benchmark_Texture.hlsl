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

#define MAX_RGB_TEXTURE_COUNT 10
#define MAX_YUV_TEXTURE_COUNT 10

struct TextureCounts {
    uint32_t rgb;
    uint32_t yuv;
};

#if defined(__spirv__)
[[vk::push_constant]]
#endif
ConstantBuffer<TextureCounts> textureCounts : register(b0, space1);

RWStructuredBuffer<float> dataBuffer : register(u0);
SamplerState pointsampler : register(s1);

Texture2D rgbTextures[MAX_RGB_TEXTURE_COUNT] : register(t2);

Texture2D yuvTextures[MAX_YUV_TEXTURE_COUNT] : register(t12);
SamplerState yuvSamplers[MAX_YUV_TEXTURE_COUNT] : register(s12);

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
    float4 sum_c_rgb = 0;
    [loop] // Signal that early termination is likely, do not unroll
    for (int i = 0; i < textureCounts.rgb; i++) {
        sum_c_rgb = sum_c_rgb + rgbTextures[i].SampleLevel(
            pointsampler, input.texcoord, 0);
    }

    // https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#samplers-subsamplesampler
    // "If the combined image sampler enables sampler Y′CBCR conversion or
    // samples a subsampled image, it must be indexed only by constant integral
    // expressions when aggregated into arrays in shader code, irrespective of
    // the shaderSampledImageArrayDynamicIndexing feature."
    float4 sum_c_yuv = 0;
    if (0 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[0], input.texcoord, 0);
    if (1 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[1], input.texcoord, 1);
    if (2 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[2], input.texcoord, 2);
    if (3 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[3], input.texcoord, 3);
    if (4 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[4], input.texcoord, 4);
    if (5 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[5], input.texcoord, 5);
    if (6 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[6], input.texcoord, 6);
    if (7 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[7], input.texcoord, 7);
    if (8 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[8], input.texcoord, 8);
    if (9 < textureCounts.yuv)
        sum_c_yuv += yuvTextures[0].SampleLevel(yuvSamplers[9], input.texcoord, 9);

    float4 sum_c = 0;
    if (textureCounts.yuv > 0 && textureCounts.rgb > 0) {
        sum_c = (sum_c_rgb / float(textureCounts.rgb)) * 0.5 +
                (sum_c_yuv / float(textureCounts.yuv)) * 0.5;
    } else if (textureCounts.rgb > 0) {
        sum_c = sum_c_rgb / float(textureCounts.rgb);
    } else if (textureCounts.yuv > 0) {
        sum_c = sum_c_yuv / float(textureCounts.yuv);
    }

    const uint rd_w = 2664;
    const uint pixel_id = uint(input.position.y * rd_w + input.position.x);
    const float red = rand_float(pixel_id);
    const float green = rand_float(pixel_id + 1);
    const float blue = rand_float(pixel_id - 1);
    float4 noise = float4(red, green, blue, 1.0f);

    if (!any(sum_c))
        dataBuffer[0] = sum_c.r;
    return sum_c;
}