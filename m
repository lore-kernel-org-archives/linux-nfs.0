From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/13] lockd: Enable NLM use of AF_INET6
Date: Wed, 05 Nov 2008 12:28:28 -0500
Message-ID: <20081105172828.7330.81092.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36481 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbYKER2p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:28:45 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the kernel is configured to support IPv6 and the RPC server can register
services via rpcbindv4, we are all set to enable IPv6 support for lockd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aime Le Rouzic <aime.le-rouzic@bull.net>
---

 fs/lockd/svc.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 50de426..582372d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -53,6 +53,17 @@ static struct svc_rqst		*nlmsvc_rqst;
 unsigned long			nlmsvc_timeout;
 
 /*
+ * If the kernel has IPv6 support available, always listen for
+ * both AF_INET and AF_INET6 requests.
+ */
+#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
+	defined(CONFIG_SUNRPC_REGISTER_V4)
+static const sa_family_t	nlmsvc_family = AF_INET6;
+#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+static const sa_family_t	nlmsvc_family = AF_INET;
+#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+
+/*
  * These can be set at insmod time (useful for NFS as root filesystem),
  * and also changed through the sysctl interface.  -- Jamie Lokier, Aug 2003
  */
@@ -250,7 +261,7 @@ int lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, AF_INET, NULL);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, nlmsvc_family, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;

