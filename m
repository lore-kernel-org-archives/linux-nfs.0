Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53894 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbaETSId (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 09/12] nfs: create a common pnfs_pgiohdr_free function
Date: Tue, 20 May 2014 14:08:16 -0400
Message-ID: <1400609299-32558-10-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is exactly the same for reads and writes.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 69751d4..b6ebea8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1499,6 +1499,12 @@ pnfs_do_rw(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr,
 	return ret;
 }
 
+static void pnfs_pgiohdr_free(struct nfs_pgio_header *hdr)
+{
+	pnfs_put_lseg(hdr->lseg);
+	nfs_pgio_header_free(hdr);
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1541,13 +1547,6 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_WRITE);
 }
 
-static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
-{
-	pnfs_put_lseg(hdr->lseg);
-	nfs_pgio_header_free(hdr);
-}
-EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
-
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
@@ -1561,7 +1560,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
 	}
-	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
+	nfs_pgheader_init(desc, hdr, pnfs_pgiohdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
@@ -1623,13 +1622,6 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 		nfs_inc_stats(hdr->inode, NFSIOS_PNFS_READ);
 }
 
-static void pnfs_readhdr_free(struct nfs_pgio_header *hdr)
-{
-	pnfs_put_lseg(hdr->lseg);
-	nfs_pgio_header_free(hdr);
-}
-EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
-
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
@@ -1644,7 +1636,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 		desc->pg_lseg = NULL;
 		return ret;
 	}
-	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
+	nfs_pgheader_init(desc, hdr, pnfs_pgiohdr_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
-- 
1.9.2

