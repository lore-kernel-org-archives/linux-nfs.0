From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 11 of 16 - Remove problematic "security" checks when NFS exporting.
Date: Thu, 12 Sep 2002 12:35:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023547.19646@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJpo-0002MU-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:00 -0700
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

The nfs server currently doesn't allow you to export both a
directory and an ancestor of that directory on the same filesystem.

This check is more of a problem than a solution and can be 
done in user-space if needed, so it is removed.

The potential for a security problem is because the files
below the lower directory could be accessed as though it were under
either of the export points, and so the access control that is 
applied might not be what is expected (by the nieve admin).

e.g.  export /a as readwrite and /a/b as readonly.  Then a/b/c
can be accessed readwrite as it is in /a which might not be the
intend.  Altering the user to this can be done in userspace though.

The current restriction also stops exporting / as readonly and
/tmp as read-write which some people want to do.  Providing 
/tmp is also exported subtree_check (the default) there is no
security issue here.


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   37 -------------------------------------
 1 files changed, 37 deletions(-)

--- ./fs/nfsd/export.c	2002/09/11 03:15:58	1.10
+++ ./fs/nfsd/export.c	2002/09/11 03:18:12	1.11
@@ -37,8 +37,6 @@ typedef struct svc_export	svc_export;
 
 static svc_export *	exp_parent(svc_client *clp, struct super_block *sb,
 					struct dentry *dentry);
-static svc_export *	exp_child(svc_client *clp, struct super_block *sb,
-					struct dentry *dentry);
 static void		exp_unexport_all(svc_client *clp);
 static void		exp_do_unexport(svc_export *unexp);
 static svc_client *	exp_getclientbyname(char *name);
@@ -147,31 +145,6 @@ exp_parent(svc_client *clp, struct super
 }
 
 /*
- * Find the child export entry for a given fs. This function is used
- * only by the export syscall to keep the export tree consistent.
- * <gam3@acm.org>
- */
-static svc_export *
-exp_child(svc_client *clp, struct super_block *sb, struct dentry *dentry)
-{
-	struct list_head *head = &clp->cl_export[EXPORT_HASH(sb->s_dev)];
-	struct list_head *p;
-	struct dentry *ndentry;
-
-	spin_lock(&dcache_lock);
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_hash);
-		ndentry = exp->ex_dentry;
-		if (ndentry && is_subdir(ndentry->d_parent, dentry)) {
-			spin_unlock(&dcache_lock);
-			return exp;
-		}
-	}
-	spin_unlock(&dcache_lock);
-	return NULL;
-}
-
-/*
  * Hashtable locking. Write locks are placed only by user processes
  * wanting to modify export information.
  * Write locking only done in this file.  Read locking
@@ -321,16 +294,6 @@ exp_export(struct nfsctl_export *nxp)
 		inode->i_sb->s_export_op->find_exported_dentry =
 			find_exported_dentry;
 
-	if (exp_child(clp, inode->i_sb, nd.dentry) != NULL) {
-		dprintk("exp_export: export not valid (Rule 3).\n");
-		goto finish;
-	}
-	/* Is this is a sub-export, must be a proper subset of FS */
-	if (exp_parent(clp, inode->i_sb, nd.dentry) != NULL) {
-		dprintk("exp_export: sub-export not valid (Rule 2).\n");
-		goto finish;
-	}
-
 	err = -ENOMEM;
 	if (!(exp = kmalloc(sizeof(*exp), GFP_USER)))
 		goto finish;


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
