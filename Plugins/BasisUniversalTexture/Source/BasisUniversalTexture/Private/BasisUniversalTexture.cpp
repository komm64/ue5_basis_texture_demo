#include "BasisUniversalTexture.h"

// Initialize Basis Universal global transcoder state at module startup
THIRD_PARTY_INCLUDES_START
#pragma warning(push)
#pragma warning(disable: 4800 4267 4244 4456 4127 4100 4668)
#include "basisu_transcoder.h"
#pragma warning(pop)
THIRD_PARTY_INCLUDES_END

#define LOCTEXT_NAMESPACE "FBasisUniversalTextureModule"

void FBasisUniversalTextureModule::StartupModule()
{
    // One-time global init required by Basis Universal
    basist::basisu_transcoder_init();
    UE_LOG(LogTemp, Log, TEXT("BasisUniversalTexture: module started, transcoder initialized."));
}

void FBasisUniversalTextureModule::ShutdownModule()
{
}

#undef LOCTEXT_NAMESPACE

IMPLEMENT_MODULE(FBasisUniversalTextureModule, BasisUniversalTexture)
