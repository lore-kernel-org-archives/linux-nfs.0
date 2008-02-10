From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sun, 10 Feb 2008 10:26:18 -0500
Message-ID: <20080210152618.GB25571@fieldses.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40704 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbYBJP0u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2008 10:26:50 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOE4q-0007qY-Q1
	for linux-nfs@vger.kernel.org; Mon, 11 Feb 2008 02:26:44 +1100
In-Reply-To: <20080210131224.1d4ae39f-mgABNEgzgxm+PRNnhPf8W5YgPPQkE1Si@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 10, 2008 at 01:12:24PM +0100, Pierre Ossman wrote:
> On Sat, 9 Feb 2008 18:14:35 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > > 
> > > I don't think I find that an acceptable answer. Giving all systems complete access to your entire server side storage isn't really acceptable in many situations.
> > 
> > I'd be curious to know what you're actually trying to accomplish.  If
> > you're mounting subdirectories of the same server filesystem, then you
> > need to be aware that, for example, anyone with access to the network
> > can probably access that whole filesystem by guessing filehandles (which
> > is very easy).
> > 
> 
> I thought the subtree check prevented that?

Yes, at the expense of odd behavior in a couple corner cases: the parent
directory is encoded in the filehandle, so, for example, a client
holding a file open will get ESTALE if it moves to a different
directory.

> The point of the setup is of course to avoid exposing more information
> than is necessary, while still having the benefit of having a single
> pool of disk space for all exported resources.

I notice that btrfs claims support for "subvolumes"--multiple filesystem
namespaces sharing the same storage.  Seems like a useful feature for
this situation.  I don't know whether it'd be possible to add to other
filesystems.

--b.

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

