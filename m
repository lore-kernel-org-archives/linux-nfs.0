Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:60574 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab3FJJQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Jun 2013 05:16:57 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1UlyDf-0007Pu-W0
	for linux-nfs@vger.kernel.org; Mon, 10 Jun 2013 11:16:56 +0200
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1UlyDe-0001CK-6A
	for linux-nfs@vger.kernel.org; Mon, 10 Jun 2013 11:16:54 +0200
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: Kerberized NFS failure with 3.9.0-rc1 (and later)
Date: Mon, 10 Jun 2013 09:16:54 +0000 (UTC)
Message-ID: <kp45i6$3st$1@ultimate100.geggus.net>
References: <3e068504c6a4b683359bad7610d84bc5.squirrel@vdtoorn.nl> <18bf175abb39f6b946156dc44fc9d111.squirrel@vdtoorn.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

richard@vdtoorn.nl wrote:

> Replying to myself, this looks to be the same problem as was reported by
> Sven earlier this week:

Jepp, I think so. Unfortunately I'm a bit stuck in debugging this, as
git-bisect just led me to another variant of broken behaviour (permission
denied instead of infinite hang during mount).

Wireshark output of Kernel 3.9.4 does not look all that interesting either
(10.1.7.30=client, 10.1.7.111=server):

No. Time        Source       Destination           Protocol Length Info
  1 0.000000    10.1.7.30    10.1.7.111            TCP      74     997 > nfs [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSval=1518792 TSecr=0 WS=128
  2 0.000224    10.1.7.111   10.1.7.30             TCP      74     nfs > 997 [SYN, ACK] Seq=0 Ack=1 Win=14480 Len=0 MSS=1460 SACK_PERM=1 TSval=18228 TSecr=1518792 WS=64
  3 0.000250    10.1.7.30    10.1.7.111            TCP      66     997 > nfs [ACK] Seq=1 Ack=1 Win=14720 Len=0 TSval=1518793 TSecr=18228
  4 0.000273    10.1.7.30    10.1.7.111            NFS      110    V4 NULL Call (Reply In 6)
  5 0.000389    10.1.7.111   10.1.7.30             TCP      66     nfs > 997 [ACK] Seq=1 Ack=45 Win=14528 Len=0 TSval=18228 TSecr=1518793
  6 0.000554    10.1.7.111   10.1.7.30             NFS      94     V4 NULL Reply (Call In 4)
  7 0.000564    10.1.7.30    10.1.7.111            TCP      66     997 > nfs [ACK] Seq=45 Ack=29 Win=14720 Len=0 TSval=1518793 TSecr=18228
  8 0.005250    10.1.7.30    10.1.7.111            TCP      74     60072 > nfs [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSval=1518794 TSecr=0 WS=128
  9 0.005393    10.1.7.111   10.1.7.30             TCP      74     nfs > 60072 [SYN, ACK] Seq=0 Ack=1 Win=14480 Len=0 MSS=1460 SACK_PERM=1 TSval=18229 TSecr=1518794 WS=64
 10 0.005409    10.1.7.30    10.1.7.111            TCP      66     60072 > nfs [ACK] Seq=1 Ack=1 Win=14720 Len=0 TSval=1518794 TSecr=18229
 11 0.006228    10.1.7.30    10.1.7.111            NFS      1450   V4 NULL Call (Reply In 13)
 12 0.006393    10.1.7.111   10.1.7.30             TCP      66     nfs > 60072 [ACK] Seq=1 Ack=1385 Win=17408 Len=0 TSval=18230 TSecr=1518794
 13 0.016922    10.1.7.111   10.1.7.30             NFS      298    V4 NULL Reply (Call In 11)
 14 0.016938    10.1.7.30    10.1.7.111            TCP      66     60072 > nfs [ACK] Seq=1385 Ack=233 Win=15744 Len=0 TSval=1518797 TSecr=18232
 15 0.017931    10.1.7.30    10.1.7.111            NFS      126    V4 NULL Call
 16 0.017950    10.1.7.30    10.1.7.111            NFS      270    V4 Call SETCLIENTID
 17 0.017956    10.1.7.30    10.1.7.111            TCP      66     60072 > nfs [FIN, ACK] Seq=1445 Ack=233 Win=15744 Len=0 TSval=1518797 TSecr=18232
 18 0.018916    10.1.7.111   10.1.7.30             TCP      66     nfs > 60072 [FIN, ACK] Seq=233 Ack=1446 Win=17408 Len=0 TSval=18233 TSecr=1518797
 19 0.018935    10.1.7.30    10.1.7.111            TCP      66     60072 > nfs [ACK] Seq=1446 Ack=234 Win=15744 Len=0 TSval=1518797 TSecr=18233
 20 0.056246    10.1.7.111   10.1.7.30             TCP      66     nfs > 997 [ACK] Seq=29 Ack=249 Win=15552 Len=0 TSval=18242 TSecr=1518797
Communication stalls here..

Sven

-- 
"Those who do not understand Unix are condemned to reinvent it, poorly"
(Henry Spencer)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
