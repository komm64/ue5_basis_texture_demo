using UnrealBuildTool;

public class BasisUniversalTextureEditor : ModuleRules
{
    public BasisUniversalTextureEditor(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

        PublicDependencyModuleNames.AddRange(new string[]
        {
            "Core", "CoreUObject", "Engine",
            "BasisUniversalTexture",
        });

        PrivateDependencyModuleNames.AddRange(new string[]
        {
            "UnrealEd", "AssetTools", "AssetDefinition",
            "Slate", "SlateCore", "ToolMenus",
        });
    }
}
