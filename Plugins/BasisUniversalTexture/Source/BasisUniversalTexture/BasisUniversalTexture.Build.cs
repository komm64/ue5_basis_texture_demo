using UnrealBuildTool;
using System.IO;

public class BasisUniversalTexture : ModuleRules
{
    public BasisUniversalTexture(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PrivatePCHHeaderFile = "Private/BasisUniversalTexturePrivatePCH.h";

        PublicDependencyModuleNames.AddRange(new string[]
        {
            "Core",
            "CoreUObject",
            "Engine",
            "RenderCore",
            "RHI",
        });

        // Basis Universal transcoder source path
        string BasisPath = Path.Combine(ModuleDirectory, "Private", "ThirdParty", "BasisUniversal");

        PrivateIncludePaths.Add(BasisPath);

        // Basis Universal compile definitions
        // zstd single-file decoder lives next to BasisUniversal
        string ZstdPath = Path.Combine(ModuleDirectory, "Private", "ThirdParty", "zstd");
        PrivateIncludePaths.Add(ZstdPath);

        PrivateDefinitions.AddRange(new string[]
        {
            "BASISD_SUPPORT_KTX2=1",
            "BASISD_SUPPORT_KTX2_ZSTD=1",
            "BASISU_NO_ITERATOR_DEBUG_LEVEL",
            // Disable GPU formats we don't need on desktop
            "BASISD_SUPPORT_PVRTC1=0",
            "BASISD_SUPPORT_PVRTC2=0",
            "BASISD_SUPPORT_ATC=0",
            "BASISD_SUPPORT_FXT1=0",
            "BASISD_SUPPORT_ETC2_EAC_A8=1",
            "BASISD_SUPPORT_UASTC=1",
            "BASISD_SUPPORT_BC7=1",
            "BASISD_SUPPORT_DXT1=1",
            "BASISD_SUPPORT_DXT5A=1",
            "BASISD_SUPPORT_ASTC=1",
            "BASISD_SUPPORT_ASTC_HIGHER_OPAQUE_QUALITY=0",
        });

    }
}
