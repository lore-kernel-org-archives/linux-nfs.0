From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 19/19] SQUASHME: pnfs-submit: get rid of pnfs_v4_clientops
Date: Thu, 17 Jun 2010 10:51:36 -0400
Message-ID: <1276786296-13160-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6567 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932915Ab0FQOva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:51:30 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |    4 ----
 fs/nfs/nfs4proc.c |   12 ------------
 fs/nfs/pnfs.c     |    7 -------
 3 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a30974a..e5f6f16 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -211,10 +211,6 @@ extern const u32 nfs41_maxwrite_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
-#ifdef CONFIG_NFS_V4_1
-extern void pnfs_v4_clientops_init(void);
-#endif /* CONFIG_NFS_V4_1 */
-
 extern int nfs4_recover_expired_lease(struct nfs_client *clp);
 
 /* proc.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 915e7cb..8109692 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5939,18 +5939,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 };
 
-#if defined(CONFIG_NFS_V4_1)
-const struct nfs_rpc_ops pnfs_v4_clientops;
-
-void
-pnfs_v4_clientops_init(void)
-{
-	struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
-
-	memcpy(p, &nfs_v4_clientops, sizeof(*p));
-}
-#endif /* CONFIG_NFS_V4_1 */
-
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 414b7dc..6dd454c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -118,8 +118,6 @@ pnfs_initialize(void)
 		return -ENOMEM;
 	}
 
-	pnfs_v4_clientops_init();
-
 	pnfs_initialized = 1;
 	return 0;
 }
@@ -229,11 +227,6 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 			       "for layout driver %u. ", __func__, id);
 			goto out_err;
 		}
-		/*
-		 * Layout driver succeeded in initializing mountpoint
-		 * and has taken a reference on the nfs_client cl_devid_cache
-		 */
-		server->nfs_client->rpc_ops = &pnfs_v4_clientops;
 		dprintk("%s: pNFS module for %u set\n", __func__, id);
 		return;
 	}
-- 
1.6.4.4

