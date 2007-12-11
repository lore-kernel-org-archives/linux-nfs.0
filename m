From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 30/38] svc: Move common create logic to common code
Date: Tue, 11 Dec 2007 17:33:00 -0600
Message-ID: <20071211233300.15718.30136.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35457 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756858AbXLKXdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:33:01 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Move the code that adds a transport instance to the sv_tempsocks and
sv_permsocks lists out of the transport specific functions and into core
logic. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    9 ++++++++-
 net/sunrpc/svcsock.c  |   39 +++++++++++++++++++--------------------
 2 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d0cbfe0..924df63 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -145,8 +145,15 @@ int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
 				if (IS_ERR(newxprt)) {
 					module_put(xcl->xcl_owner);
 					ret = PTR_ERR(newxprt);
-				} else
+				} else {
+					clear_bit(XPT_TEMP,
+						  &newxprt->xpt_flags);
+					spin_lock_bh(&serv->sv_lock);
+					list_add(&newxprt->xpt_list,
+						 &serv->sv_permsocks);
+					spin_unlock_bh(&serv->sv_lock);
 					ret = svc_xprt_local_port(newxprt);
+				}
 			}
 			goto out;
 		}
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 27cf09f..f284bdf 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -94,6 +94,7 @@ static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct sockaddr *, int, int);
+static void svc_age_temp_xprts(unsigned long closure);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -1574,7 +1575,20 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
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
@@ -1718,7 +1732,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
-	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
@@ -1752,24 +1765,6 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
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
 
@@ -1805,6 +1800,10 @@ int svc_addsock(struct svc_serv *serv,
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
+		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
+		spin_lock_bh(&serv->sv_lock);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
+		spin_unlock_bh(&serv->sv_lock);
 	}
 	if (err) {
 		sockfd_put(so);
