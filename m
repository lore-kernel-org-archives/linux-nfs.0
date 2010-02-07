From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Failure to fallback to nfsd-v3 (?)
Date: Sun, 7 Feb 2010 03:31:03 -0500
Message-ID: <20100207083103.GA4602@infradead.org>
References: <87pr4h67rf.fsf@devron.myhome.or.jp> <20100207041016.GA16865@fieldses.org> <8763695u96.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46653 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab0BGIbI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2010 03:31:08 -0500
In-Reply-To: <8763695u96.fsf-x/W9pkDDSe1TgC2z9Sl/nXf5DAMn2ifp@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 07, 2010 at 05:23:49PM +0900, OGAWA Hirofumi wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> >> And the following commit seems to change the behavior.
> >> 
> >> [nfsd4: fix error return when pseudoroot missing]
> >> f39bde24b275ddc45df1ed835725b609e178c7a0
> >> 
> >> Well, anyway, is this a expected behavior change, or something bug?
> >
> > It's expected.  I'd recommend turning off nfsv4 on the server (add "-N4"
> > to the rpc.nfsd commandline) for now.
> 
> This looks like the silent user visible change. So, it would be better
> to add more comment at least in changelog.

Or rather it should be fixed.  We should not silently break existing
and probably rather common setups.

