From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NFS: Enable NFSv4 callback server to listen on AF_INET6
	sockets
Date: Wed, 27 Aug 2008 16:57:07 -0400
Message-ID: <20080827205706.17837.28843.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59507 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186AbYH0U6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:58:00 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the NFS callback server to listen for requests via an AF_INET6 or
AF_INET socket when IPv6 support is present in the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 6a09760..c2e9cfd 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -40,6 +40,16 @@ unsigned short nfs_callback_tcpport;
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
 
+/*
+ * If the kernel has IPv6 support available, always listen for
+ * both AF_INET and AF_INET6 requests.
+ */
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static const sa_family_t	nfs_callback_family = AF_INET6;
+#else
+static const sa_family_t	nfs_callback_family = AF_INET;
+#endif
+
 static int param_set_port(const char *val, struct kernel_param *kp)
 {
 	char *endp;
@@ -106,7 +116,7 @@ int nfs_callback_up(void)
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
-				AF_INET, NULL);
+				nfs_callback_family, NULL);
 	ret = -ENOMEM;
 	if (!serv)
 		goto out_err;
@@ -116,7 +126,8 @@ int nfs_callback_up(void)
 	if (ret <= 0)
 		goto out_err;
 	nfs_callback_tcpport = ret;
-	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
+	dprintk("NFS: Callback listener port = %u (af %u)\n",
+			nfs_callback_tcpport, nfs_callback_family);
 
 	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(nfs_callback_info.rqst)) {
@@ -149,8 +160,8 @@ out:
 	mutex_unlock(&nfs_callback_mutex);
 	return ret;
 out_err:
-	dprintk("Couldn't create callback socket or server thread; err = %d\n",
-		ret);
+	dprintk("NFS: Couldn't create callback socket or server thread; "
+		"err = %d\n", ret);
 	nfs_callback_info.users--;
 	goto out;
 }

