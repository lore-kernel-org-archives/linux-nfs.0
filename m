From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 8 - Allow nfsv4 readdir to return filehandle when a mountpoint is found is a directory
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00083Z-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBg-0002aa-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:28 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:07 +1000
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

From: "William A.(Andy) Adamson" <andros@citi.umich.edu>

When readdir is enumerating a directory and finds a mountpoint,
it needs to do a bit of extra work to find the filehandle to be 
returned in the readdir reply. 
It is even possible that finding the filehandle requires an up-call,
so the request might be dropped to be re-tried later.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c         |   26 +++++++++++++----
 ./fs/nfsd/vfs.c             |   66 +++++++++++++++++++++++++++-----------------
 ./include/linux/nfsd/nfsd.h |    2 +
 3 files changed, 63 insertions(+), 31 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2003-06-18 09:24:29.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2003-06-18 09:24:29.000000000 +1000
@@ -1425,6 +1425,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	u32 *p = cd->buffer;
 	u32 *attrlenp;
 	struct dentry *dentry;
+	struct svc_export *exp = cd->rd_fhp->fh_export;
 	u32 bmval0, bmval1;
 	int nfserr = 0;
 
@@ -1454,9 +1455,7 @@ nfsd4_encode_dirent(struct readdir_cd *c
 	if ((bmval0 & ~(FATTR4_WORD0_RDATTR_ERROR | FATTR4_WORD0_FILEID)) || bmval1)  {
 		/*
 		 * "Heavyweight" case: we have no choice except to
-		 * call nfsd4_encode_fattr().  As far as I know,
-		 * only Windows clients will trigger this code
-		 * path.
+		 * call nfsd4_encode_fattr(). 
 		 */
 		dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
 		if (IS_ERR(dentry)) {
@@ -1464,10 +1463,25 @@ nfsd4_encode_dirent(struct readdir_cd *c
 			goto error;
 		}
 
-		nfserr = nfsd4_encode_fattr(NULL, cd->rd_fhp->fh_export,
-					    dentry, p, &buflen, cd->rd_bmval);
-		dput(dentry);
+		if (d_mountpoint(dentry)) {
+			if ((nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, 
+					 &exp))) {	
+			/* 
+			 * -EAGAIN is the only error returned from 
+			 * nfsd_cross_mnt() and it indicates that an 
+			 * up-call has  been initiated to fill in the export 
+			 * options on exp.  When the answer comes back,
+			 * this call will be retried.
+			 */
+				dput(dentry);
+				nfserr = nfserr_dropit;
+				goto error;
+			}
 
+		}
+
+		nfserr = nfsd4_encode_fattr(NULL, exp,
+				dentry, p, &buflen, cd->rd_bmval);
 		if (!nfserr) {
 			p += buflen;
 			goto out;

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-06-18 09:21:45.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-06-18 09:24:29.000000000 +1000
@@ -74,6 +74,46 @@ struct raparms {
 static struct raparms *		raparml;
 static struct raparms *		raparm_cache;
 
+/* 
+ * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
+ * a mount point.
+ * Returns -EAGAIN leaving *dpp and *expp unchanged, 
+ *  or nfs_ok having possibly changed *dpp and *expp
+ */
+int
+nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp, 
+		        struct svc_export **expp)
+{
+	struct svc_export *exp = *expp, *exp2 = NULL;
+	struct dentry *dentry = *dpp;
+	struct vfsmount *mnt = mntget(exp->ex_mnt);
+	struct dentry *mounts = dget(dentry);
+	int err = nfs_ok;
+
+	while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts));
+
+	exp2 = exp_get_by_name(exp->ex_client, mnt, mounts, &rqstp->rq_chandle);
+	if (IS_ERR(exp2)) {
+		err = PTR_ERR(exp2);
+		dput(mounts);
+		mntput(mnt);
+		goto out;
+	}
+	if (exp2 && ((exp->ex_flags & NFSEXP_CROSSMNT) || EX_NOHIDE(exp2))) {
+		/* successfully crossed mount point */
+		exp_put(exp);
+		*expp = exp2;
+		dput(dentry);
+		*dpp = mounts;
+	} else {
+		if (exp2) exp_put(exp2);
+		dput(mounts);
+	}
+	mntput(mnt);
+out:
+	return err;
+}
+
 /*
  * Look up one component of a pathname.
  * N.B. After this call _both_ fhp and resfh need an fh_put
@@ -154,34 +194,10 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 		 * check if we have crossed a mount point ...
 		 */
 		if (d_mountpoint(dentry)) {
-			struct svc_export *exp2 = NULL;
-			struct vfsmount *mnt = mntget(exp->ex_mnt);
-			struct dentry *mounts = dget(dentry);
-			while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts))
-				;
-
-			exp2 = exp_get_by_name(exp->ex_client, mnt, 
-					       mounts, &rqstp->rq_chandle);
-			if (IS_ERR(exp2)) {
-				err = PTR_ERR(exp2);
-				dput(mounts);
+			if ((err = nfsd_cross_mnt(rqstp, &dentry, &exp))) {
 				dput(dentry);
-				mntput(mnt);
 				goto out_nfserr;
 			}
-			if (exp2 &&
-			    ((exp->ex_flags & NFSEXP_CROSSMNT)
-			     || EX_NOHIDE(exp2))) {
-				/* successfully crossed mount point */
-				exp_put(exp);
-				exp = exp2;
-				dput(dentry);
-				dentry = mounts;
-			} else {
-				if (exp2) exp_put(exp2);
-				dput(mounts);
-			}
-			mntput(mnt);
 		}
 	}
 	/*

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-06-18 09:24:29.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-06-18 09:24:29.000000000 +1000
@@ -69,6 +69,8 @@ int		nfsd_dispatch(struct svc_rqst *rqst
 int		fh_lock_parent(struct svc_fh *, struct dentry *);
 int		nfsd_racache_init(int);
 void		nfsd_racache_shutdown(void);
+int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+		                struct svc_export **expp);
 int		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
 				const char *, int, struct svc_fh *);
 int		nfsd_setattr(struct svc_rqst *, struct svc_fh *,


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
