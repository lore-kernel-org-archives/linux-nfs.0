Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34926 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753485AbdIINTf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Sep 2017 09:19:35 -0400
Received: by mail-io0-f194.google.com with SMTP id d16so411580ioj.2
        for <linux-nfs@vger.kernel.org>; Sat, 09 Sep 2017 06:19:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix 2 use after free issues in the I/O code
Date: Sat,  9 Sep 2017 09:19:29 -0400
Message-Id: <20170909131929.17547-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The writeback code wants to send a commit after processing the pages,
which is why we want to delay releasing the struct path until after
that's done.

Also, the layout code expects that we do not free the inode before
we've put the layout segments in pnfs_writehdr_free() and
pnfs_readhdr_free()

Fixes: 919e3bd9a875 ("NFS: Ensure we commit after writeback is complete")
Fixes: 4714fb51fd03 ("nfs: remove pgio_header refcount, related cleanup")
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/internal.h |  1 -
 fs/nfs/pagelist.c | 26 ++++++++++++--------------
 fs/nfs/pnfs.c     |  2 --
 3 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dc456416d2be..68cc22083639 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -251,7 +251,6 @@ int nfs_iocounter_wait(struct nfs_lock_context *l_ctx);
 extern const struct nfs_pageio_ops nfs_pgio_rw_ops;
 struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
 void nfs_pgio_header_free(struct nfs_pgio_header *);
-void nfs_pgio_data_destroy(struct nfs_pgio_header *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 23cf4a82d94c..bec120ec1967 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -501,16 +501,6 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *ops)
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_header_alloc);
 
-/*
- * nfs_pgio_header_free - Free a read or write header
- * @hdr: The header to free
- */
-void nfs_pgio_header_free(struct nfs_pgio_header *hdr)
-{
-	hdr->rw_ops->rw_free_header(hdr);
-}
-EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
-
 /**
  * nfs_pgio_data_destroy - make @hdr suitable for reuse
  *
@@ -519,14 +509,24 @@ EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
  *
  * @hdr: A header that has had nfs_generic_pgio called
  */
-void nfs_pgio_data_destroy(struct nfs_pgio_header *hdr)
+static void nfs_pgio_data_destroy(struct nfs_pgio_header *hdr)
 {
 	if (hdr->args.context)
 		put_nfs_open_context(hdr->args.context);
 	if (hdr->page_array.pagevec != hdr->page_array.page_array)
 		kfree(hdr->page_array.pagevec);
 }
-EXPORT_SYMBOL_GPL(nfs_pgio_data_destroy);
+
+/*
+ * nfs_pgio_header_free - Free a read or write header
+ * @hdr: The header to free
+ */
+void nfs_pgio_header_free(struct nfs_pgio_header *hdr)
+{
+	nfs_pgio_data_destroy(hdr);
+	hdr->rw_ops->rw_free_header(hdr);
+}
+EXPORT_SYMBOL_GPL(nfs_pgio_header_free);
 
 /**
  * nfs_pgio_rpcsetup - Set up arguments for a pageio call
@@ -640,7 +640,6 @@ EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 static void nfs_pgio_error(struct nfs_pgio_header *hdr)
 {
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	nfs_pgio_data_destroy(hdr);
 	hdr->completion_ops->completion(hdr);
 }
 
@@ -651,7 +650,6 @@ static void nfs_pgio_error(struct nfs_pgio_header *hdr)
 static void nfs_pgio_release(void *calldata)
 {
 	struct nfs_pgio_header *hdr = calldata;
-	nfs_pgio_data_destroy(hdr);
 	hdr->completion_ops->completion(hdr);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3125a9d7b237..7879ed8ceb76 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2233,7 +2233,6 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_write_mds(desc);
 		mirror->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_destroy(hdr);
 	hdr->release(hdr);
 }
 
@@ -2357,7 +2356,6 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		nfs_pageio_reset_read_mds(desc);
 		mirror->pg_recoalesce = 1;
 	}
-	nfs_pgio_data_destroy(hdr);
 	hdr->release(hdr);
 }
 
-- 
2.13.5

