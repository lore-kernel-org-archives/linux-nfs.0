Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45785 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238AbaHGHVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:42 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 13/17] pnfs/blocklayout: don't set pages uptodate
Date: Thu,  7 Aug 2014 09:23:45 +0200
Message-Id: <1407396229-4785-14-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The core nfs code handles setting pages uptodate on reads, no need to mess
with the pageflags outselves.  Also remove a debug function to dump page
flags.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 6484b9f..92be984 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -49,20 +49,6 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Andy Adamson <andros@citi.umich.edu>");
 MODULE_DESCRIPTION("The NFSv4.1 pNFS Block layout driver");
 
-static void print_page(struct page *page)
-{
-	dprintk("PRINTPAGE page %p\n", page);
-	dprintk("	PagePrivate %d\n", PagePrivate(page));
-	dprintk("	PageUptodate %d\n", PageUptodate(page));
-	dprintk("	PageError %d\n", PageError(page));
-	dprintk("	PageDirty %d\n", PageDirty(page));
-	dprintk("	PageReferenced %d\n", PageReferenced(page));
-	dprintk("	PageLocked %d\n", PageLocked(page));
-	dprintk("	PageWriteback %d\n", PageWriteback(page));
-	dprintk("	PageMappedToDisk %d\n", PageMappedToDisk(page));
-	dprintk("\n");
-}
-
 /* Given the be associated with isect, determine if page data needs to be
  * initialized.
  */
@@ -187,16 +173,9 @@ retry:
 	return bio;
 }
 
-/* This is basically copied from mpage_end_io_read */
 static void bl_end_io_read(struct bio *bio, int err)
 {
 	struct parallel_io *par = bio->bi_private;
-	struct bio_vec *bvec;
-	int i;
-
-	if (!err)
-		bio_for_each_segment_all(bvec, bio, i)
-			SetPageUptodate(bvec->bv_page);
 
 	if (err) {
 		struct nfs_pgio_header *header = par->data;
@@ -205,6 +184,7 @@ static void bl_end_io_read(struct bio *bio, int err)
 			header->pnfs_error = -EIO;
 		pnfs_set_lo_fail(header->lseg);
 	}
+
 	bio_put(bio);
 	put_parallel(par);
 }
@@ -304,8 +284,6 @@ bl_read_pagelist(struct nfs_pgio_header *hdr)
 			/* Fill hole w/ zeroes w/o accessing device */
 			dprintk("%s Zeroing page for hole\n", __func__);
 			zero_user_segment(pages[i], pg_offset, pg_len);
-			print_page(pages[i]);
-			SetPageUptodate(pages[i]);
 		} else {
 			struct pnfs_block_extent *be_read;
 
-- 
1.9.1

