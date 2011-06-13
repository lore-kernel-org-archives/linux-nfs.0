Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1473 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab1FMWWn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 18:22:43 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Bakeathon version 2 2/2] NFSv4.1: File layout only supports whole file layouts
Date: Mon, 13 Jun 2011 18:22:38 -0400
Message-Id: <1308003758-2075-2-git-send-email-andros@netapp.com>
In-Reply-To: <1308003758-2075-1-git-send-email-andros@netapp.com>
References: <1308003758-2075-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Ask for whole file layouts. Until support for layout segments is fully
supported in the file layout code, discard non-whole file layouts.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   47 +++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pnfs.c           |    6 ++++--
 fs/nfs/pnfs.h           |    6 ++++++
 fs/nfs/read.c           |    1 +
 fs/nfs/write.c          |    1 +
 5 files changed, 57 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index f0414ee..8f16112 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -427,6 +427,14 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 
+	/* FIXME: remove this check when layout segment support is added */
+	if (fl->generic_hdr.pls_range.offset != 0 ||
+	    fl->generic_hdr.pls_range.length != NFS4_MAX_UINT64) {
+		dprintk("%s Only whole file layouts supported. Use MDS i/o\n",
+			__func__);
+		goto out;
+	}
+
 	if (fl->pattern_offset > lgr->range.offset) {
 		dprintk("%s pattern_offset %lld too large\n",
 				__func__, fl->pattern_offset);
@@ -678,14 +686,49 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	return (p_stripe == r_stripe);
 }
 
+void
+filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
+			struct nfs_page *req)
+{
+	BUG_ON(pgio->pg_lseg != NULL);
+
+	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+					   req->wb_context,
+					   0,
+					   NFS4_MAX_UINT64,
+					   IOMODE_READ,
+					   GFP_KERNEL);
+	/* If no lseg, fall back to read through mds */
+	if (pgio->pg_lseg == NULL)
+		nfs_pageio_init_read_mds(pgio, pgio->pg_inode);
+}
+
+void
+filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
+			 struct nfs_page *req)
+{
+	BUG_ON(pgio->pg_lseg != NULL);
+
+	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+					   req->wb_context,
+					   0,
+					   NFS4_MAX_UINT64,
+					   IOMODE_RW,
+					   GFP_NOFS);
+	/* If no lseg, fall back to write through mds */
+	if (pgio->pg_lseg == NULL)
+		nfs_pageio_init_write_mds(pgio, pgio->pg_inode,
+					  pgio->pg_ioflags);
+}
+
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
-	.pg_init = pnfs_generic_pg_init_read,
+	.pg_init = filelayout_pg_init_read,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = nfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
-	.pg_init = pnfs_generic_pg_init_write,
+	.pg_init = filelayout_pg_init_write,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = nfs_generic_pg_writepages,
 };
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8ff8c1b..3b13062 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -906,7 +906,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
  * Layout segment is retreived from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
-static struct pnfs_layout_segment *
+struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   loff_t pos,
@@ -975,7 +975,8 @@ pnfs_update_layout(struct inode *ino,
 		arg.offset -= pg_offset;
 		arg.length += pg_offset;
 	}
-	arg.length = PAGE_CACHE_ALIGN(arg.length);
+	if (arg.length != NFS4_MAX_UINT64)
+		arg.length = PAGE_CACHE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	if (!lseg && first) {
@@ -993,6 +994,7 @@ out_unlock:
 	spin_unlock(&ino->i_lock);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(pnfs_update_layout);
 
 int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f2b183b..8f0b733 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -185,6 +185,12 @@ int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
 int pnfs_ld_write_done(struct nfs_write_data *);
 int pnfs_ld_read_done(struct nfs_read_data *);
+struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
+					       struct nfs_open_context *ctx,
+					       loff_t pos,
+					       u64 count,
+					       enum pnfs_iomode iomode,
+					       gfp_t gfp_flags);
 
 /* pnfs_dev.c */
 struct nfs4_deviceid_node {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9b2a1d7..c394662 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -120,6 +120,7 @@ void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
 
 static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 70f1ef0..75e7f0e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1049,6 +1049,7 @@ void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
 
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
-- 
1.7.3.1

