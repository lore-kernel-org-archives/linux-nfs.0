Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:22545 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933847Ab1CXTw7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 15:52:59 -0400
From: <peter.staubach@emc.com>
To: <andros@netapp.com>, <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Date: Thu, 24 Mar 2011 15:50:49 -0400
Subject: RE: [PATCH 2/2] NFSv4.1 convert layoutcommit sync to boolean
Message-ID: <5E6794FC7B8FCA41A704019BE3C70E8B069D3AAA@MX31A.corp.emc.com>
References: <1299916690-2595-1-git-send-email-andros@netapp.com>
 <1299916690-2595-2-git-send-email-andros@netapp.com>
In-Reply-To: <1299916690-2595-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In nfs4_proc_layoutcommit(), I think that it read better as "if (!sync)".  Wasn't that part of the whole point of switching to boolean instead of just an int?  :-)

	Thanx...

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of andros@netapp.com
Sent: Saturday, March 12, 2011 2:58 AM
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org; Andy Adamson
Subject: [PATCH 2/2] NFSv4.1 convert layoutcommit sync to boolean

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/file.c     |    2 +-
 fs/nfs/nfs4_fs.h  |    2 +-
 fs/nfs/nfs4proc.c |    4 ++--
 fs/nfs/pnfs.c     |    2 +-
 fs/nfs/pnfs.h     |    4 ++--
 fs/nfs/write.c    |    8 +++++---
 6 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 85cb95d..3ac5bd6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -328,7 +328,7 @@ nfs_file_fsync(struct file *file, int datasync)
 		ret = status;
 	if (!ret && !datasync)
 		/* application has asked for meta-data sync */
-		ret = pnfs_layoutcommit_inode(inode, 1);
+		ret = pnfs_layoutcommit_inode(inode, true);
 	return ret;
 }
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1e612d1..4414fd7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -263,7 +263,7 @@ extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
-				  int sync);
+				  bool sync);
 
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f2f402..43045fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5671,7 +5671,7 @@ static const struct rpc_call_ops nfs4_layoutcommit_ops = {
 };
 
 int
-nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int sync)
+nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTCOMMIT],
@@ -5699,7 +5699,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int sync)
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (!sync)
+	if (sync == false)
 		goto out;
 	status = nfs4_wait_for_completion_rpc_task(task);
 	if (status != 0)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ac71125..22c2ddb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -991,7 +991,7 @@ EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
  * if WRITEs to a data server return NFS_DATA_SYNC.
  */
 int
-pnfs_layoutcommit_inode(struct inode *inode, int sync)
+pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0806c77..33b9ae9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -155,7 +155,7 @@ void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
-int pnfs_layoutcommit_inode(struct inode *inode, int sync);
+int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 
 static inline int lo_fail_bit(u32 iomode)
 {
@@ -328,7 +328,7 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 {
 }
 
-static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
+static inline int pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	return 0;
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index a03c11f..85d7525 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1566,10 +1566,12 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 
 	ret = nfs_commit_unstable_pages(inode, wbc);
 	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
-		int status, sync = wbc->sync_mode;
+		int status;
+		bool sync = true;
 
-		if (wbc->nonblocking || wbc->for_background)
-				sync = 0;
+		if (wbc->sync_mode == WB_SYNC_NONE || wbc->nonblocking ||
+		    wbc->for_background)
+			sync = false;
 
 		status = pnfs_layoutcommit_inode(inode, sync);
 		if (status < 0)
-- 
1.6.6

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

