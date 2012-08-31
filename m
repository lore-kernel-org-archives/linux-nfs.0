Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47653 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab2HaQrO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 12:47:14 -0400
From: Namjae Jeon <linkinjeon@gmail.com>
To: bfields@fieldses.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        chris.mason@fusionio.com, sage@inktank.com, miklos@szeredi.hu,
        swhiteho@redhat.com, konishi.ryusuke@lab.ntt.co.jp, mfasheh@suse.com,
        jlbec@ejvilplan.org, jack@suse.cz, bpm@sgi.com, elder@kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-nilfs@vger.kernel.org, reiserfs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <linkinjeon@gmail.com>,
        Vivek Trivedi <vtrivedi018@gmail.com>
Subject: [PATCH] fs: encode_fh: return FILEID_INVALID if invalid fid_type
Date: Fri, 31 Aug 2012 12:46:41 -0400
Message-Id: <1346431601-3477-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is a follow up on below patch:

[PATCH] exportfs: add FILEID_INVALID to indicate invalid fid_type
https://patchwork.kernel.org/patch/1385131/

Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
---
 fs/btrfs/export.c   |    4 ++--
 fs/ceph/export.c    |    4 ++--
 fs/fuse/inode.c     |    2 +-
 fs/gfs2/export.c    |    4 ++--
 fs/isofs/export.c   |    4 ++--
 fs/nilfs2/namei.c   |    4 ++--
 fs/ocfs2/export.c   |    4 ++--
 fs/reiserfs/inode.c |    4 ++--
 fs/udf/namei.c      |    4 ++--
 fs/xfs/xfs_export.c |    4 ++--
 mm/cleancache.c     |    2 +-
 mm/shmem.c          |    2 +-
 12 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/btrfs/export.c b/fs/btrfs/export.c
