From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sun, 10 Feb 2008 10:57:33 -0500
Message-ID: <20080210155733.GC25571@fieldses.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
	<20080210152618.GB25571@fieldses.org>
	<20080210153340.GB14540@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34518 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbYBJP6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2008 10:58:07 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOEZA-0007vq-B9
	for linux-nfs@vger.kernel.org; Mon, 11 Feb 2008 02:58:04 +1100
In-Reply-To: <20080210153340.GB14540@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 10, 2008 at 10:33:40AM -0500, Christoph Hellwig wrote:
> On Sun, Feb 10, 2008 at 10:26:18AM -0500, J. Bruce Fields wrote:
> > > The point of the setup is of course to avoid exposing more information
> > > than is necessary, while still having the benefit of having a single
> > > pool of disk space for all exported resources.
> > 
> > I notice that btrfs claims support for "subvolumes"--multiple filesystem
> > namespaces sharing the same storage.  Seems like a useful feature for
> > this situation.  I don't know whether it'd be possible to add to other
> > filesystems.
> 
> That stuff is done using a code sniplet from me, which does nothing but
> allowing to mount into a subdirectory of a filesystem.  It will look
> exactly the same as bind mounts.

To get the equivalent of subtree checking, we also need a reference from
each inode back to the subvolume it belongs to, so we can determine the
subvolume from a filehandle.  I assume that's a more intrusive change.

--b.

> I have hacked up implementations for
> ext2 and xfs aswell and in the form btfs does it currently it would
> be doable for any filesystem.  But to actually make it useful you'd
> need quotas for each subvolume which is something currently only
> xfs could provide (if I could be arsed into finally implementing
> my multiple subvolumes proposal fully).
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

