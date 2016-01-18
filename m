Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:55194 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932164AbcARUIe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jan 2016 15:08:34 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, dros@primarydata.com, Andrew Elble <aweits@rit.edu>
Subject: [PATCH v2 1/3] nfs/nfsd: Move useful bitfield ops to a commonly accessible place
Date: Mon, 18 Jan 2016 15:08:20 -0500
Message-Id: <1453147702-42961-2-git-send-email-aweits@rit.edu>
In-Reply-To: <1453147702-42961-1-git-send-email-aweits@rit.edu>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
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
index 11bbae44f4cb..f24f3d3164a2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1186,17 +1186,6 @@ struct pnfs_ds_commit_info {
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

