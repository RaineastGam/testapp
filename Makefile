# Copyright 2020 Tencent Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NAME ?= testapp
OUTPUT := bin

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
GO_VERSION := $(shell go version)

GIT_TREE_STATE=
ifneq ($(strip $(shell git status --porcelain 2>/dev/null)),)
  GIT_TREE_STATE=-dirty
endif

USEVENDOR ?= yes
ifeq (yes, ${USEVENDOR})
BUILDARG=-mod vendor
endif

VERSION ?= $(shell cat VERSION)-$(shell date '+%Y%m%d-%H%M%S')-${GOARCH}
GIT_TAG ?= $(shell git describe --tags --always)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT ?= $(shell git rev-parse HEAD)
GIT_LAST_COMMIT_TIMESTAMP ?= $(shell git log -1 --format="%at")
BUILDTIME ?= $(shell date '+%Y%m%d-%H%M%S')

LDFLAGS += -X "main.Version=v${VERSION}"
LDFLAGS += -X "main.GitTag=${GIT_TAG}"
LDFLAGS += -X "main.GitBranch=${GIT_BRANCH}"
LDFLAGS += -X "main.GitBranchState=${GIT_TREE_STATE}"
LDFLAGS += -X "main.GitCommit=${GIT_COMMIT}"
LDFLAGS += -X "main.GitLastCommitTime=$(GIT_LAST_COMMIT_TIMESTAMP)"
LDFLAGS += -X "main.BuildTime=$(BUILDTIME)"


all:  fmt vet binary

.PHONY: binary
binary: $(NAME)

.PHONY: build
build: $(NAME)

# Run tests
.PHONY: test
test: fmt vet
	go test ./... -coverprofile cover.out

# Build manager binary
.PHONY: $(NAME)
$(NAME):
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build $(BUILDARG) -trimpath -o ${OUTPUT}/${NAME} -ldflags '$(LDFLAGS)' ./main.go

# Run go fmt against code
.PHONY: fmt
fmt:
	go fmt ./...

# Run go vet against code
.PHONY: vet
vet:
	go vet ./...
