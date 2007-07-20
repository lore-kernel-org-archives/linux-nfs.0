From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix horrible indentation in nfsd_setattr
Date: Fri, 20 Jul 2007 15:19:30 -0400
Message-ID: <20070720191930.GJ6514@fieldses.org>
References: <20070307152625.GA29633@infradead.org>
	<20070513204407.GC13563@infradead.org>
	<20070720184923.GA24937@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBy0i-0002VA-Dn
	for nfs@lists.sourceforge.net; Fri, 20 Jul 2007 12:19:32 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IBy0l-00030q-0P
	for nfs@lists.sourceforge.net; Fri, 20 Jul 2007 12:19:36 -0700
In-Reply-To: <20070720184923.GA24937@infradead.org>
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

On Fri, Jul 20, 2007 at 07:49:23PM +0100, Christoph Hellwig wrote:
> On Sun, May 13, 2007 at 09:44:07PM +0100, Christoph Hellwig wrote:
> > On Wed, Mar 07, 2007 at 03:26:25PM +0000, Christoph Hellwig wrote:
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > ping?
> 
> ping^2

Git is whining because the indention for the first line of multi-line
comments has spaces in between two tabs.

Other than that seems fine, thanks.  I've added it to my tree and will
submit it eventually if nobody else picks it up....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
