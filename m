From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Failure to fallback to nfsd-v3 (?)
Date: Mon, 8 Feb 2010 13:31:06 -0500
Message-ID: <20100208183106.GB10665@fieldses.org>
References: <87pr4h67rf.fsf@devron.myhome.or.jp> <20100207041016.GA16865@fieldses.org> <8763695u96.fsf@devron.myhome.or.jp> <20100207083103.GA4602@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016Ab0BHSas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 13:30:48 -0500
In-Reply-To: <20100207083103.GA4602@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 07, 2010 at 03:31:03AM -0500, Christoph Hellwig wrote:
> On Sun, Feb 07, 2010 at 05:23:49PM +0900, OGAWA Hirofumi wrote:
> > "J. Bruce Fields" <bfields@fieldses.org> writes:
> > 
> > >> And the following commit seems to change the behavior.
> > >> 
> > >> [nfsd4: fix error return when pseudoroot missing]
> > >> f39bde24b275ddc45df1ed835725b609e178c7a0
> > >> 
> > >> Well, anyway, is this a expected behavior change, or something bug?
> > >
> > > It's expected.  I'd recommend turning off nfsv4 on the server (add "-N4"
> > > to the rpc.nfsd commandline) for now.
> > 
> > This looks like the silent user visible change. So, it would be better
> > to add more comment at least in changelog.
> 
> Or rather it should be fixed.  We should not silently break existing
> and probably rather common setups.

It's really a bug that we're returning an error at all from this point
in the code, so the new client mount code includes a workaround for this
case, added with the code that attempts v4 first by default.

The error we're returning was also wrong.  Unfortunately, my patch to
fix the error went in at around the same time the new mount code went
into nfs-utils, and we communicated poorly about the change.

So:
	- I'm reverting the server patch.  I'd like to reinstate it
	  eventually, depending on how widespread the new mount code
	  was.
	- We'll also make the mount workaround more robust.
	- Most importantly, we need to stamp out the cases where the
	  server hits this error.

--b.
