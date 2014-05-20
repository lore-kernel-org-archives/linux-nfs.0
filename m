Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaETSIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:35 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 11/12] nfs: pnfs can use nfs_generic_pgios_common() too!
Date: Tue, 20 May 2014 14:08:18 -0400
Message-ID: <1400609299-32558-12-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We just need to take a few extra steps in case of an error.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 41 ++++++++---------------------------------
 1 file changed, 8 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b6ebea8..df07832 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1540,34 +1540,22 @@ pnfs_try_to_write_data(struct nfs_pgio_header *hdr, int how)
 	return NFS_SERVER(hdr->inode)->pnfs_curr_ld->write_pagelist(hdr, how);
 }
 
-static void
+static int
 pnfs_do_write(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
 	if (pnfs_do_rw(desc, hdr, pnfs_try_to_write_data))
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_WRITE);
+	return 0;
 }
 
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_header *hdr;
-	int ret;
-
-	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
-	if (!hdr) {
-		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-		return -ENOMEM;
-	}
-	nfs_pgheader_init(desc, hdr, pnfs_pgiohdr_free);
-	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
-	ret = nfs_generic_pgio(desc, hdr);
+	int ret = nfs_generic_pgios_common(desc, pnfs_pgiohdr_free, pnfs_do_write);
 	if (ret != 0) {
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
-	} else
-		pnfs_do_write(desc, hdr);
+	}
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
@@ -1615,35 +1603,22 @@ pnfs_try_to_read_data(struct nfs_pgio_header *hdr, int how)
 	return NFS_SERVER(hdr->inode)->pnfs_curr_ld->read_pagelist(hdr);
 }
 
-static void
+static int
 pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 {
 	if (pnfs_do_rw(desc, hdr, pnfs_try_to_read_data))
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_READ);
+	return 0;
 }
 
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	struct nfs_pgio_header *hdr;
-	int ret;
-
-	hdr = nfs_pgio_header_alloc(desc->pg_rw_ops);
-	if (!hdr) {
-		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
-		ret = -ENOMEM;
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-		return ret;
-	}
-	nfs_pgheader_init(desc, hdr, pnfs_pgiohdr_free);
-	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
-	ret = nfs_generic_pgio(desc, hdr);
+	int ret = nfs_generic_pgios_common(desc, pnfs_pgiohdr_free, pnfs_do_read);
 	if (ret != 0) {
 		pnfs_put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
-	} else
-		pnfs_do_read(desc, hdr);
+	}
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
-- 
1.9.2

