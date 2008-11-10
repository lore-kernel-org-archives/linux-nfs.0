From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 39/51] nfsd41: SUPPATTR_EXCLCREAT attribute
Date: Mon, 10 Nov 2008 22:54:04 +0200
Message-ID: <1226350444-11579-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57436 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbYKJUyR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:54:17 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return bitmask for supported EXCLUSIVE4_1 create attributes.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c         |    9 ++++++++-
 include/linux/nfs4.h      |    2 ++
 include/linux/nfsd/nfsd.h |   16 +++++++++++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 89e7b0d..227434c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2180,7 +2180,14 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
-	BUG_ON(bmval2);	/* FIXME: not implemented yet */
+#if defined(CONFIG_NFSD_V4_1)
+	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
+		WRITE32(3);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index be4af09..5471adf 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -386,6 +386,8 @@ enum lock_type4 {
 #define FATTR4_WORD0_UNIQUE_HANDLES     (1UL << 9)
 #define FATTR4_WORD0_LEASE_TIME         (1UL << 10)
 #define FATTR4_WORD0_RDATTR_ERROR       (1UL << 11)
+/* Mandatory in NFSv4.1 */
+#define FATTR4_WORD2_SUPPATTR_EXCLCREAT (1UL << 11)
 
 /* Recommended Attributes */
 #define FATTR4_WORD0_ACL                (1UL << 12)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 46b8110..2e763eb 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -351,7 +351,7 @@ extern struct timeval	nfssvc_boot;
 	NFSD4_SUPPORTED_ATTRS_WORD1
 
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
-	NFSD4_SUPPORTED_ATTRS_WORD2
+	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
@@ -399,6 +399,20 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
  | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
 #define NFSD_WRITEABLE_ATTRS_WORD2 0
 
+#if defined(CONFIG_NFSD_V4_1)
+#define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
+	NFSD_WRITEABLE_ATTRS_WORD0
+/*
+ * we currently store the exclusive create verifier in the v_{a,m}time
+ * attributes so the client can't set these at create time using EXCLUSIVE4_1
+ */
+#define NFSD_SUPPATTR_EXCLCREAT_WORD1 \
+	(NFSD_WRITEABLE_ATTRS_WORD1 & \
+	 ~(FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET))
+#define NFSD_SUPPATTR_EXCLCREAT_WORD2 \
+	NFSD_WRITEABLE_ATTRS_WORD2
+#endif /* CONFIG_NFSD_V4_1 */
+
 #endif /* CONFIG_NFSD_V4 */
 
 #endif /* LINUX_NFSD_NFSD_H */
-- 
1.6.0.2

