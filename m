From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svc: Clean up deferred requests on transport destruction
Date: Mon, 05 Jan 2009 15:21:19 -0600
Message-ID: <496279CF.5050807@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55055 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754817AbZAEVVT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 16:21:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

This patch replaces 2/3 of Trond's deferral cleanup patch. This shouldn't
come across with the white-spaced munged. Please let me know if it does.

Thanks,
Tom

A race between svc_revisit and svc_delete_xprt can result in
deferred requests holding references on a transport that can never be
recovered because dead transports are not enqueued for subsequent
processing.

Check for XPT_DEAD in revisit to clean up completing deferrals on a dead
transport and sweep a transport's deferred queue to do the same for queued
but unprocessed deferrals.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  net/sunrpc/svc_xprt.c |   25 ++++++++++++++++++-------
  1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..e6e7e25 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -837,6 +837,11 @@ static void svc_age_temp_xprts(unsigned long closure)
  void svc_delete_xprt(struct svc_xprt *xprt)
  {
  	struct svc_serv	*serv = xprt->xpt_server;
+	struct svc_deferred_req *dr;
+
+	/* Only do this once */
+	if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
+		return;

  	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
  	xprt->xpt_ops->xpo_detach(xprt);
@@ -851,12 +856,16 @@ void svc_delete_xprt(struct svc_xprt *xprt)
  	 * while still attached to a queue, the queue itself
  	 * is about to be destroyed (in svc_destroy).
  	 */
-	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
-		BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
-		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
-			serv->sv_tmpcnt--;
+	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
+		serv->sv_tmpcnt--;
+
+	for (dr = svc_deferred_dequeue(xprt); dr;
+	     dr = svc_deferred_dequeue(xprt)) {
  		svc_xprt_put(xprt);
+		kfree(dr);
  	}
+
+	svc_xprt_put(xprt);
  	spin_unlock_bh(&serv->sv_lock);
  }

@@ -902,17 +911,19 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
  		container_of(dreq, struct svc_deferred_req, handle);
  	struct svc_xprt *xprt = dr->xprt;

-	if (too_many) {
+	spin_lock(&xprt->xpt_lock);
+	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
+	if (too_many || test_bit(XPT_DEAD, &xprt->xpt_flags)) {
+		spin_unlock(&xprt->xpt_lock);
+		dprintk("revisit canceled\n");
  		svc_xprt_put(xprt);
  		kfree(dr);
  		return;
  	}
  	dprintk("revisit queued\n");
  	dr->xprt = NULL;
-	spin_lock(&xprt->xpt_lock);
  	list_add(&dr->handle.recent, &xprt->xpt_deferred);
  	spin_unlock(&xprt->xpt_lock);
-	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
  	svc_xprt_enqueue(xprt);
  	svc_xprt_put(xprt);
  }
