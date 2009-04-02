From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 41/67] nfs41 write sequence setup done support
Date: Thu,  2 Apr 2009 16:56:31 +0300
Message-ID: <1238680591-14684-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2072 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755168AbZDBN4j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:39 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate write calls from nfs41: sequence setup/done support

Implement the write rpc_call_prepare method for
asynchronuos nfs rpcs, call nfs41_setup_sequence from
respective rpc_call_validate_args methods.

Call nfs4_sequence_done from respective rpc_call_done methods.

Note that we need to pass a pointer to the nfs_server in calls data
for passing on to nfs4_sequence_done.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
[nfs41: separate free slot from sequence done
Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Support sessions with O_DIRECT.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c   |    3 +++
 fs/nfs/internal.h |    3 +++
 fs/nfs/nfs4proc.c |    4 ++++
 fs/nfs/write.c    |   22 ++++++++++++++++++++++
 4 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index c8c53a0..1955bfe 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -676,6 +676,9 @@ out_unlock:
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_write_result,
 	.rpc_release = nfs_direct_write_release,
 };
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 988c8b9..f62bc52 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -209,6 +209,9 @@ extern int nfs4_path_walk(struct nfs_server *server,
 /* read.c */
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
+/* write.c */
+extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+
 /* nfs4proc.c */
 extern int _nfs4_call_sync(struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a3e19e9..ba8e419 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2890,6 +2890,10 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+	/* slot is freed in nfs_writeback_done */
+	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
+			   task->tk_status);
+
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 035e6fb..195fe76 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -25,6 +25,7 @@
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
+#include "nfs4_fs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -1050,7 +1051,23 @@ out:
 	nfs_writedata_release(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_write_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+	struct nfs_client *clp = (NFS_SERVER(data->inode))->nfs_client;
+
+	if (nfs4_setup_sequence(clp, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs_write_partial_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_writeback_done_partial,
 	.rpc_release = nfs_writeback_release_partial,
 };
@@ -1113,6 +1130,9 @@ remove_request:
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_writeback_done_full,
 	.rpc_release = nfs_writeback_release_full,
 };
@@ -1195,6 +1215,8 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
+				&data->res.seq_res);
 	return 0;
 }
 
-- 
1.6.2.1

