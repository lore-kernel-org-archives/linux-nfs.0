Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:32934 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbaEFNNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 09:13:07 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v3 17/17] NFS: Create a common nfs_pageio_ops struct
Date: Tue, 6 May 2014 09:12:40 -0400
Message-ID: <1399381960-3019-18-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At this point the read and write structures look identical, so combine
them into something shared by both.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  2 +-
 fs/nfs/pagelist.c |  7 ++++++-
 fs/nfs/read.c     | 10 ++--------
 fs/nfs/write.c    |  9 ++-------
 4 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 29e99aa..8b69cba 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -237,13 +237,13 @@ extern void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos);
 int nfs_iocounter_wait(struct nfs_io_counter *c);
 
+extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
 struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 void nfs_rw_header_free(struct nfs_pgio_header *);
 void nfs_pgio_data_release(struct nfs_pgio_data *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 		      const struct rpc_call_ops *, int, int);
-int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e6682b1..88b6442 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -689,7 +689,7 @@ static int nfs_pgio_one(struct nfs_pageio_descriptor *desc,
 	return 0;
 }
 
-int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
+static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_rw_header *rw_hdr;
 	struct nfs_pgio_header *hdr;
@@ -934,3 +934,8 @@ static const struct rpc_call_ops nfs_pgio_common_ops = {
 	.rpc_call_done = nfs_pgio_result,
 	.rpc_release = nfs_pgio_release,
 };
+
+const struct nfs_pageio_ops nfs_pgio_rw_ops = {
+	.pg_test = nfs_generic_pg_test,
+	.pg_doio = nfs_generic_pg_pgios,
+};
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index ebd1666..3986668 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -28,7 +28,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-static const struct nfs_pageio_ops nfs_pageio_read_ops;
 static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
 static const struct nfs_rw_ops nfs_rw_read_ops;
 
@@ -58,7 +57,7 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			      const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_read_ops;
+	const struct nfs_pageio_ops *pg_ops = &nfs_pgio_rw_ops;
 
 #ifdef CONFIG_NFS_V4_1
 	if (server->pnfs_curr_ld && !force_mds)
@@ -71,7 +70,7 @@ EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
-	pgio->pg_ops = &nfs_pageio_read_ops;
+	pgio->pg_ops = &nfs_pgio_rw_ops;
 	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
@@ -178,11 +177,6 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
 	.completion = nfs_read_completion,
 };
 
-static const struct nfs_pageio_ops nfs_pageio_read_ops = {
-	.pg_test = nfs_generic_pg_test,
-	.pg_doio = nfs_generic_pg_pgios,
-};
-
 /*
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 31a8b29..2680f29 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -973,17 +973,12 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
 	.completion = nfs_write_completion,
 };
 
-static const struct nfs_pageio_ops nfs_pageio_write_ops = {
-	.pg_test = nfs_generic_pg_test,
-	.pg_doio = nfs_generic_pg_pgios,
-};
-
 void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			       struct inode *inode, int ioflags, bool force_mds,
 			       const struct nfs_pgio_completion_ops *compl_ops)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_write_ops;
+	const struct nfs_pageio_ops *pg_ops = &nfs_pgio_rw_ops;
 
 #ifdef CONFIG_NFS_V4_1
 	if (server->pnfs_curr_ld && !force_mds)
@@ -996,7 +991,7 @@ EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
-	pgio->pg_ops = &nfs_pageio_write_ops;
+	pgio->pg_ops = &nfs_pgio_rw_ops;
 	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
-- 
1.9.2

