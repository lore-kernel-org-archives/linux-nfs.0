Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34373 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933063AbcFOSd0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 14:33:26 -0400
Received: by mail-yw0-f196.google.com with SMTP id b75so2726799ywe.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 11:33:20 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] pnfs: add a new mechanism to select a layout driver according to an ordered list
Date: Wed, 15 Jun 2016 14:33:11 -0400
Message-Id: <1466015591-23818-4-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1466015591-23818-1-git-send-email-jlayton@poochiereds.net>
References: <1466015591-23818-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the layout driver selection code always chooses the first one
from the list. That's not really ideal however, as the server can send
the list of layout types in any order that it likes. It's up to the
client to select the best one for its needs.

This patch adds an ordered list of preferred driver types and has the
selection code sort the list of avaiable layout drivers according to it.
Any unrecognized layout type is sorted to the end of the list.

For now, the order of preference is hardcoded, but it should be possible
to make this configurable in the future.

Signed-off-by: Jeff Layton <jlayton@poochiereds.net>
---
 fs/nfs/client.c         |  1 +
 fs/nfs/nfs4proc.c       |  3 ++-
 fs/nfs/nfs4xdr.c        | 29 +++++++++++++++-----------
 fs/nfs/pnfs.c           | 54 +++++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/pnfs.h           |  5 +++--
 include/linux/nfs_xdr.h |  1 +
 6 files changed, 70 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 067f489aab3f..2525d8f770d2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -787,6 +787,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	}
 
 	fsinfo.fattr = fattr;
+	fsinfo.nlayouttypes = 0;
 	memset(fsinfo.layouttype, 0, sizeof(fsinfo.layouttype));
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index de97567795a5..a1d6d4bd0d50 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4252,7 +4252,8 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
 	if (error == 0) {
 		/* block layout checks this! */
 		server->pnfs_blksize = fsinfo->blksize;
-		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
+		set_pnfs_layoutdriver(server, fhandle, fsinfo->nlayouttypes,
+					fsinfo->layouttype);
 	}
 
 	return error;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b2c698499ad9..4eee3a32e070 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4723,28 +4723,32 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
  * Decode potentially multiple layout types.
  */
 static int decode_pnfs_layout_types(struct xdr_stream *xdr,
-					 uint32_t *layouttype)
+				uint32_t *nlayouttypes, uint32_t *layouttype)
 {
 	__be32 *p;
-	uint32_t num, i;
+	uint32_t i;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	num = be32_to_cpup(p);
+	*nlayouttypes = be32_to_cpup(p);
 
 	/* pNFS is not supported by the underlying file system */
-	if (num == 0) {
+	if (*nlayouttypes == 0)
 		return 0;
-	}
-	if (num > NFS_MAX_LAYOUT_TYPES)
-		printk(KERN_INFO "NFS: %s: Warning: Too many (%d) pNFS layout types\n", __func__, num);
 
 	/* Decode and set first layout type, move xdr->p past unused types */
-	p = xdr_inline_decode(xdr, num * 4);
+	p = xdr_inline_decode(xdr, *nlayouttypes * 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++)
+
+	/* If we get too many, then just cap it at the max */
+	if (*nlayouttypes > NFS_MAX_LAYOUT_TYPES) {
+		printk(KERN_INFO "NFS: %s: Warning: Too many (%u) pNFS layout types\n", __func__, *nlayouttypes);
+		*nlayouttypes = NFS_MAX_LAYOUT_TYPES;
+	}
+
+	for(i = 0; i < *nlayouttypes; ++i)
 		layouttype[i] = be32_to_cpup(p++);
 	return 0;
 out_overflow:
@@ -4757,7 +4761,7 @@ out_overflow:
  * Note we must ensure that layouttype is set in any non-error case.
  */
 static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
-				uint32_t *layouttype)
+				uint32_t *nlayouttypes, uint32_t *layouttype)
 {
 	int status = 0;
 
@@ -4765,7 +4769,7 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
 		return -EIO;
 	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
-		status = decode_pnfs_layout_types(xdr, layouttype);
+		status = decode_pnfs_layout_types(xdr, nlayouttypes, layouttype);
 		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
 	}
 	return status;
@@ -4848,7 +4852,8 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
 	if (status != 0)
 		goto xdr_error;
-	status = decode_attr_pnfstype(xdr, bitmap, fsinfo->layouttype);
+	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->nlayouttypes,
+					fsinfo->layouttype);
 	if (status != 0)
 		goto xdr_error;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fc1b9354345..11e56225e6d2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -30,6 +30,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 #include <linux/module.h>
+#include <linux/sort.h>
 #include "internal.h"
 #include "pnfs.h"
 #include "iostat.h"
@@ -99,6 +100,38 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
 }
 
 /*
+ * When the server sends a list of layout types, we choose one in the order
+ * given in the list below.
+ *
+ * FIXME: should this list be configurable via module_param or mount option?
+ */
+static const u32 ld_prefs[] = {
+	LAYOUT_SCSI,
+	LAYOUT_BLOCK_VOLUME,
+	LAYOUT_OSD2_OBJECTS,
+	LAYOUT_FLEX_FILES,
+	LAYOUT_NFSV4_1_FILES,
+	0
+};
+
+static int
+ld_cmp(const void *e1, const void *e2)
+{
+	u32 ld1 = *((u32 *)e1);
+	u32 ld2 = *((u32 *)e2);
+	int i;
+
+	for (i = 0; ld_prefs[i] != 0; i++) {
+		if (ld1 == ld_prefs[i])
+			return -1;
+
+		if (ld2 == ld_prefs[i])
+			return 1;
+	}
+	return 0;
+}
+
+/*
  * Try to set the server's pnfs module to the pnfs layout type specified by id.
  * Currently only one pNFS layout driver per filesystem is supported.
  *
@@ -106,10 +139,11 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
  */
 void
 set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
-		      u32 *ids)
+		      u32 nids, u32 *ids)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 	u32 id;
+	int i;
 
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
@@ -118,18 +152,22 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		goto out_no_driver;
 	}
 
-	id = ids[0];
-	if (!id)
-		goto out_no_driver;
+	sort(ids, nids, sizeof(*ids), ld_cmp, NULL);
 
-	ld_type = find_pnfs_driver(id);
-	if (!ld_type) {
-		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+	for (i = 0; i < nids; i++) {
+		id = ids[i];
 		ld_type = find_pnfs_driver(id);
+		if (!ld_type) {
+			request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX,
+					id);
+			ld_type = find_pnfs_driver(id);
+		}
+		if (ld_type)
+			break;
 	}
 
 	if (!ld_type) {
-		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
+		dprintk("%s: No pNFS module found!\n", __func__);
 		goto out_no_driver;
 	}
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 500473c87e82..a879e747f708 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -236,7 +236,7 @@ void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
-void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32 *);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32, u32 *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
@@ -656,7 +656,8 @@ pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
 }
 
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
-					 const struct nfs_fh *mntfh, u32 *ids)
+					 const struct nfs_fh *mntfh,
+					 u32 nids, u32 *ids)
 {
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4eef590200c3..a7e6739ac936 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -144,6 +144,7 @@ struct nfs_fsinfo {
 	__u64			maxfilesize;
 	struct timespec		time_delta; /* server time granularity */
 	__u32			lease_time; /* in seconds */
+	__u32			nlayouttypes; /* number of layouttypes */
 	__u32			layouttype[NFS_MAX_LAYOUT_TYPES]; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
 	__u32			clone_blksize; /* granularity of a CLONE operation */
-- 
2.5.5

