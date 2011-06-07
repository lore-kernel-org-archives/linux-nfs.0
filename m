Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51524 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRcg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:36 -0400
Date: Tue, 7 Jun 2011 13:32:34 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 55/88] SQUASHME: pnfsblock: write_begin adjust for removed
 fields
Message-ID: <03c95cf35d2e373e504440a62d90e833d81fc375.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

ok_to_use_pnfs and PG_USE_PNFS are gone, instead test req->wb_lseg for NULL.
This also means that the entire do_flush routine is redundant.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |   21 ++++-----------------
 1 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 66044d4..eb5760f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -988,10 +988,10 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
 	if (bl->bl_blocksize < (PAGE_CACHE_SIZE >> 9)) {
 		dprintk("%s Can't handle blocksize %llu\n", __func__,
 			(u64)bl->bl_blocksize);
-		fsdata->ok_to_use_pnfs = 0;
+		put_lseg(fsdata->lseg);
+		fsdata->lseg = NULL;
 		return 0;
 	}
-	fsdata->ok_to_use_pnfs = 1;
 	if (PageMappedToDisk(page)) {
 		/* Basically, this is a flag that says we have
 		 * successfully called write_begin already on this page.
@@ -1014,7 +1014,8 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
 		 * should be true if we get here.
 		 */
 		BUG_ON(PagePrivate(page));
-		fsdata->ok_to_use_pnfs = 0;
+		put_lseg(fsdata->lseg);
+		fsdata->lseg = NULL;
 		kfree(pages_to_mark);
 		ret = 0;
 	} else {
@@ -1122,19 +1123,6 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 }
 
-/* This checks if old req will likely use same io method as soon
- * to be created request, and returns False if they are the same.
- */
-static int
-bl_do_flush(struct pnfs_layout_segment *lseg, struct nfs_page *req,
-	    struct pnfs_fsdata *fsdata)
-{
-	int will_try_pnfs;
-	dprintk("%s enter\n", __func__);
-	will_try_pnfs = fsdata ? (fsdata->ok_to_use_pnfs) : (lseg != NULL);
-	return will_try_pnfs != test_bit(PG_USE_PNFS, &req->wb_flags);
-}
-
 static struct layoutdriver_io_operations blocklayout_io_operations = {
 	.commit				= bl_commit,
 	.read_pagelist			= bl_read_pagelist,
@@ -1156,7 +1144,6 @@ static struct layoutdriver_io_operations blocklayout_io_operations = {
 static struct layoutdriver_policy_operations blocklayout_policy_operations = {
 	.get_stripesize			= bl_get_stripesize,
 	.pg_test			= bl_pg_test,
-	.do_flush			= bl_do_flush,
 };
 
 static struct pnfs_layoutdriver_type blocklayout_type = {
-- 
1.7.4.1

