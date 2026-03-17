"""
Reimport normal map KTX2 files (XUASTC LDR 8x8) into UE5.
Albedo textures (ETC1S) are left unchanged.

Usage:
  UnrealEditor-Cmd.exe <project>.uproject -ExecutePythonScript=reimport_normals_uastc.py -nullrhi -unattended

By default, KTX2 source files are expected at:
  <ProjectDir>/basis_textures/
Override by setting the BASIS_SRC environment variable.
"""
import unreal
import os

project_dir = unreal.Paths.convert_relative_path_to_full(unreal.Paths.project_dir())
BASIS_SRC   = os.environ.get("BASIS_SRC", os.path.join(project_dir, "basis_textures"))
CONTENT_DEST = "/Game/BasisTextures"

print(f"BASIS_SRC: {BASIS_SRC}")

factory = unreal.BasisTextureFactory()

tasks = []
for fname in os.listdir(BASIS_SRC):
    if "_nor_" not in fname.lower() or not (fname.endswith(".ktx2") or fname.endswith(".basis")):
        continue
    src_path = os.path.join(BASIS_SRC, fname)
    asset_name = os.path.splitext(fname)[0]

    asset_path = CONTENT_DEST + "/" + asset_name
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        unreal.EditorAssetLibrary.delete_asset(asset_path)
        print(f"Deleted old: {asset_name}")

    task = unreal.AssetImportTask()
    task.filename = src_path
    task.destination_path = CONTENT_DEST
    task.destination_name = asset_name
    task.replace_existing = True
    task.automated = True
    task.save = True
    task.factory = factory
    tasks.append(task)
    print(f"Queued: {fname}")

unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
print(f"Imported {len(tasks)} normal maps")

for task in tasks:
    asset = unreal.load_asset(CONTENT_DEST + "/" + task.destination_name)
    if asset:
        print(f"  OK: {task.destination_name} fmt={asset.source_format} size={asset.compressed_size} bytes")
    else:
        print(f"  FAIL: {task.destination_name}")

print("=== reimport_normals_uastc.py complete ===")
