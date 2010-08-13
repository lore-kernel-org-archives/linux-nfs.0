Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6928 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034Ab0HMVcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:14 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 11/50] pnfs_submit: set and unset pnfs layoutdriver modules
Date: Fri, 13 Aug 2010 17:31:23 -0400
Message-Id: <1281735122-1496-12-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-11-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |   26 +++++++++++++++++++
 fs/nfs/nfs4proc.c         |    4 +++
 fs/nfs/nfs4xdr.c          |   60 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.c             |   45 +++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |    9 ++++++
 include/linux/nfs4.h      |    1 +
 include/linux/nfs4_pnfs.h |    4 +++
 include/linux/nfs_fs_sb.h |    5 +++
 include/linux/nfs_xdr.h   |    3 ++
 9 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e7df2a..6560866 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -48,6 +48,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
@@ -866,6 +867,28 @@ error:
 }
 
 /*
+ * Initialize the pNFS layout driver and setup pNFS related parameters
+ */
+static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+{
+#if defined(CONFIG_NFS_V4_1)
+	struct nfs_client *clp = server->nfs_client;
+
+	if (nfs4_has_session(clp) &&
+	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+		set_pnfs_layoutdriver(server, fsinfo->layouttype);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+static void nfs4_uninit_pnfs(struct nfs_server *server)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (server->nfs_client && nfs4_has_session(server->nfs_client))
+		unmount_pnfs_layoutdriver(server);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
  * Load up the server record from information gained in an fsinfo record
  */
 static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
@@ -898,6 +921,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	nfs4_init_pnfs(server, fsinfo);
+
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
@@ -1017,6 +1042,7 @@ void nfs_free_server(struct nfs_server *server)
 {
 	dprintk("--> nfs_free_server()\n");
 
+	nfs4_uninit_pnfs(server);
 	spin_lock(&nfs_client_lock);
 	list_del(&server->client_link);
 	list_del(&server->master_link);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7684817..45d6526 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -129,7 +129,11 @@ const u32 nfs4_fsinfo_bitmap[2] = { FATTR4_WORD0_MAXFILESIZE
 			| FATTR4_WORD0_MAXREAD
 			| FATTR4_WORD0_MAXWRITE
 			| FATTR4_WORD0_LEASE_TIME,
+#ifdef CONFIG_NFS_V4_1
+			FATTR4_WORD1_FS_LAYOUT_TYPES
+#else /* CONFIG_NFS_V4_1 */
 			0
+#endif /* CONFIG_NFS_V4_1 */
 };
 
 const u32 nfs4_fs_locations_bitmap[2] = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 257c181..075845d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3868,6 +3868,61 @@ xdr_error:
 	return status;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * Decode potentially multiple layout types. Currently we only support
+ * one layout driver per file system.
+ */
+static int decode_pnfs_list(struct xdr_stream *xdr, uint32_t *layoutclass)
+{
+	uint32_t *p;
+	int num;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	num = be32_to_cpup(p);
+
+	/* pNFS is not supported by the underlying file system */
+	if (num == 0) {
+		*layoutclass = 0;
+		return 0;
+	}
+
+	/* TODO: We will eventually support multiple layout drivers ? */
+	if (num > 1)
+		printk(KERN_INFO "%s: Warning: Multiple pNFS layout drivers "
+			"per filesystem not supported\n", __func__);
+
+	/* Decode and set first layout type */
+	p = xdr_inline_decode(xdr, num * 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	*layoutclass = be32_to_cpup(p);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ * The type of file system exported
+ */
+static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
+				uint32_t *layoutclass)
+{
+	int status = 0;
+
+	dprintk("%s: bitmap is %x\n", __func__, bitmap[1]);
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_FS_LAYOUT_TYPES - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_FS_LAYOUT_TYPES)) {
+		status = decode_pnfs_list(xdr, layoutclass);
+		bitmap[1] &= ~FATTR4_WORD1_FS_LAYOUT_TYPES;
+	}
+	return status;
+}
+#endif /* CONFIG_NFS_V4_1 */
 
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
@@ -3894,6 +3949,11 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	if ((status = decode_attr_maxwrite(xdr, bitmap, &fsinfo->wtmax)) != 0)
 		goto xdr_error;
 	fsinfo->wtpref = fsinfo->wtmax;
+#if defined(CONFIG_NFS_V4_1)
+	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
+	if (status)
+		goto xdr_error;
+#endif /* CONFIG_NFS_V4_1 */
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 73558b7..4c78277 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -101,6 +101,51 @@ find_pnfs(u32 id, struct pnfs_module **module) {
 	return 0;
 }
 
+/* Unitialize a mountpoint in a layout driver */
+void
+unmount_pnfs_layoutdriver(struct nfs_server *nfss)
+{
+	if (PNFS_EXISTS_LDIO_OP(nfss, uninitialize_mountpoint))
+		nfss->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint(nfss);
+}
+
+/*
+ * Set the server pnfs module to the first registered pnfs_type.
+ * Only one pNFS layout driver is supported.
+ */
+void
+set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
+{
+	struct pnfs_module *mod = NULL;
+
+	if (server->pnfs_curr_ld)
+		return;
+
+	if (!find_pnfs(id, &mod)) {
+		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
+		find_pnfs(id, &mod);
+	}
+
+	if (!mod) {
+		dprintk("%s: No pNFS module found for %u. ", __func__, id);
+		goto out_err;
+	}
+
+	server->pnfs_curr_ld = mod->pnfs_ld_type;
+	if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
+							server->nfs_client)) {
+		printk(KERN_ERR "%s: Error initializing mount point "
+		       "for layout driver %u. ", __func__, id);
+		goto out_err;
+	}
+
+	dprintk("%s: pNFS module for %u set\n", __func__, id);
+	return;
+
+out_err:
+	dprintk("Using NFSv4 I/O\n");
+	server->pnfs_curr_ld = NULL;
+}
 
 /* Allow I/O module to set its functions structure */
 struct pnfs_client_operations*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 92538ce..3561fa8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -21,8 +21,17 @@
 #include <linux/nfs_iostat.h>
 #include "iostat.h"
 
+/* pnfs.c */
+void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
 
+#define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
+				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
+				     (srv)->pnfs_curr_ld->ld_io_ops->opname)
+
+#define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 07e40c6..1598e7b 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -471,6 +471,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY        (1UL << 21)
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
+#define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 4cc22c6..7240d7e 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -25,6 +25,10 @@ struct pnfs_layoutdriver_type {
  * Either the pagecache or non-pagecache read/write operations must be implemented
  */
 struct layoutdriver_io_operations {
+	/* Registration information for a new mounted file system
+	 */
+	int (*initialize_mountpoint) (struct nfs_client *);
+	int (*uninitialize_mountpoint) (struct nfs_server *server);
 };
 
 struct layoutdriver_policy_operations {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c82ee7c..e683128 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -145,6 +145,11 @@ struct nfs_server {
 						   that are supported on this
 						   filesystem */
 #endif
+
+#ifdef CONFIG_NFS_V4_1
+	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+#endif /* CONFIG_NFS_V4_1 */
+
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index fc46192..f1054d4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -113,6 +113,9 @@ struct nfs_fsinfo {
 	__u32			dtpref;	/* pref. readdir transfer size */
 	__u64			maxfilesize;
 	__u32			lease_time; /* in seconds */
+#if defined(CONFIG_NFS_V4_1)
+	__u32			layouttype; /* supported pnfs layout driver */
+#endif
 };
 
 struct nfs_fsstat {
-- 
1.6.2.5

