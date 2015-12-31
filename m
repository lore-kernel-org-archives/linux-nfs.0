Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35840 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbLaTRg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Dec 2015 14:17:36 -0500
Received: by mail-ig0-f173.google.com with SMTP id ph11so200988709igc.1
        for <linux-nfs@vger.kernel.org>; Thu, 31 Dec 2015 11:17:36 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFS: Allow multiple commit requests in flight per file
Date: Thu, 31 Dec 2015 14:10:24 -0500
Message-Id: <1451589026-50874-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451589026-50874-1-git-send-email-trond.myklebust@primarydata.com>
References: <1451589026-50874-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow synchronous RPC calls to wait for pending RPC calls to finish,
but also allow asynchronous ones to just fire off another commit.

With this patch, the xfstests generic/074 test completes in 226s
instead of 242s

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c         |  6 -----
 fs/nfs/file.c           |  2 +-
 fs/nfs/nfstrace.h       |  1 -
 fs/nfs/pnfs_nfs.c       |  5 +---
 fs/nfs/write.c          | 70 +++++++++++++++++++++++--------------------------
 include/linux/nfs_fs.h  |  1 -
 include/linux/nfs_xdr.h |  1 -
 7 files changed, 35 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e73693f75dee..14f77df79c25 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -721,14 +721,8 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		nfs_direct_write_complete(dreq, data->inode);
 }
 
-static void nfs_direct_error_cleanup(struct nfs_inode *nfsi)
-{
-	/* There is no lock to clear */
-}
-
 static const struct nfs_commit_completion_ops nfs_direct_commit_completion_ops = {
 	.completion = nfs_direct_commit_complete,
-	.error_cleanup = nfs_direct_error_cleanup,
 };
 
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 93e236429c5d..e6ef80ec699c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -514,7 +514,7 @@ static void nfs_check_dirty_writeback(struct page *page,
 	 * so it will not block due to pages that will shortly be freeable.
 	 */
 	nfsi = NFS_I(mapping->host);
-	if (test_bit(NFS_INO_COMMIT, &nfsi->flags)) {
+	if (atomic_read(&nfsi->commit_info.rpcs_out)) {
 		*writeback = true;
 		return;
 	}
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 59f838cdc009..9f80a086b612 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -39,7 +39,6 @@
 			{ 1 << NFS_INO_INVALIDATING, "INVALIDATING" }, \
 			{ 1 << NFS_INO_FLUSHING, "FLUSHING" }, \
 			{ 1 << NFS_INO_FSCACHE, "FSCACHE" }, \
-			{ 1 << NFS_INO_COMMIT, "COMMIT" }, \
 			{ 1 << NFS_INO_LAYOUTCOMMIT, "NEED_LAYOUTCOMMIT" }, \
 			{ 1 << NFS_INO_LAYOUTCOMMITTING, "LAYOUTCOMMIT" })
 
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 24655b807d44..3c8e3a44e6ea 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -266,17 +266,14 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		} else {
 			nfs_retry_commit(mds_pages, NULL, cinfo, 0);
 			pnfs_generic_retry_commit(cinfo, 0);
-			cinfo->completion_ops->error_cleanup(NFS_I(inode));
 			return -ENOMEM;
 		}
 	}
 
 	nreq += pnfs_generic_alloc_ds_commits(cinfo, &list);
 
-	if (nreq == 0) {
-		cinfo->completion_ops->error_cleanup(NFS_I(inode));
+	if (nreq == 0)
 		goto out;
-	}
 
 	atomic_add(nreq, &cinfo->mds->rpcs_out);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0aa3e6b3db70..ae29f082c9c2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -21,6 +21,8 @@
 #include <linux/nfs_page.h>
 #include <linux/backing-dev.h>
 #include <linux/export.h>
+#include <linux/freezer.h>
+#include <linux/wait.h>
 
 #include <asm/uaccess.h>
 
@@ -1535,27 +1537,29 @@ static void nfs_writeback_result(struct rpc_task *task,
 	}
 }
 
+static int nfs_wait_atomic_killable(atomic_t *key)
+{
+	if (fatal_signal_pending(current))
+		return -ERESTARTSYS;
+	freezable_schedule_unsafe();
+	return 0;
+}
 
