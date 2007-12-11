From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 32/38] svc: Make svc_check_conn_limits xprt independent
Date: Tue, 11 Dec 2007 17:33:05 -0600
Message-ID: <20071211233305.15718.58454.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35464 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757148AbXLKXdF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:33:05 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_check_conn_limits function only manipulates xprt fields. Change references
to svc_sock->sk_xprt to svc_xprt directly.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a785055..8578936 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1447,34 +1447,34 @@ static void svc_check_conn_limits(struct svc_serv *serv)
 	char	buf[RPC_MAX_ADDRBUFLEN];
 
 	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
-		struct svc_sock *svsk = NULL;
+		struct svc_xprt *xprt = NULL;
 		spin_lock_bh(&serv->sv_lock);
 		if (!list_empty(&serv->sv_tempsocks)) {
 			if (net_ratelimit()) {
 				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open TCP "
-					"sockets, consider increasing the "
+				printk(KERN_NOTICE "%s: too many open  "
+					"connections, consider increasing the "
 					"number of nfsd threads\n",
-						   serv->sv_name);
+				       serv->sv_name);
 				printk(KERN_NOTICE
-				       "%s: last TCP connect from %s\n",
+				       "%s: last connection from %s\n",
 				       serv->sv_name, buf);
 			}
 			/*
-			 * Always select the oldest socket. It's not fair,
+			 * Always select the oldest connection. It's not fair,
 			 * but so is life
 			 */
-			svsk = list_entry(serv->sv_tempsocks.prev,
-					  struct svc_sock,
-					  sk_xprt.xpt_list);
-			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-			svc_xprt_get(&svsk->sk_xprt);
+			xprt = list_entry(serv->sv_tempsocks.prev,
+					  struct svc_xprt,
+					  xpt_list);
+			set_bit(XPT_CLOSE, &xprt->xpt_flags);
+			svc_xprt_get(xprt);
 		}
 		spin_unlock_bh(&serv->sv_lock);
 
-		if (svsk) {
-			svc_xprt_enqueue(&svsk->sk_xprt);
-			svc_xprt_put(&svsk->sk_xprt);
+		if (xprt) {
+			svc_xprt_enqueue(xprt);
+			svc_xprt_put(xprt);
 		}
 	}
 }
