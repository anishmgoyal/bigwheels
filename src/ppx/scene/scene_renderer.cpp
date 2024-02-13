// Copyright 2024 Google LLC
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

#include "ppx/scene/scene_renderer.h"

#include <unordered_set>

#include "ppx/application.h"
#include "ppx/scene/scene_material.h"

namespace ppx {
namespace scene {

namespace {

// Constant buffer registers
static const int kSceneConstantsRegister = 0;
static const int kMaterialConstantsRegister = 1;
static const int kModelConstantsRegister = 2;

// Sampler registers
static const int kClampedSamplerRegister = 3;

// Texture registers
static const int kLightDataRegister = 4;
static const int kAlbedoTextureRegister = 5;
static const int kRoughnessTextureRegister = 6;
static const int kMetalnessTextureRegister = 7;
static const int kNormalMapTextureRegister = 8;
static const int kAmbientOcclusionTextureRegister = 9;
static const int kHeightMapTextureRegister = 10;
static const int kIrradianceMapTextureRegister = 11;
static const int kEnvironmentMapTextureRegister = 12;
static const int kBRDFLookupTableTextureRegister = 13;

// TODO - u/anishgoyal: Remove this. This is a temporary restriction,
// for the purposes of development, to allow us to filter scenes for
// supported material types.
const std::unordered_set<std::string> kSupportedMaterialTypes {
    PPX_MATERIAL_IDENT_UNLIT
};

}  // namespace

SceneRenderer::SceneRenderer(
    std::unique_ptr<Scene>&& scene, const Application* app)
    : mScene(scene.release()), mApp(app)
{}

SceneRenderer::~SceneRenderer() {
    mApp->GetDevice()->DestroyDescriptorSetLayout(mUnlitTextureDescriptor);
}

void SceneRenderer::AddVertexBindings(
    grfx::GraphicsPipelineCreateInfo2& createInfo)
{
    if (mScene->GetMeshCount() == 0) {
        // There are no meshes, and so there are no vertex bindings.
        return;
    }

    std::vector<grfx::VertexBinding> bindings =
        mScene->GetMeshNode(0)->GetMesh()->GetAvailableVertexBindings();

    createInfo.vertexInputState.bindingCount = std::min(
        static_cast<uint32_t>(PPX_MAX_VERTEX_BINDINGS),
        static_cast<uint32_t>(bindings.size()));

    for(int i = 0; i < createInfo.vertexInputState.bindingCount; ++i) {
        createInfo.vertexInputState.bindings[i] = bindings[i];
    }
}

void SceneRenderer::CreateSceneDescriptors() {
    grfx::DescriptorSetLayoutCreateInfo createInfo {};
    createInfo.bindings.push_back({
        grfx::DescriptorBinding{
            kSceneConstantsRegister,
            grfx::DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            /*arrayCount=*/1,
            grfx::SHADER_STAGE_ALL_GRAPHICS
        }
    });
    createInfo.bindings.push_back({
        grfx::DescriptorBinding{
            kMaterialConstantsRegister,
            grfx::DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            /*arrayCount=*/1,
            grfx::SHADER_STAGE_ALL_GRAPHICS
        }
    });
    createInfo.bindings.push_back({
        grfx::DescriptorBinding{
            kModelConstantsRegister,
            grfx::DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            /*arrayCount=*/1,
            grfx::SHADER_STAGE_ALL_GRAPHICS
        }
    });
}

void SceneRenderer::CreateUnlitPipelineDescriptors() {
    static const int kMaterialConstantsRegister = 0;
    static const int kAlbedoTextureRegister = 1;

    grfx::DescriptorSetLayoutCreateInfo textureDescriptorLayout = {};
    grfx::DescriptorSetLayoutPtr descriptor;
    textureDescriptorLayout.bindings.push_back({grfx::DescriptorBinding{
        kAlbedoTextureRegister,
        grfx::DESCRIPTOR_TYPE_SAMPLED_IMAGE,
        /*arrayCount=*/1,
        grfx::SHADER_STAGE_ALL_GRAPHICS}});
    PPX_CHECKED_CALL(mApp->GetDevice()->CreateDescriptorSetLayout(
        &textureDescriptorLayout, &descriptor));

    grfx::DescriptorSetLayoutCreateInfo asdf = {};
    grfx::DescriptorSetLayoutPtr descriptor2;
}

void SceneRenderer::Setup() {
    std::vector<char> bytecode =
        mApp->LoadShader("materials/shaders", "VertexShader.vs");
    PPX_ASSERT_MSG(!bytecode.empty(), "VS shader bytecode load failed");
    grfx::ShaderModuleCreateInfo shaderCreateInfo = {
        static_cast<uint32_t>(bytecode.size()), bytecode.data()};
    PPX_CHECKED_CALL(mApp->GetDevice()->CreateShaderModule(
        &shaderCreateInfo, &mVertexShader));
}

void SceneRenderer::SetupUnlitPipeline() {
    std::vector<char> bytecode =
        mApp->LoadShader("materials/shaders", "Unlit.ps");
    PPX_ASSERT_MSG(!bytecode.empty(), "unlit shader bytecode load failed");
    grfx::ShaderModuleCreateInfo shaderCreateInfo = {
        static_cast<uint32_t>(bytecode.size()), bytecode.data()};
    PPX_CHECKED_CALL(mApp->GetDevice()->CreateShaderModule(
        &shaderCreateInfo, &mUnlitShader));

    grfx::GraphicsPipelineCreateInfo2 gpCreateInfo{};
    gpCreateInfo.VS = {mVertexShader.Get(), "vsmain"};
    gpCreateInfo.PS = {mUnlitShader.Get(), "psunlit"};
    AddVertexBindings(gpCreateInfo);

    gpCreateInfo.topology                           = grfx::PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
    gpCreateInfo.polygonMode                        = grfx::POLYGON_MODE_FILL;
    gpCreateInfo.cullMode                           = grfx::CULL_MODE_BACK;
    gpCreateInfo.frontFace                          = grfx::FRONT_FACE_CCW;
    gpCreateInfo.depthReadEnable                    = true;
    gpCreateInfo.depthWriteEnable                   = true;
    gpCreateInfo.blendModes[0]                      = grfx::BLEND_MODE_NONE;
    gpCreateInfo.outputState.renderTargetCount      = 1;
    gpCreateInfo.outputState.renderTargetFormats[0] = mApp->GetSwapchain()->GetColorFormat();
    gpCreateInfo.outputState.depthStencilFormat     = mApp->GetSwapchain()->GetDepthFormat();
}

void SceneRenderer::Render() {
    for (int i = 0; i < mScene->GetMeshNodeCount(); ++i) {
        MeshNode* mesh = mScene->GetMeshNode(i);
        if (mesh->GetMesh() == nullptr) {
            // TODO(anishgoyal) Log this.
            continue;
        }

        // TODO(anishgoyal) Remove check for supported material types.
        for (auto primitiveBatch : mesh->GetMesh()->GetBatches()) {
            if (kSupportedMaterialTypes.find(
                    primitiveBatch.GetMaterial()->GetIdentString()) ==
                kSupportedMaterialTypes.end())
            {
                // TODO(anishgoyal) Log this.
                // Currently, this material type is not supported. We have
                // to add support for all material types for the scene
                // renderer.
                continue;
            }
        }

        // TODO(anishgoyal) Render the object with the material.
    }
}

} // namespace scene
} // namespace ppx
