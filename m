From: Christoph Hellwig <hch@lst.de>
Subject: [PATH 02/19] exportfs: add fid type
Date: Thu, 30 Aug 2007 15:15:54 +0200
Message-ID: <20070830131554.GC6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQjsI-0006zm-45
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 06:15:54 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IQjsL-0005vY-MT
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 06:15:58 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add a structured fid type so that we don't have to pass an array
of u32 values around everywhere.  It's a union of possible layouts.

As a start there's only the u32 array and the traditional 32bit
inode format, but there will be more in one of my next patchset
when I start to document the various filehandle formats we have
in lowlevel filesystems better.

Also add an enum that gives the various filehandle types human-
readable names.

Note:  Some people might think the struct containing an anonymous
union is ugly, but I didn't want to pass around a raw union type.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/exportfs.h
===================================================================
--- linux-2.6.orig/include/linux/exportfs.h	2007-07-19 15:56:47.000000000 +0200
+++ linux-2.6/include/linux/exportfs.h	2007-07-20 19:50:34.000000000 +0200
@@ -7,6 +7,44 @@ struct dentry;
 struct super_block;
 struct vfsmount;
 
+/*
+ * The fileid_type identifies how the file within the filesystem is encoded.
+ * In theory this is freely set and parsed by the filesystem, but we try to
+ * stick to conventions so we can share some generic code and don't confuse
+ * sniffers like ethereal/wireshark.
+ *
+ * The filesystem must not use the value '0' or '0xff'.
+ */
+enum fid_type {
+	/*
+	 * The root, or export point, of the filesystem.
+	 * (Never actually passed down to the filesystem.
+	 */
+	FILEID_ROOT = 0,
+
+	/*
+	 * 32bit inode number, 32 bit generation number.
+	 */
+	FILEID_INO32_GEN = 1,
+
+	/*
+	 * 32bit inode number, 32 bit generation number,
+	 * 32 bit parent directory inode number.
+	 */
+	FILEID_INO32_GEN_PARENT = 2,
+};
+
+struct fid {
+	union {
+		struct {
+			u32 ino;
+			u32 gen;
+			u32 parent_ino;
+			u32 parent_gen;
+		} i32;
+		__u32 raw[6];
+	};
+};
 
 /**
  * struct export_operations - for nfsd to communicate with file systems
@@ -117,9 +155,9 @@ extern struct dentry *find_exported_dent
 	void *parent, int (*acceptable)(void *context, struct dentry *de),
 	void *context);
 
-extern int exportfs_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
-	int connectable);
-extern struct dentry *exportfs_decode_fh(struct vfsmount *mnt, __u32 *fh,
+extern int exportfs_encode_fh(struct dentry *dentry, struct fid *fid,
+	int *max_len, int connectable);
+extern struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 	int fh_len, int fileid_type, int (*acceptable)(void *, struct dentry *),
 	void *context);
 
Index: linux-2.6/fs/nfsd/nfsfh.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfsfh.c	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/nfsd/nfsfh.c	2007-07-20 19:51:49.000000000 +0200
@@ -115,8 +115,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 	dprintk("nfsd: fh_verify(%s)\n", SVCFH_fmt(fhp));
 
 	if (!fhp->fh_dentry) {
-		__u32 *datap=NULL;
-		__u32 tfh[3];		/* filehandle fragment for oldstyle filehandles */
+		struct fid *fid = NULL, sfid;
 		int fileid_type;
 		int data_left = fh->fh_size/4;
 
