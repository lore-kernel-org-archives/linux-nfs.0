From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/21] NFS: fix print format for tk_pid
Date: Thu, 16 Nov 2006 15:04:55 -0500
Message-ID: <20061116200455.32549.98347.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1s-0006xk-4X
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:12 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1s-00051D-7t
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:13 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The tk_pid field is an unsigned short.  The proper print format specifier for
that type is %5u, not %4d.

Also clean up some miscellaneous print formatting nits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |    8 ++++----
 fs/nfs/read.c   |    4 ++--
 fs/nfs/write.c  |    8 ++++----
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index bdfabf8..1d5a49f 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -115,7 +115,7 @@ static inline int put_dreq(struct nfs_di
  */
 ssize_t nfs_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov, loff_t pos, unsigned long nr_segs)
 {
-	dprintk("NFS: nfs_direct_IO (%s) off/no(%Ld/%lu) EINVAL\n",
+	dprintk("nfs: nfs_direct_IO (%s) off/no(%Ld/%lu) EINVAL\n",
 			iocb->ki_filp->f_dentry->d_name.name,
 			(long long) pos, nr_segs);
 
@@ -311,7 +311,7 @@ static ssize_t nfs_direct_read_schedule(
 		rpc_execute(&data->task);
 		unlock_kernel();
 
-		dfprintk(VFS, "NFS: %5u initiated direct read call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		dprintk("NFS: %5u initiated direct read call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
 				data->task.tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
@@ -645,7 +645,7 @@ static ssize_t nfs_direct_write_schedule
 		rpc_execute(&data->task);
 		unlock_kernel();
 
-		dfprintk(VFS, "NFS: %5u initiated direct write call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		dprintk("NFS: %5u initiated direct write call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
 				data->task.tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
@@ -803,7 +803,7 @@ ssize_t nfs_file_direct_write(struct kio
 	const char __user *buf = iov[0].iov_base;
 	size_t count = iov[0].iov_len;
 
-	dfprintk(VFS, "nfs: direct write(%s/%s, %lu@%Ld)\n",
+	dprintk("nfs: direct write(%s/%s, %lu@%Ld)\n",
 		file->f_dentry->d_parent->d_name.name,
 		file->f_dentry->d_name.name,
 		(unsigned long) count, (long long) pos);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c2e49c3..32331a0 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -286,7 +286,7 @@ static void nfs_read_rpcsetup(struct nfs
 
 	data->task.tk_cookie = (unsigned long)inode;
 
-	dprintk("NFS: %4d initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 			data->task.tk_pid,
 			inode->i_sb->s_id,
 			(long long)NFS_FILEID(inode),
@@ -559,7 +559,7 @@ int nfs_readpage_result(struct rpc_task 
 	struct nfs_readres *resp = &data->res;
 	int status;
 
-	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
+	dprintk("NFS: %5u nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
 
 	status = NFS_PROTO(data->inode)->read_done(task, data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 883dd4a..7e3d36c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -965,7 +965,7 @@ static void nfs_write_rpcsetup(struct nf
 	data->task.tk_priority = flush_task_priority(how);
 	data->task.tk_cookie = (unsigned long)inode;
 
-	dprintk("NFS: %4d initiated write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+	dprintk("NFS: %5u initiated write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 		data->task.tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -1251,7 +1251,7 @@ int nfs_writeback_done(struct rpc_task *
 	struct nfs_writeres	*resp = &data->res;
 	int status;
 
-	dprintk("NFS: %4d nfs_writeback_done (status %d)\n",
+	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
 		task->tk_pid, task->tk_status);
 
 	/*
@@ -1367,7 +1367,7 @@ static void nfs_commit_rpcsetup(struct l
 	data->task.tk_priority = flush_task_priority(how);
 	data->task.tk_cookie = (unsigned long)inode;
 	
-	dprintk("NFS: %4d initiated commit call\n", data->task.tk_pid);
+	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 }
 
 /*
@@ -1408,7 +1408,7 @@ static void nfs_commit_done(struct rpc_t
 	struct nfs_write_data	*data = calldata;
 	struct nfs_page		*req;
 
-        dprintk("NFS: %4d nfs_commit_done (status %d)\n",
+        dprintk("NFS: %5u nfs_commit_done (status %d)\n",
                                 task->tk_pid, task->tk_status);
 
 	/* Call the NFS version-specific code */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
