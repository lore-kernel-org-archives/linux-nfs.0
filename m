From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 21/37] NFS: Fix trace debugging nits in write.c
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.14369.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757686AbYFLTf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:35:28 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: fix a few dprintk messages that still need to show the RPC task ID
correctly, and be sure we use the preferred %lld or %llu instead of %Ld or
%Lu.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ee6fcde..21d8a48 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -713,10 +713,10 @@ int nfs_updatepage(struct file *file, struct page *page,
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
-	dprintk("NFS:      nfs_updatepage(%s/%s %d@%Ld)\n",
+	dprintk("NFS:       nfs_updatepage(%s/%s %d@%lld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name, count,
-		(long long)(page_offset(page) +offset));
+		(long long)(page_offset(page) + offset));
 
 	/* If we're not using byte range locks, and we know the page
 	 * is up to date, it may be more efficient to extend the write
@@ -736,7 +736,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	else
 		__set_page_dirty_nobuffers(page);
 
-        dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
+	dprintk("NFS:       nfs_updatepage returns %d (isize %lld)\n",
 			status, (long long)i_size_read(inode));
 	return status;
 }
@@ -821,7 +821,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
 	NFS_PROTO(inode)->write_setup(data, &msg);
 
 	dprintk("NFS: %5u initiated write call "
-		"(req %s/%Ld, %u bytes @ offset %Lu)\n",
+		"(req %s/%lld, %u bytes @ offset %llu)\n",
 		data->task.tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -965,13 +965,13 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 static void nfs_writeback_done_partial(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req = data->req;
 
-	dprintk("NFS: write (%s/%Ld %d@%Ld)",
-		req->wb_context->path.dentry->d_inode->i_sb->s_id,
-		(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
-		req->wb_bytes,
-		(long long)req_offset(req));
+	dprintk("NFS: %5u write(%s/%lld %d@%lld)",
+		task->tk_pid,
+		data->req->wb_context->path.dentry->d_inode->i_sb->s_id,
+		(long long)
+		  NFS_FILEID(data->req->wb_context->path.dentry->d_inode),
+		data->req->wb_bytes, (long long)req_offset(data->req));
 
 	nfs_writeback_done(task, data);
 }
@@ -1045,7 +1045,8 @@ static void nfs_writeback_release_full(void *calldata)
 
 		nfs_list_remove_request(req);
 
-		dprintk("NFS: write (%s/%Ld %d@%Ld)",
+		dprintk("NFS: %5u write (%s/%lld %d@%lld)",
+			data->task.tk_pid,
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,
@@ -1118,7 +1119,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		static unsigned long    complain;
 
 		if (time_before(complain, jiffies)) {
-			dprintk("NFS: faulty NFS server %s:"
+			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
 				NFS_SERVER(data->inode)->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
@@ -1287,7 +1288,7 @@ static void nfs_commit_release(void *calldata)
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
 
-		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
+		dprintk("NFS:       commit (%s/%lld %d@%lld)",
 			req->wb_context->path.dentry->d_inode->i_sb->s_id,
 			(long long)NFS_FILEID(req->wb_context->path.dentry->d_inode),
 			req->wb_bytes,

