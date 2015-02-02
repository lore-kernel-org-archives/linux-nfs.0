Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:62809 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbbBBWkn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:40:43 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so88020603pad.7
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:43 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 31/53] pnfs: release lseg in pnfs_generic_pg_cleanup
Date: Mon,  2 Feb 2015 14:38:45 -0800
Message-Id: <1422916747-86649-32-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

This is needed to support mirrored writes - the first write can't just
trash the lseg, we need to keep it around until all mirrors have
written.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c |  2 ++
 fs/nfs/filelayout/filelayout.c   |  2 ++
 fs/nfs/objlayout/objio_osd.c     |  2 ++
 fs/nfs/pnfs.c                    | 32 ++++++++++++++------------------
 fs/nfs/pnfs.h                    |  1 +
 5 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 77fec6a..1cac3c1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -860,12 +860,14 @@ static const struct nfs_pageio_ops bl_pg_read_ops = {
 	.pg_init = bl_pg_init_read,
 	.pg_test = bl_pg_test_read,
 	.pg_doio = pnfs_generic_pg_readpages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static const struct nfs_pageio_ops bl_pg_write_ops = {
 	.pg_init = bl_pg_init_write,
 	.pg_test = bl_pg_test_write,
 	.pg_doio = pnfs_generic_pg_writepages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static struct pnfs_layoutdriver_type blocklayout_type = {
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 5d2eadc..2af32fc 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -933,12 +933,14 @@ static const struct nfs_pageio_ops filelayout_pg_read_ops = {
 	.pg_init = filelayout_pg_init_read,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
 	.pg_init = filelayout_pg_init_write,
 	.pg_test = filelayout_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9e5bc42..d007780 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -607,12 +607,14 @@ static const struct nfs_pageio_ops objio_pg_read_ops = {
 	.pg_init = objio_init_read,
 	.pg_test = objio_pg_test,
 	.pg_doio = pnfs_generic_pg_readpages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static const struct nfs_pageio_ops objio_pg_write_ops = {
 	.pg_init = objio_init_write,
 	.pg_test = objio_pg_test,
 	.pg_doio = pnfs_generic_pg_writepages,
+	.pg_cleanup = pnfs_generic_pg_cleanup,
 };
 
 static struct pnfs_layoutdriver_type objlayout_type = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 63992c8..2da2e77 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1631,6 +1631,16 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
+void
+pnfs_generic_pg_cleanup(struct nfs_pageio_descriptor *desc)
+{
+	if (desc->pg_lseg) {
+		pnfs_put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_cleanup);
+
 /*
  * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
  * of bytes (maximum @req->wb_bytes) that can be coalesced.
@@ -1756,11 +1766,9 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	enum pnfs_try_status trypnfs;
 
-	desc->pg_lseg = NULL;
 	trypnfs = pnfs_try_to_write_data(hdr, call_ops, lseg, how);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
 		pnfs_write_through_mds(desc, hdr);
-	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
@@ -1779,17 +1787,13 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
 		return -ENOMEM;
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
+
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
-	if (ret != 0) {
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-	} else
+	if (!ret)
 		pnfs_do_write(desc, hdr, desc->pg_ioflags);
 	return ret;
 }
@@ -1874,11 +1878,9 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 	struct pnfs_layout_segment *lseg = desc->pg_lseg;
 	enum pnfs_try_status trypnfs;
 
-	desc->pg_lseg = NULL;
 	trypnfs = pnfs_try_to_read_data(hdr, call_ops, lseg);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
 		pnfs_read_through_mds(desc, hdr);
-	pnfs_put_lseg(lseg);
 }
 
 static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
@@ -1897,18 +1899,12 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
 	if (!hdr) {
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		ret = -ENOMEM;
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-		return ret;
+		return -ENOMEM;
 	}
 	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
-	if (ret != 0) {
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-	} else
+	if (!ret)
 		pnfs_do_read(desc, hdr);
 	return ret;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 892678d..00a0a4a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -230,6 +230,7 @@ void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			        struct nfs_page *req, u64 wb_size);
+void pnfs_generic_pg_cleanup(struct nfs_pageio_descriptor *);
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 			    struct nfs_page *prev, struct nfs_page *req);
-- 
1.9.3

