From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 42/46] nfs41: unlink sequence setup/done support
Date: Wed,  4 Mar 2009 02:01:38 +0200
Message-ID: <1236124898-4135-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17931
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754355AbZCDABw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:01:52 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the rpc_call_prepare methods for
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

move nfs4_sequence_free_slot from nfs41: separate free slot from sequence done

Don't free the slot until after all rpc_restart_calls have completed.
Session reset will require more work.

[nfs41: sequence res use slotid]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 fs/nfs/unlink.c   |   17 +++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d13918..cb5d457 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2444,8 +2444,10 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
+	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
+	nfs4_sequence_free_slot(res->server, &res->seq_res);
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, &res->dir_attr);
 	return 1;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 83d0ce2..089a21b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -15,6 +15,7 @@
 #include <linux/wait.h>
 
 #include "internal.h"
+#include "nfs4_fs.h"
 
 struct nfs_unlinkdata {
 	struct hlist_node list;
@@ -102,9 +103,25 @@ static void nfs_async_unlink_release(void *calldata)
 	nfs_sb_deactive(sb);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_unlinkdata *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->dir);
+
+	if (nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+				&data->res.seq_res, 1, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_call_done = nfs_async_unlink_done,
 	.rpc_release = nfs_async_unlink_release,
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_unlink_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
-- 
1.6.1.3

