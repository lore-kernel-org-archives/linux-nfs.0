From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 42/67] nfs41 commit sequence setup done support
Date: Thu,  2 Apr 2009 16:56:37 +0300
Message-ID: <1238680597-14715-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19719 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756824AbZDBN4q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:56:46 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate commit calls from nfs41: sequence setup/done support

Implement the commit rpc_call_prepare method for
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
[nfs41: Support sessions with O_DIRECT.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: separate free slot from sequence done]
[nfs41: nfs4_sequence_free_slot use nfs_client for data server]
Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/direct.c   |    3 +++
 fs/nfs/nfs4proc.c |    4 ++++
 fs/nfs/write.c    |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1955bfe..489fc01 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -538,6 +538,9 @@ static void nfs_direct_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_direct_commit_result,
 	.rpc_release = nfs_direct_commit_release,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ba8e419..1132eda 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2920,10 +2920,14 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
+			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
+	nfs4_sequence_free_slot(NFS_SERVER(inode)->nfs_client,
+				&data->res.seq_res);
 	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 195fe76..85a7640 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1373,6 +1373,9 @@ static void nfs_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
-- 
1.6.2.1

