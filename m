From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 39/67] nfs41: unlink sequence setup/done support
Date: Thu,  2 Apr 2009 16:56:06 +0300
Message-ID: <1238680566-14622-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:31130 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755147AbZDBN4T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:19 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
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
[nfs41: separate free slot from sequence done]
[nfs41: sequence res use slotid]
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 fs/nfs/unlink.c   |   17 +++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6e6bb5b..54172c2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2424,8 +2424,10 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
+	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
+	nfs4_sequence_free_slot(res->server->nfs_client, &res->seq_res);
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
1.6.2.1

