Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57360 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab0JZBd5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Oct 2010 21:33:57 -0400
Date: Mon, 25 Oct 2010 21:33:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 4/4] svcrpc: svc_tcp_sendto XTP_DEAD check is redundant
Message-ID: <20101026013354.GK13523@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
 <1287969693-12340-4-git-send-email-bfields@redhat.com>
 <20101025131024.1addf30d@notabene>
 <20101025150308.GB3233@fieldses.org>
 <20101025174632.GA9520@pad.home.fieldses.org>
 <20101026100821.46a5ae4d@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026100821.46a5ae4d@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 10:08:21AM +1100, Neil Brown wrote:
> On Mon, 25 Oct 2010 13:46:32 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > On Mon, Oct 25, 2010 at 11:03:08AM -0400, J. Bruce Fields wrote:
> > > On Mon, Oct 25, 2010 at 01:10:24PM +1100, Neil Brown wrote:
> > > > On Sun, 24 Oct 2010 21:21:33 -0400
> > > > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > > > 
> > > > > The only caller (svc_send) has already checked XPT_DEAD.
> > > > > 
> > > > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > > > ---
> > > > >  net/sunrpc/svcsock.c |    3 ---
> > > > >  1 files changed, 0 insertions(+), 3 deletions(-)
> > > > > 
> > > > > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > > > > index 1454739..07919e1 100644
> > > > > --- a/net/sunrpc/svcsock.c
> > > > > +++ b/net/sunrpc/svcsock.c
> > > > > @@ -1135,9 +1135,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
> > > > >  	reclen = htonl(0x80000000|((xbufp->len ) - 4));
> > > > >  	memcpy(xbufp->head[0].iov_base, &reclen, 4);
> > > > >  
> > > > > -	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
> > > > > -		return -ENOTCONN;
> > > > > -
> > > > >  	sent = svc_sendto(rqstp, &rqstp->rq_res);
> > > > >  	if (sent != xbufp->len) {
> > > > >  		printk(KERN_NOTICE
> > > > 
> > > > 
> > > > So after removing all these references to XPT_DEAD, do we need XPT_DEAD at
> > > > all???
> > > > 
> > > > I think it is only used in two other places.
> > > > 
> > > > 1/ In svc_revisit we don't queue the deferred request to an XPT_DEAD
> > > >   transport.
> > > >   We could avoid that but changing the 'owner' of a deferred request from the
> > > >   service to the xprt, and call cache_clean_deferred in svc_delete_xprt
> > > 
> > > That use does seem a bit of a hack to me, so I'd be happy to get rid of
> > > it.
> > 
> > Eh, but then don't we end up doing the same check when deferring, to
> > prevent deferring a request on a dead xprt?
> 
> Good point.
> However....
> 
> If we change svc_defer to set handle.owner to rqstp->rq_xprt rather than
> rqstp->rq_server (As already suggested), then we don't need the svc_xprt_get.
> i.e. the deferred request doesn't need to hold a reference to the xprt,
> because when the xprt is finally removed it is easy (cache_clean_deferred) to
> remove all those deferred requests.
> So we put the call to cache_clean_deferred in svc_xprt_free.  By this stage
> we are guaranteed not to get more deferrals as the xprt is dead.

Oh, OK, got it.  I'll keep that in mind....

And I've also got some more cleanup, possibly bordering on barn-painting
(though I like the second one).

--b.

commit a08af80085c3ee539ca25729d7c7e9af6d060d71
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 25 12:50:15 2010 -0400

    svcrpc: don't set then immediately clear XPT_DEFERRED
    
    There's no harm to doing this, since the only caller will immediately
    call svc_enqueue() afterwards, ensuring we don't miss the remaining
    deferred requests just because XPT_DEFERRED was briefly cleared.
    
    But why not just do this the simple way?
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c82fe73..a74cb67 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1059,14 +1059,13 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 	if (!test_bit(XPT_DEFERRED, &xprt->xpt_flags))
 		return NULL;
 	spin_lock(&xprt->xpt_lock);
-	clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
 	if (!list_empty(&xprt->xpt_deferred)) {
 		dr = list_entry(xprt->xpt_deferred.next,
 				struct svc_deferred_req,
 				handle.recent);
 		list_del_init(&dr->handle.recent);
-		set_bit(XPT_DEFERRED, &xprt->xpt_flags);
-	}
+	} else
+		clear_bit(XPT_DEFERRED, &xprt->xpt_flags);
 	spin_unlock(&xprt->xpt_lock);
 	return dr;
 }
commit 79a54abe64963acc82a2bf2a61b4efff5e782805
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 25 14:12:40 2010 -0400

    nfsd4: centralize more calls to svc_xprt_received
    
    Follow up on b48fa6b99100dc7772af3cd276035fcec9719ceb by moving all the
    svc_xprt_received() calls for the main xprt to one place.  The clearing
    of XPT_BUSY here is critical to the correctness of the server, so I'd
    prefer it to be obvious where we do it.
    
    The only substantive result is moving svc_xprt_received() after
    svc_receive_deferred().  Other than a (likely insignificant) delay
    waking up the next thread, that should be harmless.
    
    Also reshuffle the exit code a little to skip a few other steps that we
    don't care about the in the svc_delete_xprt() case.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index a74cb67..dd61cd0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -716,7 +716,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
 		svc_delete_xprt(xprt);
-	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+		/* Leave XPT_BUSY set on the dead xprt: */
+		goto out;
+	}
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
@@ -741,28 +744,23 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(newxpt);
 		}
-		svc_xprt_received(xprt);
 	} else {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
-		if (rqstp->rq_deferred) {
-			svc_xprt_received(xprt);
+		if (rqstp->rq_deferred)
 			len = svc_deferred_recv(rqstp);
-		} else {
+		else
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
-			svc_xprt_received(xprt);
-		}
 		dprintk("svc: got len=%d\n", len);
 	}
+	svc_xprt_received(xprt);
 
 	/* No data, incomplete (TCP) read, or accept() */
-	if (len == 0 || len == -EAGAIN) {
-		rqstp->rq_res.len = 0;
-		svc_xprt_release(rqstp);
-		return -EAGAIN;
-	}
+	if (len == 0 || len == -EAGAIN)
+		goto out;
+
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
@@ -771,6 +769,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
 	return len;
+out:
+	rqstp->rq_res.len = 0;
+	svc_xprt_release(rqstp);
+	return -EAGAIN;
 }
 EXPORT_SYMBOL_GPL(svc_recv);
 
