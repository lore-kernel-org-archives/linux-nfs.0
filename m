Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50093 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbaESPP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:15:28 -0400
Received: by mail-ie0-f174.google.com with SMTP id lx4so2457492iec.33
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 08:15:28 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 8/8] pnfs: merge identical functions
Date: Mon, 19 May 2014 11:15:08 -0400
Message-Id: <1400512508-7530-9-git-send-email-dros@primarydata.com>
In-Reply-To: <1400512508-7530-1-git-send-email-dros@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_readhdr_free and pnfs_writehdr_free were identical - merge them
info pnfs_pgio_header_free. Also drop EXPORT_SYMBOL_GPL of static function.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pnfs.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 79792a4..d45cca8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1552,12 +1552,11 @@ pnfs_do_write(struct nfs_pageio_descriptor *desc,
 	pnfs_put_lseg(lseg);
 }
 
-static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
+static void pnfs_pgio_header_free(struct nfs_pgio_header *hdr)
 {
 	pnfs_put_lseg(hdr->lseg);
 	nfs_pgio_header_free(hdr);
 }
-EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
 
 int
 pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
@@ -1572,7 +1571,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
 	}
-	nfs_pgheader_init(desc, hdr, pnfs_writehdr_free);
+	nfs_pgheader_init(desc, hdr, pnfs_pgio_header_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
@@ -1671,13 +1670,6 @@ pnfs_do_read(struct nfs_pageio_descriptor *desc, struct nfs_pgio_header *hdr)
 	pnfs_put_lseg(lseg);
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
@@ -1692,7 +1684,7 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 		desc->pg_lseg = NULL;
 		return ret;
 	}
-	nfs_pgheader_init(desc, hdr, pnfs_readhdr_free);
+	nfs_pgheader_init(desc, hdr, pnfs_pgio_header_free);
 	hdr->lseg = pnfs_get_lseg(desc->pg_lseg);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret != 0) {
-- 
1.8.5.2 (Apple Git-48)

