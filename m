From: Neil Brown <neilb@suse.de>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Sat, 21 Feb 2009 08:06:20 +1100
Message-ID: <18847.6988.418374.839185@notabene.brown>
References: <18846.4842.625445.980681@notabene.brown>
	<1235156207.31066.21.camel@heimdal.trondhjem.org>
	<18847.2578.480148.216735@notabene.brown>
	<1235161966.31066.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40890 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218AbZBTVG2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 16:06:28 -0500
In-Reply-To: message from Trond Myklebust on Friday February 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday February 20, trond.myklebust@fys.uio.no wrote:
> On Sat, 2009-02-21 at 06:52 +1100, Neil Brown wrote:
> > On Friday February 20, trond.myklebust@fys.uio.no wrote:
> > > It should work fine. The ctime tracks the mtime in all cases except when
> > > you setacl, setfattr, chown, chgrp, chmod, or touch the directory. Those
> > > should be very rare operations for pretty much any workload...
> > > 
> > 
> > Does that mean you'll take the patch ??
> 
> Not as it stands. You really want to be calling
> nfs_force_lookup_revalidate() instead of invalidating the directory
> contents.

Surely it is 'aswell' rather than 'instead' ??
I need 
   invalid |= NFS_INO_INVALID_DATA;
to flush the readdir cache, and
   nfs_force_lookup_revalidate(inode)
to flush the lookup cache 
??

I'll respin the patches later today.

Thanks,
NeilBrown
