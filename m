From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 17 - Open code exp_get and exp_get_fsid in the one place they are called.
Date: Fri, 11 Oct 2002 15:27:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKi-0003bI-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLG-0003g4-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:07 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:27:51 +1000
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


### Comments for ChangeSet


 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   48 +++++++++++++-----------------------------------
 1 files changed, 13 insertions(+), 35 deletions(-)

--- ./fs/nfsd/export.c	2002/10/11 01:00:40	1.4
+++ ./fs/nfsd/export.c	2002/10/11 01:17:57	1.5
@@ -112,18 +112,6 @@ exp_get_key(svc_client *clp, dev_t dev, 
 	return exp_find_key(clp, 0, fsidv);
 }
 
-static inline svc_export *
-exp_get(svc_client *clp, dev_t dev, ino_t ino)
-{
-	struct svc_expkey *ek;
-
-	ek = exp_get_key(clp, dev, ino);
-	if (ek)
-		return ek->ek_export;
-	else
-		return NULL;
-}
-
 /*
  * Find the client's export entry matching fsid
  */
@@ -137,18 +125,6 @@ exp_get_fsid_key(svc_client *clp, int fs
 	return exp_find_key(clp, 1, fsidv);
 }
 
-static inline svc_export *
-exp_get_fsid(svc_client *clp, int fsid)
-{
-	struct svc_expkey *ek;
-
-	ek = exp_get_fsid_key(clp, fsid);
-	if (ek)
-		return ek->ek_export;
-	else
-		return NULL;
-}
-
 svc_export *
 exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
 {
@@ -301,7 +277,7 @@ exp_export(struct nfsctl_export *nxp)
 {
 	svc_client	*clp;
 	svc_export	*exp = NULL;
-	svc_export	*fsid_exp;
+	struct svc_expkey	*fsid_key;
 	struct nameidata nd;
 	struct inode	*inode = NULL;
 	int		err;
@@ -335,8 +311,9 @@ exp_export(struct nfsctl_export *nxp)
 
 	/* must make sure there wont be an ex_fsid clash */
 	if ((nxp->ex_flags & NFSEXP_FSID) &&
-	    (fsid_exp = exp_get_fsid(clp, nxp->ex_dev)) &&
-	    fsid_exp != exp)
+	    (fsid_key = exp_get_fsid_key(clp, nxp->ex_dev)) &&
+	    fsid_key->ek_export &&
+	    fsid_key->ek_export != exp)
 		goto finish;
 
 	if (exp != NULL) {
@@ -477,9 +454,9 @@ exp_unexport(struct nfsctl_export *nxp)
 	dom = auth_domain_find(nxp->ex_client);
 
 	if (dom) {
-		svc_export *exp = exp_get(dom, nxp->ex_dev, nxp->ex_ino);
-		if (exp) {
-			exp_do_unexport(exp);
+		struct svc_expkey *key = exp_get_key(dom, nxp->ex_dev, nxp->ex_ino);
+		if (key && key->ek_export) {
+			exp_do_unexport(key->ek_export);
 			err = 0;
 		} else
 			dprintk("nfsd: no export %x/%lx for %s\n",
@@ -547,14 +524,15 @@ out:
 int
 exp_pseudoroot(struct auth_domain *clp, struct svc_fh *fhp)
 {
-	struct svc_export *exp;
+	struct svc_expkey *fsid_key;
 
-	exp = exp_get_fsid(clp, 0);
-	if (!exp)
+	fsid_key = exp_get_fsid_key(clp, 0);
+	if (!fsid_key || IS_ERR(fsid_key))
 		return nfserr_perm;
 
-	dget(exp->ex_dentry);
-	return fh_compose(fhp, exp, exp->ex_dentry, NULL);
+	dget(fsid_key->ek_export->ex_dentry);
+	return fh_compose(fhp, fsid_key->ek_export, 
+			  fsid_key->ek_export->ex_dentry, NULL);
 }
 
 /* Iterator */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
