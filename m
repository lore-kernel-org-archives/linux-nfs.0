Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36462 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcHODFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Aug 2016 23:05:46 -0400
Received: by mail-it0-f68.google.com with SMTP id j124so2702052ith.3
        for <linux-nfs@vger.kernel.org>; Sun, 14 Aug 2016 20:05:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix layoutstat periodic reporting
Date: Sun, 14 Aug 2016 23:05:21 -0400
Message-Id: <1471230321-3066-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Putting the periodicity timer in the mirror instances is causing
non-scalable reporting behaviour and missed reporting intervals.
When you recall layouts and/or implement client side mirroring, it
leads to consecutive reports with only a few ms between RPC calls.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: d0379a5d066a9 ("pNFS/flexfiles: Support server-supplied...")
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index e6206eaf2bdf..ee1c94c7614c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -37,6 +37,7 @@ ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 	if (ffl) {
 		INIT_LIST_HEAD(&ffl->error_list);
 		INIT_LIST_HEAD(&ffl->mirrors);
+		ffl->last_report_time = ktime_get();
 		return &ffl->generic_hdr;
 	} else
 		return NULL;
@@ -640,19 +641,18 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 {
 	static const ktime_t notime = {0};
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
+	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
 	if (ktime_equal(mirror->start_time, notime))
 		mirror->start_time = now;
-	if (ktime_equal(mirror->last_report_time, notime))
-		mirror->last_report_time = now;
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
 		report_interval = (s64)layoutstats_timer * 1000LL;
-	if (ktime_to_ms(ktime_sub(now, mirror->last_report_time)) >=
+	if (ktime_to_ms(ktime_sub(now, ffl->last_report_time)) >=
 			report_interval) {
-		mirror->last_report_time = now;
+		ffl->last_report_time = now;
 		return true;
 	}
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 1bcdb15d0c41..3ee0c9fcea76 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -84,7 +84,6 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
-	ktime_t				last_report_time;
 	u32				report_interval;
 };
 
@@ -101,6 +100,7 @@ struct nfs4_flexfile_layout {
 	struct pnfs_ds_commit_info commit_info;
 	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
+	ktime_t			last_report_time; /* Layoutstat report times */
 };
 
 static inline struct nfs4_flexfile_layout *
-- 
2.7.4

