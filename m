From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 4/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:09:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.26017.962433.506534@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3Tt-0004G2-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:09:37 -0700
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

This patch changes the interface of the ->setattr() nfs_rpc_op
so that its first argument is a dentry instead of an inode.

[Explanation: The dentry is required because in NFSv4, we may
 need to OPEN the file before doing the SETATTR.  (This is
 required if the file size is changed as part of the setattr.)
 Opening the file requires making use of the containing
 directory's inode.]

diff -u --recursive --new-file linux-2.5.41-nfsv4-E03/fs/nfs/inode.c linux-2.5.41-nfsv4-E04/fs/nfs/inode.c
--- linux-2.5.41-nfsv4-E03/fs/nfs/inode.c	2002-10-01 19:43:15.000000000 -0400
+++ linux-2.5.41-nfsv4-E04/fs/nfs/inode.c	2002-10-08 18:43:57.000000000 -0400
@@ -781,7 +781,7 @@
 	if (error)
 		goto out;
 
-	error = NFS_PROTO(inode)->setattr(inode, &fattr, attr);
+	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
 	if (error)
 		goto out;
 	/*
diff -u --recursive --new-file linux-2.5.41-nfsv4-E03/fs/nfs/nfs3proc.c linux-2.5.41-nfsv4-E04/fs/nfs/nfs3proc.c
--- linux-2.5.41-nfsv4-E03/fs/nfs/nfs3proc.c	2002-10-08 18:43:34.000000000 -0400
+++ linux-2.5.41-nfsv4-E04/fs/nfs/nfs3proc.c	2002-10-08 18:43:57.000000000 -0400
@@ -86,9 +86,10 @@
 }
 
 static int
-nfs3_proc_setattr(struct inode *inode, struct nfs_fattr *fattr,
+nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 			struct iattr *sattr)
 {
+	struct inode *inode = dentry->d_inode;
 	struct nfs3_sattrargs	arg = {
 		.fh		= NFS_FH(inode),
 		.sattr		= sattr,
diff -u --recursive --new-file linux-2.5.41-nfsv4-E03/fs/nfs/proc.c linux-2.5.41-nfsv4-E04/fs/nfs/proc.c
--- linux-2.5.41-nfsv4-E03/fs/nfs/proc.c	2002-10-08 18:43:34.000000000 -0400
+++ linux-2.5.41-nfsv4-E04/fs/nfs/proc.c	2002-10-08 18:43:57.000000000 -0400
@@ -78,9 +78,10 @@
 }
 
 static int
-nfs_proc_setattr(struct inode *inode, struct nfs_fattr *fattr,
+nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		 struct iattr *sattr)
 {
+	struct inode *inode = dentry->d_inode;
 	struct nfs_sattrargs	arg = { 
 		.fh	= NFS_FH(inode),
 		.sattr	= sattr
diff -u --recursive --new-file linux-2.5.41-nfsv4-E03/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E04/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E03/include/linux/nfs_xdr.h	2002-10-08 18:43:34.000000000 -0400
+++ linux-2.5.41-nfsv4-E04/include/linux/nfs_xdr.h	2002-10-08 18:43:58.000000000 -0400
@@ -307,7 +307,7 @@
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*getattr) (struct inode *, struct nfs_fattr *);
-	int	(*setattr) (struct inode *, struct nfs_fattr *,
+	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
 	int	(*lookup)  (struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
