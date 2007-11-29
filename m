From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 13/38] svc: Change services to use new svc_create_xprt service
Date: Thu, 29 Nov 2007 16:53:59 -0600
Message-ID: <20071129225359.15107.29622.stgit@dell3.ogc.int>
References: <20071129225142.15107.46200.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47414 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763743AbXK2XU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:26 -0500
In-Reply-To: <20071129225142.15107.46200.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Modify the various kernel RPC svcs to use the svc_create_xprt service.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/lockd/svc.c                 |   17 ++++++++---------
 fs/nfs/callback.c              |    4 ++--
 fs/nfsd/nfssvc.c               |    4 ++--
 include/linux/sunrpc/svcsock.h |    1 -
 net/sunrpc/sunrpc_syms.c       |    1 -
 net/sunrpc/svcsock.c           |   22 ----------------------
 6 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 82e2192..8686915 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -219,13 +219,12 @@ lockd(struct svc_rqst *rqstp)
 	module_put_and_exit(0);
 }
 
-
-static int find_socket(struct svc_serv *serv, int proto)
+static int find_xprt(struct svc_serv *serv, char *proto)
 {
 	struct svc_sock *svsk;
 	int found = 0;
 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
-		if (svsk->sk_sk->sk_protocol == proto) {
+		if (strcmp(svsk->sk_xprt.xpt_class->xcl_name, proto) == 0) {
 			found = 1;
 			break;
 		}
@@ -243,13 +242,13 @@ static int make_socks(struct svc_serv *serv, int proto)
 	int err = 0;
 
 	if (proto == IPPROTO_UDP || nlm_udpport)
-		if (!find_socket(serv, IPPROTO_UDP))
-			err = svc_makesock(serv, IPPROTO_UDP, nlm_udpport,
-						SVC_SOCK_DEFAULTS);
+		if (!find_xprt(serv, "udp"))
+			err = svc_create_xprt(serv, "udp", nlm_udpport,
+					      SVC_SOCK_DEFAULTS);
 	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
-		if (!find_socket(serv, IPPROTO_TCP))
-			err = svc_makesock(serv, IPPROTO_TCP, nlm_tcpport,
-						SVC_SOCK_DEFAULTS);
+		if (!find_xprt(serv, "tcp"))
+			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
+					      SVC_SOCK_DEFAULTS);
 
 	if (err >= 0) {
 		warned = 0;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a796be5..e27ca14 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -123,8 +123,8 @@ int nfs_callback_up(void)
 	if (!serv)
 		goto out_err;
 
-	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport,
-							SVC_SOCK_ANONYMOUS);
+	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
+			      SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_destroy;
 	nfs_callback_tcpport = ret;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 1190aea..a828b0b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -236,7 +236,7 @@ static int nfsd_init_socks(int port)
 
 	error = lockd_up(IPPROTO_UDP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port,
+		error = svc_create_xprt(nfsd_serv, "udp", port,
 					SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
@@ -247,7 +247,7 @@ static int nfsd_init_socks(int port)
 #ifdef CONFIG_NFSD_TCP
 	error = lockd_up(IPPROTO_TCP);
 	if (error >= 0) {
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port,
+		error = svc_create_xprt(nfsd_serv, "tcp", port,
 					SVC_SOCK_DEFAULTS);
 		if (error < 0)
 			lockd_down();
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 9882ce0..3181d9d 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -67,7 +67,6 @@ struct svc_sock {
 /*
  * Function prototypes.
  */
-int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
 void		svc_force_close_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 79ea05f..52eea54 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -72,7 +72,6 @@ EXPORT_SYMBOL(svc_drop);
 EXPORT_SYMBOL(svc_process);
 EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
-EXPORT_SYMBOL(svc_makesock);
 EXPORT_SYMBOL(svc_reserve);
 EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0bfffbc..574cdbe 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -2001,28 +2001,6 @@ void svc_force_close_socket(struct svc_sock *svsk)
 	svc_close_socket(svsk);
 }
 
-/**
- * svc_makesock - Make a socket for nfsd and lockd
- * @serv: RPC server structure
- * @protocol: transport protocol to use
- * @port: port to use
- * @flags: requested socket characteristics
- *
- */
-int svc_makesock(struct svc_serv *serv, int protocol, unsigned short port,
-			int flags)
-{
-	dprintk("svc: creating socket proto = %d\n", protocol);
-	switch (protocol) {
-	case IPPROTO_TCP:
-		return svc_create_xprt(serv, "tcp", port, flags);
-	case IPPROTO_UDP:
-		return svc_create_xprt(serv, "udp", port, flags);
-	default:
-		return -EINVAL;
-	}
-}
-
 /*
  * Handle defer and revisit of requests
  */
