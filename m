From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd -  Verify exportability when updating export cache.
Date: Mon, 31 Mar 2003 11:04:20 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18znim-0003bo-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18znjE-0001Yu-00
	for <nfs@lists.sourceforge.net>; Sun, 30 Mar 2003 17:04:48 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 31 Mar 2003 11:04:26 +1000
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

The systemcall interface for adding exports checked that
the filesystem was exportable.  The new interface doesn't...

This patch splits this functionality into a separate function
which is called from both sites.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   80 ++++++++++++++++++++++++++++++-----------------------
 1 files changed, 46 insertions(+), 34 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-03-31 09:56:00.000000000 +1000
+++ ./fs/nfsd/export.c	2003-03-31 10:24:20.000000000 +1000
@@ -271,6 +271,47 @@ void svc_export_request(struct cache_det
 }
 
 static struct svc_export *svc_export_lookup(struct svc_export *, int);
+
+extern struct dentry *
+find_exported_dentry(struct super_block *sb, void *obj, void *parent,
+		     int (*acceptable)(void *context, struct dentry *de),
+		     void *context);
+
+static int check_export(struct inode *inode, int flags)
+{
+
+	/* We currently export only dirs and regular files.
+	 * This is what umountd does.
+	 */
+	if (!S_ISDIR(inode->i_mode) &&
+	    !S_ISREG(inode->i_mode))
+		return -ENOTDIR;
+
+	/* There are two requirements on a filesystem to be exportable.
+	 * 1:  We must be able to identify the filesystem from a number.
+	 *       either a device number (so FS_REQUIRES_DEV needed)
+	 *       or an FSID number (so NFSEXP_FSID needed).
+	 * 2:  We must be able to find an inode from a filehandle.
+	 *       This means that s_export_op must be set.
+	 */
+	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
+	    !(flags & NFSEXP_FSID)) {
+		dprintk("exp_export: export of non-dev fs without fsid");
+		return -EINVAL;
+	}
+	if (!inode->i_sb->s_export_op) {
+		dprintk("exp_export: export of invalid fs type.\n");
+		return -EINVAL;
+	}
+
+	/* Ok, we can export it */;
+	if (!inode->i_sb->s_export_op->find_exported_dentry)
+		inode->i_sb->s_export_op->find_exported_dentry =
+			find_exported_dentry;
+	return 0;
+
+}
+
 int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client path expiry [flags anonuid anongid fsid] */
@@ -342,6 +383,9 @@ int svc_export_parse(struct cache_detail
 		err = get_int(&mesg, &an_int);
 		if (err) goto out;
 		exp.ex_fsid = an_int;
+
+		err = check_export(nd.dentry->d_inode, exp.ex_flags);
+		if (err) goto out;
 	}
 
 	expp = svc_export_lookup(&exp, 1);
@@ -594,10 +638,6 @@ static void exp_unhash(struct svc_export
 	svc_expkey_cache.nextcheck = get_seconds();
 }
 	
-extern struct dentry *
-find_exported_dentry(struct super_block *sb, void *obj, void *parent,
-		     int (*acceptable)(void *context, struct dentry *de),
-		     void *context);
 /*
  * Export a file system.
  */
@@ -661,36 +701,8 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	}
 
-	/* We currently export only dirs and regular files.
-	 * This is what umountd does.
-	 */
-	err = -ENOTDIR;
-	if (!S_ISDIR(inode->i_mode) && !S_ISREG(inode->i_mode))
-		goto finish;
-
-	err = -EINVAL;
-	/* There are two requirements on a filesystem to be exportable.
-	 * 1:  We must be able to identify the filesystem from a number.
-	 *       either a device number (so FS_REQUIRES_DEV needed)
-	 *       or an FSID number (so NFSEXP_FSID needed).
-	 * 2:  We must be able to find an inode from a filehandle.
-	 *       This means that s_export_op must be set.
-	 */
-	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)) {
-		if (!(nxp->ex_flags & NFSEXP_FSID)) {
-			dprintk("exp_export: export of non-dev fs without fsid");
-			goto finish;
-		}
-	}
-	if (!inode->i_sb->s_export_op) {
-		dprintk("exp_export: export of invalid fs type.\n");
-		goto finish;
-	}
-
-	/* Ok, we can export it */;
-	if (!inode->i_sb->s_export_op->find_exported_dentry)
-		inode->i_sb->s_export_op->find_exported_dentry =
-			find_exported_dentry;
+	err = check_export(inode, nxp->ex_flags);
+	if (err) goto finish;
 
 	err = -ENOMEM;
 


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
