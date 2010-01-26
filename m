From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] SUNRPC: Bury "#ifdef IPV6" in svc_create_xprt()
Date: Tue, 26 Jan 2010 14:04:04 -0500
Message-ID: <20100126190404.3368.61206.stgit@localhost.localdomain>
References: <20100126190214.3368.89388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56412 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab0AZTE0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 14:04:26 -0500
In-Reply-To: <20100126190214.3368.89388.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Bruce observed we have more or less common logic in each of
svc_create_xprt()'s callers:  the check to create an IPv6 RPC listener
socket only if CONFIG_IPV6 is set.  I'm about to add another case
that does just the same.

If we move the ifdefs into __svc_xpo_create(), then svc_create_xprt()
call sites can get rid of the "#ifdef" ugliness, and can use the same
logic with or without IPv6 support available in the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c        |    2 --
 fs/nfs/callback.c     |    2 --
 net/sunrpc/svc_xprt.c |    4 ++++
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index e50cfa3..7d15051 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -243,11 +243,9 @@ static int make_socks(struct svc_serv *serv)
 	if (err < 0)
 		goto out_err;
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	err = create_lockd_family(serv, PF_INET6);
 	if (err < 0 && err != -EAFNOSUPPORT)
 		goto out_err;
-#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
 
 	warned = 0;
 	return 0;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 73ab220..36dfdae 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -118,7 +118,6 @@ nfs4_callback_up(struct svc_serv *serv)
 	dprintk("NFS: Callback listener port = %u (af %u)\n",
 			nfs_callback_tcpport, PF_INET);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	ret = svc_create_xprt(serv, "tcp", PF_INET6,
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
@@ -129,7 +128,6 @@ nfs4_callback_up(struct svc_serv *serv)
 		ret = 0;
 	else
 		goto out_err;
-#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 
 	return svc_prepare_thread(serv, &serv->sv_pools[0]);
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7d1f9e9..f886ff3 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -173,11 +173,13 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		.sin_addr.s_addr	= htonl(INADDR_ANY),
 		.sin_port		= htons(port),
 	};
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct sockaddr_in6 sin6 = {
 		.sin6_family		= AF_INET6,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 		.sin6_port		= htons(port),
 	};
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	struct sockaddr *sap;
 	size_t len;
 
@@ -186,10 +188,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
 		sap = (struct sockaddr *)&sin;
 		len = sizeof(sin);
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6:
 		sap = (struct sockaddr *)&sin6;
 		len = sizeof(sin6);
 		break;
+#endif	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 	default:
 		return ERR_PTR(-EAFNOSUPPORT);
 	}

