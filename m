Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab0JZQFW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 12:05:22 -0400
Date: Tue, 26 Oct 2010 12:05:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Subject: Re: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Message-ID: <20101026160517.GC19445@fieldses.org>
References: <20101025124357.63b966bb@notabene>
 <20101025202155.GD13523@fieldses.org>
 <20101026095836.61bf6a38@notabene>
 <20101025230331.GF13523@fieldses.org>
 <20101026105447.264b690e@notabene>
 <20101026001145.GG13523@fieldses.org>
 <20101026002858.GH13523@fieldses.org>
 <20101026003008.GI13523@fieldses.org>
 <20101026122820.1518ec7e@notabene>
 <20101026125947.GA19445@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026125947.GA19445@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 08:59:47AM -0400, J. Bruce Fields wrote:
> On Tue, Oct 26, 2010 at 12:28:20PM +1100, Neil Brown wrote:
> > On Mon, 25 Oct 2010 20:30:08 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > >     svcrpc: simplify svc_close_xprt, fix minor race
> > >     
> > >     We're assuming that in the XPT_BUSY case, somebody else will take care
> > >     of the close.  But that's not necessarily the case (e.g. if
> > >     svc_xprt_enqueue() exits due to a lack of write space).  So the close
> > >     could in theory be delayed indefinitely.  We should be calling
> > >     svc_xprt_enqueue() after every set of XPT_CLOSE.
> > >     
> > >     Also with svc_close_all() no longer relying on svc_close, it no longer
> > >     needs to be able to immediately do the svc_delete_xprt() itself.
> > >     
> > >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > > index 8c018df..dfee123 100644
> > > --- a/net/sunrpc/svc_xprt.c
> > > +++ b/net/sunrpc/svc_xprt.c
> > > @@ -928,11 +928,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
> > >  void svc_close_xprt(struct svc_xprt *xprt)
> > >  {
> > >  	set_bit(XPT_CLOSE, &xprt->xpt_flags);
> > > -	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags))
> > > -		/* someone else will have to effect the close */
> > > -		return;
> > > -
> > > -	svc_delete_xprt(xprt);
> > > +	svc_xprt_enqueue(xprt);
> > >  }
> > >  EXPORT_SYMBOL_GPL(svc_close_xprt);
> > >  
> > 
> > I'm not quite so sure about this one.
> > 
> > svc_close_xprt gets called when user-space writes some magic string to some
> > magic file.  This could be done when there are no active nfsd threads.
> > It is a bit far fetched, but you could tell nfsd to open a socket, then tell
> > it to close it, before telling it to start any threads.
> > 
> > In that case the socket would stay open until the first thread was started.
> 
> Thanks, that's an odd case, but I think you're right.  OK:

Actually.... I think the real race here is the fault of the write-space
check: once we've taken XPT_BUSY, we really do need to guarantee that
we'll arrange to have svc_xprt_enqueue() called again after clearing
XPT_BUSY, to avoid missing any events that arrived while we were
processing ours.  So putting the wspace check after taking XPT_BUSY in
svc_xprt_enqueue looks to me like a bug that could cause processing to
stall unnecessarily in some unlikely cases.

--b.

commit cf501cb479873d6e77abba131ea40c11aa924d72
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 26 11:32:03 2010 -0400

    svcrpc: fix wspace-checking race
    
    We call svc_xprt_enqueue() after something happens which we think may
    require handling from a server thread.  To avoid such events being lost,
    svc_xprt_enqueue() must guarantee that there will be a svc_serv() call
    from a server thread following any such event.  It does that by either
    waking up a server thread itself, or checking that XPT_BUSY is set (in
    which case somebody else is doing it).
    
    But the check of XPT_BUSY could occur just as someone finishes
    processing some other event, and just before they clear XPT_BUSY.
    
    Therefore it's important not to clear XPT_BUSY without subsequently
    doing another svc_export_enqueue() to check whether the xprt should be
    requeued.
    
    The xpo_wspace() check in svc_xprt_enqueue() breaks this rule, allowing
    an event to be missed in situations like:
    
    	data arrives
    	call svc_tcp_data_ready():
    	call svc_xprt_enqueue():
    	set BUSY
    	find no write space
    				svc_reserve():
    				free up write space
    				call svc_enqueue():
    				test BUSY
    	clear BUSY
    
    So, instead, check wspace in the same places that the state flags are
    checked: before taking BUSY, and in svc_receive().
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index d2261fe..9c690fa 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -92,12 +92,17 @@ static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user
 static inline int register_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
 {
 	spin_lock(&xpt->xpt_lock);
-	list_add(&u->list, &xpt->xpt_users);
-	spin_unlock(&xpt->xpt_lock);
 	if (test_bit(XPT_CLOSE, &xpt->xpt_flags)) {
-		unregister_xpt_user(xpt, u);
+		/*
+		 * The connection is about to be deleted soon (or,
+		 * worse, may already be deleted--in which case we've
+		 * already notified the xpt_users).
+		 */
+		spin_unlock(&xpt->xpt_lock);
 		return -ENOTCONN;
 	}
+	list_add(&u->list, &xpt->xpt_users);
+	spin_unlock(&xpt->xpt_lock);
 	return 0;
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 99996ad..04238a9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -302,6 +302,15 @@ static void svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
 	list_del(&rqstp->rq_list);
 }
 
+static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
+{
+	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
+		return true;
+	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED)))
+		return xprt->xpt_ops->xpo_has_wspace(xprt);
+	return false;
+}
+
 /*
  * Queue up a transport with data pending. If there are idle nfsd
  * processes, wake 'em up.
@@ -314,8 +323,7 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 	struct svc_rqst	*rqstp;
 	int cpu;
 
-	if (!(xprt->xpt_flags &
-	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
+	if (!svc_xprt_has_something_to_do(xprt))
 		return;
 
 	cpu = get_cpu();
@@ -345,25 +353,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 	BUG_ON(xprt->xpt_pool != NULL);
 	xprt->xpt_pool = pool;
 
-	/* Handle pending connection */
-	if (test_bit(XPT_CONN, &xprt->xpt_flags))
-		goto process;
-
-	/* Handle close in-progress */
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
-		goto process;
-
-	/* Check if we have space to reply to a request */
-	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
-		/* Don't enqueue while not enough space for reply */
-		dprintk("svc: no write space, transport %p  not enqueued\n",
-			xprt);
-		xprt->xpt_pool = NULL;
-		clear_bit(XPT_BUSY, &xprt->xpt_flags);
-		goto out_unlock;
-	}
-
- process:
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
@@ -744,7 +733,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(newxpt);
 		}
-	} else {
+	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
