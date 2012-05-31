Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:36482 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447Ab2EaGrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 02:47:12 -0400
Message-ID: <4FC713ED.5040807@msgid.tls.msk.ru>
Date: Thu, 31 May 2012 10:47:09 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: 3.0+ NFS issues
References: <4FBF2C57.3070203@msgid.tls.msk.ru> <20120529152416.GC3441@fieldses.org> <4FC5C82E.4020806@msgid.tls.msk.ru> <20120530132518.GA13794@fieldses.org>
In-Reply-To: <20120530132518.GA13794@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 30.05.2012 17:25, J. Bruce Fields wrote:
> On Wed, May 30, 2012 at 11:11:42AM +0400, Michael Tokarev wrote:
[]
> That's not what I meant.  During one of these read stalls, if you watch
> the network with wireshark, do you see any NFS traffic between the
> client and server?

Oh.  Indeed, I misunderstood.

And no, during these stalls, there's no network activity at all.
Here's the typical scenario:

...
10:38:53.781990 IP (tos 0x0, ttl 64, id 35131, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.2.880 > 192.168.88.4.2049: Flags [.], cksum 0x317e (incorrect -> 0xb43d), ack 89530281, win 23173, options [nop,nop,TS val 3298129 ecr 122195208], length 0
10:38:53.782000 IP (tos 0x0, ttl 64, id 6329, offset 0, flags [DF], proto TCP (6), length 1500)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0xe827 (correct), seq 89530281:89531729, ack 40321, win 6289, options [nop,nop,TS val 122195208 ecr 3298129], length 1448
10:38:53.782027 IP (tos 0x0, ttl 64, id 6330, offset 0, flags [DF], proto TCP (6), length 1708)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0x37f6 (incorrect -> 0x6790), seq 89531729:89533385, ack 40321, win 6289, options [nop,nop,TS val 122195208 ecr 3298129], length 1656
10:38:53.782029 IP (tos 0x0, ttl 64, id 35132, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.2.880 > 192.168.88.4.2049: Flags [.], cksum 0x317e (incorrect -> 0xa81d), ack 89533385, win 23173, options [nop,nop,TS val 3298129 ecr 122195208], length 0
10:38:53.782040 IP (tos 0x0, ttl 64, id 6333, offset 0, flags [DF], proto TCP (6), length 1500)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0x0d5b (correct), seq 89534833:89536281, ack 40321, win 6289, options [nop,nop,TS val 122195208 ecr 3298129], length 1448
10:38:53.782082 IP (tos 0x0, ttl 64, id 6334, offset 0, flags [DF], proto TCP (6), length 4396)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0x4276 (incorrect -> 0x778a), seq 89536281:89540625, ack 40321, win 6289, options [nop,nop,TS val 122195208 ecr 3298129], length 4344
10:38:53.782088 IP (tos 0x0, ttl 64, id 35134, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.2.880 > 192.168.88.4.2049: Flags [.], cksum 0x317e (incorrect -> 0x8bd5), ack 89540625, win 23173, options [nop,nop,TS val 3298129 ecr 122195208], length 0
10:38:53.782096 IP (tos 0x0, ttl 64, id 6337, offset 0, flags [DF], proto TCP (6), length 1500)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0x835d (correct), seq 89540625:89542073, ack 40321, win 6289, options [nop,nop,TS val 122195208 ecr 3298129], length 1448
10:38:53.827355 IP (tos 0x0, ttl 64, id 35160, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1396548098 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827379 IP (tos 0x0, ttl 64, id 35161, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1413325314 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827385 IP (tos 0x0, ttl 64, id 35162, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1430102530 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827400 IP (tos 0x0, ttl 64, id 35163, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1446879746 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827406 IP (tos 0x0, ttl 64, id 35164, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1463656962 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827409 IP (tos 0x0, ttl 64, id 35165, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1480434178 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827413 IP (tos 0x0, ttl 64, id 35166, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1497211394 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827417 IP (tos 0x0, ttl 64, id 35167, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1513988610 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827420 IP (tos 0x0, ttl 64, id 35168, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1530765826 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827424 IP (tos 0x0, ttl 64, id 35169, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1547543042 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827427 IP (tos 0x0, ttl 64, id 35170, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1564320258 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827434 IP (tos 0x0, ttl 64, id 35171, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1581097474 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827438 IP (tos 0x0, ttl 64, id 35172, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1597874690 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827443 IP (tos 0x0, ttl 64, id 35173, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1614651906 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827447 IP (tos 0x0, ttl 64, id 35174, offset 0, flags [DF], proto TCP (6), length 268)
    192.168.88.2.1631429122 > 192.168.88.4.2049: 212 getattr fh 0,0/22
10:38:53.827673 IP (tos 0x0, ttl 64, id 6428, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0xe4e5 (correct), ack 41617, win 6289, options [nop,nop,TS val 122195221 ecr 3298142], length 0
10:38:53.827699 IP (tos 0x0, ttl 64, id 6429, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0xdfd4 (correct), ack 42913, win 6289, options [nop,nop,TS val 122195221 ecr 3298143], length 0
10:38:53.865036 IP (tos 0x0, ttl 64, id 6430, offset 0, flags [DF], proto TCP (6), length 52)
    192.168.88.4.2049 > 192.168.88.2.880: Flags [.], cksum 0xdd40 (correct), ack 43561, win 6289, options [nop,nop,TS val 122195233 ecr 3298143], length 0
[pause]
^C

192.168.88.2 is the client, .4 is the server.

I'm not sure if the series of getattr requests from the client is
right before or right after the beginning of the stall, but after
the 3 last replies from server there's no other activity for a
long time, and the server is eating 100% available CPU as I described
previously.

> Also: do you have a reliable way of reproducing this quickly?

Yes, it is enough to start copying any large file and in a few
seconds the first stall happens.

Can you suggest something for the other part of the question:

>> Can at least the client be made interruptible?  Mounting with
>> -o intr,soft makes no visible difference...

please? :)

Thank you!

/mjt
