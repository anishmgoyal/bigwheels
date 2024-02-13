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

#ifndef ppx_scene_renderer_h
#define ppx_scene_renderer_h

#include "ppx/ppx.h"
#include "ppx/application.h"
#include "ppx/scene/scene_scene.h"

#include <vector>

namespace ppx {
namespace scene {

class SceneRenderer {
public:
    SceneRenderer(std::unique_ptr<Scene>&& scene, const Application* app);
    ~SceneRenderer();

    void Setup();
    void Render();

private:
    void AddVertexBindings(grfx::GraphicsPipelineCreateInfo2& createInfo);
    void CreateSceneDescriptors();
    void CreateMaterialDescriptors();
    void CreateModelDescriptors();
    void CreateUnlitPipelineDescriptors();
    void SetupUnlitPipeline();

    std::unique_ptr<Scene> mScene;
    const Application* mApp;

    struct PerFrame {
        grfx::CommandBufferPtr cmd;
        grfx::SemaphorePtr     imageAcquiredSemaphore;
        grfx::FencePtr         imageAcquiredFence;
        grfx::SemaphorePtr     renderCompleteSemaphore;
        grfx::FencePtr         renderCompleteFence;
    };

    std::vector<PerFrame>      mPerFrame;
    grfx::ShaderModulePtr      mVertexShader;
    grfx::ShaderModulePtr      mUnlitShader;
    grfx::ShaderModulePtr      mPBRShader;
    grfx::ShaderModulePtr      mDebugShader;
    grfx::ShaderModulePtr      mErrorShader;
    grfx::PipelineInterfacePtr mPipelineInterface;
    grfx::GraphicsPipelinePtr  mPipeline;

    grfx::DescriptorSetLayoutPtr mUnlitTextureDescriptor;
};

} // namespace scene
} // namespace ppx

#endif // ppx_scene_renderer_h
