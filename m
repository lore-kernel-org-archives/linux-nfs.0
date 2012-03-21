Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759006Ab2CUPVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:24 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 20/23] NFS: Create custom init_read() and init_write() functions
Date: Wed, 21 Mar 2012 11:20:50 -0400
Message-Id: <1332343253-24970-21-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

pNFS needs to select read and write functions based on the layout driver
currently in use, so I let each NFS version decide how to best handle
initializing reads and writes.  I had to add ifndef guards to internal.h
to avoid multiple-redefinition errors.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h  |    4 ++++
 fs/nfs/nfs.h       |    3 +++
 fs/nfs/nfs2super.c |    2 ++
 fs/nfs/nfs3super.c |    2 ++
 fs/nfs/nfs4super.c |    2 ++
 fs/nfs/pnfs.c      |   16 ++++++++--------
 fs/nfs/pnfs.h      |   13 +++++++------
 fs/nfs/read.c      |    6 ++++--
 fs/nfs/unlink.c    |    1 +
 fs/nfs/write.c     |    5 +++--
 10 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index bd335bb..42d0903 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -2,6 +2,9 @@
  * NFS internal definitions
  */
 
+#ifndef FS_NFS_INTERNAL_H
+#define FS_NFS_INTERNAL_H
+
 #include "nfs4_fs.h"
 #include <linux/mount.h>
 #include <linux/security.h>
@@ -463,3 +466,4 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+#endif /* FS_NFS_INTERNAL_H */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index b5771d5..21bc52b 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -9,6 +9,7 @@
 
 #include <linux/fs.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/nfs_page.h>
 #include <linux/nfs_xdr.h>
 
 struct nfs_parsed_mount_data;
@@ -40,6 +41,8 @@ struct nfs_subversion {
 	struct vfsmount *(*submount)(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*return_delegation)(struct inode *);
+	void (*init_read)(struct nfs_pageio_descriptor *, struct inode *);
+	void (*init_write)(struct nfs_pageio_descriptor *, struct inode *, int);
 };
 
 struct nfs_sb_mountdata {
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index 697356f..a9a1a0b 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -59,6 +59,8 @@ static struct nfs_subversion nfs_v2 = {
 	.fs_mount = nfs2_fs_mount,
 	.xdev_mount = nfs2_xdev_mount,
 	.submount = nfs2_do_submount,
+	.init_read = nfs_pageio_init_read_mds,
+	.init_write = nfs_pageio_init_write_mds,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 17dad41..c84ffe3 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -90,6 +90,8 @@ static struct nfs_subversion nfs_v3 = {
 	.fs_mount = nfs3_fs_mount,
 	.xdev_mount = nfs3_xdev_mount,
 	.submount = nfs3_do_submount,
+	.init_read = nfs_pageio_init_read_mds,
+	.init_write = nfs_pageio_init_write_mds,
 };
 
 static int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 2a3974d..6bf44e3 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -656,6 +656,8 @@ static struct nfs_subversion nfs_v4 = {
 	.fs_mount = nfs4_fs_mount,
 	.xdev_mount = nfs4_xdev_mount,
 	.submount = nfs4_do_submount,
+	.init_read = pnfs_pageio_init_read,
+	.init_write = pnfs_pageio_init_write,
 };
 
 int __init init_nfs_v4(void)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b5d4515..722f235 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1112,28 +1112,28 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
-bool
+void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_read_ops, server->rsize, 0);
-	return true;
+		nfs_pageio_init_read_mds(pgio, inode);
+	else
+		nfs_pageio_init(pgio, inode, ld->pg_read_ops, server->rsize, 0);
 }
 
-bool
+void
 pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_write_ops, server->wsize, ioflags);
-	return true;
+		nfs_pageio_init_write_mds(pgio, inode, ioflags);
+	else
+		nfs_pageio_init(pgio, inode, ld->pg_write_ops, server->wsize, ioflags);
 }
 
 bool
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 442ebf6..db422b2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,6 +32,7 @@
 
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include "internal.h"
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
@@ -168,8 +169,8 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 
-bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
-bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, int);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, int);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -396,14 +397,14 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+static inline void pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
-	return false;
+	nfs_pageio_init_read_mds(pgio, inode);
 }
 
-static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
+static inline void pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags)
 {
-	return false;
+	nfs_pageio_init_write_mds(pgio, inode, ioflags);
 }
 
 static inline int
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cc1f758..667f32e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -22,6 +22,7 @@
 
 #include <asm/system.h>
 #include "pnfs.h"
+#include "nfs.h"
 
 #include "nfs4_fs.h"
 #include "internal.h"
@@ -114,6 +115,7 @@ void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -125,8 +127,8 @@ EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
-	if (!pnfs_pageio_init_read(pgio, inode))
-		nfs_pageio_init_read_mds(pgio, inode);
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	nfs_mod->init_read(pgio, inode);
 }
 
 int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 05abd34..8305948 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -15,6 +15,7 @@
 #include <linux/wait.h>
 #include <linux/namei.h>
 
+#include "delegation.h"
 #include "internal.h"
 #include "nfs4_fs.h"
 #include "iostat.h"
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5b28bbe..46fff97 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1101,6 +1101,7 @@ void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -1112,8 +1113,8 @@ EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
-	if (!pnfs_pageio_init_write(pgio, inode, ioflags))
-		nfs_pageio_init_write_mds(pgio, inode, ioflags);
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(NFS_SERVER(inode));
+	nfs_mod->init_write(pgio, inode, ioflags);
 }
 
 /*
-- 
1.7.9.4

