From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/7] SQUASHME: pnfsblock: write_begin adjust for removed fields
Date: Fri, 11 Jun 2010 03:40:34 -0400
Message-ID: <1276242039-18649-3-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab0FKHky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:54 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVc027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:53 -0700 (PDT)
In-Reply-To: <1276242039-18649-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
1.6.6.1