@@ -128,7 +127,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 		if (fh->fh_version == 1) {
 			int len;
-			datap = fh->fh_auth;
 			if (--data_left<0) goto out;
 			switch (fh->fh_auth_type) {
 			case 0: break;
@@ -144,9 +142,10 @@ fh_verify(struct svc_rqst *rqstp, struct
 				fh->fh_fsid[1] = fh->fh_fsid[2];
 			}
 			if ((data_left -= len)<0) goto out;
-			exp = rqst_exp_find(rqstp, fh->fh_fsid_type, datap);
-			datap += len;
+			exp = rqst_exp_find(rqstp, fh->fh_fsid_type, fh->fh_auth);
+ 			fid = (struct fid *)(fh->fh_auth + len);
 		} else {
+			__u32 tfh[2];
 			dev_t xdev;
 			ino_t xino;
 			if (fh->fh_size != NFS_FHSIZE)
@@ -190,22 +189,22 @@ fh_verify(struct svc_rqst *rqstp, struct
 			error = nfserr_badhandle;
 
 		if (fh->fh_version != 1) {
-			tfh[0] = fh->ofh_ino;
-			tfh[1] = fh->ofh_generation;
-			tfh[2] = fh->ofh_dirino;
-			datap = tfh;
+			sfid.i32.ino = fh->ofh_ino;
+			sfid.i32.gen = fh->ofh_generation;
+			sfid.i32.parent_ino = fh->ofh_dirino;
+			fid = &sfid;
 			data_left = 3;
 			if (fh->ofh_dirino == 0)
-				fileid_type = 1;
+				fileid_type = FILEID_INO32_GEN;
 			else
-				fileid_type = 2;
+				fileid_type = FILEID_INO32_GEN_PARENT;
 		} else
 			fileid_type = fh->fh_fileid_type;
 
-		if (fileid_type == 0)
+		if (fileid_type == FILEID_ROOT)
 			dentry = dget(exp->ex_dentry);
 		else {
-			dentry = exportfs_decode_fh(exp->ex_mnt, datap,
+			dentry = exportfs_decode_fh(exp->ex_mnt, fid,
 					data_left, fileid_type,
 					nfsd_acceptable, exp);
 		}
@@ -286,16 +285,21 @@ out:
  * an inode.  In this case a call to fh_update should be made
  * before the fh goes out on the wire ...
  */
-static inline int _fh_update(struct dentry *dentry, struct svc_export *exp,
-			     __u32 *datap, int *maxsize)
+static void _fh_update(struct svc_fh *fhp, struct svc_export *exp,
+		struct dentry *dentry)
 {
-	if (dentry == exp->ex_dentry) {
-		*maxsize = 0;
-		return 0;
-	}
+	if (dentry != exp->ex_dentry) {
+		struct fid *fid = (struct fid *)
+			(fhp->fh_handle.fh_auth + fhp->fh_handle.fh_size/4 - 1);
+		int maxsize = (fhp->fh_maxsize - fhp->fh_handle.fh_size)/4;
+		int subtreecheck = !(exp->ex_flags & NFSEXP_NOSUBTREECHECK);
 
-	return exportfs_encode_fh(dentry, datap, maxsize,
-			  !(exp->ex_flags & NFSEXP_NOSUBTREECHECK));
+		fhp->fh_handle.fh_fileid_type =
+			exportfs_encode_fh(dentry, fid, &maxsize, subtreecheck);
+		fhp->fh_handle.fh_size += maxsize * 4;
+	} else {
+		fhp->fh_handle.fh_fileid_type = FILEID_ROOT;
+	}
 }
 
 /*
@@ -457,12 +461,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 		datap += len/4;
 		fhp->fh_handle.fh_size = 4 + len;
 
-		if (inode) {
-			int size = (fhp->fh_maxsize-len-4)/4;
-			fhp->fh_handle.fh_fileid_type =
-				_fh_update(dentry, exp, datap, &size);
-			fhp->fh_handle.fh_size += size*4;
-		}
+		if (inode)
+			_fh_update(fhp, exp, dentry);
 		if (fhp->fh_handle.fh_fileid_type == 255)
 			return nfserr_opnotsupp;
 	}
@@ -479,7 +479,6 @@ __be32
 fh_update(struct svc_fh *fhp)
 {
 	struct dentry *dentry;
-	__u32 *datap;
 
 	if (!fhp->fh_dentry)
 		goto out_bad;
@@ -490,15 +489,10 @@ fh_update(struct svc_fh *fhp)
 	if (fhp->fh_handle.fh_version != 1) {
 		_fh_update_old(dentry, fhp->fh_export, &fhp->fh_handle);
 	} else {
-		int size;
-		if (fhp->fh_handle.fh_fileid_type != 0)
+		if (fhp->fh_handle.fh_fileid_type != FILEID_ROOT)
 			goto out;
-		datap = fhp->fh_handle.fh_auth+
-			fhp->fh_handle.fh_size/4 -1;
-		size = (fhp->fh_maxsize - fhp->fh_handle.fh_size)/4;
-		fhp->fh_handle.fh_fileid_type =
-			_fh_update(dentry, fhp->fh_export, datap, &size);
-		fhp->fh_handle.fh_size += size*4;
+
+		_fh_update(fhp, fhp->fh_export, dentry);
 		if (fhp->fh_handle.fh_fileid_type == 255)
 			return nfserr_opnotsupp;
 	}
Index: linux-2.6/fs/exportfs/expfs.c
===================================================================
--- linux-2.6.orig/fs/exportfs/expfs.c	2007-07-19 15:56:46.000000000 +0200
+++ linux-2.6/fs/exportfs/expfs.c	2007-07-20 19:50:34.000000000 +0200
@@ -434,29 +434,29 @@ out:
  * can be used to check that it is still valid.  It places them in the
  * filehandle fragment where export_decode_fh expects to find them.
  */
-static int export_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
-		   int connectable)
+static int export_encode_fh(struct dentry *dentry, struct fid *fid,
+		int *max_len, int connectable)
 {
 	struct inode * inode = dentry->d_inode;
 	int len = *max_len;
-	int type = 1;
+	int type = FILEID_INO32_GEN;
 	
 	if (len < 2 || (connectable && len < 4))
 		return 255;
 
 	len = 2;
-	fh[0] = inode->i_ino;
-	fh[1] = inode->i_generation;
+	fid->i32.ino = inode->i_ino;
+	fid->i32.gen = inode->i_generation;
 	if (connectable && !S_ISDIR(inode->i_mode)) {
 		struct inode *parent;
 
 		spin_lock(&dentry->d_lock);
 		parent = dentry->d_parent->d_inode;
-		fh[2] = parent->i_ino;
-		fh[3] = parent->i_generation;
+		fid->i32.parent_ino = parent->i_ino;
+		fid->i32.parent_gen = parent->i_generation;
 		spin_unlock(&dentry->d_lock);
 		len = 4;
-		type = 2;
+		type = FILEID_INO32_GEN_PARENT;
 	}
 	*max_len = len;
 	return type;
@@ -494,33 +494,33 @@ static struct dentry *export_decode_fh(s
 				   acceptable, context);
 }
 
-int exportfs_encode_fh(struct dentry *dentry, __u32 *fh, int *max_len,
+int exportfs_encode_fh(struct dentry *dentry, struct fid *fid, int *max_len,
 		int connectable)
 {
  	struct export_operations *nop = dentry->d_sb->s_export_op;
 	int error;
 
 	if (nop->encode_fh)
-		error = nop->encode_fh(dentry, fh, max_len, connectable);
+		error = nop->encode_fh(dentry, fid->raw, max_len, connectable);
 	else
-		error = export_encode_fh(dentry, fh, max_len, connectable);
+		error = export_encode_fh(dentry, fid, max_len, connectable);
 
 	return error;
 }
 EXPORT_SYMBOL_GPL(exportfs_encode_fh);
 
-struct dentry *exportfs_decode_fh(struct vfsmount *mnt, __u32 *fh, int fh_len,
-		int fileid_type, int (*acceptable)(void *, struct dentry *),
-		void *context)
+struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
+		int fh_len, int fileid_type,
+		int (*acceptable)(void *, struct dentry *), void *context)
 {
 	struct export_operations *nop = mnt->mnt_sb->s_export_op;
 	struct dentry *result;
 
 	if (nop->decode_fh) {
-		result = nop->decode_fh(mnt->mnt_sb, fh, fh_len, fileid_type,
+		result = nop->decode_fh(mnt->mnt_sb, fid->raw, fh_len, fileid_type,
 			acceptable, context);
 	} else {
-		result = export_decode_fh(mnt->mnt_sb, fh, fh_len, fileid_type,
+		result = export_decode_fh(mnt->mnt_sb, fid->raw, fh_len, fileid_type,
 			acceptable, context);
 	}
 

--

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
