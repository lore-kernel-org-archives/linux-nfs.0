From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 13/19] A basic NFSv4 client for 2.5.x
Date: Sat, 12 Oct 2002 01:47:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15783.25386.497007.755000@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1809Vf-0002Tg-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 16:47:59 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

In NFSv3, an RPC is retried if the special error NFSERR_JUKEBOX is
received.  This generic bit of postprocessing happens invisibly for
synchronous RPC's, but in the async case, the ->tk_exit callback
must call nfs_async_handle_jukebox() by hand.

In NFSv4, we also need generic postprocessing of async RPC's, but
the details are different.  Therefore, we don't want to call
nfs_async_handle_jukebox(); we want to call a different, NFSv4-specific
routine.  Therefore, we want to move calls to nfs_async_handle_jukebox()
out of the "generic" NFS code and into NFSv3-specific routines.  This
has already been done for async READ and WRITE in the preceding patches,
but there is still one outstanding case: the async REMOVE in sillyrename.

This patch removes nfs_async_handle_jukebox() from the async sillyrename
path, and puts in the NFSv3 ->unlink_done() rpc_op.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E12/fs/nfs/nfs3proc.c linux-2.5.41-nfsv4-E13/fs/nfs/nfs3proc.c
--- linux-2.5.41-nfsv4-E12/fs/nfs/nfs3proc.c	2002-10-11 18:21:46.000000000 -0400
+++ linux-2.5.41-nfsv4-E13/fs/nfs/nfs3proc.c	2002-10-11 18:22:12.000000000 -0400
@@ -392,16 +392,20 @@
 	return 0;
 }
 
-static void
-nfs3_proc_unlink_done(struct dentry *dir, struct rpc_message *msg)
+static int
+nfs3_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
 {
+	struct rpc_message *msg = &task->tk_msg;
 	struct nfs_fattr	*dir_attr;
 
+	if (nfs_async_handle_jukebox(task))
+		return 1;
 	if (msg->rpc_argp) {
 		dir_attr = (struct nfs_fattr*)msg->rpc_resp;
 		nfs_refresh_inode(dir->d_inode, dir_attr);
 		kfree(msg->rpc_argp);
 	}
+	return 0;
 }
 
 static int
diff -u --recursive --new-file linux-2.5.41-nfsv4-E12/fs/nfs/proc.c linux-2.5.41-nfsv4-E13/fs/nfs/proc.c
--- linux-2.5.41-nfsv4-E12/fs/nfs/proc.c	2002-10-11 18:21:46.000000000 -0400
+++ linux-2.5.41-nfsv4-E13/fs/nfs/proc.c	2002-10-11 18:22:12.000000000 -0400
@@ -312,13 +312,16 @@
 	return 0;
 }
 
-static void
-nfs_proc_unlink_done(struct dentry *dir, struct rpc_message *msg)
+static int
+nfs_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
 {
+	struct rpc_message *msg = &task->tk_msg;
+	
 	if (msg->rpc_argp) {
 		NFS_CACHEINV(dir->d_inode);
 		kfree(msg->rpc_argp);
 	}
+	return 0;
 }
 
 static int
diff -u --recursive --new-file linux-2.5.41-nfsv4-E12/fs/nfs/unlink.c linux-2.5.41-nfsv4-E13/fs/nfs/unlink.c
--- linux-2.5.41-nfsv4-E12/fs/nfs/unlink.c	2002-03-12 15:03:56.000000000 -0500
+++ linux-2.5.41-nfsv4-E13/fs/nfs/unlink.c	2002-10-11 18:22:12.000000000 -0400
@@ -123,13 +123,12 @@
 	struct dentry		*dir = data->dir;
 	struct inode		*dir_i;
 
-	if (nfs_async_handle_jukebox(task))
-		return;
 	if (!dir)
 		return;
 	dir_i = dir->d_inode;
 	nfs_zap_caches(dir_i);
-	NFS_PROTO(dir_i)->unlink_done(dir, &task->tk_msg);
+	if (NFS_PROTO(dir_i)->unlink_done(dir, task))
+		return;
 	put_rpccred(data->cred);
 	data->cred = NULL;
 	dput(dir);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E12/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E13/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E12/include/linux/nfs_xdr.h	2002-10-11 18:21:46.000000000 -0400
+++ linux-2.5.41-nfsv4-E13/include/linux/nfs_xdr.h	2002-10-11 18:22:12.000000000 -0400
@@ -375,7 +375,7 @@
 	int	(*remove)  (struct inode *, struct qstr *);
 	int	(*unlink_setup)  (struct rpc_message *,
 			    struct dentry *, struct qstr *);
-	void	(*unlink_done) (struct dentry *, struct rpc_message *);
+	int	(*unlink_done) (struct dentry *, struct rpc_task *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
