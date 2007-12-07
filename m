From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFSv2/3 broken exporting/mounting (permission denied)
	in	2.6.24-rc4
Date: Thu, 6 Dec 2007 21:55:04 -0500
Message-ID: <20071207025504.GA3070__43318.8839968809$1196996158$gmane$org@fieldses.org>
References: <200712070220.lB72Kfqw004530@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47931 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901AbXLGCz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 21:55:27 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0TN6-0006Gh-H0
	for linux-nfs@vger.kernel.org; Fri, 07 Dec 2007 13:55:24 +1100
In-Reply-To: <200712070220.lB72Kfqw004530-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2007 at 09:20:41PM -0500, Erez Zadok wrote:
> I get a "permission denied" when trying to mount a localhost nfsv2/3
> exported volume, on v2.6.24-rc4-124-gf194d13.  It works w/ nfsv4 mounting.
> It worked fine in 2.6.24-rc3.  Here's a sequence of ops I tried:
> 
> # mount -t ext2 /dev/hdb1 /n/lower/b0
> # exportfs -o no_root_squash,rw localhost:/n/lower/b0
> # mount -t nfs -o nfsvers=3 localhost:/n/lower/b0 /mnt

What do you see if you watch the network traffic in ethereal?

--b.

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

