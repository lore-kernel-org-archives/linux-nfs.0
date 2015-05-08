Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44388 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbbEHI51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:57:27 -0400
From: NeilBrown <neilb@suse.de>
To: linux-raid@vger.kernel.org, Shaohua Li <shli@kernel.org>
Date: Fri, 08 May 2015 18:56:12 +1000
Subject: [PATCH 7/7] md/raid5: fix handling of degraded stripes in batches.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20150508085612.19179.92120.stgit@notabene.brown>
In-Reply-To: <20150508085345.19179.8866.stgit@notabene.brown>
References: <20150508085345.19179.8866.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need for special handling of stripe-batches when the array
is degraded.

There may be if there is a failure in the batch, but STRIPE_DEGRADED
does not imply an error.

So don't set STRIPE_BATCH_ERR in ops_run_io just because the array is
degraded.
This actually causes a bug: the STRIPE_DEGRADED flag gets cleared in
check_break_stripe_batch_list() and so the bitmap bit gets cleared
when it shouldn't.

So in check_break_stripe_batch_list(), split the batch up completely -
again STRIPE_DEGRADED isn't meaningful.

Also don't set STRIPE_BATCH_ERR when there is a write error to a
replacement device.  This simply removes the replacement device and
requires no extra handling.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 drivers/md/raid5.c |   17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 3873eaa6fa2e..1ba97fdc6df1 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -1078,9 +1078,6 @@ again:
 			pr_debug("skip op %ld on disc %d for sector %llu\n",
 				bi->bi_rw, i, (unsigned long long)sh->sector);
 			clear_bit(R5_LOCKED, &sh->dev[i].flags);
-			if (sh->batch_head)
-				set_bit(STRIPE_BATCH_ERR,
-					&sh->batch_head->state);
 			set_bit(STRIPE_HANDLE, &sh->state);
 		}
 
@@ -2448,7 +2445,7 @@ static void raid5_end_write_request(struct bio *bi, int error)
 	}
 	rdev_dec_pending(rdev, conf->mddev);
 
-	if (sh->batch_head && !uptodate)
+	if (sh->batch_head && !uptodate && !replacement)
 		set_bit(STRIPE_BATCH_ERR, &sh->batch_head->state);
 
 	if (!test_and_clear_bit(R5_DOUBLE_LOCKED, &sh->dev[i].flags))
@@ -4214,15 +4211,9 @@ static void check_break_stripe_batch_list(struct stripe_head *sh)
 		return;
 
 	head_sh = sh;
-	do {
-		sh = list_first_entry(&sh->batch_list,
-				      struct stripe_head, batch_list);
-		BUG_ON(sh == head_sh);
-	} while (!test_bit(STRIPE_DEGRADED, &sh->state));
 
-	while (sh != head_sh) {
-		next = list_first_entry(&sh->batch_list,
-					struct stripe_head, batch_list);
+	list_for_each_entry_safe(sh, next, &head_sh->batch_list, batch_list) {
+
 		list_del_init(&sh->batch_list);
 
 		set_mask_bits(&sh->state, ~STRIPE_EXPAND_SYNC_FLAG,
@@ -4242,8 +4233,6 @@ static void check_break_stripe_batch_list(struct stripe_head *sh)
 
 		set_bit(STRIPE_HANDLE, &sh->state);
 		release_stripe(sh);
-
-		sh = next;
 	}
 }
 


