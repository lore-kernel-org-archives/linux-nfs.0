From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 12 of 16 - Change exp_parent to talk directory tree, not hash table.
Date: Thu, 12 Sep 2002 12:35:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023559.19659@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJqF-0002Wc-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:36:27 -0700
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

Currently get_parent (needed to find the exportpoint
above a given dentry) walks the hash table of export points
checking each with is_subdir.  Now it walks up the d_parent
link checking each for membership in the hashtable.

nfsd_lookup currently does that walk too (when crossing
a mountpoint backwards) so the code gets unified.

This approach makes more sense as we move towards a cache
for export information that can be filled on demand.
It also assumes less about the hash table (which will change).


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   29 ++++++++++++-----------------
 ./fs/nfsd/vfs.c               |   16 ++++++++--------
 ./include/linux/nfsd/export.h |    2 ++
 3 files changed, 22 insertions(+), 25 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 03:15:58	1.8
+++ ./include/linux/nfsd/export.h	2002/09/11 03:56:39	1.9
@@ -91,6 +91,8 @@ struct svc_export *	exp_get_fsid(struct 
 struct svc_export *	exp_get_by_name(struct svc_client *clp,
 					struct vfsmount *mnt,
 					struct dentry *dentry);
+struct svc_export *	exp_parent(struct svc_client *clp, struct vfsmount *mnt,
+				   struct dentry *dentry);
 int			exp_rootfh(struct svc_client *, 
 					char *path, struct knfsd_fh *, int maxsize);
 int			nfserrno(int errno);
--- ./fs/nfsd/export.c	2002/09/11 03:18:12	1.11
+++ ./fs/nfsd/export.c	2002/09/11 03:56:39	1.12
@@ -35,8 +35,6 @@
 typedef struct svc_client	svc_client;
 typedef struct svc_export	svc_export;
 
-static svc_export *	exp_parent(svc_client *clp, struct super_block *sb,
-					struct dentry *dentry);
 static void		exp_unexport_all(svc_client *clp);
 static void		exp_do_unexport(svc_export *unexp);
 static svc_client *	exp_getclientbyname(char *name);
@@ -124,24 +122,21 @@ exp_get_by_name(svc_client *clp, struct 
 }
 
 /*
- * Find the export entry for a given dentry.  <gam3@acm.org>
+ * Find the export entry for a given dentry.
  */
-static svc_export *
-exp_parent(svc_client *clp, struct super_block *sb, struct dentry *dentry)
+struct svc_export *
+exp_parent(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
 {
-	struct list_head *head = &clp->cl_export[EXPORT_HASH(sb->s_dev)];
-	struct list_head *p;
+	svc_export *exp;
 
-	spin_lock(&dcache_lock);
-	list_for_each(p, head) {
-		svc_export *exp = list_entry(p, svc_export, ex_hash);
-		if (is_subdir(dentry, exp->ex_dentry)) {
-			spin_unlock(&dcache_lock);
-			return exp;
-		}
+	read_lock(&dparent_lock);
+	exp = exp_get_by_name(clp, mnt, dentry);
+	while (exp == NULL && dentry != dentry->d_parent) {
+		dentry = dentry->d_parent;
+		exp = exp_get_by_name(clp, mnt, dentry);
 	}
-	spin_unlock(&dcache_lock);
-	return NULL;
+	read_unlock(&dparent_lock);
+	return exp;
 }
 
 /*
@@ -415,7 +410,7 @@ exp_rootfh(struct svc_client *clp, char 
 	dprintk("nfsd: exp_rootfh(%s [%p] %s:%s/%ld)\n",
 		 path, nd.dentry, clp->cl_ident,
 		 inode->i_sb->s_id, inode->i_ino);
-	exp = exp_parent(clp, inode->i_sb, nd.dentry);
+	exp = exp_parent(clp, nd.mnt, nd.dentry);
 	if (!exp) {
 		dprintk("nfsd: exp_rootfh export not found.\n");
 		goto out;
--- ./fs/nfsd/vfs.c	2002/09/11 03:25:29	1.1
+++ ./fs/nfsd/vfs.c	2002/09/11 03:56:39	1.2
@@ -119,24 +119,24 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
 			struct svc_export *exp2 = NULL;
-			struct dentry *dp, *old;
+			struct dentry *dp;
 			struct vfsmount *mnt = mntget(exp->ex_mnt);
 			dentry = dget(dparent);
 			while(follow_up(&mnt, &dentry))
 				;
-			old = dentry;
 			read_lock(&dparent_lock);
-			dp = dentry->d_parent;
-			for ( ; !exp2 && dp->d_parent != dp; dp=dp->d_parent)
-				exp2 = exp_get_by_name(exp->ex_client, mnt, dp);
+			dp = dget(dentry->d_parent);
+			read_unlock(&dparent_lock);
+			dput(dentry);
+			dentry = dp;
+
+			exp2 = exp_parent(exp->ex_client, mnt, dentry);
 			if (!exp2) {
+				dput(dentry);
 				dentry = dget(dparent);
 			} else {
-				dget(dentry->d_parent);
 				exp = exp2;
 			}
-			read_unlock(&dparent_lock);
-			dput(old);
 			mntput(mnt);
 		}
 	} else {


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
