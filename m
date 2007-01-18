From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/14] NFS: fix print format for tk_pid
Date: Thu, 18 Jan 2007 18:29:27 -0500
Message-ID: <20070118232925.23310.31437.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7ghW-0002iT-AQ
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:29:49 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7ghX-0003BT-Qk
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:29:48 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
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

 fs/nfs/direct.c |    6 +++---
 fs/nfs/read.c   |    4 ++--
 fs/nfs/write.c  |    8 ++++----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index bd21d7f..7c02dc7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -309,7 +309,7 @@ static ssize_t nfs_direct_read_schedule(
 
 		rpc_execute(&data->task);
 
-		dfprintk(VFS, "NFS: %5u initiated direct read call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		dprintk("NFS: %5u initiated direct read call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
 				data->task.tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
@@ -639,7 +639,7 @@ static ssize_t nfs_direct_write_schedule
 
 		rpc_execute(&data->task);
 
-		dfprintk(VFS, "NFS: %5u initiated direct write call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
+		dprintk("NFS: %5u initiated direct write call (req %s/%Ld, %zu bytes @ offset %Lu)\n",
 				data->task.tk_pid,
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode),
@@ -797,7 +797,7 @@ ssize_t nfs_file_direct_write(struct kio
 	const char __user *buf = iov[0].iov_base;
 	size_t count = iov[0].iov_len;
 
-	dfprintk(VFS, "nfs: direct write(%s/%s, %lu@%Ld)\n",
+	dprintk("nfs: direct write(%s/%s, %lu@%Ld)\n",
 		file->f_path.dentry->d_parent->d_name.name,
 		file->f_path.dentry->d_name.name,
 		(unsigned long) count, (long long) pos);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index a9c2652..47f5e56 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -278,7 +278,7 @@ static void nfs_read_rpcsetup(struct nfs
 
 	data->task.tk_cookie = (unsigned long)inode;
 
-	dprintk("NFS: %4d initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+	dprintk("NFS: %5u initiated read call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 			data->task.tk_pid,
 			inode->i_sb->s_id,
 			(long long)NFS_FILEID(inode),
@@ -452,7 +452,7 @@ int nfs_readpage_result(struct rpc_task 
 {
 	int status;
 
-	dprintk("%s: %4d, (status %d)\n", __FUNCTION__, task->tk_pid,
+	dprintk("NFS: %s: %5u, (status %d)\n", __FUNCTION__, task->tk_pid,
 			task->tk_status);
 
 	status = NFS_PROTO(data->inode)->read_done(task, data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 345492e..0ab8435 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -852,7 +852,7 @@ static void nfs_write_rpcsetup(struct nf
 	data->task.tk_priority = flush_task_priority(how);
 	data->task.tk_cookie = (unsigned long)inode;
 
-	dprintk("NFS: %4d initiated write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
+	dprintk("NFS: %5u initiated write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 		data->task.tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
@@ -1134,7 +1134,7 @@ int nfs_writeback_done(struct rpc_task *
 	struct nfs_writeres	*resp = &data->res;
 	int status;
 
-	dprintk("NFS: %4d nfs_writeback_done (status %d)\n",
+	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
 		task->tk_pid, task->tk_status);
 
 	/*
@@ -1250,7 +1250,7 @@ static void nfs_commit_rpcsetup(struct l
 	data->task.tk_priority = flush_task_priority(how);
 	data->task.tk_cookie = (unsigned long)inode;
 	
-	dprintk("NFS: %4d initiated commit call\n", data->task.tk_pid);
+	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 }
 
 /*
@@ -1291,7 +1291,7 @@ static void nfs_commit_done(struct rpc_t
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
