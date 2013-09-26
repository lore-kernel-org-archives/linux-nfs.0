Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:48249 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:00 -0400
Received: by mail-qc0-f170.google.com with SMTP id m20so1048253qcx.29
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:00 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 31/49] pnfsd: add support for per-file layout_types attribute
Date: Thu, 26 Sep 2013 14:41:57 -0400
Message-Id: <1380220917-14099-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, just return the same per-fs layout types

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4xdr.c    | 3 ++-
 fs/nfsd/nfsd.h       | 2 +-
 include/linux/nfs4.h | 1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6781a33..1a50467 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2561,7 +2561,8 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 		WRITE64(stat.ino);
 	}
 #if defined(CONFIG_PNFSD)
-	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+	if ((bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) ||
+	    (bmval2 & FATTR4_WORD2_LAYOUT_TYPES)) {
 		struct super_block *sb = dentry->d_inode->i_sb;
 		int type = 0;
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d81db6e..87aa3aa 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -332,7 +332,7 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
 #if defined(CONFIG_PNFSD)
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT | \
-	 FATTR4_WORD2_LAYOUT_BLKSIZE)
+	 FATTR4_WORD2_LAYOUT_TYPES | FATTR4_WORD2_LAYOUT_BLKSIZE)
 #else /* CONFIG_PNFSD */
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 2c3aa9f..7f6e548 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -398,6 +398,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
 #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
+#define FATTR4_WORD2_LAYOUT_TYPES       (1UL << 0)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 17)
-- 
1.8.3.1

