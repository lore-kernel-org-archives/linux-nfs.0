From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/40] NFS: Revert creation of IPv6 listeners for lockd and
	NFSv4 callbacks
Date: Thu, 12 Mar 2009 12:07:59 -0400
Message-ID: <20090312160758.16019.97073.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:62060 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbZCLQIp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:08:45 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're about to convert over to using separate PF_INET and PF_INET6
listeners, instead of a single PF_INET6 listener that also receives
AF_INET requests and maps them to AF_INET6.

Clear the way by removing the logic in lockd and the NFSv4 callback
server that creates an AF_INET6 service listener.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c    |   13 +------------
 fs/nfs/callback.c |   14 ++------------
 2 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index d309200..566932b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -53,17 +53,6 @@ static struct svc_rqst		*nlmsvc_rqst;
 unsigned long			nlmsvc_timeout;
 
 /*
- * If the kernel has IPv6 support available, always listen for
- * both AF_INET and AF_INET6 requests.
- */
-#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
-	defined(CONFIG_SUNRPC_REGISTER_V4)
-static const sa_family_t	nlmsvc_family = AF_INET6;
-#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
-static const sa_family_t	nlmsvc_family = AF_INET;
-#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
-
-/*
  * These can be set at insmod time (useful for NFS as root filesystem),
  * and also changed through the sysctl interface.  -- Jamie Lokier, Aug 2003
  */
@@ -211,7 +200,7 @@ static int create_lockd_listener(struct svc_serv *serv, char *name,
 
 	xprt = svc_find_xprt(serv, name, 0, 0);
 	if (xprt == NULL)
-		return svc_create_xprt(serv, name, nlmsvc_family,
+		return svc_create_xprt(serv, name, PF_INET,
 					port, SVC_SOCK_DEFAULTS);
 
 	svc_xprt_put(xprt);
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ddf4b4a..0ef47df 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -41,16 +41,6 @@ unsigned short nfs_callback_tcpport;
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
 
-/*
- * If the kernel has IPv6 support available, always listen for
- * both AF_INET and AF_INET6 requests.
- */
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static const sa_family_t	nfs_callback_family = AF_INET6;
-#else
-static const sa_family_t	nfs_callback_family = AF_INET;
-#endif
-
 static int param_set_port(const char *val, struct kernel_param *kp)
 {
 	char *endp;
@@ -121,13 +111,13 @@ int nfs_callback_up(void)
 	if (!serv)
 		goto out_err;
 
-	ret = svc_create_xprt(serv, "tcp", nfs_callback_family,
+	ret = svc_create_xprt(serv, "tcp", PF_INET,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
 		goto out_err;
 	nfs_callback_tcpport = ret;
 	dprintk("NFS: Callback listener port = %u (af %u)\n",
-			nfs_callback_tcpport, nfs_callback_family);
+			nfs_callback_tcpport, PF_INET);
 
 	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(nfs_callback_info.rqst)) {

