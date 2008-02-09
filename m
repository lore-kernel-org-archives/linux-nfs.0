From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sat, 09 Feb 2008 15:40:11 -0500
Message-ID: <1202589611.11035.0.camel@heimdal.trondhjem.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52134 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402AbYBIUkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Feb 2008 15:40:43 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNwV8-0004ow-Cb
	for linux-nfs@vger.kernel.org; Sun, 10 Feb 2008 07:40:42 +1100
In-Reply-To: <20080209213511.59ff4e2c-mgABNEgzgxm+PRNnhPf8W5YgPPQkE1Si@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sat, 2008-02-09 at 21:35 +0100, Pierre Ossman wrote:

> > > 
> > > So, would it be possible to actually make the kernel realise that the
> > > source and target are in face the same fs on the server (so a NFS
> > > rename will succeed)? Or at least make the kernel present different
> > > device st_dev for the two trees.
> > 
> > I believe the same thing happens even with --bind mounts of the same
> > local filesystem, and that it's by design.  See this discussion:
> > 
> > 	http://marc.info/?t=119801816800006&r=1&w=2
> > 
> 
> They make some sound arguments for it, so I guess the optimisation is out of the question. I also couldn't find anything in POSIX linking rename() and st_dev, so it should be fine from a strict interpretation of the spec. Still, it is a bit unexpected to get -EXDEV when st_dev is the same for both points.
> 
> I though the NFS client allocates "fake" st_dev numbers to guarantee the st_dev/st_ino uniqueness, so how come each mount point doesn't get a new one?

It has the same syntax and properties as a bind mount. If you don't like
it, then fix the VFS.

Trond


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

