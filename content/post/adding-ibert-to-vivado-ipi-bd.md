---
title: "Vivado IP IntegratorのBD上にIBERTを追加する"
date: 2022-05-03T02:03:33+09:00
---
<!--more-->
Xilinx Vertex Ultrascale+のプロジェクトを触っているときに、Block DesignのAdd IPから"IBERT Ultrascale GTY"が追加できないのに気付いた。  

解決策として、Tclコンソールに次のコマンドを流すことでIPが追加できるようになる。  

{{< highlight tcl >}}
set_param bd.skipSupportedIPCheck 1
{{< / highlight >}}

IBERT以外にもBDサポート外のIPがAdd IPの一覧に表示される(例えばavalon)が、それらがまともに使えるかどうかは不明。IBERTはちゃんと使えた。  
"In System IBERT"はBDに追加できるので、なんなんだろうという気持ち(その程度RTLでインスタンシエートしなさいよというXilinxの意向？)。  
