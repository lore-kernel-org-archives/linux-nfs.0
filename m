Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51557 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbbELTRI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2015 15:17:08 -0400
Date: Tue, 12 May 2015 15:17:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH v2] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Message-ID: <20150512191708.GA8980@fieldses.org>
References: <20150507140814.GF27106@fieldses.org>
 <1431124677-13388-1-git-send-email-andreas.gruenbacher@gmail.com>
 <20150511122611.GA5732@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150511122611.GA5732@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 11, 2015 at 02:26:11PM +0200, Christoph Hellwig wrote:
> On Sat, May 09, 2015 at 12:37:57AM +0200, Andreas Gruenbacher wrote:
> > NFSv2 can set the atime and/or mtime of a file to specific timestamps but not
> > to the server's current time.  To implement the equivalent of utimes("file",
> > NULL), it uses a heuristic.
> > 
> > NFSv3 and later do support setting the atime and/or mtime to the server's
> > current time directly.  The NFSv2 heuristic is still enabled, and causes
> > timestamps to be set wrong sometimes.
> > 
> > Fix this by moving the heuristic into the NFSv2 specific code.  We can leave it
> > out of the create code path: the owner can always set timestamps arbitrarily,
> > and the workaround would never trigger.
> > 
> > Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> 
> This looks fine,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Yep, thanks, applying for 4.2.

--b.
