Justfile for rhodium-standard Zotero plugin.

Uses Rescript, Nickel, and Oil Shell for a robust and declarative build.

--- Variables ---

Default target version to focus on

TARGET_VERSION := 2.0

--- Dependencies and Setup ---

setup:
@echo "Installing/ensuring Rescript and Deno dependencies..."
npm install
deno cache ./oil-shell/build.oil # Pre-cache the oil script (if running via Deno shim)
@echo "Setup complete. Use 'just build' to create the XPI."

clean:
@echo "Cleaning compiled files and build artifacts..."
rm -rf build
rm -rf src-$(TARGET_VERSION)/lib
rm -f src-$(TARGET_VERSION)/manifest.json
rm -f src-$(TARGET_VERSION)/updates-$(TARGET_VERSION).json

--- Core Build Recipes ---

The main build recipe, orchestrated by the Oil shell script

build: setup
@./oil-shell/build.oil

1. Compile Rescript to JavaScript

compile-rescript TARGET_VERSION:
@echo "Compiling Rescript source in src-$(TARGET_VERSION) to JavaScript..."
# Ensure Rescript configuration uses the correct root for the target
rescript -with-deps -w false -format false # Assuming rescript.json is set up for the src folder structure

2. Compile Nickel Configs to JSON (manifest)

compile-nickel TARGET_VERSION:
@echo "Compiling Nickel manifest for Zotero to src-$(TARGET_VERSION)/manifest.json..."
nickel export --format json config/Manifest.nix -o src-$(TARGET_VERSION)/manifest.json

3. Generate Final Update JSON (Hash Injection)

generate-update-json TARGET_VERSION:
@echo "Generating final update JSON in build/updates-$(TARGET_VERSION).json..."
@if [ -f build/make-it-red-$(TARGET_VERSION).xpi ]; then

XPI_HASH=$$(shasum -a 256 build/make-it-red-$(TARGET_VERSION).xpi | awk '{print $$1}'); \
echo "Calculated SHA256: $$XPI_HASH"; \
# Compile Nickel Updates config, injecting the calculated hash
nickel export --format json \
--arg 'version' '"$(TARGET_VERSION)"'

--arg 'hash' '"sha256:$$XPI_HASH"'

config/Updates.nix

-o build/updates-$(TARGET_VERSION).json;

else

echo "Error: XPI file not found. Run 'just build' first.";

exit 1;

fi