-static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
+static int wait_on_commit(struct nfs_mds_commit_info *cinfo)
 {
-	int ret;
+	return wait_on_atomic_t(&cinfo->rpcs_out,
+			nfs_wait_atomic_killable, TASK_KILLABLE);
+}
 
-	if (!test_and_set_bit(NFS_INO_COMMIT, &nfsi->flags))
-		return 1;
-	if (!may_wait)
-		return 0;
-	ret = out_of_line_wait_on_bit_lock(&nfsi->flags,
-				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
-				TASK_KILLABLE);
-	return (ret < 0) ? ret : 1;
+static void nfs_commit_begin(struct nfs_mds_commit_info *cinfo)
+{
+	atomic_inc(&cinfo->rpcs_out);
 }
 
-static void nfs_commit_clear_lock(struct nfs_inode *nfsi)
+static void nfs_commit_end(struct nfs_mds_commit_info *cinfo)
 {
-	clear_bit(NFS_INO_COMMIT, &nfsi->flags);
-	smp_mb__after_atomic();
-	wake_up_bit(&nfsi->flags, NFS_INO_COMMIT);
+	if (atomic_dec_and_test(&cinfo->rpcs_out))
+		wake_up_atomic_t(&cinfo->rpcs_out);
 }
 
 void nfs_commitdata_release(struct nfs_commit_data *data)
@@ -1693,7 +1697,6 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 				   data->mds_ops, how, 0);
  out_bad:
 	nfs_retry_commit(head, NULL, cinfo, 0);
-	cinfo->completion_ops->error_cleanup(NFS_I(inode));
 	return -ENOMEM;
 }
 
@@ -1755,8 +1758,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
 
 	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
-	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
-		nfs_commit_clear_lock(NFS_I(data->inode));
+	nfs_commit_end(cinfo.mds);
 }
 
 static void nfs_commit_release(void *calldata)
@@ -1775,7 +1777,6 @@ static const struct rpc_call_ops nfs_commit_ops = {
 
 static const struct nfs_commit_completion_ops nfs_commit_completion_ops = {
 	.completion = nfs_commit_release_pages,
-	.error_cleanup = nfs_commit_clear_lock,
 };
 
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
@@ -1794,30 +1795,25 @@ int nfs_commit_inode(struct inode *inode, int how)
 	LIST_HEAD(head);
 	struct nfs_commit_info cinfo;
 	int may_wait = how & FLUSH_SYNC;
+	int error = 0;
 	int res;
 
-	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
-	if (res <= 0)
-		goto out_mark_dirty;
 	nfs_init_cinfo_from_inode(&cinfo, inode);
+	nfs_commit_begin(cinfo.mds);
 	res = nfs_scan_commit(inode, &head, &cinfo);
-	if (res) {
-		int error;
-
+	if (res)
 		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
-		if (error < 0)
-			return error;
-		if (!may_wait)
-			goto out_mark_dirty;
-		error = wait_on_bit_action(&NFS_I(inode)->flags,
-				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
-				TASK_KILLABLE);
-		if (error < 0)
-			return error;
-	} else
-		nfs_commit_clear_lock(NFS_I(inode));
+	nfs_commit_end(cinfo.mds);
+	if (error < 0)
+		goto out_error;
+	if (!may_wait)
+		goto out_mark_dirty;
+	error = wait_on_commit(cinfo.mds);
+	if (error < 0)
+		return error;
 	return res;
+out_error:
+	res = error;
 	/* Note: If we exit without ensuring that the commit is complete,
 	 * we must mark the inode as dirty. Otherwise, future calls to
 	 * sync_inode() with the WB_SYNC_ALL flag set will fail to ensure
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c0e961474a52..ebf0bd72a42b 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -216,7 +216,6 @@ struct nfs_inode {
 #define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
-#define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 #define NFS_INO_LAYOUTSTATS	(11)		/* layoutstats inflight */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e89dbb14138c..a8905b7d4d7f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1423,7 +1423,6 @@ struct nfs_mds_commit_info {
 struct nfs_commit_data;
 struct nfs_inode;
 struct nfs_commit_completion_ops {
-	void (*error_cleanup) (struct nfs_inode *nfsi);
 	void (*completion) (struct nfs_commit_data *data);
 };
 
-- 
2.5.0

