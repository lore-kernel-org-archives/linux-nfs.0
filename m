From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 10 - Change fh_compose to NOT consume a reference to the dentry.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004BD-Ik@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSP-00072w-6X
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:49 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-0002W3-DD
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:39 +1000
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


fh_compose currently consumes a reference to the dentry but 
not the export point.  This is both inconsistent and confusing. 

It is better if a routine like this doesn't consume reference points,
so with this patch, it doesn't.
This fixes a couple of very subtle and unusual reference counting errors.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c  |    3 +--
 ./fs/nfsd/nfs3xdr.c |   12 +++++++-----
 ./fs/nfsd/nfs4xdr.c |    1 +
 ./fs/nfsd/nfsfh.c   |    2 +-
 ./fs/nfsd/nfsproc.c |    1 +
 ./fs/nfsd/vfs.c     |    9 +++++++--
 6 files changed, 18 insertions(+), 10 deletions(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/export.c	2004-05-18 11:16:20.000000000 +1000
@@ -899,7 +899,7 @@ exp_rootfh(svc_client *clp, char *path, 
 	 * fh must be initialized before calling fh_compose
 	 */
 	fh_init(&fh, maxsize);
-	if (fh_compose(&fh, exp, dget(nd.dentry), NULL))
+	if (fh_compose(&fh, exp, nd.dentry, NULL))
 		err = -EINVAL;
 	else
 		err = 0;
@@ -932,7 +932,6 @@ exp_pseudoroot(struct auth_domain *clp, 
 	if (!fsid_key || IS_ERR(fsid_key))
 		return nfserr_perm;
 
-	dget(fsid_key->ek_export->ex_dentry);
 	rv = fh_compose(fhp, fsid_key->ek_export, 
 			  fsid_key->ek_export->ex_dentry, NULL);
 	expkey_put(&fsid_key->h, &svc_expkey_cache);

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2004-05-18 11:16:20.000000000 +1000
@@ -799,6 +799,7 @@ compose_entry_fh(struct nfsd3_readdirres
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent, *dchild;
+	int rv = 0;
 
 	dparent = cd->fh.fh_dentry;
 	exp  = cd->fh.fh_export;
@@ -813,11 +814,12 @@ compose_entry_fh(struct nfsd3_readdirres
 		dchild = lookup_one_len(name, dparent, namlen);
 	if (IS_ERR(dchild))
 		return 1;
-	if (d_mountpoint(dchild))
-		return 1;
-	if (fh_compose(fhp, exp, dchild, &cd->fh) != 0 || !dchild->d_inode)
-		return 1;
-	return 0;
+	if (d_mountpoint(dchild) ||
+	    fh_compose(fhp, exp, dchild, &cd->fh) != 0 ||
+	    !dchild->d_inode)
+		rv = 1;
+	dput(dchild);
+	return rv;
 }
 
 /*

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-05-18 11:16:20.000000000 +1000
@@ -1706,6 +1706,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 		nfserr = nfsd4_encode_fattr(NULL, exp,
 				dentry, p, &buflen, cd->rd_bmval,
 				cd->rd_rqstp);
+		dput(dentry);
 		if (!nfserr) {
 			p += buflen;
 			goto out;

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2004-05-18 11:16:20.000000000 +1000
@@ -367,7 +367,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 		printk(KERN_ERR "fh_compose: called with maxsize %d! %s/%s\n",
 		       fhp->fh_maxsize, parent->d_name.name, dentry->d_name.name);
 
-	fhp->fh_dentry = dentry; /* our internal copy */
+	fhp->fh_dentry = dget(dentry); /* our internal copy */
 	fhp->fh_export = exp;
 	cache_get(&exp->h);
 

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2004-05-18 11:16:20.000000000 +1000
@@ -212,6 +212,7 @@ nfsd_proc_create(struct svc_rqst *rqstp,
 	nfserr = fh_compose(newfhp, dirfhp->fh_export, dchild, dirfhp);
 	if (!nfserr && !dchild->d_inode)
 		nfserr = nfserr_noent;
+	dput(dchild);
 	if (nfserr) {
 		if (nfserr != nfserr_noent)
 			goto out_unlock;

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-05-18 11:16:20.000000000 +1000
@@ -208,6 +208,7 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 	err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && !dentry->d_inode)
 		err = nfserr_noent;
+	dput(dentry);
 out:
 	return err;
 
@@ -859,7 +860,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 		char *fname, int flen, struct iattr *iap,
 		int type, dev_t rdev, struct svc_fh *resfhp)
 {
-	struct dentry	*dentry, *dchild;
+	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
 	int		err;
 
@@ -965,6 +966,8 @@ nfsd_create(struct svc_rqst *rqstp, stru
 	if (!err)
 		err = fh_update(resfhp);
 out:
+	if (dchild && !IS_ERR(dchild))
+		dput(dchild);
 	return err;
 
 out_nfserr:
@@ -982,7 +985,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		struct svc_fh *resfhp, int createmode, u32 *verifier,
 	        int *truncp)
 {
-	struct dentry	*dentry, *dchild;
+	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
 	int		err;
 	__u32		v_mtime=0, v_atime=0;
@@ -1111,6 +1114,8 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 
  out:
 	fh_unlock(fhp);
+	if (dchild && !IS_ERR(dchild))
+		dput(dchild);
  	return err;
  
  out_nfserr:


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
