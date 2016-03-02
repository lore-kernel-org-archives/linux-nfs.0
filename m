Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:44970 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbcCBN6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2016 08:58:05 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id C18B9280A3C
	for <linux-nfs@vger.kernel.org>; Wed,  2 Mar 2016 14:58:02 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id B362013EAE
	for <linux-nfs@vger.kernel.org>; Wed,  2 Mar 2016 14:58:02 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] pnfs  support servers with multiple layout types
Date: Wed,  2 Mar 2016 14:57:59 +0100
Message-Id: <1456927079-4788-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1456920492-22533-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1456920492-22533-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

current NFSv4.1/pNFS client assumes that MDS supports
only one layout type. While it's true for most existing servers,
nevertheless, this can be change in the near future.

This patch is an attempt to multi layouttype MDS support. To make
it possible for such servers to function with existing clients,
server must always send default layout type first in the list. The
client starts processing layout types starting from the second element
and will fall back to the wfirst one, if none of presented types
is supported.

Testing done:

  - started a server with nfs4_file and flex_file layout
  - new kernel picked flexr_-file layout
  - old complained about multiple layout types and proceeded  nfs4_file layout

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/client.c         |  2 +-
 fs/nfs/nfs4xdr.c        | 23 ++++++++++-------------
 fs/nfs/pnfs.c           | 45 ++++++++++++++++++++++++++++++++-------------
 fs/nfs/pnfs.h           |  4 ++--
 include/linux/nfs_xdr.h |  8 +++++++-
 5 files changed, 52 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d6d5d2a..ec8e7db 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -787,7 +787,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	}
 
 	fsinfo.fattr = fattr;
-	fsinfo.layouttype = 0;
+	memset(fsinfo.layouttype, 0, sizeof(fsinfo.layouttype));
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
 		goto out_error;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e44412..ac8747b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4702,14 +4702,13 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
 }
 
 /*
- * Decode potentially multiple layout types. Currently we only support
- * one layout driver per file system.
+ * Decode potentially multiple layout types.
  */
-static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
+static int decode_pnfs_layout_types(struct xdr_stream *xdr,
 					 uint32_t *layouttype)
 {
 	__be32 *p;
-	int num;
+	uint32_t num, i;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
@@ -4718,18 +4717,17 @@ static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 
 	/* pNFS is not supported by the underlying file system */
 	if (num == 0) {
-		*layouttype = 0;
 		return 0;
 	}
-	if (num > 1)
-		printk(KERN_INFO "NFS: %s: Warning: Multiple pNFS layout "
-			"drivers per filesystem not supported\n", __func__);
+	if (num > NFS_MAX_LAYOUT_TYPES)
+		printk(KERN_INFO "NFS: %s: Warning: Too many (%d) pNFS layout types\n", __func__, num);
 
 	/* Decode and set first layout type, move xdr->p past unused types */
 	p = xdr_inline_decode(xdr, num * 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	*layouttype = be32_to_cpup(p);
+	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++)
+		layouttype[i] = be32_to_cpup(p++);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -4749,10 +4747,9 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
 		return -EIO;
 	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
-		status = decode_first_pnfs_layout_type(xdr, layouttype);
+		status = decode_pnfs_layout_types(xdr, layouttype);
 		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
-	} else
-		*layouttype = 0;
+	}
 	return status;
 }
 
@@ -4833,7 +4830,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
 	if (status != 0)
 		goto xdr_error;
-	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
+	status = decode_attr_pnfstype(xdr, bitmap, fsinfo->layouttype);
 	if (status != 0)
 		goto xdr_error;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fa483e..6b3b67a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -102,32 +102,51 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
  * Try to set the server's pnfs module to the pnfs layout type specified by id.
  * Currently only one pNFS layout driver per filesystem is supported.
  *
- * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
+ * @ids array of layout types supported by MDS.
  */
 void
 set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
-		      u32 id)
+		      u32 *ids)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
+	u32 id;
+	int i;
 
-	if (id == 0)
-		goto out_no_driver;
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
-		printk(KERN_ERR "NFS: %s: id %u cl_exchange_flags 0x%x\n",
-			__func__, id, server->nfs_client->cl_exchange_flags);
+		printk(KERN_ERR "NFS: %s: cl_exchange_flags 0x%x\n",
+			__func__, server->nfs_client->cl_exchange_flags);
 		goto out_no_driver;
 	}
-	ld_type = find_pnfs_driver(id);
-	if (!ld_type) {
+	/*
+	 * If server supports more than one layout types.
+	 * By assuming, that server will put 'common default' as the first
+	 * entry, try all following entries ibefore and fall back to the default
+	 * if we did not found a matching one.
+	 */
+	for(i = 1; i < NFS_MAX_LAYOUT_TYPES && ids[i] != 0; i++) {
+		id = ids[i];
 		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
 		ld_type = find_pnfs_driver(id);
-		if (!ld_type) {
-			dprintk("%s: No pNFS module found for %u.\n",
-				__func__, id);
-			goto out_no_driver;
-		}
+		if(ld_type)
+			goto found_module;
+
+		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
+	}
+
+	/*
+	 * no other layout types found. Try default one.
+	 */
+	id = ids[0];
+	request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+	ld_type = find_pnfs_driver(id);
+
+	if (!ld_type) {
+		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
+		goto out_no_driver;
 	}
+
+found_module:
 	server->pnfs_curr_ld = ld_type;
 	if (ld_type->set_layoutdriver
 	    && ld_type->set_layoutdriver(server, mntfh)) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1ac1db5..bfb5f3f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -234,7 +234,7 @@ void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
-void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32 *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
@@ -655,7 +655,7 @@ pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
 }
 
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
-					 const struct nfs_fh *mntfh, u32 id)
+					 const struct nfs_fh *mntfh, u32 *ids)
 {
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d320906..e45bcb9 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -125,6 +125,12 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_V4_SECURITY_LABEL)
 
 /*
+ * Maximal number of supported layout drivers.
+ */
+#define NFS_MAX_LAYOUT_TYPES 8
+
+
+/*
  * Info on the file system
  */
 struct nfs_fsinfo {
@@ -139,7 +145,7 @@ struct nfs_fsinfo {
 	__u64			maxfilesize;
 	struct timespec		time_delta; /* server time granularity */
 	__u32			lease_time; /* in seconds */
-	__u32			layouttype; /* supported pnfs layout driver */
+	__u32			layouttype[NFS_MAX_LAYOUT_TYPES]; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
 	__u32			clone_blksize; /* granularity of a CLONE operation */
 };
-- 
2.5.0

