From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 26] Check error status from nfsd_sync_dir
Date: Fri, 13 Jan 2006 12:00:47 +1100
Message-ID: <1060113010047.22935@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJN-0002Xz-Ia
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJM-0006i2-Tz
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:01 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:53 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:49 +1100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

Change nfsd_sync_dir to return an error if ->sync fails, and pass that
error up through the stack.
This involves a number of rearrangements of error paths, and care to
distinguish between Linux -errno numbers and NFSERR numbers.

In the 'create' routines, we continue with the 'setattr' even if a
previous sync_dir failed.

This patch is quite different from Takashi's in a few ways, but there
is still a strong lineage.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c             |   80 ++++++++++++++++++++++++--------------------
 ./include/linux/nfsd/nfsd.h |    2 -
 2 files changed, 45 insertions(+), 37 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2006-01-13 11:48:43.000000000 +1100
+++ ./fs/nfsd/vfs.c	2006-01-13 11:48:46.000000000 +1100
@@ -710,14 +710,15 @@ static inline int nfsd_dosync(struct fil
 {
 	struct inode *inode = dp->d_inode;
 	int (*fsync) (struct file *, struct dentry *, int);
-	int err = nfs_ok;
+	int err;
 
-	filemap_fdatawrite(inode->i_mapping);
-	if (fop && (fsync = fop->fsync))
-		err=fsync(filp, dp, 0);
-	filemap_fdatawait(inode->i_mapping);
+	err = filemap_fdatawrite(inode->i_mapping);
+	if (err == 0 && fop && (fsync = fop->fsync))
+		err = fsync(filp, dp, 0);
+	if (err == 0)
+		err = filemap_fdatawait(inode->i_mapping);
 
-	return nfserrno(err);
+	return err;
 }
 	
 
@@ -734,10 +735,10 @@ nfsd_sync(struct file *filp)
 	return err;
 }
 
-void
+int
 nfsd_sync_dir(struct dentry *dp)
 {
-	nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
+	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
 }
 
 /*
@@ -1065,6 +1066,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
 			err = nfsd_sync(file);
+			err = nfserrno(err);
 		} else {
 			err = nfserr_notsupp;
 		}
@@ -1175,7 +1177,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		nfsd_sync_dir(dentry);
+		err = nfsd_sync_dir(dentry);
 		write_inode_now(dchild->d_inode, 1);
 	}
 
@@ -1185,9 +1187,11 @@ nfsd_create(struct svc_rqst *rqstp, stru
 	 * send along the gid when it tries to implement setgid
 	 * directories via NFS.
 	 */
-	err = 0;
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0)
-		err = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
+		int err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+		if (err2)
+			err = err2;
+	}
 	/*
 	 * Update the file handle to get the new inode info.
 	 */
@@ -1306,17 +1310,12 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		nfsd_sync_dir(dentry);
+		err = nfsd_sync_dir(dentry);
+		if (err)
+			err = nfserrno(err);
 		/* setattr will sync the child (or not) */
 	}
 
-	/*
-	 * Update the filehandle to get the new inode info.
-	 */
-	err = fh_update(resfhp);
-	if (err)
-		goto out;
-
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
 		/* Cram the verifier into atime/mtime/mode */
 		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
@@ -1337,8 +1336,17 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	 * implement setgid directories via NFS. Clear out all that cruft.
 	 */
  set_attr:
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID)) != 0)
- 		err = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID)) != 0) {
+ 		int err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+		if (err2)
+			err = nfserrno(err2);
+	}
+
+	/*
+	 * Update the filehandle to get the new inode info.
+	 */
+	if (!err)
+		err = fh_update(resfhp);
 
  out:
 	fh_unlock(fhp);
@@ -1447,10 +1455,10 @@ nfsd_symlink(struct svc_rqst *rqstp, str
 	} else
 		err = vfs_symlink(dentry->d_inode, dnew, path, mode);
 
-	if (!err) {
+	if (!err)
 		if (EX_ISSYNC(fhp->fh_export))
-			nfsd_sync_dir(dentry);
-	} else
+			err = nfsd_sync_dir(dentry);
+	if (err)
 		err = nfserrno(err);
 	fh_unlock(fhp);
 
@@ -1506,8 +1514,10 @@ nfsd_link(struct svc_rqst *rqstp, struct
 	err = vfs_link(dold, dirp, dnew);
 	if (!err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			nfsd_sync_dir(ddir);
+			err = nfsd_sync_dir(ddir);
 			write_inode_now(dest, 1);
+			if (err)
+				err = nfserrno(err);
 		}
 	} else {
 		if (err == -EXDEV && rqstp->rq_vers == 2)
@@ -1595,8 +1605,9 @@ nfsd_rename(struct svc_rqst *rqstp, stru
 #endif
 	err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!err && EX_ISSYNC(tfhp->fh_export)) {
-		nfsd_sync_dir(tdentry);
-		nfsd_sync_dir(fdentry);
+		err = nfsd_sync_dir(tdentry);
+		if (!err)
+			err = nfsd_sync_dir(fdentry);
 	}
 
  out_dput_new:
@@ -1671,17 +1682,14 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
 
 	dput(rdentry);
 
-	if (err)
-		goto out_nfserr;
-	if (EX_ISSYNC(fhp->fh_export)) 
-		nfsd_sync_dir(dentry);
-
-out:
-	return err;
+	if (err == 0 &&
+	    EX_ISSYNC(fhp->fh_export))
+			err = nfsd_sync_dir(dentry);
 
 out_nfserr:
 	err = nfserrno(err);
-	goto out;
+out:
+	return err;
 }
 
 /*

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2006-01-13 11:48:43.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2006-01-13 11:48:46.000000000 +1100
@@ -124,7 +124,7 @@ int		nfsd_statfs(struct svc_rqst *, stru
 
 int		nfsd_notify_change(struct inode *, struct iattr *);
 int		nfsd_permission(struct svc_export *, struct dentry *, int);
-void		nfsd_sync_dir(struct dentry *dp);
+int		nfsd_sync_dir(struct dentry *dp);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
