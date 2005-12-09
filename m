From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: Re: [PATCH kNFSd ] Check error status from vfs_getattr and
 i_op->fsync
Date: Fri, 09 Dec 2005 09:25:42 +0900
Message-ID: <1134087942.500655.14993.nullmailer@yamt.dyndns.org>
References: <1051128014127.24572@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed; boundary="NextPart-20051209091918-2308700"
Cc: akpm@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkW5e-00015w-Sr
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 16:26:22 -0800
Received: from fla1aai163.kng.mesh.ad.jp ([61.193.102.163] helo=yamt.dyndns.org)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EkW5c-0006BQ-8I
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 16:26:22 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: Your message of "Mon, 28 Nov 2005 12:41:27 +1100"
	<1051128014127.24572@cse.unsw.edu.au>
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

--NextPart-20051209091918-2308700
Content-Type: Text/Plain; charset=us-ascii

hi,

> This patch against 2.6.15-rc2-mm1 checks some error statuses that nfsd
> was ignoring.  Due to the extent of the change, and the fact that the
> problem has been un-noticed for so long, there is no hurry for them to
> go to Linus - it would be best if they sit in -mm for a while.
> Thanks,
> NeilBrown
> 
> 
> ### Comments for Changeset
> 
> Bother vfs_getattr and i_op->fsync return error statuses
> which nfsd was largely ignoring.  This as noticed when
> exporting directories using fuse.
> 
> This patch cleans up most of the offences, which involves moving the
> call to vfs_getattr out of the xdr encoding routines (where it is too
> late to report an error) into the main NFS procedure handling
> routines.
> 
> There is still a called to vfs_gettattr (related to the ACL code)
> where the status is ignored, and called to nfsd_sync_dir don't check
> return status either.

it reminded me of a similar diff in our local tree.  (attached)
it's fsync part only but more complete.

YAMAMOTO Takashi

--NextPart-20051209091918-2308700
Content-Type: Text/Plain; charset=us-ascii
Content-Disposition: attachment;
 filename="vaj_2.6.12.6_nfsd-sync-error__3.patch"

--- linux/fs/nfsd/vfs.c.BACKUP	2005-11-28 10:12:24.000000000 +0900
+++ linux/fs/nfsd/vfs.c	2005-11-28 10:20:54.000000000 +0900
@@ -712,33 +712,48 @@ nfsd_close(struct file *filp)
  * As this calls fsync (not fdatasync) there is no need for a write_inode
  * after it.
  */
-static inline void nfsd_dosync(struct file *filp, struct dentry *dp,
+static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
 			       struct file_operations *fop)
 {
 	struct inode *inode = dp->d_inode;
 	int (*fsync) (struct file *, struct dentry *, int);
+	int error;
+	int ret;
 
-	filemap_fdatawrite(inode->i_mapping);
-	if (fop && (fsync = fop->fsync))
-		fsync(filp, dp, 0);
-	filemap_fdatawait(inode->i_mapping);
+	ret = filemap_fdatawrite(inode->i_mapping);
+	if (fop && (fsync = fop->fsync)) {
+		error = fsync(filp, dp, 0);
+		if (ret == 0) {
+			ret = error;
+		}
+	}
+	error = filemap_fdatawait(inode->i_mapping);
+	if (ret == 0) {
+		ret = error;
+	}
+
+	return ret;
 }
 	
 
-static void
+static int
 nfsd_sync(struct file *filp)
 {
 	struct inode *inode = filp->f_dentry->d_inode;
+	int error;
+
 	dprintk("nfsd: sync file %s\n", filp->f_dentry->d_name.name);
 	down(&inode->i_sem);
-	nfsd_dosync(filp, filp->f_dentry, filp->f_op);
+	error = nfsd_dosync(filp, filp->f_dentry, filp->f_op);
 	up(&inode->i_sem);
+
+	return error;
 }
 
-static void
+static int
 nfsd_sync_dir(struct dentry *dp)
 {
-	nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
+	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
 }
 
 /*
@@ -958,8 +973,13 @@ nfsd_vfs_write(struct svc_rqst *rqstp, s
 			}
 
 			if (inode->i_state & I_DIRTY) {
+				int err2;
+
 				dprintk("nfsd: write sync %d\n", current->pid);
-				nfsd_sync(file);
+				err2 = nfsd_sync(file);
+				if (err2) {
+					err = err2;
+				}
 			}
 #if 0
 			wake_up(&inode->i_wait);
@@ -1063,7 +1083,8 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			nfsd_sync(file);
+			err = nfsd_sync(file);
+			err = nfserrno(err);
 		} else {
 			err = nfserr_notsupp;
 		}
@@ -1174,7 +1195,11 @@ nfsd_create(struct svc_rqst *rqstp, stru
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		nfsd_sync_dir(dentry);
+		err = nfsd_sync_dir(dentry);
+		if (err) {
+			goto out_nfserr;
+		}
+
 		write_inode_now(dchild->d_inode, 1);
 	}
 
@@ -1305,7 +1330,10 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out_nfserr;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		nfsd_sync_dir(dentry);
+		err = nfsd_sync_dir(dentry);
+		if (err) {
+			goto out_nfserr;
+		}
 		/* setattr will sync the child (or not) */
 	}
 
@@ -1447,10 +1475,13 @@ nfsd_symlink(struct svc_rqst *rqstp, str
 		err = vfs_symlink(dentry->d_inode, dnew, path, mode);
 
 	if (!err) {
-		if (EX_ISSYNC(fhp->fh_export))
-			nfsd_sync_dir(dentry);
-	} else
+		if (EX_ISSYNC(fhp->fh_export)) {
+			err = nfsd_sync_dir(dentry);
+		}
+	}
+	if (err) {
 		err = nfserrno(err);
+	}
 	fh_unlock(fhp);
 
 	cerr = fh_compose(resfhp, fhp->fh_export, dnew, fhp);
@@ -1505,8 +1536,11 @@ nfsd_link(struct svc_rqst *rqstp, struct
 	err = vfs_link(dold, dirp, dnew);
 	if (!err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			nfsd_sync_dir(ddir);
+			err = nfsd_sync_dir(ddir);
 			write_inode_now(dest, 1);
+			if (err) {
+				err = nfserrno(err);
+			}
 		}
 	} else {
 		if (err == -EXDEV && rqstp->rq_vers == 2)
@@ -1594,8 +1628,10 @@ nfsd_rename(struct svc_rqst *rqstp, stru
 #endif
 	err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!err && EX_ISSYNC(tfhp->fh_export)) {
-		nfsd_sync_dir(tdentry);
-		nfsd_sync_dir(fdentry);
+		err = nfsd_sync_dir(tdentry);
+		if (!err) {
+			err = nfsd_sync_dir(fdentry);
+		}
 	}
 
  out_dput_new:
@@ -1672,8 +1708,12 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
 
 	if (err)
 		goto out_nfserr;
-	if (EX_ISSYNC(fhp->fh_export)) 
-		nfsd_sync_dir(dentry);
+	if (EX_ISSYNC(fhp->fh_export)) {
+		err = nfsd_sync_dir(dentry);
+		if (err) {
+			goto out_nfserr;
+		}
+	}
 
 out:
 	return err;

--NextPart-20051209091918-2308700--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
