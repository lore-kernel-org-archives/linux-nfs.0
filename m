From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 16 - Discard ex_dev and ex_ino from svc_export
Date: Thu, 12 Sep 2002 12:35:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023537.19634@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJpk-0002MJ-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:35:57 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

They can be deduced from ex_dentry


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   16 +++++++---------
 ./fs/nfsd/nfsfh.c             |   12 +++++++-----
 ./include/linux/nfsd/export.h |    2 --
 3 files changed, 14 insertions(+), 16 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:37:30	1.7
+++ ./include/linux/nfsd/export.h	2002/09/11 03:15:58	1.8
@@ -64,8 +64,6 @@ struct svc_export {
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
 	struct dentry *		ex_dentry;
-	dev_t			ex_dev;
-	ino_t			ex_ino;
 	uid_t			ex_anon_uid;
 	gid_t			ex_anon_gid;
 	int			ex_fsid;
--- ./fs/nfsd/export.c	2002/09/11 01:37:30	1.9
+++ ./fs/nfsd/export.c	2002/09/11 03:15:58	1.10
@@ -70,15 +70,17 @@ static svc_client *		clients;
 svc_export *
 exp_get(svc_client *clp, dev_t dev, ino_t ino)
 {
-	struct list_head *head, *p;
-	
+	struct list_head *head;
+	svc_export *exp;
+
 	if (!clp)
 		return NULL;
 
 	head = &clp->cl_export[EXPORT_HASH(dev)];
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_hash);
-		if (exp->ex_ino == ino && exp->ex_dev ==  dev)
+	list_for_each_entry(exp, head, ex_hash) {
+		struct inode *inode = exp->ex_dentry->d_inode;
+		if (inode->i_ino == ino && 
+		    inode->i_sb->s_dev ==  dev)
 			return exp;
 	}
 	return NULL;
@@ -338,8 +340,6 @@ exp_export(struct nfsctl_export *nxp)
 	exp->ex_mnt = mntget(nd.mnt);
 	exp->ex_dentry = dget(nd.dentry);
 	exp->ex_flags = nxp->ex_flags;
-	exp->ex_dev = dev;
-	exp->ex_ino = ino;
 	exp->ex_anon_uid = nxp->ex_anon_uid;
 	exp->ex_anon_gid = nxp->ex_anon_gid;
 	exp->ex_fsid = nxp->ex_dev;
@@ -376,8 +376,6 @@ exp_do_unexport(svc_export *unexp)
 	dentry = unexp->ex_dentry;
 	mnt = unexp->ex_mnt;
 	inode = dentry->d_inode;
-	if (unexp->ex_dev != inode->i_sb->s_dev || unexp->ex_ino != inode->i_ino)
-		printk(KERN_WARNING "nfsd: bad dentry in unexport!\n");
 	dput(dentry);
 	mntput(mnt);
 
--- ./fs/nfsd/nfsfh.c	2002/09/11 01:38:42	1.1
+++ ./fs/nfsd/nfsfh.c	2002/09/11 03:15:58	1.2
@@ -322,9 +322,11 @@ fh_compose(struct svc_fh *fhp, struct sv
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
+	dev_t ex_dev = exp->ex_dentry->d_inode->i_sb->s_dev;
 
 	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
-		MAJOR(exp->ex_dev), MINOR(exp->ex_dev), (long) exp->ex_ino,
+		MAJOR(ex_dev), MINOR(ex_dev),
+		(long) exp->ex_dentry->d_inode->i_ino,
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
@@ -351,9 +353,9 @@ fh_compose(struct svc_fh *fhp, struct sv
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
 		fhp->fh_handle.ofh_dcookie = 0xfeebbaca;
-		fhp->fh_handle.ofh_dev =  htonl((MAJOR(exp->ex_dev)<<16)| MINOR(exp->ex_dev));
+		fhp->fh_handle.ofh_dev =  htonl((MAJOR(ex_dev)<<16)| MINOR(ex_dev));
 		fhp->fh_handle.ofh_xdev = fhp->fh_handle.ofh_dev;
-		fhp->fh_handle.ofh_xino = ino_t_to_u32(exp->ex_ino);
+		fhp->fh_handle.ofh_xino = ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
 		fhp->fh_handle.ofh_dirino = ino_t_to_u32(parent_ino(dentry));
 		if (inode)
 			_fh_update_old(dentry, exp, &fhp->fh_handle);
@@ -370,8 +372,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 		} else {
 			fhp->fh_handle.fh_fsid_type = 0;
 			/* fsid_type 0 == 2byte major, 2byte minor, 4byte inode */
-			*datap++ = htonl((MAJOR(exp->ex_dev)<<16)| MINOR(exp->ex_dev));
-			*datap++ = ino_t_to_u32(exp->ex_ino);
+			*datap++ = htonl((MAJOR(ex_dev)<<16)| MINOR(ex_dev));
+			*datap++ = ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
 			fhp->fh_handle.fh_size = 3*4;
 		}
 		if (inode) {


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
