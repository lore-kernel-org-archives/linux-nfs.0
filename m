From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 06/38: CLIENT: change inode to dentry in ->setattr()
 nfs_rpc_op
Date: Wed, 14 Aug 2002 16:38:53 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141638330.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4uv-0003sb-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:38:57 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This patch changes the interface of the ->setattr() nfs_rpc_op
so that its first argument is a dentry instead of an inode.

[Explanation: The dentry is required because in NFSv4, we may
 need to OPEN the file before doing the SETATTR.  (This is
 required if the file size is changed as part of the setattr.)
 Opening the file requires making use of the containing
 directory's inode.]

--- old/fs/nfs/inode.c	Thu Aug  1 16:16:33 2002
+++ new/fs/nfs/inode.c	Sun Aug 11 20:27:33 2002
@@ -782,7 +782,7 @@ printk("nfs_setattr: revalidate failed,
 	if (error)
 		goto out;

-	error = NFS_PROTO(inode)->setattr(inode, &fattr, attr);
+	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
 	if (error)
 		goto out;
 	/*
--- old/fs/nfs/nfs3proc.c	Sun Aug 11 20:26:56 2002
+++ new/fs/nfs/nfs3proc.c	Sun Aug 11 20:27:33 2002
@@ -86,9 +86,10 @@ nfs3_proc_getattr(struct inode *inode, s
 }

 static int
-nfs3_proc_setattr(struct inode *inode, struct nfs_fattr *fattr,
+nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 			struct iattr *sattr)
 {
+	struct inode *inode = dentry->d_inode;
 	struct nfs3_sattrargs	arg = {
 		fh:		NFS_FH(inode),
 		sattr:		sattr,
--- old/fs/nfs/proc.c	Sun Aug 11 20:26:56 2002
+++ new/fs/nfs/proc.c	Sun Aug 11 20:27:33 2002
@@ -78,9 +78,10 @@ nfs_proc_getattr(struct inode *inode, st
 }

 static int
-nfs_proc_setattr(struct inode *inode, struct nfs_fattr *fattr,
+nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		 struct iattr *sattr)
 {
+	struct inode *inode = dentry->d_inode;
 	struct nfs_sattrargs	arg = {
 		fh:	NFS_FH(inode),
 		sattr:	sattr
--- old/include/linux/nfs_xdr.h	Sun Aug 11 20:26:56 2002
+++ new/include/linux/nfs_xdr.h	Sun Aug 11 20:27:33 2002
@@ -297,7 +297,7 @@ struct nfs_rpc_ops {
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*getattr) (struct inode *, struct nfs_fattr *);
-	int	(*setattr) (struct inode *, struct nfs_fattr *,
+	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
 	int	(*lookup)  (struct inode *, struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
