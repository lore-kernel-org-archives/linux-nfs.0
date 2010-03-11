From: Brandon Simmons <brandon.m.simmons@gmail.com>
Subject: [NFS] Very Slow Sequential Reads over NFS from an XFS disk in
	Amazon EC2
Date: Thu, 11 Mar 2010 16:40:39 -0500
Message-ID: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52703 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab0CKVqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Mar 2010 16:46:51 -0500
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NpqDR-0007xT-KQ
	for linux-nfs@vger.kernel.org; Fri, 12 Mar 2010 08:46:49 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am using tiobench to test performance of an NFS mounted volume, and
notice that Sequential Reads are much slower than Random Reads. This
isn't the behavior when I run the same test on the disk mounted
locally.

For random reads I'm getting:

    50 MB/s  over NFS

v.s

    384 MB/s  when mounted locally

This is in comparison to the benchmark for _Random Reads_, in which I get:

    288 MB/s both over NFS _and_ when directly mounted

The other benchmarks seem to be in line with what I would expect, but
I'm fairly new to NFS. Why would sequential reads over NFS be sooo
much slower than random reads over NFS?

I am exporting the volume on the server like this

/export *.internal(no_subtree_check,rw,no_root_squash)

and mounting with this:

mount -o hard,intr,async,noatime,nodiratime,noacl $NFS_SERVER:/export /nfs

Additionally I am doing all this in amazon EC2, exporting an EBS
volume with the XFS file system (redundant, I know).

I have tried using jumbo frames and various other mount options, but
none seem to have much effect.

Thanks for any clues.

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

