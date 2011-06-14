Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:54160 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756354Ab1FNLfR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 07:35:17 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 5AA246FC34
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 13:07:12 +0200 (CEST)
Received: from [129.183.101.222] (pa-129.183.101.222.frec.bull.fr [129.183.101.222])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id 52A45272F3
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 13:07:10 +0200 (CEST)
Message-ID: <4DF7406A.7040704@bull.net>
Date: Tue, 14 Jun 2011 13:05:14 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: re: [PATCH] SUNRPC: Never reuse the socket port after an xs_close()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have applied the patch for a 2.6.32, and dispite this patch the client reuses the port number on reconnect:

   1 09:38:58.513579  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [SYN] Seq=0 Win=5840 Len=0 MSS=1460 WS=8
   2 09:38:58.513655 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0 MSS=1460 WS=2
   3 09:38:58.513687  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [ACK] Seq=1 Ack=1 Win=5888 Len=0
   4 09:38:58.513708  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [FIN, ACK] Seq=1 Ack=1 Win=5888 Len=0
   5 09:38:58.513763 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP [TCP Window Update] nfs > ideafarm-door [ACK] Seq=1 Ack=1 Win=262140 Len=0
   6 09:38:58.513779 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [ACK] Seq=1 Ack=2 Win=262140 Len=0
   7 09:38:59.262101 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [FIN, ACK] Seq=1 Ack=2 Win=262140 Len=0
   8 09:38:59.262116  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [ACK] Seq=2 Ack=2 Win=5888 Len=0

   9 09:40:32.253796  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP [TCP Port numbers reused] ideafarm-door > nfs [SYN] Seq=0 Win=5840 Len=0 MSS=1460 WS=8
  10 09:40:32.253926 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0 MSS=1460 WS=2
  11 09:40:32.253959  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [ACK] Seq=1 Ack=1 Win=5888 Len=0
  12 09:40:32.253992  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [FIN, ACK] Seq=1 Ack=1 Win=5888 Len=0
  13 09:40:32.254047 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP [TCP Window Update] nfs > ideafarm-door [ACK] Seq=1 Ack=1 Win=262140 Len=0
  14 09:40:32.254063 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [ACK] Seq=1 Ack=2 Win=262140 Len=0
  15 09:40:32.254639 DLL.Q.SCO.SUH -> DLL.Q.UJ.RS  TCP nfs > ideafarm-door [FIN, ACK] Seq=1 Ack=2 Win=262140 Len=0
  16 09:40:32.254654  DLL.Q.UJ.RS -> DLL.Q.SCO.SUH TCP ideafarm-door > nfs [ACK] Seq=2 Ack=2 Win=5888 Len=0

What else should be patched?

Thanks in advance,

Zoltan Menyhart

