# Basis Universal Texture Compression Demo for Unreal Engine 5

## Motivation

Install size directly affects user acquisition and retention across virtually all game categories. Players who hesitate to download a large game, or who delete it during a storage cleanup, are customers lost. Keeping package size as small as possible is a genuine business concern, not just a technical preference.

### The problem with today's GPU texture formats

UE5 developers can already choose compression formats per texture — BC1, BC5, BC7, ASTC, and so on. But all of these are **GPU-native formats with fixed bitrates**:

| Format | Bitrate | Notes |
|---|---|---|
| BC1 | 4 bpp | fixed |
| BC5 | 4 bpp | fixed |
| BC7 | 8 bpp | fixed |
| ASTC 4×4 | 8 bpp | fixed |
| ASTC 8×8 | 2 bpp | fixed |

There is no intermediate option. A developer who wants something between BC1 and BC7 has no choice. And regardless of format, developers must make separate format decisions for each target platform — BC7 for PC, ASTC for mobile — duplicating cook passes and pak storage.

Unreal Engine 5's **Oodle Texture RDO** improves on this by making GPU block data more compressible inside the pak, with no quality cost. But it is still bound by these fixed bitrate floors — it cannot compress below what the GPU format physically requires.

### What Basis Universal makes possible

**Basis Universal** introduces a fundamentally different tradeoff space. XUASTC LDR alone spans **0.3 to 5.7 bpp** continuously across block sizes 4×4 through 12×12:

| Block size | Bitrate |
|---|---|
| XUASTC 4×4 | 5.7 bpp |
| XUASTC 6×6 | ~2.5 bpp |
| XUASTC 8×8 | 2.0 bpp |
| XUASTC 10×10 | 1.3 bpp |
| XUASTC 12×12 | 0.9 bpp |

This continuous space means a developer can allocate quality precisely — higher bitrate for hero assets seen up close, lower bitrate for distant or secondary textures — rather than jumping between coarse fixed formats.

More importantly, **a single Basis Universal (KTX2) asset transcodes to any GPU-native format at runtime**: BC5/BC7 on PC, ASTC on mobile. The developer never specifies a platform-specific format. One asset, one cook pass, one pak file serves all platforms.

