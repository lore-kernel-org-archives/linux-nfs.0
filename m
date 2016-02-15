Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:43040 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbcBOCah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Feb 2016 21:30:37 -0500
From: green@linuxhacker.ru
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Dmitry Eremin <dmitry.eremin@intel.com>,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH][RESEND] staging/lustre: proper support of NFS anonymous dentries
Date: Sun, 14 Feb 2016 20:42:33 -0500
Message-Id: <1455500553-3271566-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

NFS can ask to encode dentries that are not connected to the root.
The fix check for parent is NULL and encode a file handle accordingly.

Reviewed-on: http://review.whamcloud.com/8347
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4231
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
Greg wanted an ack from some of the NFSD maintainers, so resending with
enlarged CC list.

This also happens to fix a crash when you try to use fhandle syscalls
with Lustre.


 drivers/staging/lustre/lustre/llite/llite_nfs.c | 30 ++++++++++++++-----------
 include/linux/exportfs.h                        |  6 +++++
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 9f64dd1..58ee239 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -141,10 +141,11 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 	struct inode  *inode;
 	struct dentry *result;
 
-	CDEBUG(D_INFO, "Get dentry for fid: "DFID"\n", PFID(fid));
 	if (!fid_is_sane(fid))
 		return ERR_PTR(-ESTALE);
 
+	CDEBUG(D_INFO, "Get dentry for fid: " DFID "\n", PFID(fid));
+
 	inode = search_inode_for_lustre(sb, fid);
 	if (IS_ERR(inode))
 		return ERR_CAST(inode);
@@ -160,7 +161,7 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 	 * We have to find the parent to tell MDS how to init lov objects.
 	 */
 	if (S_ISREG(inode->i_mode) && !ll_i2info(inode)->lli_has_smd &&
-	    parent != NULL) {
+	    parent && !fid_is_zero(parent)) {
 		struct ll_inode_info *lli = ll_i2info(inode);
 
 		spin_lock(&lli->lli_lock);
@@ -174,8 +175,6 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 	return result;
 }
 
-#define LUSTRE_NFS_FID	  0x97
-
 /**
  * \a connectable - is nfsd will connect himself or this should be done
  *		  at lustre
@@ -188,20 +187,25 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
 			struct inode *parent)
 {
+	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
 	struct lustre_nfs_fid *nfs_fid = (void *)fh;
 
 	CDEBUG(D_INFO, "encoding for (%lu,"DFID") maxlen=%d minlen=%d\n",
-	      inode->i_ino, PFID(ll_inode2fid(inode)), *plen,
-	      (int)sizeof(struct lustre_nfs_fid));
+	      inode->i_ino, PFID(ll_inode2fid(inode)), *plen, fileid_len);
 
-	if (*plen < sizeof(struct lustre_nfs_fid) / 4)
-		return 255;
+	if (*plen < fileid_len) {
+		*plen = fileid_len;
+		return FILEID_INVALID;
+	}
 
 	nfs_fid->lnf_child = *ll_inode2fid(inode);
-	nfs_fid->lnf_parent = *ll_inode2fid(parent);
-	*plen = sizeof(struct lustre_nfs_fid) / 4;
+	if (parent)
+		nfs_fid->lnf_parent = *ll_inode2fid(parent);
+	else
+		fid_zero(&nfs_fid->lnf_parent);
+	*plen = fileid_len;
 
-	return LUSTRE_NFS_FID;
+	return FILEID_LUSTRE;
 }
 
 static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
@@ -259,7 +263,7 @@ static struct dentry *ll_fh_to_dentry(struct super_block *sb, struct fid *fid,
 {
 	struct lustre_nfs_fid *nfs_fid = (struct lustre_nfs_fid *)fid;
 
-	if (fh_type != LUSTRE_NFS_FID)
+	if (fh_type != FILEID_LUSTRE)
 		return ERR_PTR(-EPROTO);
 
 	return ll_iget_for_nfs(sb, &nfs_fid->lnf_child, &nfs_fid->lnf_parent);
@@ -270,7 +274,7 @@ static struct dentry *ll_fh_to_parent(struct super_block *sb, struct fid *fid,
 {
 	struct lustre_nfs_fid *nfs_fid = (struct lustre_nfs_fid *)fid;
 
-	if (fh_type != LUSTRE_NFS_FID)
+	if (fh_type != FILEID_LUSTRE)
 		return ERR_PTR(-EPROTO);
 
 	return ll_iget_for_nfs(sb, &nfs_fid->lnf_parent, NULL);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index fa05e04..d841450 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -97,6 +97,12 @@ enum fid_type {
 	FILEID_FAT_WITH_PARENT = 0x72,
 
 	/*
+	 * 128 bit child FID (struct lu_fid)
+	 * 128 bit parent FID (struct lu_fid)
+	 */
+	FILEID_LUSTRE = 0x97,
+
+	/*
 	 * Filesystems must not use 0xff file ID.
 	 */
 	FILEID_INVALID = 0xff,
-- 
2.1.0

