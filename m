Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:18067 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757417AbbLBOkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 09:40:03 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC 1/4] nfs/nfsd: Move useful bitfield ops to a commonly accessible place
Date: Wed,  2 Dec 2015 09:39:50 -0500
Message-Id: <1449067193-53310-2-git-send-email-aweits@rit.edu>
In-Reply-To: <1449067193-53310-1-git-send-email-aweits@rit.edu>
References: <1449067193-53310-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So these may be used in nfsd as well

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 include/linux/nfs4.h    | 11 +++++++++++
 include/linux/nfs_xdr.h | 11 -----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e7e78537aea2..95ead47154ec 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -592,4 +592,15 @@ enum data_content4 {
 	NFS4_CONTENT_HOLE		= 1,
 };
 
+#define NFS4_OP_MAP_NUM_LONGS					\
+	DIV_ROUND_UP(LAST_NFS4_OP, 8 * sizeof(unsigned long))
+#define NFS4_OP_MAP_NUM_WORDS \
+	(NFS4_OP_MAP_NUM_LONGS * sizeof(unsigned long) / sizeof(u32))
+struct nfs4_op_map {
+	union {
+		unsigned long longs[NFS4_OP_MAP_NUM_LONGS];
+		u32 words[NFS4_OP_MAP_NUM_WORDS];
+	} u;
+};
+
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 570d630f98ae..7f11c487ab0f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1185,17 +1185,6 @@ struct pnfs_ds_commit_info {
 	struct pnfs_commit_bucket *buckets;
 };
 
-#define NFS4_OP_MAP_NUM_LONGS \
-	DIV_ROUND_UP(LAST_NFS4_OP, 8 * sizeof(unsigned long))
-#define NFS4_OP_MAP_NUM_WORDS \
-	(NFS4_OP_MAP_NUM_LONGS * sizeof(unsigned long) / sizeof(u32))
-struct nfs4_op_map {
-	union {
-		unsigned long longs[NFS4_OP_MAP_NUM_LONGS];
-		u32 words[NFS4_OP_MAP_NUM_WORDS];
-	} u;
-};
-
 struct nfs41_state_protection {
 	u32 how;
 	struct nfs4_op_map enforce;
-- 
2.6.3

