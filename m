Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33012 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932818AbcFOSdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 14:33:23 -0400
Received: by mail-yw0-f193.google.com with SMTP id h185so2725899ywc.0
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 11:33:18 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/3] nfsd: allow nfsd to advertise multiple layout types
Date: Wed, 15 Jun 2016 14:33:09 -0400
Message-Id: <1466015591-23818-2-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1466015591-23818-1-git-send-email-jlayton@poochiereds.net>
References: <1466015591-23818-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the underlying filesystem supports multiple layout types, then there
is little reason not to advertise that fact to clients and let them
choose what type to use.

Turn the ex_layout_type field into a bitfield. For each supported
layout type, we set a bit in that field. When the client requests a
layout, ensure that the bit for that layout type is set. When the
client requests attributes, send back a list of supported types.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
Reviewed-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfsd/export.c      |  4 ++--
 fs/nfsd/export.h      |  2 +-
 fs/nfsd/nfs4layouts.c |  6 +++---
 fs/nfsd/nfs4proc.c    |  4 ++--
 fs/nfsd/nfs4xdr.c     | 30 ++++++++++++++----------------
 5 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b4d84b579f20..f97ba49d5e66 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -706,7 +706,7 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
-	new->ex_layout_type = 0;
+	new->ex_layout_types = 0;
 	new->ex_uuid = NULL;
 	new->cd = item->cd;
 }
@@ -731,7 +731,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 	item->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = item->ex_fslocs.migrated;
 	item->ex_fslocs.migrated = 0;
-	new->ex_layout_type = item->ex_layout_type;
+	new->ex_layout_types = item->ex_layout_types;
 	new->ex_nflavors = item->ex_nflavors;
 	for (i = 0; i < MAX_SECINFO_LIST; i++) {
 		new->ex_flavors[i] = item->ex_flavors[i];
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 2e315072bf3f..730f15eeb7ed 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -57,7 +57,7 @@ struct svc_export {
 	struct nfsd4_fs_locations ex_fslocs;
 	uint32_t		ex_nflavors;
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
-	enum pnfs_layouttype	ex_layout_type;
+	u32			ex_layout_types;
 	struct nfsd4_deviceid_map *ex_devid_map;
 	struct cache_detail	*cd;
 };
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6d98d16b3354..2be9602b0221 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -139,21 +139,21 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
 	 * otherwise advertise the block layout.
 	 */
 #ifdef CONFIG_NFSD_FLEXFILELAYOUT
-	exp->ex_layout_type = LAYOUT_FLEX_FILES;
+	exp->ex_layout_types |= 1 << LAYOUT_FLEX_FILES;
 #endif
 #ifdef CONFIG_NFSD_BLOCKLAYOUT
 	/* overwrite flex file layout selection if needed */
 	if (sb->s_export_op->get_uuid &&
 	    sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks)
-		exp->ex_layout_type = LAYOUT_BLOCK_VOLUME;
+		exp->ex_layout_types |= 1 << LAYOUT_BLOCK_VOLUME;
 #endif
 #ifdef CONFIG_NFSD_SCSILAYOUT
 	/* overwrite block layout selection if needed */
 	if (sb->s_export_op->map_blocks &&
 	    sb->s_export_op->commit_blocks &&
 	    sb->s_bdev && sb->s_bdev->bd_disk->fops->pr_ops)
-		exp->ex_layout_type = LAYOUT_SCSI;
+		exp->ex_layout_types |= 1 << LAYOUT_SCSI;
 #endif
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2ee2dc170327..719c620753e2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1219,12 +1219,12 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 static const struct nfsd4_layout_ops *
 nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
 {
-	if (!exp->ex_layout_type) {
+	if (!exp->ex_layout_types) {
 		dprintk("%s: export does not support pNFS\n", __func__);
 		return NULL;
 	}
 
-	if (exp->ex_layout_type != layout_type) {
+	if (!(exp->ex_layout_types & (1 << layout_type))) {
 		dprintk("%s: layout type %d not supported\n",
 			__func__, layout_type);
 		return NULL;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9df898ba648f..4d3ae75ad4c8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2164,22 +2164,20 @@ nfsd4_encode_aclname(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 }
 
 static inline __be32
-nfsd4_encode_layout_type(struct xdr_stream *xdr, enum pnfs_layouttype layout_type)
+nfsd4_encode_layout_types(struct xdr_stream *xdr, u32 layout_types)
 {
-	__be32 *p;
+	__be32		*p;
+	unsigned long	i = hweight_long(layout_types);
 
-	if (layout_type) {
-		p = xdr_reserve_space(xdr, 8);
-		if (!p)
-			return nfserr_resource;
-		*p++ = cpu_to_be32(1);
-		*p++ = cpu_to_be32(layout_type);
-	} else {
-		p = xdr_reserve_space(xdr, 4);
-		if (!p)
-			return nfserr_resource;
-		*p++ = cpu_to_be32(0);
-	}
+	p = xdr_reserve_space(xdr, 4 + 4 * i);
+	if (!p)
+		return nfserr_resource;
+
+	*p++ = cpu_to_be32(i);
+
+	for (i = LAYOUT_NFSV4_1_FILES; i < LAYOUT_TYPE_MAX; ++i)
+		if (layout_types & (1 << i))
+			*p++ = cpu_to_be32(i);
 
 	return 0;
 }
@@ -2754,13 +2752,13 @@ out_acl:
 	}
 #ifdef CONFIG_NFSD_PNFS
 	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
-		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
+		status = nfsd4_encode_layout_types(xdr, exp->ex_layout_types);
 		if (status)
 			goto out;
 	}
 
 	if (bmval2 & FATTR4_WORD2_LAYOUT_TYPES) {
-		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
+		status = nfsd4_encode_layout_types(xdr, exp->ex_layout_types);
 		if (status)
 			goto out;
 	}
-- 
2.5.5

