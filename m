Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36633 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbbHEVNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:55 -0400
Received: by ykeo23 with SMTP id o23so46446617yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:54 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 16/18] nfsd: add a fh_compose_shallow
Date: Wed,  5 Aug 2015 17:13:34 -0400
Message-Id: <1438809216-4846-17-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll need to be able to cook up a knfsd_fh from a
dentry/export combo. Usually nfsd works with svc_fh's, but that takes
a lot of extra baggage that we don't really need here.

Add a routine that encodes the filehandle directly into a knfsd_fh
instead. Much like we have a fh_copy_shallow, the new routine is called
fh_compose_shallow.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsfh.c | 112 +++++++++++++++++++++++++++++---------------------------
 fs/nfsd/nfsfh.h |   2 +
 2 files changed, 60 insertions(+), 54 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index b601f291d825..ee6d4b746467 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -511,32 +511,64 @@ retry:
 }
 
 __be32
-fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
-	   struct svc_fh *ref_fh)
+fh_compose_shallow(struct knfsd_fh *kfh, int maxsize, struct svc_export *exp,
+			struct dentry *dentry, struct svc_fh *ref_fh)
 {
-	/* ref_fh is a reference file handle.
-	 * if it is non-null and for the same filesystem, then we should compose
-	 * a filehandle which is of the same version, where possible.
-	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
-	 * Then create a 32byte filehandle using nfs_fhbase_old
-	 *
-	 */
+	struct inode	*inode = d_inode(dentry);
+	dev_t		ex_dev = exp_sb(exp)->s_dev;
 
-	struct inode * inode = d_inode(dentry);
-	dev_t ex_dev = exp_sb(exp)->s_dev;
-
-	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %pd2, ino=%ld)\n",
-		MAJOR(ex_dev), MINOR(ex_dev),
+	dprintk("nfsd: %s(exp %02x:%02x/%ld %pd2, ino=%ld)\n",
+		__func__, MAJOR(ex_dev), MINOR(ex_dev),
 		(long) d_inode(exp->ex_path.dentry)->i_ino,
-		dentry,
-		(inode ? inode->i_ino : 0));
+		dentry, (inode ? inode->i_ino : 0));
 
-	/* Choose filehandle version and fsid type based on
-	 * the reference filehandle (if it is in the same export)
-	 * or the export options.
+	/*
+	 * Choose filehandle version and fsid type based on the reference
+	 * filehandle (if it is in the same export) or the export options.
 	 */
-	 set_version_and_fsid_type(&fhp->fh_handle, fhp->fh_maxsize,
-				   exp, ref_fh);
+	set_version_and_fsid_type(kfh, maxsize, exp, ref_fh);
+	if (kfh->fh_version == 0xca) {
+		/* old style filehandle please */
+		memset(&kfh->fh_base, 0, NFS_FHSIZE);
+		kfh->fh_size = NFS_FHSIZE;
+		kfh->ofh_dcookie = 0xfeebbaca;
+		kfh->ofh_dev =  old_encode_dev(ex_dev);
+		kfh->ofh_xdev = kfh->ofh_dev;
+		kfh->ofh_xino =
+			ino_t_to_u32(d_inode(exp->ex_path.dentry)->i_ino);
+		kfh->ofh_dirino = ino_t_to_u32(parent_ino(dentry));
+		if (inode)
+			_fh_update_old(dentry, exp, kfh);
+	} else {
+		kfh->fh_size = key_len(kfh->fh_fsid_type) + 4;
+		kfh->fh_auth_type = 0;
+
+		mk_fsid(kfh->fh_fsid_type, kfh->fh_fsid, ex_dev,
+			d_inode(exp->ex_path.dentry)->i_ino,
+			exp->ex_fsid, exp->ex_uuid);
+
+		if (inode)
+			_fh_update(kfh, maxsize, exp, dentry);
+
+		if (kfh->fh_fileid_type == FILEID_INVALID)
+			return nfserr_opnotsupp;
+	}
+	return nfs_ok;
+}
+
+/*
+ * ref_fh is a reference file handle.
+ * if it is non-null and for the same filesystem, then we should compose
+ * a filehandle which is of the same version, where possible.
+ * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
+ * Then create a 32byte filehandle using nfs_fhbase_old
+ *
+ */
+__be32
+fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
+	   struct svc_fh *ref_fh)
+{
+	__be32		status;
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
@@ -553,39 +585,11 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	fhp->fh_dentry = dget(dentry); /* our internal copy */
 	fhp->fh_export = exp_get(exp);
 
-	if (fhp->fh_handle.fh_version == 0xca) {
-		/* old style filehandle please */
-		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
-		fhp->fh_handle.fh_size = NFS_FHSIZE;
-		fhp->fh_handle.ofh_dcookie = 0xfeebbaca;
-		fhp->fh_handle.ofh_dev =  old_encode_dev(ex_dev);
-		fhp->fh_handle.ofh_xdev = fhp->fh_handle.ofh_dev;
-		fhp->fh_handle.ofh_xino =
-			ino_t_to_u32(d_inode(exp->ex_path.dentry)->i_ino);
-		fhp->fh_handle.ofh_dirino = ino_t_to_u32(parent_ino(dentry));
-		if (inode)
-			_fh_update_old(dentry, exp, &fhp->fh_handle);
-	} else {
-		fhp->fh_handle.fh_size =
-			key_len(fhp->fh_handle.fh_fsid_type) + 4;
-		fhp->fh_handle.fh_auth_type = 0;
-
-		mk_fsid(fhp->fh_handle.fh_fsid_type,
-			fhp->fh_handle.fh_fsid,
-			ex_dev,
-			d_inode(exp->ex_path.dentry)->i_ino,
-			exp->ex_fsid, exp->ex_uuid);
-
-		if (inode)
-			_fh_update(&fhp->fh_handle, fhp->fh_maxsize,
-					exp, dentry);
-		if (fhp->fh_handle.fh_fileid_type == FILEID_INVALID) {
-			fh_put(fhp);
-			return nfserr_opnotsupp;
-		}
-	}
-
-	return 0;
+	status = fh_compose_shallow(&fhp->fh_handle, fhp->fh_maxsize, exp,
+					dentry, ref_fh);
+	if (status != nfs_ok)
+		fh_put(fhp);
+	return status;
 }
 
 /*
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 1e90dad4926b..dec472131588 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -159,6 +159,8 @@ extern char * SVCFH_fmt(struct svc_fh *fhp);
  * Function prototypes
  */
 __be32	fh_verify(struct svc_rqst *, struct svc_fh *, umode_t, int);
+__be32	fh_compose_shallow(struct knfsd_fh *, int, struct svc_export *,
+			   struct dentry *, struct svc_fh *);
 __be32	fh_compose(struct svc_fh *, struct svc_export *, struct dentry *, struct svc_fh *);
 __be32	fh_update(struct svc_fh *);
 void	fh_put(struct svc_fh *);
-- 
2.4.3

