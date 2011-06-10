Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756852Ab1FJBbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 21:31:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4.1: Fall back to ordinary i/o through the mds if we have no layout segment
Date: Thu,  9 Jun 2011 21:31:02 -0400
Message-Id: <1307669462-15764-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>
 <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com>
 <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com>
 <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h            |    6 ++++++
 fs/nfs/nfs4filelayout.c      |    4 +---
 fs/nfs/objlayout/objio_osd.c |    3 ---
 fs/nfs/pnfs.c                |    7 +++++++
 fs/nfs/read.c                |    2 +-
 fs/nfs/write.c               |    2 +-
 6 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b9056cb..9f4386a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -282,7 +282,13 @@ extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 
+struct nfs_pageio_descriptor;
+extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+		struct inode *inode);
+
 /* write.c */
+extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
+				  struct inode *inode, int ioflags);
 extern void nfs_commit_free(struct nfs_write_data *p);
 extern int nfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 93c5bae1f..c3857f4 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -662,10 +662,8 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	u32 stripe_unit;
 
 	if (!pnfs_generic_pg_test(pgio, prev, req))
-		return 0;
+		return false;
 
-	if (!pgio->pg_lseg)
-		return 1;
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
 	r_stripe = (u64)req->wb_index << PAGE_CACHE_SHIFT;
 	stripe_unit = FILELAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 84b5fb7..f014038 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1001,9 +1001,6 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 	if (!pnfs_generic_pg_test(pgio, prev, req))
 		return false;
 
-	if (pgio->pg_lseg == NULL)
-		return true;
-
 	return pgio->pg_count + req->wb_bytes <=
 			OBJIO_LSEG(pgio->pg_lseg)->max_io_size;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e9a8072..b848a7e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1054,6 +1054,10 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 					   req->wb_bytes,
 					   IOMODE_READ,
 					   GFP_KERNEL);
+	/* If no lseg, fall back to read through mds */
+	if (pgio->pg_lseg == NULL)
+		nfs_pageio_init_read_mds(pgio, pgio->pg_inode);
+
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
 
@@ -1068,6 +1072,9 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *
 					   req->wb_bytes,
 					   IOMODE_RW,
 					   GFP_NOFS);
+	/* If no lseg, fall back to write through mds */
+	if (pgio->pg_lseg == NULL)
+		nfs_pageio_init_write_mds(pgio, pgio->pg_inode, pgio->pg_ioflags);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index dbb89a3..9c5cf57 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -114,7 +114,7 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
 	}
 }
 
-static void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
+void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f0ce0c3..70f1ef0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1043,7 +1043,7 @@ static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 	.pg_doio = nfs_generic_pg_writepages,
 };
 
-static void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
+void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
-- 
1.7.5.2

