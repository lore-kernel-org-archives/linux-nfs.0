Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19790 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab1EUKdN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:33:13 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/13] [RFC] Bugs in new pnfs write path
Date: Sat, 21 May 2011 13:33:02 +0300
Message-Id: <1305973982-17499-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

1. In nfs4_write_done_cb: data->write_done_cb comes with a NULL.
   Just as a guess I call nfs4_write_done_cb() just above it
   it looked like the right thing todo. With that in, I'm able
   to write things to file When converting pnfs.c:258 to a WARN_ON.

   Benny we might want to set data->write_done_cb somewhere in the
   none-rpc path? where is it best to do that?

2. In pnfs_ld_write_done:
	put_lseg(data->lseg);
	data->lseg = NULL;
   was done before the call to pnfs_set_layoutcommit()
   which trys to get_lseg() on that same data->lseg.

3. In pnfs_ld_write_done:
   data->mds_ops->rpc_call_done(NULL, data);
   crashes with a NULL task. Just pass it with &data->task

   Which calls for a cleanup. There is bunch of functions
   with [task, write_data] API. And the task is always
   write_data->task

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 fs/nfs/pnfs.c     |   10 ++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 759523a..1a53187 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3250,7 +3250,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
-	return data->write_done_cb(task, data);
+	return data->write_done_cb ? data->write_done_cb(task, data) :
+		nfs4_write_done_cb(task, data);
 }
 
 /* Reset the the nfs_write_data to send the write to the MDS. */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 17d0c4c..b04cdb4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -255,7 +255,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = lseg->pls_layout->plh_inode;
 
-	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+ 	WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
 	if (list_empty(&lseg->pls_layout->plh_segs)) {
 		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
@@ -1124,15 +1124,17 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 {
 	int status;
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
 	if (!data->pnfs_error) {
 		pnfs_set_layoutcommit(data);
-		data->mds_ops->rpc_call_done(NULL, data);
+		data->mds_ops->rpc_call_done(&data->task, data);
 		data->mds_ops->rpc_release(data);
+		put_lseg(data->lseg);
+		data->lseg = NULL;
 		return 0;
 	}
 
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
 		data->pnfs_error);
 	status = nfs_initiate_write(data, NFS_CLIENT(data->inode), data->mds_ops, NFS_FILE_SYNC);
-- 
1.7.2.3

