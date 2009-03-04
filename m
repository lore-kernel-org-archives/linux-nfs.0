From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 44/46] nfs41 write sequence setup done support
Date: Wed,  4 Mar 2009 02:01:59 +0200
Message-ID: <1236124919-4187-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17856
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754218AbZCDACN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:02:13 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: client data server write validate and release]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[move the nfs4_sequence_free_slot call in nfs_readpage_retry from]
[nfs41: separate free slot from sequence done
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Support sessions with O_DIRECT.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    4 ++++
 fs/nfs/write.c    |   21 +++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d7627c4..f37420c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2910,6 +2910,10 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
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
index a48afb4..d01050b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -25,6 +25,7 @@
 #include "delegation.h"
 #include "internal.h"
 #include "iostat.h"
+#include "nfs4_fs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -1028,7 +1029,23 @@ out:
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
@@ -1091,6 +1108,9 @@ remove_request:
 }
 
 static const struct rpc_call_ops nfs_write_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_writeback_done_full,
 	.rpc_release = nfs_writeback_release_full,
 };
@@ -1173,6 +1193,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode), &data->res.seq_res);
 	return 0;
 }
 
-- 
1.6.1.3

