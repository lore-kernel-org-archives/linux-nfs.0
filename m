From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: [NFS] sync, async, write speeds.
Date: Wed, 17 Sep 2008 09:35:15 +0200
Message-ID: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42924 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbYIQIA5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 04:00:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Kfry2-00021u-0z
	for linux-nfs@vger.kernel.org; Wed, 17 Sep 2008 18:00:54 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

I'm using NFS to mount /home on a gigabit network.
/etc/exports on the server
/home  192.168.2.48/255.255.255.248(rw,no_root_squash,sync,no_subtree_check)

/proc/mount on the client
home_server:/home /home nfs
rw,vers=3,rsize=32768,wsize=32768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.2.22
0 0

Write performance is not good.

dd if=/dev/zero of=/home/testfile bs=16k count=16384
268435456 bytes (268 MB) copied, 45.0461 seconds, 6.0 MB/s

If I change the export to async, it improves a lot.

dd if=/dev/zero of=./testfile bs=16k count=16384
268435456 bytes (268 MB) copied, 3.6 seconds, 74.4 MB/s

But the recommendation is not to use async, right?

I've tried the same thing on two different servers (one xenified
kernel, one stock etch kernel) and two different clients (ubuntu 7.10
y debian etch), with the same results. :(
Where should I start looking to fix this?

Thanks.
Chris.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

