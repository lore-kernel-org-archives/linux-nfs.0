Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752197AbcIOSkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Sep 2016 14:40:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, tigran.mkrtchyan@desy.de
Subject: [PATCH v4 resend 2/2] pnfs: add a new mechanism to select a layout driver according to an ordered list
Date: Thu, 15 Sep 2016 14:40:49 -0400
Message-Id: <1473964849-3194-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473964849-3194-1-git-send-email-jlayton@redhat.com>
References: <1473964849-3194-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the layout driver selection code always chooses the first one
from the list. That's not really ideal however, as the server can send
the list of layout types in any order that it likes. It's up to the
client to select the best one for its needs.

This patch adds an ordered list of preferred driver types and has the
selection code sort the list of available layout drivers according to it.
Any unrecognized layout type is sorted to the end of the list.

For now, the order of preference is hardcoded, but it should be possible
to make this configurable in the future.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/nfs/client.c         |  1 +
 fs/nfs/nfs4proc.c       |  2 +-
 fs/nfs/nfs4xdr.c        | 31 +++++++++++++++------------
 fs/nfs/pnfs.c           | 56 ++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/pnfs.h           |  5 +++--
 include/linux/nfs_xdr.h |  1 +
 6 files changed, 72 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0c1b3a002dc2..31b03375a039 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -785,6 +785,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	}
 
 	fsinfo.fattr = fattr;
+	fsinfo.nlayouttypes = 0;
 	memset(fsinfo.layouttype, 0, sizeof(fsinfo.layouttype));
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dd19ab986b80..1e45952e44f6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4312,7 +4312,7 @@ static int nfs4_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, s
 	if (error == 0) {
 		/* block layout checks this! */
 		server->pnfs_blksize = fsinfo->blksize;
-		set_pnfs_layoutdriver(server, fhandle, fsinfo->layouttype);
+		set_pnfs_layoutdriver(server, fhandle, fsinfo);
 	}
 
 	return error;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 41a02f994976..17b4e059c588 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4728,29 +4728,34 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr,
  * Decode potentially multiple layout types.
  */
 static int decode_pnfs_layout_types(struct xdr_stream *xdr,
-					 uint32_t *layouttype)
+				    struct nfs_fsinfo *fsinfo)
 {
 	__be32 *p;
-	uint32_t num, i;
+	uint32_t i;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	num = be32_to_cpup(p);
+	fsinfo->nlayouttypes = be32_to_cpup(p);
 
 	/* pNFS is not supported by the underlying file system */
-	if (num == 0) {
+	if (fsinfo->nlayouttypes == 0)
 		return 0;
-	}
-	if (num > NFS_MAX_LAYOUT_TYPES)
-		printk(KERN_INFO "NFS: %s: Warning: Too many (%d) pNFS layout types\n", __func__, num);
 
 	/* Decode and set first layout type, move xdr->p past unused types */
-	p = xdr_inline_decode(xdr, num * 4);
+	p = xdr_inline_decode(xdr, fsinfo->nlayouttypes * 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++)
-		layouttype[i] = be32_to_cpup(p++);
+
+	/* If we get too many, then just cap it at the max */
+	if (fsinfo->nlayouttypes > NFS_MAX_LAYOUT_TYPES) {
+		printk(KERN_INFO "NFS: %s: Warning: Too many (%u) pNFS layout types\n",
+			__func__, fsinfo->nlayouttypes);
+		fsinfo->nlayouttypes = NFS_MAX_LAYOUT_TYPES;
+	}
+
+	for(i = 0; i < fsinfo->nlayouttypes; ++i)
+		fsinfo->layouttype[i] = be32_to_cpup(p++);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -4762,7 +4767,7 @@ out_overflow:
  * Note we must ensure that layouttype is set in any non-error case.
  */
 static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
-				uint32_t *layouttype)
+				struct nfs_fsinfo *fsinfo)
 {
 	int status = 0;
 
@@ -4770,7 +4775,7 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
 		return -EIO;
 	if (bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES) {
-		status = decode_pnfs_layout_types(xdr, layouttype);
+		status = decode_pnfs_layout_types(xdr, fsinfo);
 		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
 	}
 	return status;
@@ -4853,7 +4858,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_time_delta(xdr, bitmap, &fsinfo->time_delta);
 	if (status != 0)
 		goto xdr_error;
-	status = decode_attr_pnfstype(xdr, bitmap, fsinfo->layouttype);
+	status = decode_attr_pnfstype(xdr, bitmap, fsinfo);
 	if (status != 0)
 		goto xdr_error;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a6a683fbd230..b588ccf05045 100644
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
@@ -99,6 +100,39 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
 }
 
 /*
+ * When the server sends a list of layout types, we choose one in the order
+ * given in the list below.
+ *
+ * FIXME: should this list be configurable in some fashion? module param?
+ * 	  mount option? something else?
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
@@ -106,10 +140,11 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
  */
 void
 set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
-		      u32 *ids)
+		      struct nfs_fsinfo *fsinfo)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 	u32 id;
+	int i;
 
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
@@ -118,18 +153,23 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
 		goto out_no_driver;
 	}
 
-	id = ids[0];
-	if (!id)
-		goto out_no_driver;
+	sort(fsinfo->layouttype, fsinfo->nlayouttypes,
+		sizeof(*fsinfo->layouttype), ld_cmp, NULL);
 
-	ld_type = find_pnfs_driver(id);
-	if (!ld_type) {
-		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+	for (i = 0; i < fsinfo->nlayouttypes; i++) {
+		id = fsinfo->layouttype[i];
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
index be515e6a3823..5c295512c967 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -236,7 +236,7 @@ void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 void pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg);
 
-void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32 *);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, struct nfs_fsinfo *);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
@@ -657,7 +657,8 @@ pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
 }
 
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
-					 const struct nfs_fh *mntfh, u32 *ids)
+					 const struct nfs_fh *mntfh,
+					 struct nfs_fsinfo *fsinfo)
 {
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f11b26ed001b..beb1e10f446e 100644
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
2.7.4