index 614f34a..81ee29e 100644
--- a/fs/btrfs/export.c
+++ b/fs/btrfs/export.c
@@ -22,10 +22,10 @@ static int btrfs_encode_fh(struct inode *inode, u32 *fh, int *max_len,
 
 	if (parent && (len < BTRFS_FID_SIZE_CONNECTABLE)) {
 		*max_len = BTRFS_FID_SIZE_CONNECTABLE;
-		return 255;
+		return FILEID_INVALID;
 	} else if (len < BTRFS_FID_SIZE_NON_CONNECTABLE) {
 		*max_len = BTRFS_FID_SIZE_NON_CONNECTABLE;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	len  = BTRFS_FID_SIZE_NON_CONNECTABLE;
diff --git a/fs/ceph/export.c b/fs/ceph/export.c
index 8e1b60e..98bde89 100644
--- a/fs/ceph/export.c
+++ b/fs/ceph/export.c
@@ -79,7 +79,7 @@ static int ceph_encode_fh(struct inode *inode, u32 *rawfh, int *max_len,
 		if (parent_inode) {
 			/* nfsd wants connectable */
 			*max_len = connected_handle_length;
-			type = 255;
+			type = FILEID_INVALID;
 		} else {
 			dout("encode_fh %p\n", dentry);
 			fh->ino = ceph_ino(inode);
@@ -88,7 +88,7 @@ static int ceph_encode_fh(struct inode *inode, u32 *rawfh, int *max_len,
 		}
 	} else {
 		*max_len = handle_length;
-		type = 255;
+		type = FILEID_INVALID;
 	}
 	return type;
 }
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 2690a76..b787a6f 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -672,7 +672,7 @@ static int fuse_encode_fh(struct inode *inode, u32 *fh, int *max_len,
 
 	if (*max_len < len) {
 		*max_len = len;
-		return  255;
+		return  FILEID_INVALID;
 	}
 
 	nodeid = get_fuse_inode(inode)->nodeid;
diff --git a/fs/gfs2/export.c b/fs/gfs2/export.c
index e8ed6d4..f7a8092 100644
--- a/fs/gfs2/export.c
+++ b/fs/gfs2/export.c
@@ -37,10 +37,10 @@ static int gfs2_encode_fh(struct inode *inode, __u32 *p, int *len,
 
 	if (parent && (*len < GFS2_LARGE_FH_SIZE)) {
 		*len = GFS2_LARGE_FH_SIZE;
-		return 255;
+		return FILEID_INVALID;
 	} else if (*len < GFS2_SMALL_FH_SIZE) {
 		*len = GFS2_SMALL_FH_SIZE;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	fh[0] = cpu_to_be32(ip->i_no_formal_ino >> 32);
diff --git a/fs/isofs/export.c b/fs/isofs/export.c
index 1d38044..5e693b3 100644
--- a/fs/isofs/export.c
+++ b/fs/isofs/export.c
@@ -125,10 +125,10 @@ isofs_export_encode_fh(struct inode *inode,
 	 */
 	if (parent && (len < 5)) {
 		*max_len = 5;
-		return 255;
+		return FILEID_INVALID;
 	} else if (len < 3) {
 		*max_len = 3;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	len = 3;
diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 1d0c0b8..9de78f0 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -517,11 +517,11 @@ static int nilfs_encode_fh(struct inode *inode, __u32 *fh, int *lenp,
 
 	if (parent && *lenp < NILFS_FID_SIZE_CONNECTABLE) {
 		*lenp = NILFS_FID_SIZE_CONNECTABLE;
-		return 255;
+		return FILEID_INVALID;
 	}
 	if (*lenp < NILFS_FID_SIZE_NON_CONNECTABLE) {
 		*lenp = NILFS_FID_SIZE_NON_CONNECTABLE;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	fid->cno = root->cno;
diff --git a/fs/ocfs2/export.c b/fs/ocfs2/export.c
index 322216a..2965116 100644
--- a/fs/ocfs2/export.c
+++ b/fs/ocfs2/export.c
@@ -195,11 +195,11 @@ static int ocfs2_encode_fh(struct inode *inode, u32 *fh_in, int *max_len,
 
 	if (parent && (len < 6)) {
 		*max_len = 6;
-		type = 255;
+		type = FILEID_INVALID;
 		goto bail;
 	} else if (len < 3) {
 		*max_len = 3;
-		type = 255;
+		type = FILEID_INVALID;
 		goto bail;
 	}
 
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index 855da58..1a212ed 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -1599,10 +1599,10 @@ int reiserfs_encode_fh(struct inode *inode, __u32 * data, int *lenp,
 
 	if (parent && (maxlen < 5)) {
 		*lenp = 5;
-		return 255;
+		return FILEID_INVALID;
 	} else if (maxlen < 3) {
 		*lenp = 3;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	data[0] = inode->i_ino;
diff --git a/fs/udf/namei.c b/fs/udf/namei.c
index 95fee27..102c072 100644
--- a/fs/udf/namei.c
+++ b/fs/udf/namei.c
@@ -1270,10 +1270,10 @@ static int udf_encode_fh(struct inode *inode, __u32 *fh, int *lenp,
 
 	if (parent && (len < 5)) {
 		*lenp = 5;
-		return 255;
+		return FILEID_INVALID;
 	} else if (len < 3) {
 		*lenp = 3;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	*lenp = 3;
diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
index 4267922..a5a4e52 100644
--- a/fs/xfs/xfs_export.c
+++ b/fs/xfs/xfs_export.c
@@ -47,7 +47,7 @@ static int xfs_fileid_length(int fileid_type)
 	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
 		return 6;
 	}
-	return 255; /* invalid */
+	return FILEID_INVALID; /* invalid */
 }
 
 STATIC int
@@ -89,7 +89,7 @@ xfs_fs_encode_fh(
 	len = xfs_fileid_length(fileid_type);
 	if (*max_len < len) {
 		*max_len = len;
-		return 255;
+		return FILEID_INVALID;
 	}
 	*max_len = len;
 
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 32e6f41..d76ba74 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -89,7 +89,7 @@ static int cleancache_get_key(struct inode *inode,
 		fhfn = sb->s_export_op->encode_fh;
 		if  (fhfn) {
 			len = (*fhfn)(inode, &key->u.fh[0], &maxlen, NULL);
-			if (len <= 0 || len == 255)
+			if (len <= FILEID_ROOT || len == FILEID_INVALID)
 				return -1;
 			if (maxlen > CLEANCACHE_KEY_MAX)
 				return -1;
diff --git a/mm/shmem.c b/mm/shmem.c
index 1d04904..5cbae30 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2386,7 +2386,7 @@ static int shmem_encode_fh(struct inode *inode, __u32 *fh, int *len,
 {
 	if (*len < 3) {
 		*len = 3;
-		return 255;
+		return FILEID_INVALID;
 	}
 
 	if (inode_unhashed(inode)) {
-- 
1.7.9.5

