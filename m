Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37370 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065Ab0JYXIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 19:08:30 -0400
Date: Tue, 26 Oct 2010 10:08:21 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 4/4] svcrpc: svc_tcp_sendto XTP_DEAD check is redundant
Message-ID: <20101026100821.46a5ae4d@notabene>
In-Reply-To: <20101025174632.GA9520@pad.home.fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
	<1287969693-12340-4-git-send-email-bfields@redhat.com>
	<20101025131024.1addf30d@notabene>
	<20101025150308.GB3233@fieldses.org>
	<20101025174632.GA9520@pad.home.fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 25 Oct 2010 13:46:32 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> On Mon, Oct 25, 2010 at 11:03:08AM -0400, J. Bruce Fields wrote:
> > On Mon, Oct 25, 2010 at 01:10:24PM +1100, Neil Brown wrote:
> > > On Sun, 24 Oct 2010 21:21:33 -0400
> > > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > > 
> > > > The only caller (svc_send) has already checked XPT_DEAD.
> > > > 
> > > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > > ---
> > > >  net/sunrpc/svcsock.c |    3 ---
> > > >  1 files changed, 0 insertions(+), 3 deletions(-)
> > > > 
> > > > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > > > index 1454739..07919e1 100644
> > > > --- a/net/sunrpc/svcsock.c
> > > > +++ b/net/sunrpc/svcsock.c
> > > > @@ -1135,9 +1135,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
> > > >  	reclen = htonl(0x80000000|((xbufp->len ) - 4));
> > > >  	memcpy(xbufp->head[0].iov_base, &reclen, 4);
> > > >  
> > > > -	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
> > > > -		return -ENOTCONN;
> > > > -
> > > >  	sent = svc_sendto(rqstp, &rqstp->rq_res);
> > > >  	if (sent != xbufp->len) {
> > > >  		printk(KERN_NOTICE
> > > 
> > > 
> > > So after removing all these references to XPT_DEAD, do we need XPT_DEAD at
> > > all???
> > > 
> > > I think it is only used in two other places.
> > > 
> > > 1/ In svc_revisit we don't queue the deferred request to an XPT_DEAD
> > >   transport.
> > >   We could avoid that but changing the 'owner' of a deferred request from the
> > >   service to the xprt, and call cache_clean_deferred in svc_delete_xprt
> > 
> > That use does seem a bit of a hack to me, so I'd be happy to get rid of
> > it.
> 
> Eh, but then don't we end up doing the same check when deferring, to
> prevent deferring a request on a dead xprt?

Good point.
However....

If we change svc_defer to set handle.owner to rqstp->rq_xprt rather than
rqstp->rq_server (As already suggested), then we don't need the svc_xprt_get.
i.e. the deferred request doesn't need to hold a reference to the xprt,
because when the xprt is finally removed it is easy (cache_clean_deferred) to
remove all those deferred requests.
So we put the call to cache_clean_deferred in svc_xprt_free.  By this stage
we are guaranteed not to get more deferrals as the xprt is dead.

> 
> Maybe we should leave well enough alone here.

That is certainly an option, especially if it turns out that we cannot remove
XPT_DEAD completely.

Thanks,
NeilBrown

> 
> --b.

