Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34498 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbcFIMVO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 08:21:14 -0400
Received: by mail-yw0-f194.google.com with SMTP id j74so4506581ywg.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2016 05:21:14 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] pnfs: track multiple layout types in fsinfo structure
Date: Thu,  9 Jun 2016 08:21:04 -0400
Message-Id: <1465474865-15285-3-git-send-email-jlayton@poochiereds.net>
In-Reply-To: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
References: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jeff.layton@primarydata.com>

Current NFSv4.1/pNFS client assumes that MDS supports only one layout
type. While it's true for most existing servers, nevertheless, this can
be change in the near future.

For now, this patch just plumbs in the ability to track a list of
layouts in the fsinfo structure. The existing behavior of the client
is preserved, by having it just select the first entry in the list.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/client.c         |  2 +-
 fs/nfs/nfs4xdr.c        | 23 ++++++++++-------------
 fs/nfs/pnfs.c           | 27 ++++++++++++++++-----------
 fs/nfs/pnfs.h           |  4 ++--
 include/linux/nfs_xdr.h |  7 ++++++-
 5 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0c96528db94a..067f489aab3f 100644
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
index 661e753fe1c9..b2c698499ad9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4720,14 +4720,13 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
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
@@ -4736,18 +4735,17 @@ static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 
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
@@ -4767,10 +4765,9 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
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
 
@@ -4851,7 +4848,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
 	if (status != 0)
 		goto xdr_error;
-	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
+	status = decode_attr_pnfstype(xdr, bitmap, fsinfo->layouttype);
 	if (status != 0)
 		goto xdr_error;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c7e0d45a4de..2fc1b9354345 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -102,32 +102,37 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
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
+
+	id = ids[0];
+	if (!id)
+		goto out_no_driver;
+
 	ld_type = find_pnfs_driver(id);
 	if (!ld_type) {
 		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
 		ld_type = find_pnfs_driver(id);
-		if (!ld_type) {
-			dprintk("%s: No pNFS module found for %u.\n",
-				__func__, id);
-			goto out_no_driver;
-		}
 	}
+
+	if (!ld_type) {
+		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
+		goto out_no_driver;
+	}
+
 	server->pnfs_curr_ld = ld_type;
 	if (ld_type->set_layoutdriver
 	    && ld_type->set_layoutdriver(server, mntfh)) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b21bd0bee784..500473c87e82 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -236,7 +236,7 @@ void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
-void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32 *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
@@ -656,7 +656,7 @@ pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
 }
 
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
-					 const struct nfs_fh *mntfh, u32 id)
+					 const struct nfs_fh *mntfh, u32 *ids)
 {
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c304a11b5b1a..4eef590200c3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -125,6 +125,11 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_V4_SECURITY_LABEL)
 
 /*
+ * Maximal number of supported layout drivers.
+ */
+#define NFS_MAX_LAYOUT_TYPES 8
+
+/*
  * Info on the file system
  */
 struct nfs_fsinfo {
@@ -139,7 +144,7 @@ struct nfs_fsinfo {
 	__u64			maxfilesize;
 	struct timespec		time_delta; /* server time granularity */
 	__u32			lease_time; /* in seconds */
-	__u32			layouttype; /* supported pnfs layout driver */
+	__u32			layouttype[NFS_MAX_LAYOUT_TYPES]; /* supported pnfs layout driver */
 	__u32			blksize; /* preferred pnfs io block size */
 	__u32			clone_blksize; /* granularity of a CLONE operation */
 };
-- 
2.5.5

