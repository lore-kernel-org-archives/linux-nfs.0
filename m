From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 16 - Get rid of ex_parent from svc_export
Date: Thu, 12 Sep 2002 12:34:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023448.19569@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJop-0002CT-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:34:59 -0700
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

I was never entirely sure what it was for, but it
is not used now, only set, so it can go.



 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   27 +++------------------------
 ./include/linux/nfsd/export.h |    1 -
 2 files changed, 3 insertions(+), 25 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:32:34	1.3
+++ ./include/linux/nfsd/export.h	2002/09/11 01:33:52	1.4
@@ -64,7 +64,6 @@ struct svc_export {
 	struct list_head	ex_fsid_hash;
 	struct list_head	ex_list;
 	char			ex_path[NFS_MAXPATHLEN+1];
-	struct svc_export *	ex_parent;
 	struct svc_client *	ex_client;
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
--- ./fs/nfsd/export.c	2002/09/11 01:32:34	1.4
+++ ./fs/nfsd/export.c	2002/09/11 01:33:52	1.5
@@ -169,19 +169,6 @@ exp_child(svc_client *clp, struct super_
 	return NULL;
 }
 
-/* Update parent pointers of all exports */
-static void exp_change_parents(svc_client *clp, svc_export *old, svc_export *new)
-{
-	struct list_head *head = &clp->cl_list;
-	struct list_head *p;
-
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_list);
-		if (exp->ex_parent == old)
-			exp->ex_parent = new;
-	}
-}
-
 /*
  * Hashtable locking. Write locks are placed only by user processes
  * wanting to modify export information.
@@ -245,7 +232,7 @@ int
 exp_export(struct nfsctl_export *nxp)
 {
 	svc_client	*clp;
-	svc_export	*exp = NULL, *parent;
+	svc_export	*exp = NULL;
 	svc_export	*fsid_exp;
 	struct nameidata nd;
 	struct inode	*inode = NULL;
@@ -332,12 +319,12 @@ exp_export(struct nfsctl_export *nxp)
 		inode->i_sb->s_export_op->find_exported_dentry =
 			find_exported_dentry;
 
-	if ((parent = exp_child(clp, inode->i_sb, nd.dentry)) != NULL) {
+	if (exp_child(clp, inode->i_sb, nd.dentry) != NULL) {
 		dprintk("exp_export: export not valid (Rule 3).\n");
 		goto finish;
 	}
 	/* Is this is a sub-export, must be a proper subset of FS */
-	if ((parent = exp_parent(clp, inode->i_sb, nd.dentry)) != NULL) {
+	if (exp_parent(clp, inode->i_sb, nd.dentry) != NULL) {
 		dprintk("exp_export: sub-export not valid (Rule 2).\n");
 		goto finish;
 	}
@@ -349,7 +336,6 @@ exp_export(struct nfsctl_export *nxp)
 
 	strcpy(exp->ex_path, nxp->ex_path);
 	exp->ex_client = clp;
-	exp->ex_parent = parent;
 	exp->ex_mnt = mntget(nd.mnt);
 	exp->ex_dentry = dget(nd.dentry);
 	exp->ex_flags = nxp->ex_flags;
@@ -359,11 +345,6 @@ exp_export(struct nfsctl_export *nxp)
 	exp->ex_anon_gid = nxp->ex_anon_gid;
 	exp->ex_fsid = nxp->ex_dev;
 
-
-	/* Update parent pointers of all exports */
-	if (parent)
-		exp_change_parents(clp, parent, exp);
-
 	list_add(&exp->ex_hash, clp->cl_export + EXPORT_HASH(dev));
 	list_add_tail(&exp->ex_list, &clp->cl_list);
 
@@ -393,8 +374,6 @@ exp_do_unexport(svc_export *unexp)
 	list_del(&unexp->ex_list);
 	list_del(&unexp->ex_hash);
 	exp_fsid_unhash(unexp);
-	/* Update parent pointers. */
-	exp_change_parents(unexp->ex_client, unexp, unexp->ex_parent);
 	dentry = unexp->ex_dentry;
 	mnt = unexp->ex_mnt;
 	inode = dentry->d_inode;


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
