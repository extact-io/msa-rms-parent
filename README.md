# Rental Management System Application 
> Rental Management System(RMS)は[Helidon](https://helidon.io/)を用いてマイクロサービスやMicroProfileの利用法や効果を確認することを目的としたリファレンス的なアプリケーションです。  

## Table of Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# アプリケーション機能
RMSは会員がレンタル品を予約するアプリケーションで管理機能としてマスターデータをメンテナンスする機能を持っています。なお、実装している機能は予約まででレンタルを行う機能はまだ持っていません

| 分類 | 機能 | 内容 |
|------|------|------|
|会員機能|レンタル品検索|レンタル品を検索し予約状況の確認ができます|
||レンタル品予約|予約したいレンタル品を選択しレンタル期間を指定した予約ができます|
||予約確認|自分の予約を確認したりキャンセルしたりすることができます|
|管理機能|レンタル品管理|レンタル品の登録や更新などを行うことができます|
||予約管理|登録されたレンタル予約の削除や変更を行うことができます|
||ユーザ管理|ユーザの登録や更新、削除などを行うことができます|
|共通機能|ログイン/ログアウト|システムへのログインとログアウト|
||ユーザプロファイル|ユーザが自分の登録情報を確認、変更ができます|

:information_desk_person: INFO
手っ取り早く動くものを見たい方は[こちら](https://app.rms.extact.io/) <a href="https://app.rms.extact.io" target="_dummy">新規タブで開く</a>のデモアプリをお試しください。

# サービス構成
RMSは次のアプリケーションから構成されるマイクロサービスアーキテクチャになっています。

![service_overview](./docs/service_overview.drawio.svg)

DBはh2のインメモリデータベースを使ったDatabase per Service構成にしている  

|要素|説明|
|---|----|
|ApiGateway| 主に以下の役割を担う<br>- フロントエンドに対するFacade<br>- フロントエンドとバックエンドのデータモデルの変換<br>- ユーザ認証と後段サービスへの認証情報の伝播|
|RentalItemService|レンタル品を管理するサービス|
|ReservationService|予約を管理するサービス|
|UserService|ユーザを管理するサービス|
|SPAクライアント|ReactによるSPAのUIアプリ|
|CLIクライアント|JavaSEによるコンソールUIアプリ |

なお、SPA,CLIのどちらでもレンタル品の予約や管理を行うことができるが、CLIアプリはSPAアプリよりもできることが少なくなっている。

:warning: WARNIG  
サンプルとして扱いやすいように小さいサービスを使っていますが、実業務ではこのような小さな粒度マイクロサービス化することはお勧めしません。マイクロサービスアーキテクチャで得られるメリットよりもデメリットの方が大きくなります。

# repository構成
RMSを構成する各アプリケーションやライブラリはマルチレポ形式で次のように管理されている

|repository| 説明 |
|----------|------|
|[msa-rms](/msa-rms-parent/)| 親pomや共通的なGitHub Actionsのワークフローなどの共通定義を格納しているリポジトリ |
|[msa-rms-platform](/msa-rms-platform/)| サービスに依らない基盤的な仕組みを提供する。このリポジトリ内だけはMavenのマルチモジュールによるモノレポ形式になっている。詳細はレポジトリの[README](/msa-rms-platform/README.md)を参照 |
|[msa-rms-apigateway](/msa-rms-apigateway/)| ApiGatewayを格納するリポジトリ |
|[msa-rms-service-item](/msa-rms-service-item/)| RentalItemServiceを格納するリポジトリ |
|[msa-rms-service-reservation](/msa-rms-service-reservation/)| ReservationServiceを格納するリポジトリ |
|[msa-rms-service-user](/msa-rms-service-user/)| UserServiceを格納するリポジトリ |
|[msa-rms-ui-console](/msa-rms-ui-console/)| RMSのコンソールアプリを格納するリポジトリ |

## Reactアプリのrepository構成
Reactアプリを構成するrepositoryにはApiGatewayの[ソースコード](/msa-rms-apigateway/src/main/java/io/extact/msa/rms/apigateway/webapi/ApiGatewayResource.java)からMicroProfile OpenAPIで出力したOAS情報(openapi.yml)をもとにOpenAPI Generatorで自動生成したAPI Clientのコードを格納するrepositoryも含まれる。このrepository間の関係は次のとおり

![react_rep_relations](./docs/react_rep_relations.drawio.svg)

|repository| 説明 |
|---|---|
|[rms-ui-react](/rms-ui-react)|ReactによるrmsののSPAフロントエンドアプリのリポジトリ |
|[rms-generated-client-js](/rms-generated-client-js)| OpenAPI Generatorで生成したAPI Clientコードを格納するリポジトリ |
|[msa-rms-apigateway](/msa-rms-apigateway/)|openapi.ymlを出力するアプリのリポジトリ|

# システムアーキテクチャ
ローカルでも動作するがAWS上の次の構成をアプリケーションを動作させるターゲット環境としている。なお、CI/CDにはGitHub ActionsをContainerRegistryにはGitHub Packagesを使っている。

![aws_arch](./docs/aws_arch.drawio.svg)

バックエンドサービスをPrivate subnetに配置することのみ必須とし、他はコストを最優先の構成にしている。このため、敢えて以下の構成としている
- 高可用性は求めない。よって、シングルAZ構成にして高額なALBも利用していない
- ECRは有料のためContainer RegistryにはGitHub Packagesを使用する
- Private Subnetからインターネットへアクセスする方法はNATゲートウェイなどいくつかあるが、スポットインスタンスを使うことで利用料を大きく抑えることができるNATインスタンスとして使う方式にしている
- EC2インスタンスをNATインスタンスだけで使うのはもったいないので、DockerをインストールしApiGatewayを相乗りさせている
- サービス間通信はService Connectを使いたいところだが上述のとおり呼び出しの起点となるApiGatewayをアンマネージドなDockerで動かすためService Connectを使うことはできない。よって、Service Desicovery方式で行っている
- CI/CDはGitHub Actionが無料のため、一部を除きAWSのCodeシリーズは使用しない
- 誰も使わない深夜にサービスを起動しておくのはもったいないため、午後11時から翌9時の間はECS(Fargate)を停止する

# アプリケーションアーキテクチャ
## 論理アーキテクチャ
ApiGatwayやReservationServiceなどのバックエンドアプリはいずれも次に示すDomainレイヤをリラックスレイヤにした一般的なレイヤーアーキテクチャを採用している

![layer_arch](./docs/layer_arch.drawio.svg)
