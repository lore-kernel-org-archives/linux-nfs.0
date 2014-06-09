Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34387 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933276AbaFIPsq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 11:48:46 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so5705909iec.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 08:48:45 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 6/7] pnfs: clean up *_resend_to_mds
Date: Mon,  9 Jun 2014 11:48:38 -0400
Message-Id: <1402328919-5065-7-git-send-email-dros@primarydata.com>
In-Reply-To: <1402328919-5065-1-git-send-email-dros@primarydata.com>
References: <1402328919-5065-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up pnfs_read_done_resend_to_mds and pnfs_write_done_resend_to_mds:
 - instead of passing all arguments from a nfs_pgio_header, just pass the header
 - share the common code

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 10 ++-----
 fs/nfs/pagelist.c              | 32 +++++++++++++++++++++
 fs/nfs/pnfs.c                  | 63 ++++++------------------------------------
 fs/nfs/pnfs.h                  |  8 ++----
 include/linux/nfs_page.h       |  2 ++
 5 files changed, 47 insertions(+), 68 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 537e7f7..504d58a 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -97,10 +97,7 @@ static void filelayout_reset_write(struct nfs_pgio_header *hdr)
 			hdr->args.count,
 			(unsigned long long)hdr->args.offset);
 
-		task->tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
-							&hdr->pages,
-							hdr->completion_ops,
-							hdr->dreq);
+		task->tk_status = pnfs_write_done_resend_to_mds(hdr);
 	}
 }
 
@@ -117,10 +114,7 @@ static void filelayout_reset_read(struct nfs_pgio_header *hdr)
 			hdr->args.count,
 			(unsigned long long)hdr->args.offset);
 
-		task->tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
-							&hdr->pages,
-							hdr->completion_ops,
-							hdr->dreq);
+		task->tk_status = pnfs_read_done_resend_to_mds(hdr);
 	}
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b4dbcfb..6c5dd8b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -949,6 +949,38 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
 
+/*
+ * nfs_pageio_resend - Transfer requests to new descriptor and resend
+ * @hdr - the pgio header to move request from
+ * @desc - the pageio descriptor to add requests to
+ *
+ * Try to move each request (nfs_page) from @hdr to @desc then attempt
+ * to send them.
+ *
+ * Returns 0 on success and < 0 on error.
+ */
+int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
+		      struct nfs_pgio_header *hdr)
+{
+	LIST_HEAD(failed);
+
+	desc->pg_dreq = hdr->dreq;
+	while (!list_empty(&hdr->pages)) {
+		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
+
+		nfs_list_remove_request(req);
+		if (!nfs_pageio_add_request(desc, req))
+			nfs_list_add_request(req, &failed);
+	}
+	nfs_pageio_complete(desc);
+	if (!list_empty(&failed)) {
+		list_move(&failed, &hdr->pages);
+		return -EIO;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nfs_pageio_resend);
+
 /**
  * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
  * @desc: pointer to io descriptor
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2585933..0ecaf6e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1466,35 +1466,14 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
-int pnfs_write_done_resend_to_mds(struct inode *inode,
-				struct list_head *head,
-				const struct nfs_pgio_completion_ops *compl_ops,
-				struct nfs_direct_req *dreq)
+int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *hdr)
 {
 	struct nfs_pageio_descriptor pgio;
-	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_write(&pgio, inode, FLUSH_STABLE, true, compl_ops);
-	pgio.pg_dreq = dreq;
-	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
-
-		nfs_list_remove_request(req);
-		if (!nfs_pageio_add_request(&pgio, req))
-			nfs_list_add_request(req, &failed);
-	}
-	nfs_pageio_complete(&pgio);
-
-	if (!list_empty(&failed)) {
-		/* For some reason our attempt to resend pages. Mark the
-		 * overall send request as having failed, and let
-		 * nfs_writeback_release_full deal with the error.
-		 */
-		list_move(&failed, head);
-		return -EIO;
-	}
-	return 0;
+	nfs_pageio_init_write(&pgio, hdr->inode, FLUSH_STABLE, true,
+			      hdr->completion_ops);
+	return nfs_pageio_resend(&pgio, hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
 
@@ -1507,10 +1486,7 @@ static void pnfs_ld_handle_write_error(struct nfs_pgio_header *hdr)
 		pnfs_return_layout(hdr->inode);
 	}
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
-		hdr->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
-							&hdr->pages,
-							hdr->completion_ops,
-							hdr->dreq);
+		hdr->task.tk_status = pnfs_write_done_resend_to_mds(hdr);
 }
 
 /*
@@ -1608,31 +1584,13 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
-int pnfs_read_done_resend_to_mds(struct inode *inode,
-				struct list_head *head,
-				const struct nfs_pgio_completion_ops *compl_ops,
-				struct nfs_direct_req *dreq)
+int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *hdr)
 {
 	struct nfs_pageio_descriptor pgio;
-	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_read(&pgio, inode, true, compl_ops);
-	pgio.pg_dreq = dreq;
-	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
-
-		nfs_list_remove_request(req);
-		if (!nfs_pageio_add_request(&pgio, req))
-			nfs_list_add_request(req, &failed);
-	}
-	nfs_pageio_complete(&pgio);
-
-	if (!list_empty(&failed)) {
-		list_move(&failed, head);
-		return -EIO;
-	}
-	return 0;
+	nfs_pageio_init_read(&pgio, hdr->inode, true, hdr->completion_ops);
+	return nfs_pageio_resend(&pgio, hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_read_done_resend_to_mds);
 
@@ -1644,10 +1602,7 @@ static void pnfs_ld_handle_read_error(struct nfs_pgio_header *hdr)
 		pnfs_return_layout(hdr->inode);
 	}
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
-		hdr->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
-							&hdr->pages,
-							hdr->completion_ops,
-							hdr->dreq);
+		hdr->task.tk_status = pnfs_read_done_resend_to_mds(hdr);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f385afa..552b2e9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -228,12 +228,8 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       gfp_t gfp_flags);
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
-int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head,
-			const struct nfs_pgio_completion_ops *compl_ops,
-			struct nfs_direct_req *dreq);
-int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head,
-			const struct nfs_pgio_completion_ops *compl_ops,
-			struct nfs_direct_req *dreq);
+int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *);
+int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 
 /* nfs4_deviceid_flags */
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d0fae7b..4b48548 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -112,6 +112,8 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     int how);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
+extern  int nfs_pageio_resend(struct nfs_pageio_descriptor *,
+			      struct nfs_pgio_header *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
 extern	void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *, pgoff_t);
 extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
-- 
1.8.5.2 (Apple Git-48)

