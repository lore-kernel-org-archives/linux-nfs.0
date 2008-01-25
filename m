From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 061/100] svc: Change services to use new svc_create_xprt service
Date: Fri, 25 Jan 2008 18:16:41 -0500
Message-ID: <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47461 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758683AbYAYXRx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:53 -0500
In-Reply-To: <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Modify the various kernel RPC svcs to use the svc_create_xprt service.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
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
index a7827e4..df382f2 100644
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
index 9f0f6d0..e6bb1b0 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1988,28 +1988,6 @@ void svc_force_close_socket(struct svc_sock *svsk)
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
-- 
1.5.4.rc2.60.gb2e62

