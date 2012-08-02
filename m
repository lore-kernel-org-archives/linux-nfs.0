Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44277 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab2HBMek (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 08:34:40 -0400
Message-ID: <501A73D3.7090000@panasas.com>
Date: Thu, 2 Aug 2012 15:34:27 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
CC: Peng Tao <tao.peng@emc.com>
Subject: [PATCH 1/3] NFS41: add pg_layout_private to nfs_pageio_descriptor
References: <501A7369.6090808@panasas.com>
In-Reply-To: <501A7369.6090808@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


To allow layout driver to pass private information around
pg_init/pg_doio.

Signed-off-by: Peng Tao <tao.peng@emc.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pagelist.c        | 2 ++
 include/linux/nfs_page.h | 1 +
 include/linux/nfs_xdr.h  | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aed913c..342ca5e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -49,6 +49,7 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = desc->pg_count;
 	hdr->dreq = desc->pg_dreq;
+	hdr->layout_private = desc->pg_layout_private;
 	hdr->release = release;
 	hdr->completion_ops = desc->pg_completion_ops;
 	if (hdr->completion_ops->init_hdr)
@@ -267,6 +268,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
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
index 8aadd90..58023cd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1244,6 +1244,7 @@ struct nfs_pgio_header {
 	void (*release) (struct nfs_pgio_header *hdr);
 	const struct nfs_pgio_completion_ops *completion_ops;
 	struct nfs_direct_req	*dreq;
+	void			*layout_private;
 	spinlock_t		lock;
 	/* fields protected by lock */
 	int			pnfs_error;
-- 
1.7.10.2.677.gb6bc67f


