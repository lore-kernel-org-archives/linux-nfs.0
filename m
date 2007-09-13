From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATH 08/19] jfs: new export ops
Date: Thu, 13 Sep 2007 15:59:34 +0200
Message-ID: <20070913135933.GA11411@lst.de>
References: <20070830131632.GI6834@lst.de>
	<20070910194533.GA18793@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	nfs@lists.sourceforge.net, Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVpEK-0000t6-Cj
	for nfs@lists.sourceforge.net; Thu, 13 Sep 2007 06:59:40 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IVpEN-0004xF-OY
	for nfs@lists.sourceforge.net; Thu, 13 Sep 2007 06:59:45 -0700
In-Reply-To: <20070910194533.GA18793@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, Sep 10, 2007 at 03:45:33PM -0400, J. Bruce Fields wrote:
> On Thu, Aug 30, 2007 at 03:16:32PM +0200, Christoph Hellwig wrote:
> > Trivial switch over to the new generic helpers.
> > -	    	result = ERR_PTR(-ESTALE);
> > -		goto out_iput;
> > +		iput(inode);
> > +	    	return ERR_PTR(-ESTALE);
> 
> For some reason you're introducing a bunch of whitespace damage on lines
> like that last one.  Would you mind running these through checkpatch.pl
> or whatever and then resending?
> 
> Other than that I can't find any problem, and it seems like an obvious
> improvement, though I'd like to see Neil take a look.  Do you want these
> added to the nfsd patches for 2.6.24?

Yes, please add them to the queue.  I've put a quilt series of patches
with the whitespace fixe on http://verein.lst.de/~hch/patches.nfsd.tgz.
Do you want to take it that way or should I resend everything to the
list?

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
