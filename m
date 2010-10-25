Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39363 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab0JYPDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 11:03:13 -0400
Date: Mon, 25 Oct 2010 11:03:08 -0400
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 4/4] svcrpc: svc_tcp_sendto XTP_DEAD check is redundant
Message-ID: <20101025150308.GB3233@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-4-git-send-email-bfields@redhat.com>
 <20101025131024.1addf30d@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101025131024.1addf30d@notabene>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 25, 2010 at 01:10:24PM +1100, Neil Brown wrote:
> On Sun, 24 Oct 2010 21:21:33 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > The only caller (svc_send) has already checked XPT_DEAD.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/svcsock.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 1454739..07919e1 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1135,9 +1135,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
> >  	reclen = htonl(0x80000000|((xbufp->len ) - 4));
> >  	memcpy(xbufp->head[0].iov_base, &reclen, 4);
> >  
> > -	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
> > -		return -ENOTCONN;
> > -
> >  	sent = svc_sendto(rqstp, &rqstp->rq_res);
> >  	if (sent != xbufp->len) {
> >  		printk(KERN_NOTICE
> 
> 
> So after removing all these references to XPT_DEAD, do we need XPT_DEAD at
> all???
> 
> I think it is only used in two other places.
> 
> 1/ In svc_revisit we don't queue the deferred request to an XPT_DEAD
>   transport.
>   We could avoid that but changing the 'owner' of a deferred request from the
>   service to the xprt, and call cache_clean_deferred in svc_delete_xprt

That use does seem a bit of a hack to me, so I'd be happy to get rid of
it.

> 2/ in svc_send().  I wonder if we need this at all.  There doesn't seem to be
> any locking to ensure that XPT_DEAD doesn't get set immediately after the
> test, and the underlying sendto (whether tcp or udp or whatever) should fail
> if the socket is closed, and if it doesn't it shouldn't really matter??

Does it make a difference in the case of a half-close?  If the client
follows a request immediately by a FIN, and if that results in our
setting DEAD (I think it does, assuming svc_tcp_state_change() is called
in that case), then the current code may have the effect of preventing
us from sending the reply.

I don't know if that's good or bad.

> So can we get rid of XPT_DEAL altogether?

OK, I also had another use in mind: for the purposes of 4.1 (which needs
to know when a connection goes down, e.g. to know that it's no longer
available for callbacks), I added a list of callbacks to the xprt,
called on svc_delete_xprt().

I just noticed that I think my current code allows the 4.1 code to
register an xprt after svc_delete_xprt() is called.  I could fix that
race by checking for DEAD after trying to register.

(That callback code already seems messier than it should be, so maybe
someone else could suggest a better scheme.  I'm stuck.

In any case, it wouldn't be so bad if that were the one remaining use of
DEAD.)

--b.
