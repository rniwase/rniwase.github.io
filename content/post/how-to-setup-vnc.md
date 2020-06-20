---
title: "VNCサーバ設定と接続手順"
date: 2020-06-14T07:51:50+09:00
draft: false
---
ヘッドレス運用の開発マシンをセットアップするとき、VNCサーバの設定方法をよく忘れるのでメモ。  
<!--more-->

### VNCサーバ設定
- OS: Ubuntu Server 18.04  

1. 環境のインストール
{{< highlight shell >}}
$ sudo apt update
$ sudo apt install xfce4 xfce4-goodies tightvncserver firefox
{{< / highlight >}}


2. VNC接続パスワードの設定
{{< highlight shell >}}
$ vncpasswd
Using password file /home/<ユーザ名>/.vnc/passwd
VNC directory /home/<ユーザ名>/.vnc does not exist, creating.
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
{{< / highlight >}}
パスワードは9文字以上だと`Warning: password truncated to the length of 8.`と表示されて8文字に短縮されるので注意。

3. VNCサーバを起動
{{< highlight shell >}}
$ vncserver
xauth:  file /home/<ユーザ名>/.Xauthority does not exist

New 'X' desktop is <ホスト名>:<ディスプレイ番号>

Creating default startup script /home/<ユーザ名>/.vnc/xstartup
Starting applications specified in /home/<ユーザ名>/.vnc/xstartup
Log file is /home/<ユーザ名>/.vnc/<ホスト名>:<ディスプレイ番号>.log
{{< / highlight >}}
サーバは初回起動時にホームディレクトリ内で`.vnc`や`.Xauthority`などのファイルを生成する。
他にVNCサーバを起動しているユーザがいなければ、ディスプレイ番号は1になる。
自分または他のユーザが特にディスプレイ番号を指定せずVNCサーバを起動していくと2, 3...と順番にディスプレイ番号が増える。

4. 設定ファイルを編集する
{{< highlight shell >}}
$ vncserver -kill :<ディスプレイ番号>
{{< / highlight >}}
で一度VNCサーバを閉じて
`~/.vnc/xstartup`を次のように編集する（そのままだとアイコンが表示されなかったりする）。
{{< highlight shell >}}
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
{{< / highlight >}}
再度VNCサーバを起動する。
{{< highlight shell >}}
$ vncserver
{{< / highlight >}}

- 運用方法  
OSを再起動したときユーザは`vncserver`コマンドを叩いて再度VNCサーバを起動する必要がある。  
画面の解像度と色深度を変更したい場合、以下のようにサーバ起動時に設定する。  
{{< highlight shell >}}
$ vncserver -depth 24 -geometry 1920x1080
{{< / highlight >}}

### クライアント接続手順
###### Ubuntu Desktop 18.04  
[Remmina](https://remmina.org/)というリモートデスクトップクライアントが標準でインストールされているのでこれを使う。
1. Remminaを起動する。
2. ＋ボタンを押す
3. 次のように各項目を設定する。
- `Name` : `<適当な表示名>`
- `Protocol` : `VNC - Virtual Network Computing`
- `Server` : `<接続先アドレス>:<ポート番号>` (<ポート番号>=5900+<ディスプレイ番号>)  
例 : `192.168.1.100:5901`
- `User password` : `<vncpasswdで設定したパスワード>`
- `Color depth` : `True color (24 bpp)`
- `Quality` : `Medium`
4. `Save and Connect`を押す。
5. 接続が確立するとリモート画面が表示される。  
次回以降は一覧に表示された項目をダブルクリックすると接続できるようになる。

###### macOS  
OS標準のクライアントを使う。
1. Finderを開いて、`メニュー -> 移動 -> サーバへ接続...`を押す。
2. サーバアドレスに`vnc://<接続先アドレス>:<ポート番号>/`を入力して接続を押す(`<ポート番号>=5900+<ディスプレイ番号>`)。  
例 : `vnc://192.168.1.100:5901/`
3. 画面共有が起動してパスワードを聞かれるので、`vncpasswd`で設定したパスワードを入力して接続を押す。
4. 接続が確立するとリモート画面が表示される。

###### Windows
[RealVNC VNC Viewer](https://realvnc.com/en/connect/download/viewer/windows/)を使う。  
1. VNC Viewerをダウンロードしてインストールする。
2. VNC Viewerを起動する。
3. `Enter a VNC Server address or search`に`<接続先アドレス>:<ポート番号>`を入力して接続を押す(`<ポート番号>=5900+<ディスプレイ番号>`)。  
例 : `192.168.1.100:5901`
4. `Unencrypted connection`という警告ウィンドウが出るので`Continue`を押して続行する。
5. パスワードを聞かれるので、`vncpasswd`で設定したパスワードを入力して`OK`を押す。
6. 接続が確立するとリモート画面が表示される。  
次回以降は一覧に表示された項目をダブルクリックすると接続できるようになる。

###### 初回接続時  
初回接続時に`Welcome to the first start of the panel`というウィンドウが表示されるので`Use default config`を押して閉じる。  
もしWebブラウザ、ターミナルのアイコンを押しても起動しなければ、
`Applications -> Settings -> Preferred Applications`を開いて
`Internetタブ -> Web Browser`が`Mozilla Firefox`に、
`Utilitiesタブ -> Terminal Emulator`が`Xfce Terminal`に設定されているか確認する。

#### セキュリティについて
VNCプロトコルでは映像の転送が暗号化されていないので、そのままだと通信内容から映像を傍受できてしまう。
通信を暗号化するにはSSHのポートフォワーディング機能を使う。

具体的には、クライアントからサーバに対してSSHでログインできる状態で、
{{< highlight shell >}}
$ ssh <ユーザ名>@<接続先アドレス> -L <ポート番号>:localhost:<ポート番号> -f -N
例 :
$ ssh user@192.168.1.100 -L 5901:localhost:5901 -f -N
{{< / highlight >}}
をターミナルで実行したあとに、VNCクライアントで`localhost:<ポート番号>`に接続するとVNC over SSHが実現できる。

VNCクライアントによっては接続時にSSHポートフォワーディングを設定してくれる機能を持つものもある。  
例えば、Remminaだと設定画面の`SSH Tunnel`タブで

- `Enable SSH tunnel`にチェックを入れる。  
- `SSH Authentication`の`User name`にログインユーザ名を入れる。  
- パスワード認証なら`Password`にチェック、公開鍵認証なら`Public key(automatic)`にチェックをいれる。  

と設定すると、接続するときに自動的にSSHポートフォワーディングを設定してくれる。
