From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sun, 10 Feb 2008 10:33:40 -0500
Message-ID: <20080210153340.GB14540@infradead.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
	<20080210152618.GB25571@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45961 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbYBJPeq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2008 10:34:46 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOECa-0007rx-Md
	for linux-nfs@vger.kernel.org; Mon, 11 Feb 2008 02:34:44 +1100
In-Reply-To: <20080210152618.GB25571@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 10, 2008 at 10:26:18AM -0500, J. Bruce Fields wrote:
> > The point of the setup is of course to avoid exposing more information
> > than is necessary, while still having the benefit of having a single
> > pool of disk space for all exported resources.
> 
> I notice that btrfs claims support for "subvolumes"--multiple filesystem
> namespaces sharing the same storage.  Seems like a useful feature for
> this situation.  I don't know whether it'd be possible to add to other
> filesystems.

That stuff is done using a code sniplet from me, which does nothing but
allowing to mount into a subdirectory of a filesystem.  It will look
exactly the same as bind mounts.  I have hacked up implementations for
ext2 and xfs aswell and in the form btfs does it currently it would
be doable for any filesystem.  But to actually make it useful you'd
need quotas for each subvolume which is something currently only
xfs could provide (if I could be arsed into finally implementing
my multiple subvolumes proposal fully).


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

