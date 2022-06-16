---
title: "個人的ヘッドレス Ubuntu Server 20.04 構築メモ"
date: 2021-10-09
draft: false
---

FPGAや組み込みシステムの開発向けに構築したUbuntu Serverの構築手順メモ。 

<!--more-->

### OSインストールの注意点
- 必要な場合、固定IPアドレスを割り当てる。
- インストール先のボリューム選択時にデフォルトでLVMが有効になっているので無効にする。
- opensshの公開鍵はGitHubアカウントから取得する仕組みがあるので利用すると便利。

### アップデートと不要なパッケージの削除
{{< highlight shell >}}
$ sudo apt update && sudo apt upgrade
$ sudo apt purge plymouth cloud-init apport*
$ sudo apt --purge autoremove
{{< / highlight >}}
- plymouth ... 起動スプラッシュとかを出す仕組み。
- cloud-init ... IaaS向けに仮想マシンの初期設定を自動化するための仕組み。
- apport* ... クラッシュレポートをカノニカルに送信する仕組み。

### 起動時のネットワーク接続待ちの無効化
ネットワークI/Fが有効だけど未接続の場合、networkdがOS起動時に接続待ちになるのでこれを無効化する。
{{< highlight shell >}}
$ sudo systemctl disable systemd-networkd-wait-online.service
$ sudo systemctl mask systemd-networkd-wait-online.service
{{< / highlight >}}

### xfce4とtigervncの導入
FPGAの開発環境はGUIを使う場合が多いので、VNCでリモートデスクトップ環境を構築する。
1. 環境のインストール
{{< highlight shell >}}
$ sudo apt install xfce4 xfce4-goodies tigervnc-common tigervnc-standalone-server tigervnc-xorg-extension firefox
{{< / highlight >}}
xfce4のインストール時にディスプレイマネージャとしてgdm3とlighdmのどちらをインストールするか聞かれるので、
とりあえずlightdmを選択する。ディスプレイマネージャは使わないのでアンインストールする。
{{< highlight shell >}}
$ sudo apt purge lightdm
{{< / highlight >}}

2. VNC接続パスワードの設定
{{< highlight shell >}}
$ vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
{{< / highlight >}}

3. xstartupの設定  
~/.vnc/xstartupに次のスクリプトを入力して保存する。
{{< highlight shell >}}
#!/bin/bash
xrdb $HOME/.Xresources
exec xfce4-session &
{{< / highlight >}}

4. VNCサーバの起動
以下のコマンドでVNCサーバを起動する。
{{< highlight shell >}}
$ vncserver -localhost no -SecurityTypes VncAuth,TLSVnc -geometry 1920x1080 -depth 24
{{< / highlight >}}
起動中のセッション・ポート番号・ディスプレイ番号の確認
{{< highlight shell >}}
$ vncserver -list

TigerVNC server sessions:

X DISPLAY #     RFB PORT #      PROCESS ID
:1              5901            75572
{{< / highlight >}}
サーバーの切断は以下のコマンドの通り。
{{< highlight shell >}}
$ vncserver -kill :<ディスプレイ番号>
{{< / highlight >}}

### シリアルコンソールにログインプロンプトを表示させる
PCにシリアルポートがあり、OSから/dev/ttyS\*が見える場合はシリアルコンソールを有効にできる(USBシリアル変換の場合は/dev/ttyUSB\*)。
グラフィック出力がなく、SSHサーバが死んでネットワークからログインが不能となった場合に使える。

管理者権限で/etc/default/grubの10行目を次のように編集する。
{{< highlight shell >}}
GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200n8"
{{< / highlight >}}
上記の場合は/dev/ttyS0、ボーレート115200baudという設定。  
以下コマンドで設定を適用して再起動。
{{< highlight shell >}}
$ sudo update-grub
$ sudo reboot
{{< / highlight >}}

Ubuntu Serverのインストールディスクのカーネルコマンドラインを上のように編集しておくと、OSのインストール自体もシリアルコンソール経由で可能になる。起動ディスクが内臓ストレージではなくインストールディスクになっている時は有用。

