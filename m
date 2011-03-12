Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933963Ab1CXT1c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Mar 2011 15:27:32 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] NFSv4.1 convert layoutcommit sync to boolean
Date: Sat, 12 Mar 2011 02:58:10 -0500
Message-Id: <1299916690-2595-2-git-send-email-andros@netapp.com>
In-Reply-To: <1299916690-2595-1-git-send-email-andros@netapp.com>
References: <1299916690-2595-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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

