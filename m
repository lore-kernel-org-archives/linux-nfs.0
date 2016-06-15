Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:19650 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932772AbcFOQ65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 12:58:57 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3 1/3] nfs/nfsd: Move useful bitfield ops to a commonly accessible place
Date: Wed, 15 Jun 2016 12:52:07 -0400
Message-Id: <1466009529-3421-2-git-send-email-aweits@rit.edu>
In-Reply-To: <1466009529-3421-1-git-send-email-aweits@rit.edu>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So these may be used in nfsd as well

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 include/linux/nfs4.h    | 11 +++++++++++
 include/linux/nfs_xdr.h | 11 -----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index bfed6b367350..c6564ada9beb 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -643,4 +643,15 @@ enum pnfs_update_layout_reason {
 	PNFS_UPDATE_LAYOUT_SEND_LAYOUTGET,
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
index c304a11b5b1a..e66abc2d1f88 100644
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

