# Makefile for the dotfiles repo (Nix flake + Home Manager)
#
# The target system is detected automatically (macos / wsl / cachyos).
# Override with: make switch HOST=wsl

# --- Host detection ----------------------------------------------------------
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
  HOST ?= macos
else ifneq ($(shell grep -qi microsoft /proc/version 2>/dev/null && echo wsl),)
  HOST ?= wsl
else
  HOST ?= cachyos
endif

# home-manager from PATH, otherwise run it through Nix (e.g. on the first run)
HM := $(shell command -v home-manager 2>/dev/null)
ifeq ($(HM),)
  HM := nix run home-manager/master --
endif

FLAKE := .\#$(HOST)

.DEFAULT_GOAL := help
.PHONY: help host stage build switch update update-nixpkgs generations gc clean

help: ## Show this help
	@echo "Host: $(HOST)  (override with HOST=cachyos|macos|wsl)"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk -F':.*?## ' '{printf "  %-16s %s\n", $$1, $$2}'

host: ## Show the detected host
	@echo $(HOST)

stage: ## Make new/changed files visible to flakes (git add -A)
	@git add -A

build: stage ## Build the configuration without activating it
	nix build --no-link ".#homeConfigurations.$(HOST).activationPackage"

switch: stage ## Build and activate the configuration
	$(HM) switch -b backup --flake "$(FLAKE)"

update: ## Update all flake inputs (flake.lock)
	nix flake update

update-nixpkgs: ## Update only nixpkgs (new package versions, e.g. dotnet)
	nix flake update nixpkgs

generations: ## List Home Manager generations
	$(HM) generations

gc: ## Delete generations older than 14 days and unused store paths
	nix-collect-garbage --delete-older-than 14d

clean: ## Remove local result links
	rm -f result result-*