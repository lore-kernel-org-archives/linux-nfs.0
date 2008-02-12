From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] -EXDEV between mounts that are same fs
Date: Mon, 11 Feb 2008 23:54:04 -0500
Message-ID: <20080212045404.GA625@infradead.org>
References: <20080209213511.59ff4e2c@poseidon.drzeus.cx>
	<20080209231435.GA20501@fieldses.org>
	<20080210131224.1d4ae39f@poseidon.drzeus.cx>
	<20080210152618.GB25571@fieldses.org>
	<20080210153340.GB14540@infradead.org>
	<20080210155733.GC25571@fieldses.org>
	<20080210155923.GA15345@infradead.org>
	<20080210181053.GD25571@fieldses.org>
	<20080210182121.GA5247@infradead.org>
	<20080211162136.GK25742@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53604 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbYBLFn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 00:43:28 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JOnvR-0007Vi-Ll
	for linux-nfs@vger.kernel.org; Tue, 12 Feb 2008 16:43:25 +1100
In-Reply-To: <20080211162136.GK25742@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 11:21:36AM -0500, J. Bruce Fields wrote:
> > http://verein.lst.de/~hch/xfs/xfs-multiple-containers.txt
> 
> Excellent, thanks, yes that's just what we'd want....

The proposal still lacks the idea of encoding the projid in the file
handle.  But I think we could do that quite easily, but I'd do it after
my planned next round of the export interface cleanups, so that a
filehandle can see at mount time how much of the filehandle space it
has left and refuse the export if it doesn't fit (e.g. exporting with
various 64bit inode fields and NFSv2, or projids on NFSv2)


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