The long-term goal of this project is to expose this capability directly in the UE5 texture pipeline: the developer sets a quality level, and the engine handles format selection and platform transcoding automatically. This repository is the proof-of-concept demonstrating these properties in UE5, along with a [Roadmap](#roadmap) toward full pipeline integration.

---

## Results

All comparisons are made against a **fair baseline**: the Standard build has Oodle Texture RDO enabled (`FinalRDOLambda=30`), which is Epic's own technology for optimizing GPU texture block data before pak compression.

| | Standard (BC1/BC5 + Oodle RDO) | Basis (ETC1S + XUASTC LDR 8x8) |
|---|---|---|
| **Pak size** | 178.0 MB | **152.7 MB (−14.5%)** |
| **Texture data in pak** | 39.1 MB | **13.8 MB (−64.7%)** |

> The pak contains substantial shared shader data (~138 MB) identical in both builds. The texture-only reduction of **−64.7%** represents the actual compression improvement, which translates to proportionally larger savings in texture-heavy real-world projects.

### Mobile (ASTC devices)

| | Standard (ASTC 4×4) | Basis (XUASTC LDR 8×8) |
|---|---|---|
| Disk (10 normal maps) | ~40 MB (estimated) | **8.3 MB (measured)** |
| Runtime decode cost | native | ~33 ms (decompress supercompression only) |

The Standard figure (~40 MB) is a theoretical estimate based on raw ASTC 4×4 block size (4 MB × 10 textures); an actual mobile cook with Oodle compression would be somewhat smaller. The Basis figure (8.3 MB) is the measured size of the KTX2 files produced by this pipeline. XUASTC's Weight Grid DCT + RDO supercompression operates on the ASTC block data itself, achieving results well beyond what general-purpose pak compression can deliver on pre-compressed GPU texture data.

On ASTC-capable devices, XUASTC LDR 8×8 decompresses directly to native ASTC 8×8 blocks — nearly zero transcoding overhead.

### Single pak for all platforms (design goal)

A key architectural advantage of the Basis Universal approach is that **one KTX2 file can serve every target platform**. The Basis Universal transcoder supports transcoding to any GPU-native format at runtime:

| Platform | Transcodes to | Cost (measured on PC) |
|---|---|---|
| PC / Console (DX12/Vulkan) | BC5_RG (normal) | ~128 ms / 2048×2048 |
| PC / Console (DX12/Vulkan) | BC7 (albedo) | ~397 ms / 2048×2048 |
| Mobile (ASTC) | ASTC 8×8 | ~33 ms / 2048×2048 |
| Mobile (ETC2 fallback) | ETC2 | supported by transcoder |

> **Note**: This demo targets Win64 only. The mobile transcoding path is supported by the underlying `basist::ktx2_transcoder` but has not been tested on device in this prototype. Full multi-platform support is part of the [Roadmap](#roadmap).

In a standard UE5 multi-platform build, the cook process generates separate platform-specific paks — BC5/BC7 for PC, ASTC for iOS/Android — each requiring its own cook pass and storage. With Basis Universal, a single pak could ship to all platforms and transcoding would happen once at load time, simplifying the build pipeline.

---

## What is XUASTC LDR?

XUASTC LDR is a supercompressed ASTC format introduced in **Basis Universal v2.10**. It applies Weight Grid DCT + RDO supercompression on top of ASTC blocks, achieving bitrates from 0.3 to 5.7 bpp across block sizes 4×4 through 12×12.

Key properties:
- **Explicitly supports normal maps** (documented in official Basis Universal spec)
- **KTX2 container** with `KTX2_SS_XUASTC_LDR` supercompression scheme
- **Transcodes to any GPU format** at runtime: BC5, BC7, ASTC, ETC2, etc.
- **`BASISD_SUPPORT_XUASTC=1` is the default** in the Basis Universal transcoder

This demo uses **XUASTC LDR 8×8 (2 bpp)** for normal maps and **ETC1S** for albedo textures.

### Quality

| Format | PSNR (2048×2048 normal map) |
|---|---|
| UASTC LDR 4×4 | 33.4 dB |
| XUASTC LDR 8×8 | 27.2 dB |

XUASTC LDR 8×8 at 27.2 dB PSNR was visually acceptable in this demo scene under typical viewing conditions. Results may vary with close-up inspection or grazing-angle lighting.

### Runtime transcoding (per 2048×2048 texture)

| Target format | Time |
|---|---|
| BC5_RG (normal maps) | ~128 ms |
| BC7_RGBA | ~397 ms |
| ASTC 8×8 (mobile) | ~33 ms |

---

## Project Structure

```
BasisDemo.uproject
├── Config/
│   └── DefaultEngine.ini          # Oodle Texture RDO settings
├── Plugins/
│   └── BasisUniversalTexture/     # UE5 plugin
│       └── Source/
│           ├── BasisUniversalTexture/
│           │   ├── Private/
│           │   │   ├── BasisTextureLoader.cpp   # Transcode to BC5/RGBA32
│           │   │   ├── BasisTexture.cpp
│           │   │   └── ThirdParty/
│           │   │       ├── BasisUniversal/      # basis_universal v2.10 transcoder
│           │   │       └── zstd/                # zstd single-file decoder
│           │   └── Public/
│           └── BasisUniversalTextureEditor/
└── Source/
    └── BasisDemo/
        ├── GalleryActor.cpp        # Runtime gallery: Standard vs Basis side-by-side
        └── GalleryActor.h
```

---

## Requirements

- Unreal Engine 5.7
- Visual Studio 2022
- [basisu CLI](https://github.com/BinomialLLC/basis_universal/releases) (for encoding KTX2 files)
- Source textures: 2K PNG normal maps and albedo maps

---

## Workflow

### 1. Encode normal maps to XUASTC LDR 8×8

```powershell
.\encode_normals_xuastc8x8.ps1
```

Encodes all `*nor_dx*.png` files in `source_textures/` to KTX2 using:
```
basisu <input>.png -ldr_8x8i -normal_map -quality 128 -effort 6 -output_file <output>.ktx2
```

### 2. Deploy KTX2 files

```powershell
.\deploy_xuastc8x8.ps1
```

Copies encoded KTX2 files to the UE project's `basis_textures/` source directory.

### 3. Reimport into UE5

```powershell
.\run_reimport_normals.ps1
```

Runs `reimport_normals_uastc.py` via `UnrealEditor-Cmd.exe` to reimport KTX2 assets.

### 4. Package

```powershell
# Basis build (ETC1S albedo + XUASTC 8x8 normals)
.\package_basis_nobuild.ps1

# Standard build (BC1/BC5 + Oodle Texture RDO)
.\package_standard_timed.ps1
```

---

## Plugin Implementation Notes

- Normal maps (filename contains `_nor_`) are transcoded to **BC5_RG** — the correct 2-channel GPU format for DX normal maps.
- All other textures use **RGBA32** for broad UE5 compatibility.
- The transcoder uses `basist::ktx2_transcoder`, which handles UASTC+Zstd, XUASTC LDR, and ETC1S natively (`BASISD_SUPPORT_XUASTC=1` by default).
- `PrivatePCHHeaderFile` is set to a plugin-local PCH to avoid loading the 2+ GB shared UE editor PCH on every incremental build.

---

## Background

This demo was developed to evaluate Basis Universal as a practical texture compression pipeline for Unreal Engine 5, with a focus on:

1. **Accurate comparison** — enabling Oodle Texture RDO on the Standard build ensures a fair baseline
2. **XUASTC LDR discovery** — demonstrating the first known UE5 integration of the XUASTC LDR format
3. **Mobile-first potential** — XUASTC 8×8 → ASTC 8×8 transcoding is nearly free on mobile hardware (~33 ms), and the KTX2 supercompression achieves significantly smaller disk sizes than shipping raw ASTC blocks

---

## Roadmap

This repository is a proof of concept. The goal is to evolve it into a fully integrated UE5 texture compression pipeline with a simple developer experience: **set a quality level, and the engine handles the rest** — format selection, platform transcoding, and pak optimization — automatically.

### 1. UE5 Texture Pipeline Integration

Currently, Basis Universal assets are imported through a custom factory (`BasisTextureFactory`) and loaded via a separate loader class. This requires a parallel asset management workflow alongside standard `UTexture2D` assets.

The target architecture is a native UE5 `ITextureFormat` plugin that hooks into the standard compression pipeline:

- **Quality-driven format selection**: The developer selects a quality level (or size budget) per texture in the Compression Settings dropdown. The plugin automatically chooses the optimal XUASTC LDR block size (4×4 through 12×12) or ETC1S to meet that target — no manual format knowledge required.
- **Platform-transparent transcoding**: At runtime, the plugin transcodes each KTX2 asset to the platform-native GPU format (BC5/BC7 on PC/console, ASTC on mobile) without any developer input. A single cooked asset serves all platforms.
- **Zero workflow changes**: Encoding happens at cook time via `ITextureFormatModule`. The cooked assets are standard `UTexture2D` objects, fully compatible with materials, streaming, and LOD.

This unifies what is currently a fragmented decision — "which format for which platform?" — into a single quality dial that works across all targets.

### 2. Automatic Per-Texture Optimization

Today, developers must manually assess each texture's role (hero vs. secondary, close-up vs. distant) and assign formats accordingly. A production-ready integration will include tooling to automate this:

- Analyze each texture's usage context (material slot, LOD range, screen-space coverage)
- Assign quality targets automatically based on perceptual importance
- Distribute a project-wide size budget optimally across the texture library

This kind of per-texture quality allocation is only possible with a continuous bitrate space like XUASTC LDR. Fixed-bitrate GPU formats (BC1, BC7) cannot offer it.

### 3. Mip Streaming Support

The current implementation loads only mip level 0 (full resolution). A production-ready integration requires full mip chain support and compatibility with UE5's texture streaming system:

- Encode and store all mip levels in the KTX2 container at cook time
- At runtime, integrate with `FStreamableRenderResourceState` so UE5's streaming manager can request individual mip levels on demand
- Reduce initial VRAM usage and support large open-world scenes where texture streaming is critical

Mip streaming support is a prerequisite for any production use case.

### 4. Direct Memory Transcoding

The current prototype writes a temporary file to disk before transcoding. The production implementation will transcode directly from the cooked asset's memory buffer, eliminating I/O overhead and making runtime loading competitive with native formats.

---

## License

Plugin source code: MIT
Basis Universal transcoder: Apache 2.0 (Binomial LLC)
zstd: BSD (Meta Platforms)
