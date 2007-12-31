From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 32/40] svc: Move create logic to common code
Date: Sun, 30 Dec 2007 21:08:20 -0600
Message-ID: <20071231030820.8430.79422.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41581 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752957AbXLaDIV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:08:21 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Move the svc transport list logic into common transport creation code.
Refactor this code path to make the flow of control easier to read.

Move the setting and clearing of the BUSY_BIT during transport creation
to common code.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   43 +++++++++++++++++++++++++------------------
 net/sunrpc/svcsock.c  |   41 +++++++++++++++++++----------------------
 2 files changed, 44 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index eb650af..271467c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -105,6 +105,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
+	set_bit(XPT_BUSY, &xprt->xpt_flags);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
@@ -112,7 +113,6 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 		    int flags)
 {
 	struct svc_xprt_class *xcl;
-	int ret = -ENOENT;
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= INADDR_ANY,
@@ -121,27 +121,34 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
 	spin_lock(&svc_xprt_class_lock);
 	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
-		if (strcmp(xprt_name, xcl->xcl_name) == 0) {
-			spin_unlock(&svc_xprt_class_lock);
-			if (try_module_get(xcl->xcl_owner)) {
-				struct svc_xprt *newxprt;
-				newxprt = xcl->xcl_ops->xpo_create
-					(serv,
-					 (struct sockaddr *)&sin, sizeof(sin),
-					 flags);
-				if (IS_ERR(newxprt)) {
-					module_put(xcl->xcl_owner);
-					ret = PTR_ERR(newxprt);
-				} else
-					ret = svc_xprt_local_port(newxprt);
-			}
-			goto out;
+		struct svc_xprt *newxprt;
+
+		if (strcmp(xprt_name, xcl->xcl_name))
+			continue;
+
+		if (!try_module_get(xcl->xcl_owner))
+			goto err;
+
+		spin_unlock(&svc_xprt_class_lock);
+		newxprt = xcl->xcl_ops->
+			xpo_create(serv, (struct sockaddr *)&sin, sizeof(sin),
+				   flags);
+		if (IS_ERR(newxprt)) {
+			module_put(xcl->xcl_owner);
+			return PTR_ERR(newxprt);
 		}
+
+		clear_bit(XPT_TEMP, &newxprt->xpt_flags);
+		spin_lock_bh(&serv->sv_lock);
+		list_add(&newxprt->xpt_list, &serv->sv_permsocks);
+		spin_unlock_bh(&serv->sv_lock);
+		clear_bit(XPT_BUSY, &newxprt->xpt_flags);
+		return svc_xprt_local_port(newxprt);
 	}
+ err:
 	spin_unlock(&svc_xprt_class_lock);
 	dprintk("svc: transport %s not found\n", xprt_name);
- out:
-	return ret;
+	return -ENOENT;
 }
 EXPORT_SYMBOL_GPL(svc_create_xprt);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 822ccb6..db9a541 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -94,6 +94,7 @@ static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct sockaddr *, int, int);
+static void svc_age_temp_xprts(unsigned long closure);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -1572,7 +1573,20 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 			 * listener holds a reference too
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(svsk->sk_xprt.xpt_server);
+			svc_check_conn_limits(xprt->xpt_server);
+			spin_lock_bh(&serv->sv_lock);
+			set_bit(XPT_TEMP, &newxpt->xpt_flags);
+			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
+			serv->sv_tmpcnt++;
+			if (serv->sv_temptimer.function == NULL) {
+				/* setup timer to age temp sockets */
+				setup_timer(&serv->sv_temptimer,
+					    svc_age_temp_xprts,
+					    (unsigned long)serv);
+				mod_timer(&serv->sv_temptimer,
+					  jiffies + svc_conn_age_period * HZ);
+			}
+			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(newxpt);
 		}
 		svc_xprt_received(xprt);
@@ -1716,7 +1730,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
-	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
@@ -1736,7 +1749,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		return NULL;
 	}
 
-	set_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags);
 	inet->sk_user_data = svsk;
 	svsk->sk_sock = sock;
 	svsk->sk_sk = inet;
@@ -1750,24 +1762,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	else
 		svc_tcp_init(svsk, serv);
 
-	spin_lock_bh(&serv->sv_lock);
-	if (is_temporary) {
-		set_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_tempsocks);
-		serv->sv_tmpcnt++;
-		if (serv->sv_temptimer.function == NULL) {
-			/* setup timer to age temp sockets */
-			setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
-					(unsigned long)serv);
-			mod_timer(&serv->sv_temptimer,
-					jiffies + svc_conn_age_period * HZ);
-		}
-	} else {
-		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
-		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
-	}
-	spin_unlock_bh(&serv->sv_lock);
-
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);
 
@@ -1800,6 +1794,10 @@ int svc_addsock(struct svc_serv *serv,
 			int salen;
 			if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
 				svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
+			clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
+			spin_lock_bh(&serv->sv_lock);
+			list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
+			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
@@ -1865,7 +1863,6 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
 		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
-		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
 
