Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32853 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbFZBqG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 21:46:06 -0400
Received: by pdjn11 with SMTP id n11so64615759pdj.0
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 18:46:05 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] pnfs/flexfiles: protect ktime manipulation with mirror lock
Date: Fri, 26 Jun 2015 09:45:49 +0800
Message-Id: <1435283149-14223-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It looks as if xchg() and cmpxchg() are not available for 64-bit integers on sparc32:

> New breakage seen in linux-next today:
>
> ERROR: "__xchg_called_with_bad_pointer" [fs/nfs/flexfilelayout/nfs_layout_flexfiles.ko] undefined!
> ERROR: "__cmpxchg_called_with_bad_pointer" [fs/nfs/flexfilelayout/nfs_layout_flexfiles.ko] undefined!
> make[2]: *** [__modpost] Error 1
> make[1]: *** [modules] Error 2

Given that mirror ktime manipulation is already under mirror->lock, let's make use of the fact.

Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index d3b3b62..85b4234 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -417,21 +417,9 @@ ff_layout_get_lseg_count(struct nfs4_ff_layout_segment *fls)
 static void
 nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer)
 {
-	ktime_t old, new;
-
-	/*
-	 * Note: careful here!
-	 * If the counter is zero, then we must not increment it until after
-	 * we've set the start_time.
-	 * If we were instead to use atomic_inc_return(), then another
-	 * request might come in, bump, and then call end_busy_timer()
-	 * before we've set the timer->start_time.
-	 */
-	old = timer->start_time;
-	if (atomic_inc_not_zero(&timer->n_ops) == 0) {
-		new = ktime_get();
-		cmpxchg(&timer->start_time.tv64, old.tv64, new.tv64);
-		atomic_inc(&timer->n_ops);
+	/* first IO request? */
+	if (atomic_inc_return(&timer->n_ops) == 1) {
+		timer->start_time = ktime_get();
 	}
 }
 
@@ -440,9 +428,12 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer)
 {
 	ktime_t start, now;
 
+	if (atomic_dec_return(&timer->n_ops) < 0)
+		WARN_ON_ONCE(1);
+
 	now = ktime_get();
-	start.tv64 = xchg(&timer->start_time.tv64, now.tv64);
-	atomic_dec(&timer->n_ops);
+	start = timer->start_time;
+	timer->start_time = now;
 	return ktime_sub(now, start);
 }
 
@@ -460,8 +451,10 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	ktime_t now = ktime_get();
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
-	cmpxchg(&mirror->start_time.tv64, notime.tv64, now.tv64);
-	cmpxchg(&mirror->last_report_time.tv64, notime.tv64, now.tv64);
+	if (ktime_equal(mirror->start_time, notime))
+		mirror->start_time = now;
+	if (ktime_equal(mirror->last_report_time, notime))
+		mirror->last_report_time = now;
 	if (ktime_to_ms(ktime_sub(now, mirror->last_report_time)) >=
 			FF_LAYOUTSTATS_REPORT_INTERVAL) {
 		mirror->last_report_time = now;
-- 
1.8.3.1

