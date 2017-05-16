Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34928 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752373AbdEPNgg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 May 2017 09:36:36 -0400
Received: by mail-io0-f196.google.com with SMTP id o12so14460395iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 May 2017 06:36:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Remove unused fields in the page I/O structures
Date: Tue, 16 May 2017 09:36:26 -0400
Message-Id: <20170516133628.16525-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170516133628.16525-1-trond.myklebust@primarydata.com>
References: <20170516133628.16525-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the 'layout_private' fields that were only used by the pNFS OSD
layout driver.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        | 2 --
 include/linux/nfs_page.h | 1 -
 include/linux/nfs_xdr.h  | 1 -
 3 files changed, 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ad92b401326c..de107d866297 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -51,7 +51,6 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = mirror->pg_count;
 	hdr->dreq = desc->pg_dreq;
-	hdr->layout_private = desc->pg_layout_private;
 	hdr->release = release;
 	hdr->completion_ops = desc->pg_completion_ops;
 	if (hdr->completion_ops->init_hdr)
@@ -711,7 +710,6 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
 	desc->pg_dreq = NULL;
-	desc->pg_layout_private = NULL;
 	desc->pg_bsize = bsize;
 
 	desc->pg_mirror_count = 1;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 247cc3d3498f..6138cf91346b 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -94,7 +94,6 @@ struct nfs_pageio_descriptor {
 	const struct nfs_pgio_completion_ops *pg_completion_ops;
 	struct pnfs_layout_segment *pg_lseg;
 	struct nfs_direct_req	*pg_dreq;
-	void			*pg_layout_private;
 	unsigned int		pg_bsize;	/* default bsize for mirrors */
 
 	u32			pg_mirror_count;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b28c83475ee8..ee998ed08cf6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1436,7 +1436,6 @@ struct nfs_pgio_header {
 	const struct nfs_pgio_completion_ops *completion_ops;
 	const struct nfs_rw_ops	*rw_ops;
 	struct nfs_direct_req	*dreq;
-	void			*layout_private;
 	spinlock_t		lock;
 	/* fields protected by lock */
 	int			pnfs_error;
-- 
2.9.4

