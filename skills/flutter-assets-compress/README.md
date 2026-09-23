# flutter-assets-compress

Generate Flutter 1x and 2x image assets from existing 3.0x sources using a pure Dart script, then update an `AppImages` asset index.

## When to use

- Normalize Flutter image assets from `assets/images/3.0x/`.
- Generate `assets/images/2.0x/<name>` and `assets/images/<name>`.
- Create or update `tool/image_assets.dart` without external image CLI tools.

## Not suitable for

- Projects without Flutter-style asset directories.
- Manual image retouching or design editing.
- Workflows that require ImageMagick, pngquant, cwebp, or other external tools.

## Environment

- Requires Dart SDK.
- Requires source images in `assets/images/3.0x/`.
- Requires dependencies `image: ^4.8.0` and `path: ^1.9.1`.
- Does not require network access after dependencies are available.

## File and command behavior

- Creates or merges `tool/image_assets.dart`.
- Generates 1x and 2x assets.
- Updates `lib/core/assets/app_images.dart`.
- Runs `dart run tool/image_assets.dart`.
- Does not delete source images.

## Installation

```bash
gh skill install ducafecat/ducafe-skills flutter-assets-compress@v1.0.0
```
