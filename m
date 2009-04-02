From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 40/67] nfs41: read sequence setup/done support
Date: Thu,  2 Apr 2009 16:56:18 +0300
Message-ID: <1238680578-14653-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29875 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752327AbZDBN4d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:33 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the read rpc_call_prepare method for
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
[nfs41: separate free slot from sequence done]
[remove nfs_readargs.nfs_server, use calldata->inode instead]
Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Support sessions with O_DIRECT]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c   |    3 +++
 fs/nfs/internal.h |    3 +++
 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/read.c     |   30 ++++++++++++++++++++++++++++--
 4 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 08f6b04..c8c53a0 100644
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
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 12f4c5e..988c8b9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -206,6 +206,9 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* read.c */
+extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
+
 /* nfs4proc.c */
 extern int _nfs4_call_sync(struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 54172c2..a3e19e9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2864,6 +2864,11 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
+	dprintk("--> %s\n", __func__);
+
+	/* nfs4_sequence_free_slot called in the read rpc_call_done */
+	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 70ba2b4..d71f0d5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -22,6 +22,7 @@
 
 #include <asm/system.h>
 
+#include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
@@ -358,19 +359,25 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	struct nfs_readres *resp = &data->res;
 
 	if (resp->eof || resp->count == argp->count)
-		return;
+		goto out;
 
 	/* This is a short read! */
 	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
 	if (resp->count == 0)
-		return;
+		goto out;
 
 	/* Yes, so retry the read at the end of the data */
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
 	rpc_restart_call(task);
+	return;
+out:
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
+				&data->res.seq_res);
+	return;
+
 }
 
 /*
@@ -407,7 +414,23 @@ static void nfs_readpage_release_partial(void *calldata)
 	nfs_readdata_release(calldata);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+void nfs_read_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_read_data *data = calldata;
+
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode)->nfs_client,
+				&data->args.seq_args, &data->res.seq_res,
+				0, task))
+		return;
+	rpc_call_start(task);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 static const struct rpc_call_ops nfs_read_partial_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_readpage_result_partial,
 	.rpc_release = nfs_readpage_release_partial,
 };
@@ -471,6 +494,9 @@ static void nfs_readpage_release_full(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_readpage_result_full,
 	.rpc_release = nfs_readpage_release_full,
 };
-- 
1.6.2.1

