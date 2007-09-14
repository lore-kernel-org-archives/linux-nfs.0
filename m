From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 00/19] export operations rewrite
Date: Fri, 14 Sep 2007 19:00:25 +0200
Message-ID: <20070914170025.GA8594@lst.de>
References: <20070914114746.GA28282@lst.de>
	<20070914164355.GD26622@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	nfs@lists.sourceforge.net, hch@lst.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWEWt-0001SZ-1K
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 10:00:31 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IWEWw-0000vJ-Cl
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 10:00:35 -0700
In-Reply-To: <20070914164355.GD26622@fieldses.org>
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

On Fri, Sep 14, 2007 at 12:43:55PM -0400, J. Bruce Fields wrote:
> I'm hoping Neil can take a quick look as well (and make a response to
> the comment on patch #1 along the way).

The exportfs_d_alloc one?  I have a patch for the done, I just need
to run it through my testing setup before sending it out.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
