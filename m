Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34097 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753753AbZB0LFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Feb 2009 06:05:13 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Ld0Wf-0004Z2-0p
	for linux-nfs@vger.kernel.org; Fri, 27 Feb 2009 22:05:05 +1100
From: Thorsten Meinl <Thorsten.Meinl@uni-konstanz.de>
To: nfs@lists.sourceforge.net
Date: Fri, 27 Feb 2009 12:04:05 +0100
Message-Id: <200902271204.05099.Thorsten.Meinl@uni-konstanz.de>
Subject: [NFS] Write stalls over UDP and Gigabit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,

Ich have to computer connected via Gigabit Ethernet via just one switch. I did 
some experiments with dd from one computer to the other and got only rates of 
about 10MB/s. Looking further at it, it looks quite strange: for the first 
few seconds the transmission rate is at about 100MB/s which one would expect. 
Then it drops down to about 20MB/s and then to only a few megabytes. Using 
Wireshark I found out the following (this is a dump from the client that 
writes the 10GB file):


    302 0.048432    192.168.224.75        192.168.224.206       IP       
Fragmented IP protocol (proto=UDP 0x11, off=5920) [Reassembled in #303]
    303 0.048433    192.168.224.75        192.168.224.206       NFS      V3 
WRITE Call (Reply In 311), FH:0xdde80f28 Offset:2243969024 Len:8192 UNSTABLE
    304 0.048515    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 254) Len:8192 UNSTABLE
    305 0.048522    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 262) Len:8192 UNSTABLE
    306 0.048527    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 268) Len:8192 UNSTABLE
    307 0.048637    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 277) Len:8192 UNSTABLE
    308 0.048762    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 283) Len:8192 UNSTABLE
    309 0.048768    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 289) Len:8192 UNSTABLE
    310 0.048887    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 295) Len:8192 UNSTABLE
    311 0.048894    192.168.224.206       192.168.224.75        NFS      V3 
WRITE Reply (Call In 303) Len:8192 UNSTABLE
    312 0.200814    192.168.224.75        192.168.224.206       IP       
Fragmented IP protocol (proto=UDP 0x11, off=0) [Reassembled in #317]
    313 0.200822    192.168.224.75        192.168.224.206       IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480) [Reassembled in #317]
    314 0.200824    192.168.224.75        192.168.224.206       IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960) [Reassembled in #317]

There is a 0.2s delay between packet 311 and 312 and it is totally uncleat to 
me what could be the cause, as the reply for the last write call in 303 
arrived in 311. So what is NFS waiting for (This situation occurs frequently 
and I assume this is the cause of the very low throughput).
The server storage system and the network cannot be the problem because using 
sshfs I get rates of about 80MB/s and the bottleneck here is the CPU at the 
client side.
I also tried TCP and there the rates are slightly better but still do not 
exceed ~20MB/s.
Does anyone have an idea or any hints how I can debug this further? And yes, I 
already tried the various suggestions in the FAQs like increasing receive 
buffer sizes and such.

Regards,

Thorsten


-- 
Thorsten Meinl                        room: Z815
Nycomed Chair for Bioinformatics      fax: +49 (0)7531 88-5132
and Information Mining                phone: +49 (0)7531 88-5016
Box 712, 78457 Konstanz, Germany

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

