From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Sun, 10 Feb 2008 13:21:21 -0500
Message-ID: <20080210182121.GA5247@infradead.org>
References: <20080209200503.6a11e88b@poseidon.drzeus.cx>
	<20080209191021.GE25533@fieldses.org>
	<20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
	<20080210152618.GB25571@fieldses.org>
	<20080210153340.GB14540@infradead.org>
	<20080210155733.GC25571@fieldses.org>
	<20080210155923.GA15345@infradead.org>
	<20080210181053.GD25571@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39702 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769AbYBJSVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Feb 2008 13:21:38 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOGo3-0008O7-OO
	for linux-nfs@vger.kernel.org; Mon, 11 Feb 2008 05:21:35 +1100
In-Reply-To: <20080210181053.GD25571@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 10, 2008 at 01:10:53PM -0500, J. Bruce Fields wrote:
> > XFS actually has the infrastructure for that by having a project id
> > that's inheritable to child directories/files.  But to actuall make
> > that useable we'd have to encode it in the fsid.  I must admit
> > I haven't thought that far yet.
> 
> It'd be useful for nfsd.  So if you have any design notes or anything
> I'd be interested.

http://verein.lst.de/~hch/xfs/xfs-multiple-containers.txt

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

