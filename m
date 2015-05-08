Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44304 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862AbbEHI5B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:57:01 -0400
From: NeilBrown <neilb@suse.de>
To: linux-raid@vger.kernel.org, Shaohua Li <shli@kernel.org>
Date: Fri, 08 May 2015 18:56:11 +1000
Subject: [PATCH 3/7] md/raid5: more incorrect BUG_ON in handle_stripe_fill.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20150508085611.19179.1093.stgit@notabene.brown>
In-Reply-To: <20150508085345.19179.8866.stgit@notabene.brown>
References: <20150508085345.19179.8866.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is not incorrect to call handle_stripe_fill() when
a batch of full-stripe writes is active.
It is, however, a BUG if fetch_block() then decides
it needs to actually fetch anything.

So move the 'BUG_ON' to where it belongs.

Signed-off-by: NeilBrown  <neilb@suse.de>
Fixes: 59fc630b8b5f ("RAID5: batch adjacent full stripe write")
---
 drivers/md/raid5.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 91a1e8b26b52..415cac6d89bd 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -3302,6 +3302,7 @@ static int fetch_block(struct stripe_head *sh, struct stripe_head_state *s,
 		 */
 		BUG_ON(test_bit(R5_Wantcompute, &dev->flags));
 		BUG_ON(test_bit(R5_Wantread, &dev->flags));
+		BUG_ON(sh->batch_head);
 		if ((s->uptodate == disks - 1) &&
 		    (s->failed && (disk_idx == s->failed_num[0] ||
 				   disk_idx == s->failed_num[1]))) {
@@ -3370,7 +3371,6 @@ static void handle_stripe_fill(struct stripe_head *sh,
 {
 	int i;
 
-	BUG_ON(sh->batch_head);
 	/* look for blocks to read/compute, skip this if a compute
 	 * is already in flight, or if the stripe contents are in the
 	 * midst of changing due to a write


