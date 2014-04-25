Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15489 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160AbaDYU4c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 16/17] NFS: Create a common generic_pg_pgios()
Date: Fri, 25 Apr 2014 16:55:59 -0400
Message-ID: <1398459360-2093-17-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

What we have here is two functions that look identical.  Let's share
some more code!

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  1 +
 fs/nfs/pageio.c   | 23 +++++++++++++++++++++++
 fs/nfs/read.c     | 25 +------------------------
 fs/nfs/write.c    | 26 +-------------------------
 4 files changed, 26 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 81c314c..0243825 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -403,6 +403,7 @@ extern int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_head
 extern int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 			     const struct rpc_call_ops *, int, int);
 extern int nfs_do_multiple_pgios(struct list_head *, const struct rpc_call_ops *, int);
+extern int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index e985b0e..feac787 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -312,6 +312,29 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pgio);
 
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
+					    desc->pg_rpc_callops, 0);
+	if (atomic_dec_and_test(&hdr->refcnt))
+		hdr->completion_ops->completion(hdr);
+	return ret;
+}
+
 static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_pgio_data *data = calldata;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9dd1aeb..8460795 100644
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
index 28fdde2..ebbb663 100644
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

