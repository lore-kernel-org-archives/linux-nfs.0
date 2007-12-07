From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: [NFS] NFSv2/3 broken exporting/mounting (permission denied) in
	2.6.24-rc4
Date: Thu, 6 Dec 2007 21:20:41 -0500
Message-ID: <200712070220.lB72Kfqw004530__45412.4415097342$1196994102$gmane$org@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57408 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbXLGCU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 21:20:59 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0Spk-0006EG-Qb
	for linux-nfs@vger.kernel.org; Fri, 07 Dec 2007 13:20:56 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get a "permission denied" when trying to mount a localhost nfsv2/3
exported volume, on v2.6.24-rc4-124-gf194d13.  It works w/ nfsv4 mounting.
It worked fine in 2.6.24-rc3.  Here's a sequence of ops I tried:

# mount -t ext2 /dev/hdb1 /n/lower/b0
# exportfs -o no_root_squash,rw localhost:/n/lower/b0
# mount -t nfs -o nfsvers=3 localhost:/n/lower/b0 /mnt

Erez.

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

