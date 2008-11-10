From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 33/85] nfs41: Support sessions with O_DIRECT.
Date: Mon, 10 Nov 2008 22:23:59 +0200
Message-ID: <1226348639-8322-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48800 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbYKJUYF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:24:05 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dean Hildebrand <seattleplus@gmail.com>

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c   |    9 +++++++++
 fs/nfs/internal.h |    6 ++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d4ae559..b20c393 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -259,6 +259,9 @@ static void nfs_direct_read_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_read_result,
 	.rpc_release = nfs_direct_read_release,
 };
@@ -536,6 +539,9 @@ static void nfs_direct_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_commit_result,
 	.rpc_release = nfs_direct_commit_release,
 };
@@ -674,6 +680,9 @@ out_unlock:
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_write_result,
 	.rpc_release = nfs_direct_write_release,
 };
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 86cd70b..f78720b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -180,6 +180,12 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* read.c */
+extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
+
+/* write.c */
+extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+
 /* nfs4proc.c */
 #ifdef CONFIG_NFS_V4_1
 extern void nfs41_sequence_free_slot(struct nfs41_sequence_res *res);
-- 
1.6.0.2

