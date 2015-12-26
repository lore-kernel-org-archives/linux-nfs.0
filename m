Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34597 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbLZXVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:41 -0500
Received: by mail-io0-f178.google.com with SMTP id e126so280361640ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:41 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/14] nfs: centralize pgio error cleanup
Date: Sat, 26 Dec 2015 18:20:50 -0500
Message-Id: <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

In case we fail during setting things up for read/write IO, set
pg_error in IO descriptor and do the cleanup in nfs_pageio_add_request,
where we clean up all pages that are still hanging around on the IO
descriptor.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 53 +++++++++++++++++++++++++++++------------------------
 fs/nfs/pnfs.c     | 12 ++++--------
 2 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f66021663645..eeddbf0bf4c4 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -664,22 +664,11 @@ EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
  * @desc: IO descriptor
  * @hdr: pageio header
  */
-static int nfs_pgio_error(struct nfs_pageio_descriptor *desc,
-			  struct nfs_pgio_header *hdr)
+static void nfs_pgio_error(struct nfs_pgio_header *hdr)
 {
-	struct nfs_pgio_mirror *mirror;
-	u32 midx;
-
 	set_bit(NFS_IOHDR_REDO, &hdr->flags);
 	nfs_pgio_data_destroy(hdr);
 	hdr->completion_ops->completion(hdr);
-	/* TODO: Make sure it's right to clean up all mirrors here
-	 *       and not just hdr->pgio_mirror_idx */
-	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
-		mirror = &desc->pg_mirrors[midx];
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
-	}
-	return -ENOMEM;
 }
 
 /**
@@ -800,8 +789,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	unsigned int pagecount, pageused;
 
 	pagecount = nfs_page_array_len(mirror->pg_base, mirror->pg_count);
-	if (!nfs_pgarray_set(&hdr->page_array, pagecount))
-		return nfs_pgio_error(desc, hdr);
+	if (!nfs_pgarray_set(&hdr->page_array, pagecount)) {
+		nfs_pgio_error(hdr);
+		desc->pg_error = -ENOMEM;
+		return desc->pg_error;
+	}
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = hdr->page_array.pagevec;
@@ -819,8 +811,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 			*pages++ = last_page = req->wb_page;
 		}
 	}
-	if (WARN_ON_ONCE(pageused != pagecount))
-		return nfs_pgio_error(desc, hdr);
+	if (WARN_ON_ONCE(pageused != pagecount)) {
+		nfs_pgio_error(hdr);
+		desc->pg_error = -EINVAL;
+		return desc->pg_error;
+	}
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo)))
@@ -843,10 +838,8 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
-		/* TODO: make sure this is right with mirroring - or
-		 *       should it back out all mirrors? */
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
-		return -ENOMEM;
+		desc->pg_error = -ENOMEM;
+		return desc->pg_error;
 	}
 	nfs_pgheader_init(desc, hdr, nfs_pgio_header_free);
 	ret = nfs_generic_pgio(desc, hdr);
@@ -1120,7 +1113,6 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 static int nfs_pageio_add_request_mirror(struct nfs_pageio_descriptor *desc,
 		struct nfs_page *req)
 {
-	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 	int ret;
 
 	do {
@@ -1187,10 +1179,23 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 out_failed:
 	/*
 	 * We might have failed before sending any reqs over wire.
-	 * clean up rest of the reqs in mirror pg_list
+	 * Clean up rest of the reqs in mirror pg_list.
 	 */
-	if (desc->pg_error)
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
+	if (desc->pg_error) {
+		struct nfs_pgio_mirror *mirror;
+		void (*func)(struct list_head *);
+
+		/* remember fatal errors */
+		if (nfs_error_is_fatal(desc->pg_error))
+			mapping_set_error(desc->pg_inode->i_mapping,
+					  desc->pg_error);
+
+		func = desc->pg_completion_ops->error_cleanup;
+		for (midx = 0; midx < desc->pg_mirror_count; midx++) {
+			mirror = &desc->pg_mirrors[midx];
+			func(&mirror->pg_list);
+		}
+	}
 	return 0;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b1acc4135c3c..0fb3552ccfbe 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2026,15 +2026,13 @@ static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
-
 	struct nfs_pgio_header *hdr;
 	int ret;
 
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
-		return -ENOMEM;
+		desc->pg_error = -ENOMEM;
+		return desc->pg_error;
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
 
@@ -2157,15 +2155,13 @@ static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
-
 	struct nfs_pgio_header *hdr;
 	int ret;
 
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
-		return -ENOMEM;
+		desc->pg_error = -ENOMEM;
+		return desc->pg_error;
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
-- 
2.5.0

