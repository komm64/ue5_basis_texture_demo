#pragma once

#include "CoreMinimal.h"
#include "Factories/Factory.h"
#include "BasisTextureFactory.generated.h"

/**
 * Factory that imports .basis files into UBasisTexture assets.
 * Drop a .basis file into the Content Browser → UBasisTexture is created.
 */
UCLASS()
class UBasisTextureFactory : public UFactory
{
    GENERATED_BODY()

public:
    UBasisTextureFactory();

    virtual UObject* FactoryCreateBinary(
        UClass* InClass, UObject* InParent, FName InName, EObjectFlags Flags,
        UObject* Context, const TCHAR* Type,
        const uint8*& Buffer, const uint8* BufferEnd,
        FFeedbackContext* Warn) override;

    virtual bool FactoryCanImport(const FString& Filename) override;
};
