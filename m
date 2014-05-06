Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:62440 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220AbaEFNNI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 09:13:08 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v3 16/17] NFS: Create a common generic_pg_pgios()
Date: Tue, 6 May 2014 09:12:39 -0400
Message-ID: <1399381960-3019-17-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

What we have here is two functions that look identical.  Let's share
some more code!

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  2 +-
 fs/nfs/pagelist.c | 26 +++++++++++++++++++++++++-
 fs/nfs/read.c     | 25 +------------------------
 fs/nfs/write.c    | 26 +-------------------------
 4 files changed, 28 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 886273a..29e99aa 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -243,7 +243,7 @@ void nfs_pgio_data_release(struct nfs_pgio_data *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 		      const struct rpc_call_ops *, int, int);
-int nfs_do_multiple_pgios(struct list_head *, const struct rpc_call_ops *, int);
+int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 4f03629..e6682b1 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -494,7 +494,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
-int nfs_do_multiple_pgios(struct list_head *head,
+static int nfs_do_multiple_pgios(struct list_head *head,
 				 const struct rpc_call_ops *call_ops,
 				 int how)
 {
@@ -689,6 +689,30 @@ static int nfs_pgio_one(struct nfs_pageio_descriptor *desc,
 	return 0;
 }
 
+int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
+{
+	struct nfs_rw_header *rw_hdr;
+	struct nfs_pgio_header *hdr;
+	int ret;
+
+	rw_hdr = nfs_rw_header_alloc(desc->pg_rw_ops);
+	if (!rw_hdr) {
+		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
+		return -ENOMEM;
+	}
+	hdr = &rw_hdr->header;
+	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
+	atomic_inc(&hdr->refcnt);
+	ret = nfs_generic_pgio(desc, hdr);
+	if (ret == 0)
+		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
+					    desc->pg_rpc_callops,
+					    desc->pg_ioflags);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		hdr->completion_ops->completion(hdr);
+	return ret;
+}
+
 int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 		     struct nfs_pgio_header *hdr)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b834d45..ebd1666 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -178,32 +178,9 @@ static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops = {
 	.completion = nfs_read_completion,
 };
 
-static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
-{
-	struct nfs_rw_header *rhdr;
-	struct nfs_pgio_header *hdr;
-	int ret;
-
-	rhdr = nfs_rw_header_alloc(desc->pg_rw_ops);
-	if (!rhdr) {
-		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		return -ENOMEM;
-	}
-	hdr = &rhdr->header;
-	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
-	atomic_inc(&hdr->refcnt);
-	ret = nfs_generic_pgio(desc, hdr);
-	if (ret == 0)
-		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
-					    desc->pg_rpc_callops, 0);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
-	return ret;
-}
-
 static const struct nfs_pageio_ops nfs_pageio_read_ops = {
 	.pg_test = nfs_generic_pg_test,
-	.pg_doio = nfs_generic_pg_readpages,
+	.pg_doio = nfs_generic_pg_pgios,
 };
 
 /*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d3fa181..31a8b29 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -973,33 +973,9 @@ static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
 	.completion = nfs_write_completion,
 };
 
-static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
-{
-	struct nfs_rw_header *whdr;
-	struct nfs_pgio_header *hdr;
-	int ret;
-
-	whdr = nfs_rw_header_alloc(desc->pg_rw_ops);
-	if (!whdr) {
-		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		return -ENOMEM;
-	}
-	hdr = &whdr->header;
-	nfs_pgheader_init(desc, hdr, nfs_rw_header_free);
-	atomic_inc(&hdr->refcnt);
-	ret = nfs_generic_pgio(desc, hdr);
-	if (ret == 0)
-		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
-					     desc->pg_rpc_callops,
-					     desc->pg_ioflags);
-	if (atomic_dec_and_test(&hdr->refcnt))
-		hdr->completion_ops->completion(hdr);
-	return ret;
-}
-
 static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 	.pg_test = nfs_generic_pg_test,
-	.pg_doio = nfs_generic_pg_writepages,
+	.pg_doio = nfs_generic_pg_pgios,
 };
 
 void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
-- 
1.9.2

