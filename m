From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: inline nfs4_restart_rpc
Date: Mon,  6 Apr 2009 10:50:13 +0300
Message-ID: <1239004213-8740-1-git-send-email-bhalevy@panasas.com>
References: <49D9B2B9.5010401@panasas.com>
Cc: Andy Adamson <andros@netapp.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-next@vger.kernel.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1904 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751741AbZDFHuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 03:50:25 -0400
In-Reply-To: <49D9B2B9.5010401@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must always define nfs4_restart_rpc.

fs/built-in.o: In function `nfs_readpage_result_full':
read.c:(.text+0x70d24): undefined reference to `nfs4_restart_rpc'
fs/built-in.o: In function `nfs_readpage_result_partial':
read.c:(.text+0x70e3c): undefined reference to `nfs4_restart_rpc'
fs/built-in.o: In function `nfs_async_unlink_done':
unlink.c:(.text+0x71af0): undefined reference to `nfs4_restart_rpc'
fs/built-in.o: In function `nfs_writeback_done':
(.text+0x72c00): undefined reference to `nfs4_restart_rpc'

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |   39 +++++++++++++++++++++++++--------------
 fs/nfs/nfs4proc.c |   12 ------------
 2 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index a812866..43d9ca4 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -2,6 +2,7 @@
  * NFS internal definitions
  */
 
+#include "nfs4_fs.h"
 #include <linux/mount.h>
 #include <linux/security.h>
 
@@ -15,6 +16,18 @@ struct nfs_string;
  */
 #define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
 
+/*
+ * Determine if sessions are in use.
+ */
+static inline int nfs4_has_session(const struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (clp->cl_session)
+		return 1;
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
@@ -146,8 +159,18 @@ extern struct rpc_procinfo nfs3_procedures[];
 extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);
 
 /* nfs4proc.c */
-extern void nfs4_restart_rpc(struct rpc_task *task,
-			     const struct nfs_client *clp);
+static inline void nfs4_restart_rpc(struct rpc_task *task,
+				    const struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp) &&
+	    test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
+		rpc_restart_call_prepare(task);
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+	rpc_restart_call(task);
+}
 
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
@@ -222,18 +245,6 @@ extern int _nfs4_call_sync_session(struct nfs_server *server,
 				   struct nfs4_sequence_res *res,
 				   int cache_reply);
 
-/*
- * Determine if sessions are in use.
- */
-static inline int nfs4_has_session(const struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (clp->cl_session)
-		return 1;
-#endif /* CONFIG_NFS_V4_1 */
-	return 0;
-}
-
 #ifdef CONFIG_NFS_V4_1
 extern void nfs41_sequence_free_slot(const struct nfs_client *,
 				     struct nfs4_sequence_res *res);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d6ed319..3e4194f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -646,18 +646,6 @@ static void nfs4_sequence_done_free_slot(const struct nfs_server *server,
 	nfs4_sequence_free_slot(server->nfs_client, res);
 }
 
-void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp) &&
-	    test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
-		rpc_restart_call_prepare(task);
-		return;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-	rpc_restart_call(task);
-}
-
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
-- 
1.6.2.1

