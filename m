From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/6] nfsd: move fsid_type choice out of fh_compose
Date: Fri,  4 Sep 2009 15:47:02 -0400
Message-ID: <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50165 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757291AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More trivial cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |   77 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 41 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 78d8ebf..bce0b2b 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -431,43 +431,17 @@ static bool fsid_type_ok_for_exp(u8 fsid_type, struct svc_export *exp)
 	return 1;
 }
 
-__be32
-fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
-	   struct svc_fh *ref_fh)
-{
-	/* ref_fh is a reference file handle.
-	 * if it is non-null and for the same filesystem, then we should compose
-	 * a filehandle which is of the same version, where possible.
-	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
-	 * Then create a 32byte filehandle using nfs_fhbase_old
-	 *
-	 */
 
+static void set_version_and_fsid_type(struct svc_fh *fhp, struct svc_export *exp, struct svc_fh *ref_fh)
+{
 	u8 version;
-	u8 fsid_type = 0;
-	struct inode * inode = dentry->d_inode;
-	struct dentry *parent = dentry->d_parent;
-	__u32 *datap;
-	dev_t ex_dev = exp_sb(exp)->s_dev;
-
-	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
-		MAJOR(ex_dev), MINOR(ex_dev),
-		(long) exp->ex_path.dentry->d_inode->i_ino,
-		parent->d_name.name, dentry->d_name.name,
-		(inode ? inode->i_ino : 0));
-
-	/* Choose filehandle version and fsid type based on
-	 * the reference filehandle (if it is in the same export)
-	 * or the export options.
-	 */
- retry:
+	u8 fsid_type;
+retry:
 	version = 1;
 	if (ref_fh && ref_fh->fh_export == exp) {
 		version = ref_fh->fh_handle.fh_version;
 		fsid_type = ref_fh->fh_handle.fh_fsid_type;
 
-		if (ref_fh == fhp)
-			fh_put(ref_fh);
 		ref_fh = NULL;
 
 		switch (version) {
@@ -502,11 +476,44 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 			else
 				fsid_type = FSID_UUID4_INUM;
 		}
-	} else if (!old_valid_dev(ex_dev))
+	} else if (!old_valid_dev(exp_sb(exp)->s_dev))
 		/* for newer device numbers, we must use a newer fsid format */
 		fsid_type = FSID_ENCODE_DEV;
 	else
 		fsid_type = FSID_DEV;
+	fhp->fh_handle.fh_version = version;
+	if (version)
+		fhp->fh_handle.fh_fsid_type = fsid_type;
+}
+
+__be32
+fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
+	   struct svc_fh *ref_fh)
+{
+	/* ref_fh is a reference file handle.
+	 * if it is non-null and for the same filesystem, then we should compose
+	 * a filehandle which is of the same version, where possible.
+	 * Currently, that means that if ref_fh->fh_handle.fh_version == 0xca
+	 * Then create a 32byte filehandle using nfs_fhbase_old
+	 *
+	 */
+
+	struct inode * inode = dentry->d_inode;
+	struct dentry *parent = dentry->d_parent;
+	__u32 *datap;
+	dev_t ex_dev = exp_sb(exp)->s_dev;
+
+	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
+		MAJOR(ex_dev), MINOR(ex_dev),
+		(long) exp->ex_path.dentry->d_inode->i_ino,
+		parent->d_name.name, dentry->d_name.name,
+		(inode ? inode->i_ino : 0));
+
+	/* Choose filehandle version and fsid type based on
+	 * the reference filehandle (if it is in the same export)
+	 * or the export options.
+	 */
+	 set_version_and_fsid_type(fhp, exp, ref_fh);
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
@@ -524,7 +531,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	fhp->fh_export = exp;
 	cache_get(&exp->h);
 
-	if (version == 0xca) {
+	if (fhp->fh_handle.fh_version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
@@ -538,15 +545,13 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 			_fh_update_old(dentry, exp, &fhp->fh_handle);
 	} else {
 		int len;
-		fhp->fh_handle.fh_version = 1;
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
-		fhp->fh_handle.fh_fsid_type = fsid_type;
-		mk_fsid(fsid_type, datap, ex_dev,
+		mk_fsid(fhp->fh_handle.fh_fsid_type, datap, ex_dev,
 			exp->ex_path.dentry->d_inode->i_ino,
 			exp->ex_fsid, exp->ex_uuid);
 
-		len = key_len(fsid_type);
+		len = key_len(fhp->fh_handle.fh_fsid_type);
 		datap += len/4;
 		fhp->fh_handle.fh_size = 4 + len;
 
-- 
1.6.0.4

