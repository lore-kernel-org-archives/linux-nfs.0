From: Neil Brown <neilb@suse.de>
Subject: [PATCH] sunrpc: remove unnecessary svc_xprt_put
Date: Sat, 27 Feb 2010 09:33:40 +1100
Message-ID: <19336.19524.469529.431210@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:32953 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966347Ab0BZWdr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Feb 2010 17:33:47 -0500
Cc: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


[I found this while looking for the current refcount problem
 that triggers a warning in svc_recv.  This isn't that bug
 but is a different refcount bug - NB]

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

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7d1f9e9..4f30336 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -889,11 +889,8 @@ void svc_delete_xprt(struct svc_xprt *xprt)
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
