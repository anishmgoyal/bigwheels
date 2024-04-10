// Copyright 2022 Google LLC
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

#include "ppx/cachedir.h"

#include <optional>
#include <string>

namespace ppx {
namespace {

static std::optional<std::string> sCacheDir;

} // namespace

std::optional<std::string> GetCacheDir() {
    return sCacheDir;
}

// Note: not thread safe - should only be done once per process.
void SetCacheDir(const std::string& cacheDir) {
    sCacheDir = cacheDir;
}

void UnsetCacheDir() {
    sCacheDir.reset();
}

} // namespace ppx
