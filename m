From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to
 enqueue 'XPT_DEAD' transports
Date: Sun, 04 Jan 2009 14:25:31 -0500
Message-ID: <1231097131.7363.11.camel@heimdal.trondhjem.org>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228090815.7112.15.camel@heimdal.trondhjem.org>
	 <49491C58.9@opengridcomputing.com>
	 <1229540877.7257.97.camel@heimdal.trondhjem.org>
	 <495E8AB2.8020805@opengridcomputing.com>
	 <1231096358.7363.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45923 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbZADTZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Jan 2009 14:25:43 -0500
In-Reply-To: <1231096358.7363.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-01-04 at 14:12 -0500, Trond Myklebust wrote:
> On Fri, 2009-01-02 at 15:44 -0600, Tom Tucker wrote:
> > Bruce/Trond:
> > 
> > This is an alternative to patches 2 and 3 from Trond's fix. I think 
> > Trond's fix is correct, but I believe this approach to be simpler.
> > 
> > From: Tom Tucker <tom@opengridcomputing.com>
> > Date: Wed, 31 Dec 2008 17:18:33 -0600
> > Subject: [PATCH] svc: Clean up deferred requests on transport destruction
> > 
> > A race between svc_revisit and svc_delete_xprt can result in
> > deferred requests holding references on a transport that can never be
> > recovered because dead transports are not enqueued for subsequent
> > processing.
> > 
> > Check for XPT_DEAD in revisit to clean up completing deferrals on a dead
> > transport and sweep a transport's deferred queue to do the same for queued
> > but unprocessed deferrals.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> >  net/sunrpc/svc_xprt.c |   20 +++++++++++++++-----
> >  1 files changed, 15 insertions(+), 5 deletions(-)
> > 
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index bf5b5cd..92ca5c6 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -837,6 +837,11 @@ static void svc_age_temp_xprts(unsigned long closure)
> >  void svc_delete_xprt(struct svc_xprt *xprt)
> >  {
> >         struct svc_serv *serv = xprt->xpt_server;
> > +       struct svc_deferred_req *dr;
> > +
> > +       /* Only do this once */
> > +       if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
> > +               return;
> > 
> >         dprintk("svc: svc_delete_xprt(%p)\n", xprt);
> >         xprt->xpt_ops->xpo_detach(xprt);
> > @@ -851,12 +856,16 @@ void svc_delete_xprt(struct svc_xprt *xprt)
> >          * while still attached to a queue, the queue itself
> >          * is about to be destroyed (in svc_destroy).
> >          */
> > -       if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
> > -               BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
> > -               if (test_bit(XPT_TEMP, &xprt->xpt_flags))
> > -                       serv->sv_tmpcnt--;
> > +       if (test_bit(XPT_TEMP, &xprt->xpt_flags))
> > +               serv->sv_tmpcnt--;
> > +
> > +       for (dr = svc_deferred_dequeue(xprt); dr;
> > +            dr = svc_deferred_dequeue(xprt)) {
> >                 svc_xprt_put(xprt);
> > +               kfree(dr);
> >         }
> > +
> > +       svc_xprt_put(xprt);
> >         spin_unlock_bh(&serv->sv_lock);
> >  }
> > 
> > @@ -902,7 +911,8 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
> >                 container_of(dreq, struct svc_deferred_req, handle);
> >         struct svc_xprt *xprt = dr->xprt;
> > 
> > -       if (too_many) {
> > +       if (too_many || test_bit(XPT_DEAD, &xprt->xpt_flags)) {
> > +               dprintk("revisit cancelled\n");
> >                 svc_xprt_put(xprt);
> >                 kfree(dr);
> >                 return;
> > 
> 
> I see nothing that stops svc_delete_xprt() from setting XPT_DEAD after
> the above test in svc_revisit(), and before the test inside
> svc_xprt_enqueue(). What's preventing a race there?

I suppose one way to fix it would be to hold the xprt->xpt_lock across
the above test, and to make sure that you set XPT_DEFERRED while holding
the lock, and _before_ you test for XPT_DEAD. That way, you guarantee
that the svc_deferred_dequeue() loop in svc_delete_xprt() will pick up
anything that races with the setting of XPT_DEAD.

Trond

