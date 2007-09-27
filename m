From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 29/33] svc: Move common create logic to common code
Date: Thu, 27 Sep 2007 00:02:35 -0500
Message-ID: <20070927050235.12677.21554.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalWA-0005jk-W7
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:31 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWF-0005VB-Js
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:36 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
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


Move the code that adds a transport instance to the sv_tempsocks and
sv_permsocks lists out of the transport specific functions and into core
logic. 

The svc_addsock routine still manipulates sv_permsocks directly. This
code may be removed when rpc.nfsd is modified to create transports
by writing to the portlist file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |    7 +++++++
 net/sunrpc/svcsock.c  |   38 +++++++++++++++++++-------------------
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8d87b6a..78c93a4 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -146,6 +146,13 @@ int svc_create_xprt(struct svc_serv *ser
 				if (IS_ERR(newxprt)) {
 					module_put(xcl->xcl_owner);
 					ret = PTR_ERR(newxprt);
+				} else {
+					clear_bit(XPT_TEMP, 
+						  &newxprt->xpt_flags);
+					spin_lock_bh(&serv->sv_lock);
+					list_add(&newxprt->xpt_list, 
+						 &serv->sv_permsocks);
+					spin_unlock_bh(&serv->sv_lock);
 				}
 				goto out;
 			}
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b1affaa..8a708a8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -92,6 +92,7 @@ static int svc_deferred_recv(struct svc_
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 static struct svc_xprt *
 svc_create_socket(struct svc_serv *, int, struct sockaddr *, int, int);
+static void svc_age_temp_xprts(unsigned long closure);
 
 /* apparently the "standard" is that clients close
  * idle connections after 5 minutes, servers after
@@ -1598,6 +1599,18 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
 			svc_check_conn_limits(xprt->xpt_server);
+			spin_lock_bh(&serv->sv_lock);
+			set_bit(XPT_TEMP, &newxpt->xpt_flags);
+			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
+			serv->sv_tmpcnt++;
+			if (serv->sv_temptimer.function == NULL) {
+				/* setup timer to age temp sockets */
+				setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
+					    (unsigned long)serv);
+				mod_timer(&serv->sv_temptimer,
+					  jiffies + svc_conn_age_period * HZ);
+			}
+			spin_unlock_bh(&serv->sv_lock);
 		}			
 		svc_xprt_received(xprt);
 	} else {
@@ -1746,7 +1759,6 @@ static struct svc_sock *svc_setup_socket
 	struct svc_sock	*svsk;
 	struct sock	*inet;
 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
-	int		is_temporary = flags & SVC_SOCK_TEMPORARY;
 
 	dprintk("svc: svc_setup_socket %p\n", sock);
 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
@@ -1785,24 +1797,6 @@ static struct svc_sock *svc_setup_socket
 		set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	}
 
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
 
@@ -1833,6 +1827,12 @@ int svc_addsock(struct svc_serv *serv,
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
 		}
+		if (so->sk->sk_protocol == IPPROTO_TCP)
+			set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
+		clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
+		spin_lock_bh(&serv->sv_lock);
+		list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
+		spin_unlock_bh(&serv->sv_lock);
 	}
 	if (err) {
 		sockfd_put(so);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
