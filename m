From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: The recent kref_put warning (was: [PATCH] sunrpc: remove
	unnecessary svc_xprt_put)
Date: Sun, 28 Feb 2010 22:46:47 -0500
Message-ID: <20100301034647.GA8462@fieldses.org>
References: <19336.19524.469529.431210@notabene.brown> <20100226225416.GF26598@fieldses.org> <4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown> <20100227165913.53718449@notabene.brown> <20100228210553.GA27965@fieldses.org> <20100228220723.GB27965@fieldses.org> <20100301105734.7fe935b0@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33936 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649Ab0CADpm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Feb 2010 22:45:42 -0500
In-Reply-To: <20100301105734.7fe935b0-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 10:57:34AM +1100, Neil Brown wrote:
> No, you are correct.  "return 0" is wrong, it should be "return -EAGAIN",
> both in the XPT_CLOSE case and the XPT_LISTENER case.
> 
> I observed that in both those cases, 'len' remained at 0 and we didn't do
> much else but 'return len', so I optimised.
> I forgot to factor in:
> 
> 	if (len == 0 || len == -EAGAIN) {
> 		rqstp->rq_res.len = 0;
> 		svc_xprt_release(rqstp);
> 		return -EAGAIN;
> 	}
> 
> So the svc_xprt_release needs to be moved in there as well, I'm not sure
> about the rq_res.len = 0.
> Maybe that was a bad case of premature-optimisation :-)
> 
> We should probably leave that last else clause as it is and just have a
> single return from the function.

OK, so the below is what I'm thinking of sending, after some testing;
really just a split-up version of your patches (uh, so credits may be
wrong) with the final cleanup removed:

	1. remove the extra put from svc_delete_xprt().
	2,3. Revert 2 problematic patches which caused the oops people
	are seeing.
	4. Fix the original bug from the rdma series.

And the first 3 will go to stable as well.  The 4th might eventually
too, it just seems less urgent.

I also agree with the cleanup that moves the svc_xprt_received to one
place, I'm just hoping you won't mind regenerating it against this.

--b.

>From ab1b18f70a007ea6caeb007d269abb75b131a410 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Sat, 27 Feb 2010 09:33:40 +1100
Subject: [PATCH 1/4] sunrpc: remove unnecessary svc_xprt_put

The 'struct svc_deferred_req's on the xpt_deferred queue do not
own a reference to the owning xprt.  This is seen in svc_revisit
which is where things are added to this queue.  dr->xprt is set to
NULL and the reference to the xprt it put.

So when this list is cleaned up in svc_delete_xprt, we mustn't
put the reference.

Also, replace the 'for' with a 'while' which is arguably
simpler and more likely to compile efficiently.

Cc: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: NeilBrown <neilb@suse.de>
Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svc_xprt.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d7ec5ca..0983830 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -896,11 +896,8 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
 
-	for (dr = svc_deferred_dequeue(xprt); dr;
-	     dr = svc_deferred_dequeue(xprt)) {
-		svc_xprt_put(xprt);
+	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
 		kfree(dr);
-	}
 
 	svc_xprt_put(xprt);
 	spin_unlock_bh(&serv->sv_lock);
-- 
1.6.3.3


>From 56dd703462dad7311f3c5a736343f38d7b34b965 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Sun, 28 Feb 2010 16:32:51 -0500
Subject: [PATCH 2/4] Revert "sunrpc: fix peername failed on closed listener"

This reverts commit b292cf9ce70d221c3f04ff62db5ab13d9a249ca8.  The
commit that it attempted to patch up, b0401d "sunrpc: fix peername
failed on closed listener" was fundamentally wrong, and will also be
reverted.

Cc: stable@kernel.org
Cc: Xiaotian Feng <dfeng@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svc_xprt.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 0983830..818c4c3 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -706,8 +706,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
-	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
-- 
1.6.3.3


>From 4d87b1d6c9832b19068f662101d27c82f3bb659d Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Sun, 28 Feb 2010 16:33:31 -0500
Subject: [PATCH 3/4] Revert "sunrpc: move the close processing after do recvfrom method"

This reverts commit b0401d725334a94d57335790b8ac2404144748ee, which
moved svc_delete_xprt() outside of XPT_BUSY, and allowed it to be called
after svc_xpt_recived(), removing the xprt's last reference and
destroying the xprt after it had already been queued for future
processing.

Cc: Wei Yongjun <yjwei@cn.fujitsu.com>
Cc: stable_kernel.org
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svc_xprt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 818c4c3..8f0f1fb 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -706,7 +706,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+		dprintk("svc_recv: found XPT_CLOSE\n");
+		svc_delete_xprt(xprt);
+	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
@@ -732,7 +735,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
-	} else if (!test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
+	} else {
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, pool->sp_id, xprt,
 			atomic_read(&xprt->xpt_ref.refcount));
@@ -745,11 +748,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		dprintk("svc: got len=%d\n", len);
 	}
 
-	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
-		dprintk("svc_recv: found XPT_CLOSE\n");
-		svc_delete_xprt(xprt);
-	}
-
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
-- 
1.6.3.3


>From f41357becb29e874a7adf4d77d52c31cb7b91820 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Sun, 28 Feb 2010 22:01:05 -0500
Subject: [PATCH 4/4] nfsd: ensure sockets are closed on error

One of the changes in commit d7979ae4a "svc: Move close processing to a
single place" is:

	  err_delete:
	-       svc_delete_socket(svsk);
	+       set_bit(SK_CLOSE, &svsk->sk_flags);
	        return -EAGAIN;

This is insufficient. The recvfrom methods must always call
svc_xprt_received on completion so that the socket gets re-queued if
there is any more work to do.  This particular path did not make that
call because it actually destroyed the svsk, making requeue pointless.
When the svc_delete_socket was change to just set a bit, we should have
added a call to svc_xprt_received,

This is the problem that b0401d7253 attempted to fix, incorrectly.

Cc: Tom Tucker <tom@opengridcomputing.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9e09391..a29f259 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -968,6 +968,7 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return len;
  err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	svc_xprt_received(&svsk->sk_xprt);
  err_again:
 	return -EAGAIN;
 }
-- 
1.6.3.3

