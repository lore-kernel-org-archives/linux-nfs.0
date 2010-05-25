From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SQUASHME: nfsd4: fix cb_recall encoding
Date: Tue, 25 May 2010 14:49:01 -0400
Message-ID: <20100525184900.GD7085@fieldses.org>
References: <20100524152825.GB18625@fieldses.org> <4BFB6AAA.5090308@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Groshans <groshans@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44151 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933161Ab0EYStB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 14:49:01 -0400
In-Reply-To: <4BFB6AAA.5090308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 25, 2010 at 09:14:02AM +0300, Benny Halevy wrote:
> On May. 24, 2010, 18:28 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > "nfsd: nfs4callback encode_stateid helper function" forgot to reserve
> > more space after return from the new helper.
> > 
> > Reported-by: Michael Groshans <groshans@citi.umich.edu>
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfsd/nfs4callback.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > Benny, maybe you could fix that patch and then pass it upstream?
> 
> Sure.  I submitted this fix to the pnfs tree and will test and
> send a fixed version of "nfsd: nfs4callback encode_stateid helper function"
> upstream.

That's what I meant to say, yes, thanks!

--b.

> 
> Benny
> 
> > 
> > --b.
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index b279738..238e0b8 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -246,6 +246,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
> >  	RESERVE_SPACE(4);
> >  	WRITE32(OP_CB_RECALL);
> >  	encode_stateid(xdr, &dp->dl_stateid);
> > +	RESERVE_SPACE(8 + (XDR_QUADLEN(len) << 2));
> >  	WRITE32(0); /* truncate optimization not implemented */
> >  	WRITE32(len);
> >  	WRITEMEM(&dp->dl_fh.fh_base, len);
> 
