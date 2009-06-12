From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 01/14] SQUASHME: Type check arguments of nfs_callback_up
Date: Thu, 11 Jun 2009 22:54:07 -0700
Message-ID: <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbZFLF6J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:09 -0400
In-Reply-To: <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: minorversion support for nfs4_{init, destroy}_callback

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/callback.c |    5 +----
 fs/nfs/callback.h |    2 +-
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 972e38b..4395c96 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -214,7 +214,7 @@ out:
 /*
  * Bring up the callback thread if it is not already up.
  */
-int nfs_callback_up(u32 minorversion, void *args)
+int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 {
 	struct svc_serv *serv = NULL;
 	struct svc_rqst *rqstp;
@@ -222,9 +222,6 @@ int nfs_callback_up(u32 minorversion, void *args)
 	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	char svc_name[12];
 	int ret = 0;
-#if defined(CONFIG_NFS_V4_1)
-	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
-#endif /* CONFIG_NFS_V4_1 */
 
 	mutex_lock(&nfs_callback_mutex);
 	if (cb_info->users++ || cb_info->task != NULL) {
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 4bd0daf..07baa82 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -112,7 +112,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getat
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
 
 #ifdef CONFIG_NFS_V4
-extern int nfs_callback_up(u32 minorversion, void *args);
+extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 #endif /* CONFIG_NFS_V4 */
 
-- 
1.5.4.3

