From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFSv2/3 broken exporting/mounting (permission denied)
	in	2.6.24-rc4
Date: Fri, 7 Dec 2007 10:32:31 -0500
Message-ID: <20071207153230.GA20872@fieldses.org>
References: <200712071054.lB7AscVW002471@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47725 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754119AbXLGPct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 10:32:49 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0fC2-00074K-9y
	for linux-nfs@vger.kernel.org; Sat, 08 Dec 2007 02:32:46 +1100
In-Reply-To: <200712071054.lB7AscVW002471-gq7oiAaKCbRt3AgVzhmPzw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 07, 2007 at 11:54:38AM +0100, Mikael Pettersson wrote:
> On Thu, 6 Dec 2007 21:20:41 -0500, Erez Zadok wrote:
> > I get a "permission denied" when trying to mount a localhost nfsv2/3
> > exported volume, on v2.6.24-rc4-124-gf194d13.  It works w/ nfsv4 mounting.
> > It worked fine in 2.6.24-rc3.  Here's a sequence of ops I tried:
> > 
> > # mount -t ext2 /dev/hdb1 /n/lower/b0
> > # exportfs -o no_root_squash,rw localhost:/n/lower/b0
> > # mount -t nfs -o nfsvers=3 localhost:/n/lower/b0 /mnt
> 
> I'm seeing something similar too. NFSv3 export of an ext3 partition
> to another machine in my lan fails (client gets permission denied)
> when the server runs 2.6.24-rc4. It worked fine in 2.6.24-rc3.
> 
> There's no NFSv4 of any kind on either client or server.

And you're not varying the client at all, you're only changing the
kernel version on the server?

There are literally no commits between v2.6.24-rc3 and v2.6.24-rc4 which
touch fs/nfsd/.  What filesystem are you exporting?  Are the nfs-utils
versions the same in both cases?

Also, could you get a network trace showing the failure?

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

