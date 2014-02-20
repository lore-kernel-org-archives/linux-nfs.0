Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f193.google.com ([209.85.128.193]:55028 "EHLO
	mail-ve0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbaBTPj2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Feb 2014 10:39:28 -0500
Received: by mail-ve0-f193.google.com with SMTP id pa12so595733veb.4
        for <linux-nfs@vger.kernel.org>; Thu, 20 Feb 2014 07:39:27 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 20 Feb 2014 18:39:27 +0300
Message-ID: <CA+NKcRwjoaeQUZEGSeVC+Tfa3jDzvTLt1RBjSQrkj6KJMcC-zg@mail.gmail.com>
Subject: Reliable NFS statistics tool to monitoring all incoming network traffic
From: Pavel Karneliuk <pavel.karneliuk@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello linux-nfs members,

I am looking for some tool for monitoring all incoming traffic on the
wire and collecting NFSv3 operations over TCP transport protocol in
1G-10G networks.

Could you advise me some fast and reliable utility?

I have tried NFSwatch tool, but its results are not reliable.
At first, I mount NFSv3 directory with TCP transport protocol and wsize=512k

sudo mount -v -t nfs 10.6.136.187:/share /mnt/nfs-fedora/ -o
rw,vers=3.0,tcp,wsize=524288

then I write 10Mb file to NFS server:

sudo dd if=/dev/zero of=/mnt/nfs-fedora/zero.data bs=1M count=10

I expect to see 20 WRITE operations (10Mb / 512Kb == 20).
The nfsstat (nfsstat --nfs -3 -Z) shows exactly 20 WRITE operations,
because it takes statistic from the kernel.

When I try to get the same result with NFSwatch by (sudo nfswatch -all
-procs3 -t 20)
I get unreproducible results with 1 or 2 registered WRITE operations.
NFSwatch works well on NFSv3 over UDP, but loses almost all READ/WRITE
operations in case of TCP protocol.
I have checked its source code and found that NFSwatch doesn't
performs reassembling TCP streams between NFS server and NFS client.
It just looks at TCP segment and expects headers of RPC/NFSv3
operations exactly after TCP header.

The tcpdump works similarly. Wireshark(and Tshark) is too slow for
live 1G-10G NFSv3/TCP traffic capturing and filtration.


Would you suggest some alternative utils, solutions or workarounds?


Thanks,
Pavel K
