From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 4 - nfsd/export.c tidyup and add missing exp_put
Date: Sun, 13 Apr 2003 16:18:05 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E194aoX-0007lt-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 194apd-0006gY-00
	for <nfs@lists.sourceforge.net>; Sat, 12 Apr 2003 23:19:14 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Sun, 13 Apr 2003 16:19:06 +1000
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

There was a missing exp_put in export.c so that after a client
mounts an exported filesystem, the server would never be able to
unmount, even after trying to unexport.  This is fixed by the last
chunk of this patch.

Also assorted cleanups to the code found while hunting.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-04-13 16:14:46.000000000 +1000
+++ ./fs/nfsd/export.c	2003-04-13 16:14:46.000000000 +1000
@@ -175,7 +175,7 @@ int expkey_parse(struct cache_detail *cd
 		ek = svc_expkey_lookup(&key, 2);
 		if (ek)
 			expkey_put(&ek->h, &svc_expkey_cache);
-		svc_export_put(&exp->h, &svc_export_cache);
+		exp_put(exp);
 		err = 0;
 	out_nd:
 		path_release(&nd);
@@ -648,7 +648,6 @@ exp_export(struct nfsctl_export *nxp)
 	struct svc_export	new;
 	struct svc_expkey	*fsid_key = NULL;
 	struct nameidata nd;
-	struct inode	*inode = NULL;
 	int		err;
 
 	/* Consistency check */
@@ -674,7 +673,6 @@ exp_export(struct nfsctl_export *nxp)
 	err = path_lookup(nxp->ex_path, 0, &nd);
 	if (err)
 		goto out_unlock;
-	inode = nd.dentry->d_inode;
 	err = -EINVAL;
 
 	exp = exp_get_by_name(clp, nd.mnt, nd.dentry, NULL);
@@ -687,7 +685,7 @@ exp_export(struct nfsctl_export *nxp)
 	    fsid_key->ek_export != exp)
 		goto finish;
 
-	if (exp != NULL) {
+	if (exp) {
 		/* just a flags/id/fsid update */
 
 		exp_fsid_unhash(exp);
@@ -700,7 +698,7 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	}
 
-	err = check_export(inode, nxp->ex_flags);
+	err = check_export(nd.dentry->d_inode, nxp->ex_flags);
 	if (err) goto finish;
 
 	err = -ENOMEM;
@@ -838,7 +836,7 @@ exp_rootfh(svc_client *clp, char *path, 
 		err = 0;
 	memcpy(f, &fh.fh_handle, sizeof(struct knfsd_fh));
 	fh_put(&fh);
-
+	exp_put(exp);
 out:
 	path_release(&nd);
 	return err;


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
