Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:38905 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146Ab2CKCCS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Mar 2012 21:02:18 -0500
Received: from cpe-74-73-178-142.nyc.res.rr.com ([74.73.178.142] helo=vostro)
	by ebox.rath.org with esmtps (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.71)
	(envelope-from <Nikolaus@rath.org>)
	id 1S6XgQ-0002hq-8D
	for linux-nfs@vger.kernel.org; Sun, 11 Mar 2012 01:34:50 +0000
From: Nikolaus Rath <Nikolaus@rath.org>
To: linux-nfs@vger.kernel.org
Subject: NFS4 over VPN hangs when connecting > 2 clients
Date: Sat, 10 Mar 2012 20:34:44 -0500
Message-ID: <878vj7x6mj.fsf@vostro.rath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I am experiencing system hangs when running NFSv4 over a tinc VPN. I
don't know if the problem is with NFS or tinc and would appreciate any
suggestions on how to narrow down the culprit. Unfortunately I cannot
simply run NFS directly over TCP -- the participating systems are
connected only over an open network.

The configuration is as follows: I have a main server that exports the
NFS shares and also acts as hub for the VPN. All other clients connect
to the main server to establish the VPN, and then mount the NFS shares
over the VPN.

I am using kernel 3.0.0, 64bit Ubuntu 10.04 LTS on both server and
clients.

On the server:
# cat /etc/exports
/srv/nfs4 -ro,no_subtree_check,fsid=root 192.168.1.1/24
/srv/nfs4/home -rw,async,no_subtree_check 192.168.1.1/24
/srv/nfs4/opt -rw,async,no_subtree_check 192.168.1.1/24
/srv/nfs4/hbt -rw,async,no_subtree_check 192.168.1.1/24

On the clients:
# cat /etc/hostconf/all/etc/fstab | grep -i nfs
spitzer:/opt /opt        nfs4    bg 0  0
spitzer:/home /home          nfs4    bg 0  0

The problem is that as soon as more than three clients are accessing the
NFS shares, any operations on the NFS mountpoints by the clients hang.
At the same time, CPU usage of the VPN processes becomes very high. If I
run the VPN in debug mode, all I can see is that it is busy forwarding
lots of packets. I also ran a packet sniffer which showed me that 90% of
the packets were NFS related, but I am not familiar enough with NFS to
be able to tell anything from the packets themselves. I can provide an
example of the dump if that helps.


Any suggestions how I could further debug this?


Best,


   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
