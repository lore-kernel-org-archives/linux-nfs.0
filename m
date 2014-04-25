Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34165 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932157AbaDYU4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:23 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 10/17] NFS: Create a common rpc_call_ops struct
Date: Fri, 25 Apr 2014 16:55:53 -0400
Message-ID: <1398459360-2093-11-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

The read and write paths set up this struct in exactly the same way, so
create a single shared struct.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  4 +---
 fs/nfs/pageio.c   | 10 ++++++++--
 fs/nfs/read.c     | 11 ++---------
 fs/nfs/write.c    | 11 ++---------
 4 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b18cca4..798eb47 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -396,13 +396,11 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool
 struct nfs_pgio_completion_ops;
 
 /* pageio.c */
+extern const struct rpc_call_ops nfs_pgio_common_ops;
 extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
-extern void nfs_pgio_prepare(struct rpc_task *, void *);
-extern void nfs_pgio_release_common(void *);
-extern void nfs_pgio_result_common(struct rpc_task *, void *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index 91c49cc..0ef8079 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -87,7 +87,7 @@ void nfs_pgio_data_release(struct nfs_pgio_data *data)
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
 
-void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
+static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_pgio_data *data = calldata;
 	int err;
@@ -114,7 +114,7 @@ static int nfs_pgio_result(struct rpc_task *task, struct nfs_pgio_data *data)
 	return data->header->rw_ops->rw_result(task, data, inode);
 }
 
-void nfs_pgio_result_common(struct rpc_task *task, void *calldata)
+static void nfs_pgio_result_common(struct rpc_task *task, void *calldata)
 {
 	struct nfs_pgio_data *data = calldata;
 
@@ -125,3 +125,9 @@ void nfs_pgio_result_common(struct rpc_task *task, void *calldata)
 	else
 		data->header->rw_ops->rw_result_common(task, data);
 }
+
+const struct rpc_call_ops nfs_pgio_common_ops = {
+	.rpc_call_prepare = nfs_pgio_prepare,
+	.rpc_call_done = nfs_pgio_result_common,
+	.rpc_release = nfs_pgio_release_common,
+};
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4f49507..98373ba 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -29,7 +29,6 @@
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
 static const struct nfs_pageio_ops nfs_pageio_read_ops;
-static const struct rpc_call_ops nfs_read_common_ops;
 static const struct nfs_pgio_completion_ops nfs_async_read_completion_ops;
 static const struct nfs_rw_ops nfs_rw_read_ops;
 
@@ -314,7 +313,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &hdr->pages);
-	desc->pg_rpc_callops = &nfs_read_common_ops;
+	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
 
@@ -343,7 +342,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 
 	nfs_read_rpcsetup(data, desc->pg_count, 0);
 	list_add(&data->list, &hdr->rpc_list);
-	desc->pg_rpc_callops = &nfs_read_common_ops;
+	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
 
@@ -443,12 +442,6 @@ static void nfs_readpage_result_common(struct rpc_task *task, struct nfs_pgio_da
 		nfs_readpage_retry(task, data);
 }
 
-static const struct rpc_call_ops nfs_read_common_ops = {
-	.rpc_call_prepare = nfs_pgio_prepare,
-	.rpc_call_done = nfs_pgio_result_common,
-	.rpc_release = nfs_pgio_release_common,
-};
-
 /*
  * Read a page over NFS.
  * We read the page synchronously in the following case:
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d2351a1..e492537 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -42,7 +42,6 @@
  * Local function declarations
  */
 static void nfs_redirty_request(struct nfs_page *req);
-static const struct rpc_call_ops nfs_write_common_ops;
 static const struct rpc_call_ops nfs_commit_ops;
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops;
 static const struct nfs_commit_completion_ops nfs_commit_completion_ops;
@@ -1138,7 +1137,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 	} while (nbytes != 0);
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &hdr->pages);
-	desc->pg_rpc_callops = &nfs_write_common_ops;
+	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
 
@@ -1182,7 +1181,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
 	list_add(&data->list, &hdr->rpc_list);
-	desc->pg_rpc_callops = &nfs_write_common_ops;
+	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
 }
 
@@ -1272,12 +1271,6 @@ static void nfs_writeback_release_common(struct nfs_pgio_data *data)
 	}
 }
 
-static const struct rpc_call_ops nfs_write_common_ops = {
-	.rpc_call_prepare = nfs_pgio_prepare,
-	.rpc_call_done = nfs_pgio_result_common,
-	.rpc_release = nfs_pgio_release_common,
-};
-
 /*
  * Special version of should_remove_suid() that ignores capabilities.
  */
-- 
1.9.2

