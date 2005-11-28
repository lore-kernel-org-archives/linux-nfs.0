From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Check error status from vfs_getattr and i_op->fsync
Date: Mon, 28 Nov 2005 12:41:27 +1100
Message-ID: <1051128014127.24572@cse.unsw.edu.au>
References: <20051128123945.24553.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EgY1U-00075o-Nc
	for nfs@lists.sourceforge.net; Sun, 27 Nov 2005 17:41:40 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EgY1T-0000bJ-SQ
	for nfs@lists.sourceforge.net; Sun, 27 Nov 2005 17:41:40 -0800
To: Andrew Morton <akpm@osdl.org>
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

This patch against 2.6.15-rc2-mm1 checks some error statuses that nfsd
was ignoring.  Due to the extent of the change, and the fact that the
problem has been un-noticed for so long, there is no hurry for them to
go to Linus - it would be best if they sit in -mm for a while.
Thanks,
NeilBrown


### Comments for Changeset

Bother vfs_getattr and i_op->fsync return error statuses
which nfsd was largely ignoring.  This as noticed when
exporting directories using fuse.

This patch cleans up most of the offences, which involves moving the
call to vfs_getattr out of the xdr encoding routines (where it is too
late to report an error) into the main NFS procedure handling
routines.

There is still a called to vfs_gettattr (related to the ACL code)
where the status is ignored, and called to nfsd_sync_dir don't check
return status either.

From: David Shaw <dshaw@jabberwocky.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3proc.c        |   11 ++++++++--
 ./fs/nfsd/nfs3xdr.c         |   47 ++++++++++++++++++++++---------------------
 ./fs/nfsd/nfsxdr.c          |   48 ++++++++++++++++++++++----------------------
 ./fs/nfsd/vfs.c             |   20 +++++++++++-------
 ./include/linux/nfsd/xdr.h  |    3 ++
 ./include/linux/nfsd/xdr3.h |    1 
 6 files changed, 75 insertions(+), 55 deletions(-)

diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
--- ./fs/nfsd/nfs3proc.c~current~	2005-11-28 11:46:42.000000000 +1100
+++ ./fs/nfsd/nfs3proc.c	2005-11-28 11:55:03.000000000 +1100
@@ -56,13 +56,20 @@ static int
 nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 					   struct nfsd3_attrstat *resp)
 {
-	int	nfserr;
+	int	err, nfserr;
 
 	dprintk("nfsd: GETATTR(3)  %s\n",
-				SVCFH_fmt(&argp->fh));
+		SVCFH_fmt(&argp->fh));
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP);
+	if (nfserr)
+		RETURN_STATUS(nfserr);
+
+	err = vfs_getattr(resp->fh.fh_export->ex_mnt,
+			  resp->fh.fh_dentry, &resp->stat);
+	nfserr = nfserrno(err);
+
 	RETURN_STATUS(nfserr);
 }
 

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2005-11-28 11:46:42.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2005-11-28 11:53:43.000000000 +1100
@@ -154,37 +154,34 @@ decode_sattr3(u32 *p, struct iattr *iap)
 }
 
 static inline u32 *
