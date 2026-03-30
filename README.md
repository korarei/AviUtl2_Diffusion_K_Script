# Diffusion_K

![GitHub License](https://img.shields.io/github/license/korarei/AviUtl2_Diffusion_K_Script)
![GitHub Last commit](https://img.shields.io/github/last-commit/korarei/AviUtl2_Diffusion_K_Script)
![GitHub Downloads](https://img.shields.io/github/downloads/korarei/AviUtl2_Diffusion_K_Script/total)
![GitHub Release](https://img.shields.io/github/v/release/korarei/AviUtl2_Diffusion_K_Script)

画像に対してオートン効果をかけるスクリプト

[ダウンロードはこちらから](https://github.com/korarei/AviUtl2_Diffusion_K_Script/releases)

## 動作確認

- [AviUtl ExEdit2 beta39](https://spring-fragrance.mints.ne.jp/aviutl/)

> [!CAUTION]
> beta38以降必須．

## 導入・更新・削除

初期配置場所は`光効果`と`ぼかし`である．

`オブジェクト追加メニューの設定`から`ラベル`を変更することで任意の場所へ移動可能．

### 導入・更新

ダウンロードした`*.au2pkg.zip`をAviUtl2にD&D．

手動で導入する場合は，`*.anm2`をAviUtl2が認識する場所に設置．

### 削除

パッケージ情報からアンインストールする．

手動で導入した場合は設置した`*.anm2`を削除する．

## 使い方

### Orton

オートン効果の機能拡張版エフェクト．

#### パラメータ

- Intensity: オートン効果の強さ
- Bluriness: ぼかしの強さ
- Low: マスクの閾値 (下)
- High: マスクの閾値 (上)
- Softness: マスクの柔らかさ
- Invert: マスクの反転
- Blend Mode: 合成モード (暗くするものと明るくするものを選択可能)
- Clamp: 描画結果を0-1に飽和

### GaussianBlur

ガウシアンぼかし．

#### パラメータ

- Bluriness: ぼかしの強さ
- Dimensions: ぼかしの方向 (Horizontal, Vertical, Horizontal and Vertical)
- Resize: ぼかした画像のサイズを調整 (フィルタオブジェクトでは無視)

## ビルド方法

[リリース用ワークフロー](./.github/workflows/releaser.yml)を参照されたい．

## ライセンス

本プログラムのライセンスは[LICENSE](./LICENSE)を参照されたい．

## 更新履歴

[CHANGELOG](./CHANGELOG.md)を参照されたい．
