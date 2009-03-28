From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 45/47] nfsd41: SUPPATTR_EXCLCREAT attribute
Date: Sat, 28 Mar 2009 11:35:15 +0300
Message-ID: <1238229315-11675-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1232 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754358AbZC1IfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:35:21 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return bitmask for supported EXCLUSIVE4_1 create attributes.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c         |    7 ++++++-
 include/linux/nfs4.h      |    2 ++
 include/linux/nfsd/nfsd.h |   14 +++++++++++++-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 079626c..288332c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2154,7 +2154,12 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
-	BUG_ON(bmval2);	/* FIXME: not implemented yet */
+	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
+		WRITE32(3);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD1);
+		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
+	}
 
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a34683e..735c7d8 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -404,6 +404,8 @@ enum lock_type4 {
 #define FATTR4_WORD0_UNIQUE_HANDLES     (1UL << 9)
 #define FATTR4_WORD0_LEASE_TIME         (1UL << 10)
 #define FATTR4_WORD0_RDATTR_ERROR       (1UL << 11)
+/* Mandatory in NFSv4.1 */
+#define FATTR4_WORD2_SUPPATTR_EXCLCREAT (1UL << 11)
 
 /* Recommended Attributes */
 #define FATTR4_WORD0_ACL                (1UL << 12)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 3dccb76..b9e6682 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -374,7 +374,7 @@ extern struct timeval	nfssvc_boot;
 	NFSD4_SUPPORTED_ATTRS_WORD1
 
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
-	NFSD4_SUPPORTED_ATTRS_WORD2
+	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
 #if defined(CONFIG_NFSD_V4_1)
 
@@ -427,6 +427,18 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
  | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
 #define NFSD_WRITEABLE_ATTRS_WORD2 0
 
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
+
 #endif /* CONFIG_NFSD_V4 */
 
 #endif /* LINUX_NFSD_NFSD_H */
-- 
1.6.2.1

