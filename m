From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 45/46] nfs41 commit sequence setup done support
Date: Wed,  4 Mar 2009 02:02:11 +0200
Message-ID: <1236124931-4212-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17984
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754265AbZCDACY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 19:02:24 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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

move the nfs4_sequence_free_slot call in nfs_readpage_retry from
nfs41: separate free slot from sequence done

Signed-off-by: Andy Adamson<andros@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 fs/nfs/write.c    |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f37420c..6f92037 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2940,10 +2940,13 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
+			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
+	nfs4_sequence_free_slot(NFS_SERVER(inode), &data->res.seq_res);
 	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d01050b..5c01551 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1350,6 +1350,9 @@ static void nfs_commit_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
+#if defined(CONFIG_NFS_V4_1)
+	.rpc_call_prepare = nfs_write_prepare,
+#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs_commit_done,
 	.rpc_release = nfs_commit_release,
 };
-- 
1.6.1.3

