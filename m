From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] NFS: Fix trace debugging nits in write.c
Date: Tue, 27 May 2008 16:29:44 -0400
Message-ID: <20080527202944.6651.59747.stgit@ellison.1015granger.net>
References: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32607 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758006AbYE0UaH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 16:30:07 -0400
In-Reply-To: <20080527202347.6651.54668.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fix a few dprintk messages that still need to show the RPC task ID
correctly, and be sure we use the preferred %lld or %llu instead of %Ld or
%Lu.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/write.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 6d8ace3..c03a039 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -721,10 +721,10 @@ int nfs_updatepage(struct file *file, struct page *page,
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
-	dprintk("NFS:      nfs_updatepage(%s/%s %d@%Ld)\n",
+	dprintk("NFS:       nfs_updatepage(%s/%s %d@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) +offset));
+		(long long)(page_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -741,7 +741,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	status = nfs_writepage_setup(ctx, page, offset, count);
 	__set_page_dirty_nobuffers(page);
 
-        dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
+	dprintk("NFS:       nfs_updatepage returns %d (isize %lld)\n",
 			status, (long long)i_size_read(inode));
 	if (status < 0)
 		nfs_set_pageerror(page);
@@ -833,7 +833,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	NFS_PROTO(inode)->write_setup(data, &msg);
 
 	dprintk("NFS: %5u initiated write call "
-		"(req %s/%Ld, %u bytes @ offset %Lu)\n",
+		"(req %s/%lld, %u bytes @ offset %llu)\n",
 		data->task.tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -979,7 +979,8 @@ static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 	struct nfs_write_data	*data = calldata;
 	struct nfs_page		*req = data->req;
 
-	dprintk("NFS: write (%s/%Ld %d@%Ld)",
+	dprintk("NFS: %5u write(%s/%lld %d@%lld)",
+		task->tk_pid,
 		req->wb_context->path.dentry->d_inode->i_sb->s_id,
 		(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 		req->wb_bytes,
@@ -1057,7 +1058,8 @@ static void nfs_writeback_release_full(void *calldata)
 
 		nfs_list_remove_request(req);
 
-		dprintk("NFS: write (%s/%Ld %d@%Ld)",
+		dprintk("NFS: %5u write (%s/%lld %d@%lld)",
+			data->task.tk_pid,
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,
@@ -1132,7 +1134,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		static unsigned long    complain;
 
 		if (time_before(complain, jiffies)) {
-			dprintk("NFS: faulty NFS server %s:"
+			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
 				NFS_SERVER(data->inode)->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
@@ -1301,7 +1303,7 @@ static void nfs_commit_release(void *calldata)
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
 
-		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
+		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,

