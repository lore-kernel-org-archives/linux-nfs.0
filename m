Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56796 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab2E2Ej3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2012 00:39:29 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so5401164pbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 21:39:29 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com,
        Peng Tao <tao.peng@emc.com>
Subject: [PATCH-v2 2/3] NFS41: add pg_layout_private and moreio fields
Date: Tue, 29 May 2012 12:38:53 +0800
Message-Id: <1338266334-11490-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
References: <1338266334-11490-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow layout driver to pass private information around
pg_init/pg_doio.

Cc: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Peng Tao <tao.peng@emc.com>
---
 fs/nfs/pagelist.c        |    3 +++
 include/linux/nfs_page.h |    1 +
 include/linux/nfs_xdr.h  |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aed913c..a47d18a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -49,6 +49,8 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = desc->pg_count;
 	hdr->dreq = desc->pg_dreq;
+	hdr->layout_private = desc->pg_layout_private;
+	hdr->moreio = desc->pg_moreio;
 	hdr->release = release;
 	hdr->completion_ops = desc->pg_completion_ops;
 	if (hdr->completion_ops->init_hdr)
@@ -267,6 +269,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
 	desc->pg_dreq = NULL;
+	desc->pg_layout_private = NULL;
 }
 
 /**
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 88d166b..63093b1 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -69,6 +69,7 @@ struct nfs_pageio_descriptor {
 	const struct nfs_pgio_completion_ops *pg_completion_ops;
 	struct pnfs_layout_segment *pg_lseg;
 	struct nfs_direct_req	*pg_dreq;
+	void			*pg_layout_private;
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e53a3f..88e95a7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1224,6 +1224,8 @@ struct nfs_pgio_header {
 	void (*release) (struct nfs_pgio_header *hdr);
 	const struct nfs_pgio_completion_ops *completion_ops;
 	struct nfs_direct_req	*dreq;
+	void			*layout_private;
+	bool			moreio;
 	spinlock_t		lock;
 	/* fields protected by lock */
 	int			pnfs_error;
-- 
1.7.1.262.g5ef3d

