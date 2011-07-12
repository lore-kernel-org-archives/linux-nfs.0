Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1GLTaI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFS: Cache rpc_ops in struct nfs_pageio_descriptor
Date: Tue, 12 Jul 2011 15:29:49 -0400
Message-Id: <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/read.c            |   19 ++++++++-----------
 fs/nfs/write.c           |   20 +++++++-------------
 include/linux/nfs_page.h |    1 +
 3 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d30d6de..b2e9aad 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -327,6 +327,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc, struct list_head
 	} while(nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
 	ClearPageError(page);
+	desc->pg_rpc_callops = &nfs_read_partial_ops;
 	return ret;
 out_bad:
 	while (!list_empty(res)) {
@@ -366,6 +367,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc, struct list_head *
 
 	nfs_read_rpcsetup(req, data, desc->pg_count, 0);
 	list_add(&data->list, res);
+	desc->pg_rpc_callops = &nfs_read_full_ops;
 out:
 	return ret;
 }
@@ -375,19 +377,14 @@ int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	LIST_HEAD(head);
 	int ret;
 
-	if (desc->pg_bsize < PAGE_CACHE_SIZE) {
+	if (desc->pg_bsize < PAGE_CACHE_SIZE)
 		ret = nfs_pagein_multi(desc, &head);
-		if (ret == 0)
-			ret = nfs_do_multiple_reads(&head,
-					&nfs_read_partial_ops,
-					desc->pg_lseg);
-	} else {
+	else
 		ret = nfs_pagein_one(desc, &head);
-		if (ret == 0)
-			ret = nfs_do_multiple_reads(&head,
-					&nfs_read_full_ops,
-					desc->pg_lseg);
-	}
+
+	if (ret == 0)
+		ret = nfs_do_multiple_reads(&head, desc->pg_rpc_callops,
+				desc->pg_lseg);
 	put_lseg(desc->pg_lseg);
 	desc->pg_lseg = NULL;
 	return ret;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 89cc687..8fa7def 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -975,6 +975,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc, struct list_head
 		offset += len;
 	} while (nbytes != 0);
 	atomic_set(&req->wb_complete, requests);
+	desc->pg_rpc_callops = &nfs_write_partial_ops;
 	return ret;
 
 out_bad:
@@ -1031,6 +1032,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc, struct list_head *r
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(req, data, desc->pg_count, 0, desc->pg_ioflags);
 	list_add(&data->list, res);
+	desc->pg_rpc_callops = &nfs_write_full_ops;
 out:
 	return ret;
 }
@@ -1040,21 +1042,13 @@ int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	LIST_HEAD(head);
 	int ret;
 
-	if (desc->pg_bsize < PAGE_CACHE_SIZE) {
+	if (desc->pg_bsize < PAGE_CACHE_SIZE)
 		ret = nfs_flush_multi(desc, &head);
-		if (ret == 0)
-			ret = nfs_do_multiple_writes(&head,
-					&nfs_write_partial_ops,
-					desc->pg_lseg,
-					desc->pg_ioflags);
-	} else {
+	else
 		ret = nfs_flush_one(desc, &head);
-		if (ret == 0)
-			ret = nfs_do_multiple_writes(&head,
-					&nfs_write_full_ops,
-					desc->pg_lseg,
-					desc->pg_ioflags);
-	}
+	if (ret == 0)
+		ret = nfs_do_multiple_writes(&head, desc->pg_rpc_callops,
+				desc->pg_lseg, desc->pg_ioflags);
 	put_lseg(desc->pg_lseg);
 	desc->pg_lseg = NULL;
 	return ret;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 9ac2dd1..db3194f 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -74,6 +74,7 @@ struct nfs_pageio_descriptor {
 	const struct nfs_pageio_ops *pg_ops;
 	int 			pg_ioflags;
 	int			pg_error;
+	const struct rpc_call_ops *pg_rpc_callops;
 	struct pnfs_layout_segment *pg_lseg;
 };
 
-- 
1.7.6

