Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38804 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcADSVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:52 -0500
Received: by mail-ig0-f169.google.com with SMTP id mw1so109436622igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:52 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 09/18] NFSv4.1/pNFS: Don't queue up a new commit if the layout segment is invalid
Date: Mon,  4 Jan 2016 13:21:07 -0500
Message-Id: <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the layout segment is invalid, then we should not be adding more
write requests to the commit list. Instead, those writes should be
replayed after requesting a new layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c  |  2 ++
 fs/nfs/direct.c         | 12 ++++++++++++
 fs/nfs/pnfs.c           |  3 +++
 fs/nfs/pnfs.h           |  6 ++++++
 fs/nfs/pnfs_nfs.c       |  5 +++++
 fs/nfs/write.c          |  9 +++++++++
 include/linux/nfs_xdr.h |  2 ++
 7 files changed, 39 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e4dbab5dce6e..2be8b252e3b1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -233,6 +233,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
+	/* Free all lsegs that are attached to commit buckets */
+	nfs_commit_inode(ino, 0);
 	pnfs_put_layout_hdr(lo);
 	trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, ino,
 			&args->cbl_stateid, -rv);
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 14f77df79c25..a9a93927fe3e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -721,8 +721,20 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		nfs_direct_write_complete(dreq, data->inode);
 }
 
+static void nfs_direct_resched_write(struct nfs_commit_info *cinfo,
+		struct nfs_page *req)
+{
+	struct nfs_direct_req *dreq = cinfo->dreq;
+
+	spin_lock(&dreq->lock);
+	dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+	spin_unlock(&dreq->lock);
+	nfs_mark_request_commit(req, NULL, cinfo, 0);
+}
+
 static const struct nfs_commit_completion_ops nfs_direct_commit_completion_ops = {
 	.completion = nfs_direct_commit_complete,
+	.resched_write = nfs_direct_resched_write,
 };
 
 static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 360fe95c97b5..6593be7c0129 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -703,6 +703,8 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 			ret = -EAGAIN;
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg_list(&lseg_list);
+		/* Free all lsegs that are attached to commit buckets */
+		nfs_commit_inode(inode, 0);
 		pnfs_put_layout_hdr(lo);
 		iput(inode);
 	}
@@ -1811,6 +1813,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	pnfs_mark_matching_lsegs_return(lo, &free_me, &range);
 	spin_unlock(&inode->i_lock);
 	pnfs_free_lseg_list(&free_me);
+	nfs_commit_inode(inode, 0);
 }
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d93c2ebc0fd3..4bd7faf9ce50 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -412,6 +412,12 @@ pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 	return lseg;
 }
 
+static inline bool
+pnfs_is_valid_lseg(struct pnfs_layout_segment *lseg)
+{
+	return test_bit(NFS_LSEG_VALID, &lseg->pls_flags) != 0;
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 3c8e3a44e6ea..81ac6480f9e7 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -868,6 +868,11 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	buckets = cinfo->ds->buckets;
 	list = &buckets[ds_commit_idx].written;
 	if (list_empty(list)) {
+		if (!pnfs_is_valid_lseg(lseg)) {
+			spin_unlock(cinfo->lock);
+			cinfo->completion_ops->resched_write(cinfo, req);
+			return;
+		}
 		/* Non-empty buckets hold a reference on the lseg.  That ref
 		 * is normally transferred to the COMMIT call and released
 		 * there.  It could also be released if the last req is pulled
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ae29f082c9c2..0aa8d6f23b4c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1676,6 +1676,13 @@ void nfs_retry_commit(struct list_head *page_list,
 }
 EXPORT_SYMBOL_GPL(nfs_retry_commit);
 
+static void
+nfs_commit_resched_write(struct nfs_commit_info *cinfo,
+		struct nfs_page *req)
+{
+	__set_page_dirty_nobuffers(req->wb_page);
+}
+
 /*
  * Commit dirty pages
  */
@@ -1777,6 +1784,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 
 static const struct nfs_commit_completion_ops nfs_commit_completion_ops = {
 	.completion = nfs_commit_release_pages,
+	.resched_write = nfs_commit_resched_write,
 };
 
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
@@ -1823,6 +1831,7 @@ out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return res;
 }
+EXPORT_SYMBOL_GPL(nfs_commit_inode);
 
 int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a8905b7d4d7f..bee3e60a7006 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1420,10 +1420,12 @@ struct nfs_mds_commit_info {
 	struct list_head	list;
 };
 
+struct nfs_commit_info;
 struct nfs_commit_data;
 struct nfs_inode;
 struct nfs_commit_completion_ops {
 	void (*completion) (struct nfs_commit_data *data);
+	void (*resched_write) (struct nfs_commit_info *, struct nfs_page *);
 };
 
 struct nfs_commit_info {
-- 
2.5.0

