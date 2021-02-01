#!/bin/bash

nix-shell obelisk-template/obeliskShell.nix --show-trace --run "make default.nix && nix-shell obelisk-template/obeliskShell.nix"