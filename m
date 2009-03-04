From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 43/46] nfs41: read sequence setup/done support
Date: Wed,  4 Mar 2009 02:01:48 +0200
Message-ID: <1236124908-4160-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17925
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754265AbZCDAB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:01:59 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the read rpc_call_prepare method for
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
[nfs41: separate free slot from sequence done]
[remove nfs_readargs.nfs_server, use calldata->inode instead]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Support sessions with O_DIRECT]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c   |    9 +++++++++
 fs/nfs/internal.h |    6 ++++++
 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/read.c     |   30 +++++++++++++++++++++++++++---
 4 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 08f6b04..489fc01 100644
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
@@ -535,6 +538,9 @@ static void nfs_direct_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_commit_result,
 	.rpc_release = nfs_direct_commit_release,
 };
@@ -673,6 +679,9 @@ out_unlock:
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_write_result,
 	.rpc_release = nfs_direct_write_release,
 };
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f7d55a5..0294a4a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -198,6 +198,12 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* read.c */
+extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
+
+/* write.c */
+extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
+
 /* nfs4proc.c */
 extern int _nfs4_call_sync(struct nfs_server *server,
 			   struct rpc_message *msg,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cb5d457..d7627c4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2884,6 +2884,11 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
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
index 9d72124..20104d5 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -22,6 +22,7 @@
 
 #include <asm/system.h>
 
+#include "nfs4_fs.h"
 #include "internal.h"
 #include "iostat.h"
 
@@ -305,7 +306,6 @@ static int nfs_pagein_one(struct inode *inode, struct list_head *head, unsigned
 	data = nfs_readdata_alloc(npages);
 	if (!data)
 		goto out_bad;
-
 	pages = data->pagevec;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
@@ -352,19 +352,24 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
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
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode), &data->res.seq_res);
+	return;
+
 }
 
 /*
@@ -401,7 +406,23 @@ static void nfs_readpage_release_partial(void *calldata)
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
@@ -465,6 +486,9 @@ static void nfs_readpage_release_full(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_read_full_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_read_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_readpage_result_full,
 	.rpc_release = nfs_readpage_release_full,
 };
-- 
1.6.1.3

