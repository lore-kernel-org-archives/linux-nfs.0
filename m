Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27994 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab1FMW0B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 18:26:01 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 1/1] NFSv4.1: allow nfs_fhget to succeed with mounted on fileid
Date: Mon, 13 Jun 2011 18:25:56 -0400
Message-Id: <1308003956-2201-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Commit 28331a46d88459788c8fca72dbb0415cd7f514c9 "Ensure we request the
ordinary fileid when doing readdirplus"
changed the meaning of NFS_ATTR_FATTR_FILEID which used to be set when
FATTR4_WORD1_MOUNTED_ON_FILED was requested.

Allow nfs_fhget to succeed with only a mounted on fileid when crossing
a mountpoint or a referral.

Ask for the fileid of the absent file system if mounted_on_fileid is not
supported.

Signed-off-by: Andy Adamson <andros@netapp.com>
cc:stable@kernel.org [2.6.39]
---
 fs/nfs/inode.c    |    3 ++-
 fs/nfs/internal.h |   11 +++++++++++
 fs/nfs/nfs4proc.c |   33 +++++++++++++++++++++++----------
 3 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 144f2a3..d24984b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -256,7 +256,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 
 	nfs_attr_check_mountpoint(sb, fattr);
 
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 && (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0)
+	if (((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0) &&
+	    !nfs_attr_use_mounted_on_fileid(fattr))
 		goto out_no_inode;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1ff5820..31e8b50 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -45,6 +45,17 @@ static inline void nfs_attr_check_mountpoint(struct super_block *parent, struct
 		fattr->valid |= NFS_ATTR_FATTR_MOUNTPOINT;
 }
 
+static inline int nfs_attr_use_mounted_on_fileid(struct nfs_fattr *fattr)
+{
+	if (((fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID) == 0) ||
+	    (((fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0) &&
+	     ((fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) == 0)))
+		return 0;
+
+	fattr->fileid = fattr->mounted_on_fileid;
+	return 1;
+}
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 59fc918..eb8a211 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2283,12 +2283,14 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	return nfs4_map_errors(status);
 }
 
+static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 /*
  * Get locations and (maybe) other attributes of a referral.
  * Note that we'll actually follow the referral later when
  * we detect fsid mismatch in inode revalidation
  */
-static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+static int nfs4_get_referral(struct inode *dir, const struct qstr *name,
+			     struct nfs_fattr *fattr, struct nfs_fh *fhandle)
 {
 	int status = -ENOMEM;
 	struct page *page = NULL;
@@ -2306,15 +2308,16 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
 	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
-		dprintk("%s: server did not return a different fsid for a referral at %s\n", __func__, name->name);
+		dprintk("%s: server did not return a different fsid for"
+			" a referral at %s\n", __func__, name->name);
 		status = -EIO;
 		goto out;
 	}
+	/* Fixup attributes for the nfs_lookup() call to nfs_fhget() */
+	nfs_fixup_referral_attributes(&locations->fattr);
 
+	/* replace the lookup nfs_fattr with the locations nfs_fattr */
 	memcpy(fattr, &locations->fattr, sizeof(struct nfs_fattr));
-	fattr->valid |= NFS_ATTR_FATTR_V4_REFERRAL;
-	if (!fattr->mode)
-		fattr->mode = S_IFDIR;
 	memset(fhandle, 0, sizeof(struct nfs_fh));
 out:
 	if (page)
@@ -4699,11 +4702,15 @@ static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
 	return len;
 }
 
+/*
+ * nfs_fhget will use either the mounted_on_fileid or the fileid
+ */
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
-	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
-		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
-		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
+	if (!(((fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID) ||
+	       (fattr->valid & NFS_ATTR_FATTR_FILEID)) &&
+	      (fattr->valid & NFS_ATTR_FATTR_FSID) &&
+	      (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
 		return;
 
 	fattr->valid |= NFS_ATTR_FATTR_TYPE | NFS_ATTR_FATTR_MODE |
@@ -4718,7 +4725,6 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	struct nfs_server *server = NFS_SERVER(dir);
 	u32 bitmask[2] = {
 		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
-		[1] = FATTR4_WORD1_MOUNTED_ON_FILEID,
 	};
 	struct nfs4_fs_locations_arg args = {
 		.dir_fh = NFS_FH(dir),
@@ -4737,11 +4743,18 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	int status;
 
 	dprintk("%s: start\n", __func__);
+
+	/* Ask for the fileid of the absent filesystem if mounted_on_fileid
+	 * is not supported */
+	if (NFS_SERVER(dir)->attr_bitmask[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)
+		bitmask[1] |= FATTR4_WORD1_MOUNTED_ON_FILEID;
+	else
+		bitmask[0] |= FATTR4_WORD0_FILEID;
+
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
-	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
-- 
1.7.3.1

