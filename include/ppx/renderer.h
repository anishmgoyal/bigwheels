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

#ifndef ppx_renderer_h
#define ppx_renderer_h

#include "ppx/application.h"

namespace ppx {

class Renderer {
  public:
    Renderer(const Application* application);
    virtual ~Renderer() = default;

    // Draw the current frame, given frame data and a render pass. Frame
    // data will vary from renderer to renderer.
    virtual void Render(
        grfx::CommandBuffer& cmd, grfx::RenderPass& renderPass) = 0;

  private:
    // Referenced, not owned. Contains functions for getting information
    // about the current screen, loading shaders, etc.
    const Application* mApplication;
};

}  // namespace ppx

#endif // ppx_renderer_h
