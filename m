Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:32934 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbaEFNNG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 09:13:06 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v3 15/17] NFS: Create a common multiple_pgios() function
Date: Tue, 6 May 2014 09:12:38 -0400
Message-ID: <1399381960-3019-16-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Once again, these two functions look identical in the read and write
case.  Time to combine them together!

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  1 +
 fs/nfs/pagelist.c | 21 +++++++++++++++++++++
 fs/nfs/read.c     | 32 ++------------------------------
 fs/nfs/write.c    | 31 +------------------------------
 4 files changed, 25 insertions(+), 60 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index be4f2a7..886273a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -243,6 +243,7 @@ void nfs_pgio_data_release(struct nfs_pgio_data *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 		      const struct rpc_call_ops *, int, int);
+int nfs_do_multiple_pgios(struct list_head *, const struct rpc_call_ops *, int);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 55e2f90..4f03629 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -494,6 +494,27 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
+int nfs_do_multiple_pgios(struct list_head *head,
+				 const struct rpc_call_ops *call_ops,
+				 int how)
+{
+	struct nfs_pgio_data *data;
+	int ret = 0;
+
+	while (!list_empty(head)) {
+		int ret2;
+
+		data = list_first_entry(head, struct nfs_pgio_data, list);
+		list_del_init(&data->list);
+
+		ret2 = nfs_initiate_pgio(NFS_CLIENT(data->header->inode),
+					 data, call_ops, how, 0);
+		if (ret == 0)
+			 ret = ret2;
+	}
+	return ret;
+}
+
 /**
  * nfs_pgio_error - Clean up from a pageio error
  * @desc: IO descriptor
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0359b0d..b834d45 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -161,34 +161,6 @@ static void nfs_initiate_read(struct nfs_pgio_data *data, struct rpc_message *ms
 	NFS_PROTO(inode)->read_setup(data, msg);
 }
 
-static int nfs_do_read(struct nfs_pgio_data *data,
-		const struct rpc_call_ops *call_ops)
-{
-	struct inode *inode = data->header->inode;
-
-	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, 0, 0);
-}
-
-static int
-nfs_do_multiple_reads(struct list_head *head,
-		const struct rpc_call_ops *call_ops)
-{
-	struct nfs_pgio_data *data;
-	int ret = 0;
-
-	while (!list_empty(head)) {
-		int ret2;
-
-		data = list_first_entry(head, struct nfs_pgio_data, list);
-		list_del_init(&data->list);
-
-		ret2 = nfs_do_read(data, call_ops);
-		if (ret == 0)
-			ret = ret2;
-	}
-	return ret;
-}
-
 static void
 nfs_async_read_error(struct list_head *head)
 {
@@ -222,8 +194,8 @@ static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_reads(&hdr->rpc_list,
-					    desc->pg_rpc_callops);
+		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
+					    desc->pg_rpc_callops, 0);
 	if (atomic_dec_and_test(&hdr->refcnt))
 		hdr->completion_ops->completion(hdr);
 	return ret;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e46a1fc..d3fa181 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -945,35 +945,6 @@ static void nfs_initiate_write(struct nfs_pgio_data *data, struct rpc_message *m
 				 &task_setup_data->rpc_client, msg, data);
 }
 
-static int nfs_do_write(struct nfs_pgio_data *data,
-		const struct rpc_call_ops *call_ops,
-		int how)
-{
-	struct inode *inode = data->header->inode;
-
-	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, how, 0);
-}
-
-static int nfs_do_multiple_writes(struct list_head *head,
-		const struct rpc_call_ops *call_ops,
-		int how)
-{
-	struct nfs_pgio_data *data;
-	int ret = 0;
-
-	while (!list_empty(head)) {
-		int ret2;
-
-		data = list_first_entry(head, struct nfs_pgio_data, list);
-		list_del_init(&data->list);
-		
-		ret2 = nfs_do_write(data, call_ops, how);
-		 if (ret == 0)
-			 ret = ret2;
-	}
-	return ret;
-}
-
 /* If a nfs_flush_* function fails, it should remove reqs from @head and
  * call this on each, which will prepare them to be retried on next
  * writeback using standard nfs.
@@ -1018,7 +989,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	atomic_inc(&hdr->refcnt);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
-		ret = nfs_do_multiple_writes(&hdr->rpc_list,
+		ret = nfs_do_multiple_pgios(&hdr->rpc_list,
 					     desc->pg_rpc_callops,
 					     desc->pg_ioflags);
 	if (atomic_dec_and_test(&hdr->refcnt))
-- 
1.9.2

