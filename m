From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 05/38: CLIENT: change inode to dentry in ->readdir()
 nfs_rpc_op
Date: Wed, 14 Aug 2002 16:38:29 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141638060.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4uV-0003qj-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:38:31 -0700
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


This patch changes the interface of the ->readdir() nfs_rpc_op
so that its first argument is a dentry instead of an inode.

[Explanation: The dentry is required because in NFSv4, we need
 to make use of the _parent_ directory's inode.  This is because
 NFSv4 servers no longer return an entry for ".." in the READDIR
 response, so the client kernel needs to fake this entry, inode
 number and all.]

--- old/fs/nfs/dir.c	Thu Aug  1 16:16:25 2002
+++ new/fs/nfs/dir.c	Sun Aug 11 20:26:49 2002
@@ -107,7 +107,7 @@ int nfs_readdir_filler(nfs_readdir_descr
 	dfprintk(VFS, "NFS: nfs_readdir_filler() reading cookie %Lu into page %lu.\n", (long long)desc->entry->cookie, page->index);

  again:
-	error = NFS_PROTO(inode)->readdir(inode, cred, desc->entry->cookie, page,
+	error = NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->entry->cookie, page,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -341,7 +341,7 @@ int uncached_readdir(nfs_readdir_descrip
 		status = -ENOMEM;
 		goto out;
 	}
-	desc->error = NFS_PROTO(inode)->readdir(inode, cred, desc->target,
+	desc->error = NFS_PROTO(inode)->readdir(file->f_dentry, cred, desc->target,
 						page,
 						NFS_SERVER(inode)->dtsize,
 						desc->plus);
--- old/fs/nfs/nfs3proc.c	Thu Aug  1 16:16:25 2002
+++ new/fs/nfs/nfs3proc.c	Sun Aug 11 20:26:49 2002
@@ -543,9 +543,10 @@ nfs3_proc_rmdir(struct inode *dir, struc
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
--- old/fs/nfs/proc.c	Thu Aug  1 16:16:20 2002
+++ new/fs/nfs/proc.c	Sun Aug 11 20:26:49 2002
@@ -425,9 +425,10 @@ nfs_proc_rmdir(struct inode *dir, struct
  * from nfs_readdir by calling the decode_entry function directly.
  */
 static int
-nfs_proc_readdir(struct inode *dir, struct rpc_cred *cred,
+nfs_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		 u64 cookie, struct page *page, unsigned int count, int plus)
 {
+	struct inode		*dir = dentry->d_inode;
 	struct nfs_readdirargs	arg = {
 		fh:		NFS_FH(dir),
 		cookie:		cookie,
--- old/include/linux/nfs_xdr.h	Thu Aug  1 16:16:16 2002
+++ new/include/linux/nfs_xdr.h	Sun Aug 11 20:26:49 2002
@@ -328,7 +328,7 @@ struct nfs_rpc_ops {
 	int	(*mkdir)   (struct inode *, struct qstr *, struct iattr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 	int	(*rmdir)   (struct inode *, struct qstr *);
-	int	(*readdir) (struct inode *, struct rpc_cred *,
+	int	(*readdir) (struct dentry *, struct rpc_cred *,
 			    u64, struct page *, unsigned int, int);
 	int	(*mknod)   (struct inode *, struct qstr *, struct iattr *,
 			    dev_t, struct nfs_fh *, struct nfs_fattr *);



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
