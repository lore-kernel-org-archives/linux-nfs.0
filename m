Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64472 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab2BWSfb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 13:35:31 -0500
Received: by yhoo21 with SMTP id o21so761972yho.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 10:35:30 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: add support for per-file layout_types attribute
Date: Thu, 23 Feb 2012 10:35:25 -0800
Message-Id: <1330022125-15809-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, just return the same per-fs layout types

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4xdr.c    |    3 ++-
 fs/nfsd/nfsd.h       |    2 +-
 include/linux/nfs4.h |    1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f2e4ec3..38a957b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2560,7 +2560,8 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 		WRITE64(stat.ino);
 	}
 #if defined(CONFIG_PNFSD)
-	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+	if ((bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) ||
+	    (bmval2 & FATTR4_WORD2_LAYOUT_TYPES)) {
 		struct super_block *sb = dentry->d_inode->i_sb;
 		int type = 0;
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 5d4b0e6..c262762 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -326,7 +326,7 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
 #if defined(CONFIG_PNFSD)
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
-	 FATTR4_WORD2_LAYOUT_BLKSIZE)
+	 FATTR4_WORD2_LAYOUT_TYPES | FATTR4_WORD2_LAYOUT_BLKSIZE)
 #else /* CONFIG_PNFSD */
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 97605bc..0ad26b5 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -542,6 +542,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
 #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
+#define FATTR4_WORD2_LAYOUT_TYPES       (1UL << 0)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 
 #define NFSPROC4_NULL 0
-- 
1.7.6.5

