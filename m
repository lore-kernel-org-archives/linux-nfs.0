Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990Ab1FCRQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jun 2011 13:16:23 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1: allow nfs_fhget to succeed with mounted on fileid
Date: Fri,  3 Jun 2011 10:36:52 -0400
Message-Id: <1307111812-2380-1-git-send-email-andros@netapp.com>
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

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c    |    4 +++-
 fs/nfs/internal.h |    7 +++++++
 fs/nfs/nfs4proc.c |    2 +-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 144f2a3..06b40e3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -256,7 +256,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 
 	nfs_attr_check_mountpoint(sb, fattr);
 
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 && (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0)
+	if (((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0 &&
+	    (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0) &&
+	    nfs_attr_check_mounted_on_fileid(fattr))
 		goto out_no_inode;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b9056cb..257139d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -45,6 +45,13 @@ static inline void nfs_attr_check_mountpoint(struct super_block *parent, struct
 		fattr->valid |= NFS_ATTR_FATTR_MOUNTPOINT;
 }
 
+static inline boolean nfs_attr_check_mounted_on_fileid(struct nfs_fattr *fattr)
+{
+	return (((fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID) == 0) ||
+		((fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0) &&
+		 (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) == 0);
+}
+
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2c4b59..9c6e391 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4669,7 +4669,7 @@ static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
 
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr)
 {
-	if (!((fattr->valid & NFS_ATTR_FATTR_FILEID) &&
+	if (!((fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID) &&
 		(fattr->valid & NFS_ATTR_FATTR_FSID) &&
 		(fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)))
 		return;
-- 
1.7.3.1

