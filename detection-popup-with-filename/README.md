## 概要

ファイル隔離時に、隔離されたファイルのファイルパス（ファイル名含む）をポップアップメッセージとして端末に表示するカスタムスクリプトです。

Windows向けです（PopwershellスクリプトをRTRで実行する形になりますので、端末側の環境によってはエラーがでるケースがあります）



### パターン1 (detection-popup-with-filename-v1.ps1)

シンプルバージョン

ポップアップメッセージ内にファイルパスを記載（ファイルパスの長さによっては最後まで見れないケースがあり）

＜ポップアップ例＞

![image](https://github.com/user-attachments/assets/7aa35cb1-0755-4bba-aa99-68a9ba4cc283)


### パターン2 (detection-popup-with-filename-detail-v1.ps1)

長い文章を書きたいバージョン

ポップアップメッセージをクリックするとメモ帳が起動し、メモ帳内に任意のメッセージおよびファイルパスが記載されるもの

＜ポップアップ例＞

![image](https://github.com/user-attachments/assets/25f52456-b95c-4192-8434-797e0fb9f347)

＜メッセージ例＞

![image](https://github.com/user-attachments/assets/35beb1e3-3bdf-4202-b467-b30f46151f83)

## Fusionの設定

### 手順1

ホストのセットアップおよび管理 >> レスポンススクリプトとレスポンスファイル

でカスタムスクリプトを新規作成する

スクリプトの項目にはパターン1もしくはパターン2のいずれかの ps1ファイルの内容をコピー＆ペーストする。

入力スキーマには「detection-popup-with-filename-input.json」の内容をコピー＆ペーストする。

### 手順2

Fusion SOAR >> ワークフロー

でワークフローを新規作成する

トリガー：Alert（サブカテゴリー：EPP Detection）

![image](https://github.com/user-attachments/assets/c4b0bf41-4475-48e2-9e07-8a4160cb1b65)


条件1：Action Taken include XXX (任意のActionを選択）

条件2：Sensor Platform equal Windows （必須）

（条件1と2はAND条件で作成）


![image](https://github.com/user-attachments/assets/7a12673f-f631-464f-9689-60e4acacec1c)


アクション：手順1で作成したカスタムスクリプトを選択（Fileにはfilepathを、Device IDにはSensor host idを選択）

![image](https://github.com/user-attachments/assets/a3bbc7ee-53ad-4c14-846c-53dea9f8b32b)



＜ワークフロー例＞

![image](https://github.com/user-attachments/assets/f846fbd5-8ff4-4711-a3bb-ad9171e5d577)


