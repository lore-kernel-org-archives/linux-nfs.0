From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 3/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:08:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.25992.863708.912932@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3TU-0004DW-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:09:12 -0700
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

This patch changes the interface of the ->readdir() nfs_rpc_op
so that its first argument is a dentry instead of an inode.

[Explanation: The dentry is required because in NFSv4, we need
 to make use of the _parent_ directory's inode.  This is because
 NFSv4 servers no longer return an entry for ".." in the READDIR
 response, so the client kernel needs to fake this entry, inode
 number and all.]

diff -u --recursive --new-file linux-2.5.41-nfsv4-E02/fs/nfs/dir.c linux-2.5.41-nfsv4-E03/fs/nfs/dir.c
--- linux-2.5.41-nfsv4-E02/fs/nfs/dir.c	2002-10-01 19:43:15.000000000 -0400
+++ linux-2.5.41-nfsv4-E03/fs/nfs/dir.c	2002-10-08 18:43:34.000000000 -0400
@@ -107,7 +107,7 @@
 	dfprintk(VFS, "NFS: nfs_readdir_filler() reading cookie %Lu into page %lu.\n", (long long)desc->entry->cookie, page->index);
 
  again:
-	error = NFS_PROTO(inode)->readdir(inode, cred, desc->entry->cookie, page,
+	error = NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->entry->cookie, page,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -341,7 +341,7 @@
 		status = -ENOMEM;
 		goto out;
 	}
-	desc->error = NFS_PROTO(inode)->readdir(inode, cred, desc->target,
+	desc->error = NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->target,
 						page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E02/fs/nfs/nfs3proc.c linux-2.5.41-nfsv4-E03/fs/nfs/nfs3proc.c
--- linux-2.5.41-nfsv4-E02/fs/nfs/nfs3proc.c	2002-09-10 05:10:40.000000000 -0400
+++ linux-2.5.41-nfsv4-E03/fs/nfs/nfs3proc.c	2002-10-08 18:43:34.000000000 -0400
@@ -543,9 +543,10 @@
  * readdirplus.
  */
 static int
-nfs3_proc_readdir(struct inode *dir, struct rpc_cred *cred,
+nfs3_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		  u64 cookie, struct page *page, unsigned int count, int plus)
 {
+	struct inode		*dir = dentry->d_inode;
 	struct nfs_fattr	dir_attr;
 	u32			*verf = NFS_COOKIEVERF(dir);
 	struct nfs3_readdirargs	arg = {
diff -u --recursive --new-file linux-2.5.41-nfsv4-E02/fs/nfs/proc.c linux-2.5.41-nfsv4-E03/fs/nfs/proc.c
--- linux-2.5.41-nfsv4-E02/fs/nfs/proc.c	2002-09-10 05:10:40.000000000 -0400
+++ linux-2.5.41-nfsv4-E03/fs/nfs/proc.c	2002-10-08 18:43:34.000000000 -0400
@@ -425,9 +425,10 @@
  * from nfs_readdir by calling the decode_entry function directly.
  */
 static int
-nfs_proc_readdir(struct inode *dir, struct rpc_cred *cred,
+nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		 u64 cookie, struct page *page, unsigned int count, int plus)
 {
+	struct inode		*dir = dentry->d_inode;
 	struct nfs_readdirargs	arg = {
 		.fh		= NFS_FH(dir),
 		.cookie		= cookie,
diff -u --recursive --new-file linux-2.5.41-nfsv4-E02/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E03/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E02/include/linux/nfs_xdr.h	2002-10-04 11:30:34.000000000 -0400
+++ linux-2.5.41-nfsv4-E03/include/linux/nfs_xdr.h	2002-10-08 18:43:34.000000000 -0400
@@ -338,7 +338,7 @@
 	int	(*mkdir)   (struct inode *, struct qstr *, struct iattr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*rmdir)   (struct inode *, struct qstr *);
-	int	(*readdir) (struct inode *, struct rpc_cred *,
+	int	(*readdir) (struct dentry *, struct rpc_cred *,
 			    u64, struct page *, unsigned int, int);
 	int	(*mknod)   (struct inode *, struct qstr *, struct iattr *,
 			    dev_t, struct nfs_fh *, struct nfs_fattr *);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
