Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36014 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbcLJE05 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2016 23:26:57 -0500
Received: by mail-io0-f196.google.com with SMTP id b194so10759744ioa.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Dec 2016 20:26:57 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS/flexfiles: Ensure we have enough buffer for layoutreturn
Date: Fri,  9 Dec 2016 23:26:52 -0500
Message-Id: <20161210042652.21731-2-trond.myklebust@primarydata.com>
In-Reply-To: <20161210042652.21731-1-trond.myklebust@primarydata.com>
References: <20161210042652.21731-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The flexfiles client can piggyback both layout errors and layoutstats
as part of the layoutreturn. Both these payloads can get large, with
20 layout error entries taking up about 1.2K, and 4 layoutstats entries
taking up another 1K.
This patch allows a maximum payload of 4k by allocating a full page.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 32 ++++++++++++++++++++++++++------
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 49954442173d..9e111d07f667 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2049,16 +2049,28 @@ ff_layout_encode_layoutreturn(struct xdr_stream *xdr,
 {
 	const struct nfs4_layoutreturn_args *args = voidargs;
 	struct nfs4_flexfile_layoutreturn_args *ff_args = ff_opaque->data;
+	struct xdr_buf tmp_buf = {
+		.head = {
+			[0] = {
+				.iov_base = page_address(ff_args->pages[0]),
+			},
+		},
+		.buflen = PAGE_SIZE,
+	};
+	struct xdr_stream tmp_xdr;
 	__be32 *start;
 
 	dprintk("%s: Begin\n", __func__);
-	start = xdr_reserve_space(xdr, 4);
-	BUG_ON(!start);
 
-	ff_layout_encode_ioerr(xdr, args, ff_args);
-	ff_layout_encode_iostats_array(xdr, args, ff_args);
+	xdr_init_encode(&tmp_xdr, &tmp_buf, NULL);
+
+	ff_layout_encode_ioerr(&tmp_xdr, args, ff_args);
+	ff_layout_encode_iostats_array(&tmp_xdr, args, ff_args);
+
+	start = xdr_reserve_space(xdr, 4);
+	*start = cpu_to_be32(tmp_buf.len);
+	xdr_write_pages(xdr, ff_args->pages, 0, tmp_buf.len);
 
-	*start = cpu_to_be32((xdr->p - start - 1) * 4);
 	dprintk("%s: Return\n", __func__);
 }
 
@@ -2075,6 +2087,7 @@ ff_layout_free_layoutreturn(struct nfs4_xdr_opaque_data *args)
 	ff_layout_free_ds_ioerr(&ff_args->errors);
 	ff_layout_free_iostats_array(ff_args->devinfo, ff_args->num_dev);
 
+	put_page(ff_args->pages[0]);
 	kfree(ff_args);
 }
 
@@ -2091,7 +2104,10 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 
 	ff_args = kmalloc(sizeof(*ff_args), GFP_KERNEL);
 	if (!ff_args)
-		return -ENOMEM;
+		goto out_nomem;
+	ff_args->pages[0] = alloc_page(GFP_KERNEL);
+	if (!ff_args->pages[0])
+		goto out_nomem_free;
 
 	INIT_LIST_HEAD(&ff_args->errors);
 	ff_args->num_errors = ff_layout_fetch_ds_ioerr(args->layout,
@@ -2106,6 +2122,10 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 	args->ld_private->ops = &layoutreturn_ops;
 	args->ld_private->data = ff_args;
 	return 0;
+out_nomem_free:
+	kfree(ff_args);
+out_nomem:
+	return -ENOMEM;
 }
 
 static int
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 7223c4ea8cde..f4f39b0ab09b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -113,6 +113,7 @@ struct nfs4_flexfile_layoutreturn_args {
 	struct nfs42_layoutstat_devinfo devinfo[FF_LAYOUTSTATS_MAXDEV];
 	unsigned int num_errors;
 	unsigned int num_dev;
+	struct page *pages[1];
 };
 
 static inline struct nfs4_flexfile_layout *
-- 
2.9.3

