## 概要

Fusionワークフロー（オンデマンド トリガー）を用いて、特定の端末のセンサーグルーピングタグを書き換える

※アンインストール トークン設定ありバージョン

※カスタムスクリプトはFusionワークフローでなくともRTR単体でも利用可能

## 手順

Work In Progress

### 1. API クライアントの作成

「サポートおよびリソース >> APIクライアントおよびキー」

Sensor Update Policies の [書き込み] にチェックをいれて API クレデンシャルを発行する

![image](https://github.com/user-attachments/assets/01b15c1e-4cbd-4c08-89dc-62df93af90db)


### 2. カスタムスクリプトを作成する

「ホストのセットアップおよび管理 >> レスポンススクリプトとレスポンスファイル」

[update-sensor-grouping-tags.ps1] の USER CONFIG セクションに 1. で取得した API ID および SECRET を入力して、スクリプトに入力する
（ワークフローとのスクリプト共有へのチェックも後続のFusionでの利用時に必須）

<img width="819" alt="image" src="https://github.com/user-attachments/assets/40099b98-1223-498a-b646-dad1e58875d8" />


[input-json.json] を入力スキーマに入力

この時点で、RTRとして本スクリプトは利用可能。Fusionワークフローの活用例として 3. で後続の手順を実施する

### 3. Fusion ワークフローの作成

本スクリプトの使用例として、特定のFalcon グルーピングタグを有している端末に対して、センサーグルーピングタグを書き換えるというワークフローを作成する


ワークフローを新規作成し、トリガーに「オンデマンド」を選択

![image](https://github.com/user-attachments/assets/7fe36af7-24b0-4ea5-bc26-8976f73a91b9)

右上に表示されるスキーマビルダーで任意の名称のString オブジェクトを作成しておく（以下では、NewTagsというオブジェクト）

![image](https://github.com/user-attachments/assets/021a9735-f1f0-4e31-835a-d7eef9d5ebc6)

次に、Actionから「Device Query」を選択

![image](https://github.com/user-attachments/assets/14625ff9-9305-4b37-a26b-b60736f5afc6)

ここでは例として、FalconGroupingTags/ReplaceTagsというタグが付与されている端末を対象にする

![image](https://github.com/user-attachments/assets/51f781bc-ee0e-45d7-9a0b-bbda3bee720e)

次に、ループを選択し、For eachで作成

![image](https://github.com/user-attachments/assets/aa1e7541-a6f2-49d7-bc4f-d12f017b3ffa)

次に、ループ内の最初の処理として「Get Device Details」を選択する（今回のカスタムスクリプト実行のためには、対象端末がWindowsであることを示す必要があるため）

![image](https://github.com/user-attachments/assets/35c528c3-2e5a-4df2-ae0f-2a1e634cc80a)

次に、「条件」を選択して「Platform が Windows」であることを指定

![image](https://github.com/user-attachments/assets/057cf9b7-6cad-46ee-87dd-264ebe404830)

次に、2. で作成したカスタムスクリプトを呼び出す（この例では Custom - Set Sensor Grouping Tags というアクション）

![image](https://github.com/user-attachments/assets/dcd45dfd-a28d-4462-96d6-6a735f4e0517)

このアクションにはTagsに何のパラメータを渡すかを指定する必要があるため、オンデマンドトリガーを作成した際に入力したString オブジェクトを選択する（ここではNewTags）

![image](https://github.com/user-attachments/assets/7f1d08cc-92c2-4e1e-8365-7d0e428af2bf)

最後に、アクションとして「Remove Falcon Grouping Tags」を選択

![image](https://github.com/user-attachments/assets/631d5a6a-f32f-4bf9-970e-17925b189234)

FalconGroupingTags/ReplaceTags を選択して削除しておく

![image](https://github.com/user-attachments/assets/637f1874-a477-4c3b-9ab3-a24e6c539661)

以下のようなワークフローが完成する

![image](https://github.com/user-attachments/assets/fafaf4f7-8b71-4c82-872e-490c7842e349)

### 4. ワークフローの実行

完成したワークフローを実行する

![image](https://github.com/user-attachments/assets/bf5f9838-ef27-4a4f-a387-4efb63781161)

NewTagsオブジェクトに設定をしたいタグ名を入力する（注意：複数入力時はカンマ区切りでスペースなしで入力すること）

![image](https://github.com/user-attachments/assets/22fd4ad2-f759-4d88-aed7-72bf187353a0)

ワークフローを実行すれば、対象端末のセンサーグルーピングタグがNewTagsで入力したタグにアップデートされる



以上

