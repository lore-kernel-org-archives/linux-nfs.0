From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 31/35] svc: Make svc_check_conn_limits xprt independent
Date: Mon, 01 Oct 2007 14:28:39 -0500
Message-ID: <20071001192838.3250.16552.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwZ-0005eh-MR
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:39 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwe-0001Ch-CX
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:44 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


The svc_check_conn_limits function only manipulates xprt fields. Change references
to svc_sock->sk_xprt to svc_xprt directly.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0f57426..353aae2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1450,38 +1450,37 @@ svc_check_conn_limits(struct svc_serv *s
 	 * seconds. An attacker can easily beat that.
 	 *
 	 * The only somewhat efficient mechanism would be if drop
-	 * old connections from the same IP first. But right now
-	 * we don't even record the client IP in svc_sock.
+	 * old connections from the same IP first.
 	 */
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
