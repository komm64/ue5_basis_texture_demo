#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

class FBasisUniversalTextureEditorModule : public IModuleInterface
{
public:
    virtual void StartupModule() override
    {
        UE_LOG(LogTemp, Log, TEXT("BasisUniversalTextureEditor: editor module started."));
    }
    virtual void ShutdownModule() override {}
};

IMPLEMENT_MODULE(FBasisUniversalTextureEditorModule, BasisUniversalTextureEditor)
