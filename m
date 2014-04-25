Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18579 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164AbaDYU4b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 16:56:31 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v2 15/17] NFS: Create a common multiple_pgios() function
Date: Fri, 25 Apr 2014 16:55:58 -0400
Message-ID: <1398459360-2093-16-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1398459360-2093-1-git-send-email-Anna.Schumaker@Netapp.com>
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
 fs/nfs/pageio.c   | 29 +++++++++++++++++++++++++++++
 fs/nfs/read.c     | 32 ++------------------------------
 fs/nfs/write.c    | 31 +------------------------------
 4 files changed, 33 insertions(+), 60 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 027d72c..81c314c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -402,6 +402,7 @@ extern void nfs_pgio_data_release(struct nfs_pgio_data *);
 extern int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 extern int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_data *,
 			     const struct rpc_call_ops *, int, int);
+extern int nfs_do_multiple_pgios(struct list_head *, const struct rpc_call_ops *, int);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index f07a132..e985b0e 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -173,6 +173,35 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
+static int nfs_do_pgio(struct nfs_pgio_data *data,
+		       const struct rpc_call_ops *call_ops,
+		       int how)
+{
+	struct inode *inode = data->header->inode;
+
+	return nfs_initiate_pgio(NFS_CLIENT(inode), data, call_ops, how, 0);
+}
+
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
+		ret2 = nfs_do_pgio(data, call_ops, how);
+		 if (ret == 0)
+			 ret = ret2;
+	}
+	return ret;
+}
+
 static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
 			  struct nfs_pgio_header *hdr)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index ebea335..9dd1aeb 100644
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
index 4279f80..28fdde2 100644
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

