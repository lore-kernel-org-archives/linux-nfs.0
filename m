From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/13] NFSD: Enable NFS server use of AF_INET6
Date: Wed, 05 Nov 2008 12:29:58 -0500
Message-ID: <20081105172958.7330.70896.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36956 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbYKERaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:21 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the kernel is configured to support IPv6 and the RPC server can register
services via rpcbindv4, we are all set to enable IPv6 support for NFSD.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aime Le Rouzic <aime.le-rouzic@bull.net>
---

 fs/nfsd/nfssvc.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 07e4f5d..47e21d0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -45,6 +45,17 @@ static unsigned long		nfsd_last_call;
 static DEFINE_SPINLOCK(nfsd_call_lock);
 
 /*
+ * If the kernel has IPv6 support available, always listen for
+ * both AF_INET and AF_INET6 requests.
+ */
+#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
+	defined(CONFIG_SUNRPC_REGISTER_V4)
+static const sa_family_t	nfsd_family = AF_INET6;
+#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+static const sa_family_t	nfsd_family = AF_INET;
+#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+
+/*
  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
  * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
  * extent ->sv_temp_socks and ->sv_permsocks. It also protects nfsdstats.th_cnt
@@ -229,7 +240,7 @@ int nfsd_create_serv(void)
 
 	atomic_set(&nfsd_busy, 0);
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      AF_INET,
+				      nfsd_family,
 				      nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;

