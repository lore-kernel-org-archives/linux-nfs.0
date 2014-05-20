Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbaETSIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:36 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 12/12] nfs: Create a common pnfs_generic_rwpages() function
Date: Tue, 20 May 2014 14:08:19 -0400
Message-ID: <1400609299-32558-13-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code is almost identical, so it might as well be combined.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index df07832..6f1fd5e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1505,6 +1505,18 @@ static void pnfs_pgiohdr_free(struct nfs_pgio_header *hdr)
 	nfs_pgio_header_free(hdr);
 }
 
+static int pnfs_generic_pg_rwpages(struct nfs_pageio_descriptor *desc,
+			int (*do_pgio)(struct nfs_pageio_descriptor *,
+				       struct nfs_pgio_header *))
+{
+	int ret = nfs_generic_pgios_common(desc, pnfs_pgiohdr_free, do_pgio);
+	if (ret != 0) {
+		pnfs_put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+	}
+	return ret;
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1551,12 +1563,7 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
-	int ret = nfs_generic_pgios_common(desc, pnfs_pgiohdr_free, pnfs_do_write);
-	if (ret != 0) {
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-	}
-	return ret;
+	return pnfs_generic_pg_rwpages(desc, pnfs_do_write);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
@@ -1614,12 +1621,7 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 int
 pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
-	int ret = nfs_generic_pgios_common(desc, pnfs_pgiohdr_free, pnfs_do_read);
-	if (ret != 0) {
-		pnfs_put_lseg(desc->pg_lseg);
-		desc->pg_lseg = NULL;
-	}
-	return ret;
+	return pnfs_generic_pg_rwpages(desc, pnfs_do_read);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
 
-- 
1.9.2