-encode_fattr3(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
+encode_fattr3(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp,
+	      struct kstat *stat)
 {
-	struct vfsmount *mnt = fhp->fh_export->ex_mnt;
 	struct dentry	*dentry = fhp->fh_dentry;
-	struct kstat stat;
 	struct timespec time;
 
-	vfs_getattr(mnt, dentry, &stat);
-
-	*p++ = htonl(nfs3_ftypes[(stat.mode & S_IFMT) >> 12]);
-	*p++ = htonl((u32) stat.mode);
-	*p++ = htonl((u32) stat.nlink);
-	*p++ = htonl((u32) nfsd_ruid(rqstp, stat.uid));
-	*p++ = htonl((u32) nfsd_rgid(rqstp, stat.gid));
-	if (S_ISLNK(stat.mode) && stat.size > NFS3_MAXPATHLEN) {
+	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
+	*p++ = htonl((u32) stat->mode);
+	*p++ = htonl((u32) stat->nlink);
+	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
+	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
+	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN) {
 		p = xdr_encode_hyper(p, (u64) NFS3_MAXPATHLEN);
 	} else {
-		p = xdr_encode_hyper(p, (u64) stat.size);
+		p = xdr_encode_hyper(p, (u64) stat->size);
 	}
-	p = xdr_encode_hyper(p, ((u64)stat.blocks) << 9);
-	*p++ = htonl((u32) MAJOR(stat.rdev));
-	*p++ = htonl((u32) MINOR(stat.rdev));
+	p = xdr_encode_hyper(p, ((u64)stat->blocks) << 9);
+	*p++ = htonl((u32) MAJOR(stat->rdev));
+	*p++ = htonl((u32) MINOR(stat->rdev));
 	if (is_fsid(fhp, rqstp->rq_reffh))
 		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
 	else
-		p = xdr_encode_hyper(p, (u64) huge_encode_dev(stat.dev));
-	p = xdr_encode_hyper(p, (u64) stat.ino);
-	p = encode_time3(p, &stat.atime);
+		p = xdr_encode_hyper(p, (u64) huge_encode_dev(stat->dev));
+	p = xdr_encode_hyper(p, (u64) stat->ino);
+	p = encode_time3(p, &stat->atime);
 	lease_get_mtime(dentry->d_inode, &time); 
 	p = encode_time3(p, &time);
-	p = encode_time3(p, &stat.ctime);
+	p = encode_time3(p, &stat->ctime);
 
 	return p;
 }
@@ -232,8 +229,14 @@ encode_post_op_attr(struct svc_rqst *rqs
 {
 	struct dentry *dentry = fhp->fh_dentry;
 	if (dentry && dentry->d_inode != NULL) {
-		*p++ = xdr_one;		/* attributes follow */
-		return encode_fattr3(rqstp, p, fhp);
+	        int err;
+		struct kstat stat;
+
+		err = vfs_getattr(fhp->fh_export->ex_mnt, dentry, &stat);
+		if (!err) {
+			*p++ = xdr_one;		/* attributes follow */
+			return encode_fattr3(rqstp, p, fhp, &stat);
+		}
 	}
 	*p++ = xdr_zero;
 	return p;
@@ -616,7 +619,7 @@ nfs3svc_encode_attrstat(struct svc_rqst 
 					struct nfsd3_attrstat *resp)
 {
 	if (resp->status == 0)
-		p = encode_fattr3(rqstp, p, &resp->fh);
+		p = encode_fattr3(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 

diff ./fs/nfsd/nfsxdr.c~current~ ./fs/nfsd/nfsxdr.c
--- ./fs/nfsd/nfsxdr.c~current~	2005-11-28 11:56:02.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2005-11-28 12:18:25.000000000 +1100
@@ -152,46 +152,44 @@ decode_sattr(u32 *p, struct iattr *iap)
 }
 
 static inline u32 *
-encode_fattr(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
+encode_fattr(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp,
+	     struct kstat *stat)
 {
-	struct vfsmount *mnt = fhp->fh_export->ex_mnt;
 	struct dentry	*dentry = fhp->fh_dentry;
-	struct kstat stat;
 	int type;
 	struct timespec time;
 
-	vfs_getattr(mnt, dentry, &stat);
-	type = (stat.mode & S_IFMT);
+	type = (stat->mode & S_IFMT);
 
 	*p++ = htonl(nfs_ftypes[type >> 12]);
-	*p++ = htonl((u32) stat.mode);
-	*p++ = htonl((u32) stat.nlink);
-	*p++ = htonl((u32) nfsd_ruid(rqstp, stat.uid));
-	*p++ = htonl((u32) nfsd_rgid(rqstp, stat.gid));
+	*p++ = htonl((u32) stat->mode);
+	*p++ = htonl((u32) stat->nlink);
+	*p++ = htonl((u32) nfsd_ruid(rqstp, stat->uid));
+	*p++ = htonl((u32) nfsd_rgid(rqstp, stat->gid));
 
-	if (S_ISLNK(type) && stat.size > NFS_MAXPATHLEN) {
+	if (S_ISLNK(type) && stat->size > NFS_MAXPATHLEN) {
 		*p++ = htonl(NFS_MAXPATHLEN);
 	} else {
-		*p++ = htonl((u32) stat.size);
+		*p++ = htonl((u32) stat->size);
 	}
-	*p++ = htonl((u32) stat.blksize);
+	*p++ = htonl((u32) stat->blksize);
 	if (S_ISCHR(type) || S_ISBLK(type))
-		*p++ = htonl(new_encode_dev(stat.rdev));
+		*p++ = htonl(new_encode_dev(stat->rdev));
 	else
 		*p++ = htonl(0xffffffff);
-	*p++ = htonl((u32) stat.blocks);
+	*p++ = htonl((u32) stat->blocks);
 	if (is_fsid(fhp, rqstp->rq_reffh))
 		*p++ = htonl((u32) fhp->fh_export->ex_fsid);
 	else
-		*p++ = htonl(new_encode_dev(stat.dev));
-	*p++ = htonl((u32) stat.ino);
-	*p++ = htonl((u32) stat.atime.tv_sec);
-	*p++ = htonl(stat.atime.tv_nsec ? stat.atime.tv_nsec / 1000 : 0);
+		*p++ = htonl(new_encode_dev(stat->dev));
+	*p++ = htonl((u32) stat->ino);
+	*p++ = htonl((u32) stat->atime.tv_sec);
+	*p++ = htonl(stat->atime.tv_nsec ? stat->atime.tv_nsec / 1000 : 0);
 	lease_get_mtime(dentry->d_inode, &time); 
 	*p++ = htonl((u32) time.tv_sec);
 	*p++ = htonl(time.tv_nsec ? time.tv_nsec / 1000 : 0); 
-	*p++ = htonl((u32) stat.ctime.tv_sec);
-	*p++ = htonl(stat.ctime.tv_nsec ? stat.ctime.tv_nsec / 1000 : 0);
+	*p++ = htonl((u32) stat->ctime.tv_sec);
+	*p++ = htonl(stat->ctime.tv_nsec ? stat->ctime.tv_nsec / 1000 : 0);
 
 	return p;
 }
@@ -199,7 +197,9 @@ encode_fattr(struct svc_rqst *rqstp, u32
 /* Helper function for NFSv2 ACL code */
 u32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
 {
-	return encode_fattr(rqstp, p, fhp);
+	struct kstat stat;
+	vfs_getattr(fhp->fh_export->ex_mnt, fhp->fh_dentry, &stat);
+	return encode_fattr(rqstp, p, fhp, &stat);
 }
 
 /*
@@ -394,7 +394,7 @@ int
 nfssvc_encode_attrstat(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_attrstat *resp)
 {
-	p = encode_fattr(rqstp, p, &resp->fh);
+	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -403,7 +403,7 @@ nfssvc_encode_diropres(struct svc_rqst *
 					struct nfsd_diropres *resp)
 {
 	p = encode_fh(p, &resp->fh);
-	p = encode_fattr(rqstp, p, &resp->fh);
+	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	return xdr_ressize_check(rqstp, p);
 }
 
@@ -428,7 +428,7 @@ int
 nfssvc_encode_readres(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_readres *resp)
 {
-	p = encode_fattr(rqstp, p, &resp->fh);
+	p = encode_fattr(rqstp, p, &resp->fh, &resp->stat);
 	*p++ = htonl(resp->count);
 	xdr_ressize_check(rqstp, p);
 

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-11-28 11:46:41.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-11-28 12:34:22.000000000 +1100
@@ -705,27 +705,33 @@ nfsd_close(struct file *filp)
  * As this calls fsync (not fdatasync) there is no need for a write_inode
  * after it.
  */
-static inline void nfsd_dosync(struct file *filp, struct dentry *dp,
-			       struct file_operations *fop)
+static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
+			      struct file_operations *fop)
 {
 	struct inode *inode = dp->d_inode;
 	int (*fsync) (struct file *, struct dentry *, int);
+	int err = nfs_ok;
 
 	filemap_fdatawrite(inode->i_mapping);
 	if (fop && (fsync = fop->fsync))
-		fsync(filp, dp, 0);
+		err=fsync(filp, dp, 0);
 	filemap_fdatawait(inode->i_mapping);
+
+	return nfserrno(err);
 }
 	
 
-static void
+static int
 nfsd_sync(struct file *filp)
 {
+        int err;
 	struct inode *inode = filp->f_dentry->d_inode;
 	dprintk("nfsd: sync file %s\n", filp->f_dentry->d_name.name);
 	down(&inode->i_sem);
-	nfsd_dosync(filp, filp->f_dentry, filp->f_op);
+	err=nfsd_dosync(filp, filp->f_dentry, filp->f_op);
 	up(&inode->i_sem);
+
+	return err;
 }
 
 void
@@ -950,7 +956,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, s
 
 			if (inode->i_state & I_DIRTY) {
 				dprintk("nfsd: write sync %d\n", current->pid);
-				nfsd_sync(file);
+				err=nfsd_sync(file);
 			}
 #if 0
 			wake_up(&inode->i_wait);
@@ -1054,7 +1060,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			nfsd_sync(file);
+			err = nfsd_sync(file);
 		} else {
 			err = nfserr_notsupp;
 		}

diff ./include/linux/nfsd/xdr.h~current~ ./include/linux/nfsd/xdr.h
--- ./include/linux/nfsd/xdr.h~current~	2005-11-28 12:02:25.000000000 +1100
+++ ./include/linux/nfsd/xdr.h	2005-11-28 12:16:36.000000000 +1100
@@ -88,10 +88,12 @@ struct nfsd_readdirargs {
 
 struct nfsd_attrstat {
 	struct svc_fh		fh;
+	struct kstat		stat;
 };
 
 struct nfsd_diropres  {
 	struct svc_fh		fh;
+	struct kstat		stat;
 };
 
 struct nfsd_readlinkres {
@@ -101,6 +103,7 @@ struct nfsd_readlinkres {
 struct nfsd_readres {
 	struct svc_fh		fh;
 	unsigned long		count;
+	struct kstat		stat;
 };
 
 struct nfsd_readdirres {

diff ./include/linux/nfsd/xdr3.h~current~ ./include/linux/nfsd/xdr3.h
--- ./include/linux/nfsd/xdr3.h~current~	2005-11-28 11:46:42.000000000 +1100
+++ ./include/linux/nfsd/xdr3.h	2005-11-28 12:02:05.000000000 +1100
@@ -126,6 +126,7 @@ struct nfsd3_setaclargs {
 struct nfsd3_attrstat {
 	__u32			status;
 	struct svc_fh		fh;
+	struct kstat            stat;
 };
 
 /* LOOKUP, CREATE, MKDIR, SYMLINK, MKNOD */


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
