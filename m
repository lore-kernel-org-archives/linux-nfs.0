From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/24] NFS: Fix trace debugging nits in write.c
Date: Mon, 14 Apr 2008 12:26:54 -0400
Message-ID: <20080414162654.12741.73715.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:47981 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756831AbYDNQ1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:15 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/write.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bed6341..969658b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -728,10 +728,10 @@ int nfs_updatepage(struct file *file, struct page *page,
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
-	dprintk("NFS:      nfs_updatepage(%s/%s %d@%Ld)\n",
+	dprintk("NFS:       nfs_updatepage(%s/%s %d@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) +offset));
+		(long long)(page_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -748,7 +748,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	status = nfs_writepage_setup(ctx, page, offset, count);
 	__set_page_dirty_nobuffers(page);
 
-        dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
+	dprintk("NFS:       nfs_updatepage returns %d (isize %Ld)\n",
 			status, (long long)i_size_read(inode));
 	if (status < 0)
 		nfs_set_pageerror(page);
@@ -974,7 +974,8 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 	struct nfs_page		*req = data->req;
 	struct page		*page = req->wb_page;
 
-	dprintk("NFS: write (%s/%Ld %d@%Ld)",
+	dprintk("NFS: %5u write(%s/%Ld %d@%Ld)",
+		task->tk_pid,
 		req->wb_context->path.dentry->d_inode->i_sb->s_id,
 		(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 		req->wb_bytes,
@@ -1040,7 +1041,8 @@ static void nfs_writeback_done_full(struct rpc_task *task, void *calldata)
 		nfs_list_remove_request(req);
 		page = req->wb_page;
 
-		dprintk("NFS: write (%s/%Ld %d@%Ld)",
+		dprintk("NFS: %5u write (%s/%Ld %d@%Ld)",
+			task->tk_pid,
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,
@@ -1114,7 +1116,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		static unsigned long    complain;
 
 		if (time_before(complain, jiffies)) {
-			dprintk("NFS: faulty NFS server %s:"
+			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
 				NFS_SERVER(data->inode)->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
@@ -1272,7 +1274,7 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
 
-		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
+		dprintk("NFS:       commit (%s/%Ld %d@%Ld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,

