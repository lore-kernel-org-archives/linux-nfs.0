From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Mon, 11 Feb 2008 11:21:36 -0500
Message-ID: <20080211162136.GK25742@fieldses.org>
References: <20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
	<20080210152618.GB25571@fieldses.org>
	<20080210153340.GB14540@infradead.org>
	<20080210155733.GC25571@fieldses.org>
	<20080210155923.GA15345@infradead.org>
	<20080210181053.GD25571@fieldses.org>
	<20080210182121.GA5247@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40507 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755562AbYBKQWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 11:22:02 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JObPn-00057U-BR
	for linux-nfs@vger.kernel.org; Tue, 12 Feb 2008 03:21:55 +1100
In-Reply-To: <20080210182121.GA5247@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 10, 2008 at 01:21:21PM -0500, Christoph Hellwig wrote:
> On Sun, Feb 10, 2008 at 01:10:53PM -0500, J. Bruce Fields wrote:
> > > XFS actually has the infrastructure for that by having a project id
> > > that's inheritable to child directories/files.  But to actuall make
> > > that useable we'd have to encode it in the fsid.  I must admit
> > > I haven't thought that far yet.
> > 
> > It'd be useful for nfsd.  So if you have any design notes or anything
> > I'd be interested.
> 
> http://verein.lst.de/~hch/xfs/xfs-multiple-containers.txt

Excellent, thanks, yes that's just what we'd want....

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

