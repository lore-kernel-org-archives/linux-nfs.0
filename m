Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:39783 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab3IEQmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 12:42:43 -0400
MIME-Version: 1.0
In-Reply-To: <12EF8D94C6F8734FB2FF37B9FBEDD173585722AA@EXCHANGE.collogia.de>
References: <12EF8D94C6F8734FB2FF37B9FBEDD173585722AA@EXCHANGE.collogia.de>
Date: Thu, 5 Sep 2013 09:42:42 -0700
Message-ID: <CABgxfbF6iWsDei3De0ePsrVnA-a3vYuUbD07Bog6m1Mquy6Ecw@mail.gmail.com>
Subject: Re: Strange NFS client ACK behaviour
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Markus Stockhausen <stockhausen@collogia.de>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CC linux-nfs .. maybe this is obvious to someone there ... Two
comments inlined below.

On Tue, Sep 3, 2013 at 11:28 AM, Markus Stockhausen
<stockhausen@collogia.de> wrote:
> Hello,
>
> we observed a performance drop in our IPoIB NFS backup
> infrastructure since we switched to machines with newer
> kernels. As I do not know where to start I hope someone
> on this list can give me hint where to dig for more details.

In case of no other reply, I would start w/ a socket program (or a
network performance measuring tool) on the interface that does similar
logic as "dd" you described below; that is, send a 256K message in a
fixed number of loops (so total transfer size somewhere close to your
file size) between client and server, followed by comparing the
interrupt counters (cat /proc/interrtups) on both kernels. If the
interrupt count differs as you described, the problem is most likely
with the IB driver, not NFS layer.

>
> To make a long story short. We use ConnectX cards with the
> standard kernel drivers on version 2.6.32 (Ubuntu 10.04), 3.5
> (Ubuntu 12.04) and 3.10 (Fedora 19). The very simple and not
> scientific test consists of mounting a NFS share using IPoIB UD
> network interfaces at MTU of 2044. Afterwards read a large file
> on the client side with dd if=file of=/dev/null bs=256K.
> During the transfer we run a tcpdump on the ibX interface on
> the NFS server side. No special settings for kernel parameters
> until now.

I don't know much about ConnectX. Not sure what "IPoIB UD" means ?
"Datagram vs. CM" or "TCP vs. UDP" ?

>
> When doing the test with a 2.6.32 kernel based client we see the
> following packet sequence. More or less a lot of transferd blocks
> from the NFS server to the client with sometimes an ACK package
> from the client to the server:
>
> 16:16:45.050930 IP server.nfs > cli_2_6_32.896:
>   Flags [.], seq 8909853:8913837, ack 1154149,
>   win 604, options [nop,nop,TS val 1640401415
>   ecr 3881919089], length 3984
> 16:16:45.050936 IP server.nfs > cli_2_6_32.896:
>   Flags [.], seq 8913837:8917821, ack 1154149,
>   win 604, options [nop,nop,TS val 1640401415
>   ecr 3881919089], length 3984
>
> ... 8 more ...
>
> 16:16:45.050976 IP cli_2_6_32.896 > server.nfs:
>   Flags [.], ack 8909853, win 24574, options
>   [nop,nop,TS val 3881919089 ecr 1640401415],
>   length 0
> ...
>
> After switchng to a client with a newer kernel (3.5 or 3.10) the
> sequence all of a sudden gives just the opposite behaviour.
> One should note that this is the same server as in the test
> above. The server sends bigger packets (I guess TSO is doing
> the rest of the work). After each packet the client sends
> several ACK packages back.
>
> 16:15:21.038782 IP server.nfs > cli_3_5_0.928:
>   Flags [.], seq 9612429:9652269, ack 372776,
>   win 5815, options [nop,nop,TS val 1640380412
>   ecr 560111379], length 39840
> 16:15:21.038806 IP cli_3_5_0.928 > server.nfs:
>   Flags [.], ack 9542205, win 16384, options
>   [nop,nop,TS val 560111379 ecr 1640380412],
>   length 0
> 16:15:21.038812 IP cli_3_5_0.928 > server.nfs:
>   Flags [.], ack 9546077, win 16384, options
>   [nop,nop,TS val 560111379 ecr 1640380412],
> length 0
>
> ... 6-8 more ...
>
> The visible side effects of this changed processing include:
> - NIC interrupts on the NFS servers raise by a factor of 8.
> - Transfer speed lowers by 50% (400->200 MB/sec)
>
> Best regards.
>
> Markus
