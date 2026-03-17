#include "BasisTexture.h"
#include "BasisTextureLoader.h"
#include "HAL/FileManager.h"

UTexture2D* UBasisTexture::Transcode()
{
    if (BasisData.Num() == 0)
    {
        UE_LOG(LogTemp, Warning, TEXT("UBasisTexture::Transcode: no data"));
        return nullptr;
    }

    FBasisTranscodeInfo Info;
    // Write to a temp file so we can reuse the existing file-based loader
    // (In production this would transcode directly from memory)
    const FString TempPath = FPaths::ProjectSavedDir() / TEXT("BasisTemp.basis");
    FFileHelper::SaveArrayToFile(BasisData, *TempPath);

    UTexture2D* Tex = UBasisTextureLoader::LoadBasisTexture(TempPath, Info);
    IFileManager::Get().Delete(*TempPath);
    return Tex;
}
