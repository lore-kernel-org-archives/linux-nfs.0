Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f53.google.com ([209.85.215.53]:55763 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbaAOL5j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jan 2014 06:57:39 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so1328100lan.12
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jan 2014 03:57:37 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 15 Jan 2014 03:57:37 -0800
Message-ID: <CAACXELkPL0g8SNrYWSGoh+-0Uo4pbHeWGa5rtv_7X6vviAnkMQ@mail.gmail.com>
Subject: unable to send TCP SYNs from ports lower than 1024
From: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is anyone else seeing this?  This issue prevents NFS client mounting,
since the NFS client wants to use source ports below 1024

Linux ubuntu 3.8.0-35-generic #50~precise1-Ubuntu SMP Wed Dec 4
17:25:51 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

As I analyze, I use netcat plus wireshark to validate, with wireshark
running on both the client machine and on a second machine plugged
into the local Ethernet switch's SPAN port

This invocation produces outbound TCP SYNs in both traces:
ubuntu# nc -4 -p 1024 10.1.1.1 2049

Whereas this invocation produces TCP SYNs only in the on-board pcap --
the pcap taken from the switch's SPAN port contains nothing (well, it
contains the ARP exchange with10.1.1.1, but no TCP frames).
ubuntu# nc -4 -p 1023 10.1.1.1 2049

I have some evidence to suggest that it appeared in 3.8.0-33 or higher

--sk

Stuart Kendrick
