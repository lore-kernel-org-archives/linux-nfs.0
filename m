Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15489 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932155AbaDYU4e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 17/17] NFS: Create a common nfs_pageio_ops struct
Date: Fri, 25 Apr 2014 16:56:00 -0400
Message-ID: <1398459360-2093-18-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At this point the read and write structures look identical, so combine
them into something shared by both.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  2 +-
 fs/nfs/pageio.c   |  7 ++++++-
 fs/nfs/read.c     | 10 ++--------
 fs/nfs/write.c    |  9 ++-------
 4 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0243825..0c22142 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -396,6 +396,7 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool
 struct nfs_pgio_completion_ops;
 
 /* pageio.c */
+extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
 extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
@@ -403,7 +404,6 @@ extern int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_head
 extern int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 			     const struct rpc_call_ops *, int, int);
 extern int nfs_do_multiple_pgios(struct list_head *, const struct rpc_call_ops *, int);
-extern int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index feac787..4c93611 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -312,7 +312,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pgio);
 
-int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
+static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_rw_header *rw_hdr;
 	struct nfs_pgio_header *hdr;
@@ -379,3 +379,8 @@ static const struct rpc_call_ops nfs_pgio_common_ops = {
 	.rpc_call_done = nfs_pgio_result_common,
 	.rpc_release = nfs_pgio_release_common,
 };
+
+const struct nfs_pageio_ops nfs_pgio_rw_ops = {
+	.pg_test = nfs_generic_pg_test,
+	.pg_doio = nfs_generic_pg_pgios,
+};
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 8460795..d7e9460 100644
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
index ebbb663..3483dd4 100644
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

