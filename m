Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754893Ab1GLTaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:12 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] NFS: Clean up - simplify the switch to read/write-through-MDS
Date: Tue, 12 Jul 2011 15:29:54 -0400
Message-Id: <1310498994-12685-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-7-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use nfs_pageio_reset_read_mds and nfs_pageio_reset_write_mds instead of
completely reinitialising the struct nfs_pageio_descriptor.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h       |    4 ----
 fs/nfs/nfs4filelayout.c |    5 ++---
 fs/nfs/pnfs.c           |    4 ++--
 fs/nfs/read.c           |    4 ++--
 fs/nfs/write.c          |    4 ++--
 5 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 758db89..38b1ffc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -299,16 +299,12 @@ extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
 
 struct nfs_pageio_descriptor;
-extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
-		struct inode *inode);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
-extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
-				  struct inode *inode, int ioflags);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_writedata_release(struct nfs_write_data *wdata);
 extern void nfs_commit_free(struct nfs_write_data *p);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fbc5b42..f0b37e1 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -711,7 +711,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_init_read_mds(pgio, pgio->pg_inode);
+		nfs_pageio_reset_read_mds(pgio);
 }
 
 void
@@ -728,8 +728,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_init_write_mds(pgio, pgio->pg_inode,
-					  pgio->pg_ioflags);
+		nfs_pageio_reset_write_mds(pgio);
 }
 
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 93c7329..38e5508 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1075,7 +1075,7 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_init_read_mds(pgio, pgio->pg_inode);
+		nfs_pageio_reset_read_mds(pgio);
 
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
@@ -1093,7 +1093,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_init_write_mds(pgio, pgio->pg_inode, pgio->pg_ioflags);
+		nfs_pageio_reset_write_mds(pgio);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3745eed..1472933 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -112,19 +112,19 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
 	}
 }
 
-void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+static void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
 			NFS_SERVER(inode)->rsize, 0);
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
 	pgio->pg_ops = &nfs_pageio_read_ops;
 	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
 static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e18d842..525fb02 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1051,19 +1051,19 @@ static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 	.pg_doio = nfs_generic_pg_writepages,
 };
 
-void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
+static void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
 				NFS_SERVER(inode)->wsize, ioflags);
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
 	pgio->pg_ops = &nfs_pageio_write_ops;
 	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
 }
+EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
-- 
1.7.6

