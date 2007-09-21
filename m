From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 02/18] exportfs: add new methods
Date: Fri, 21 Sep 2007 10:01:39 +0200
Message-ID: <20070921080139.GA4928@lst.de>
References: <20070919163025.GC18952@lst.de>
	<20070920171840.0c6949a6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYdSM-00048b-GM
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 01:01:46 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IYdSP-0005fe-VP
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 01:01:51 -0700
In-Reply-To: <20070920171840.0c6949a6.akpm@linux-foundation.org>
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

On Thu, Sep 20, 2007 at 05:18:40PM -0700, Andrew Morton wrote:
> On Wed, 19 Sep 2007 18:30:25 +0200
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > +		/*
> > +		 * It's not a directory.  Life is a little more complicated.
> > +		 */
> > +		struct dentry *target_dir, *nresult;
> > +		char nbuf[NAME_MAX+1];
> 
> Lots of stack usage there.

True.  But this is just copying the old code around to make use of the
new methods, so I didn't want to mess with underlying details.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
