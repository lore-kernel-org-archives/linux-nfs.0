Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35517 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbbFWLwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:54 -0400
Received: by pactm7 with SMTP id tm7so5619099pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:53 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-v2 10/10] pnfs/flexfiles: report layoutstat regularly
Date: Tue, 23 Jun 2015 19:52:04 +0800
Message-Id: <1435060324-13279-11-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
References: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a simple scheme, report every minute if IO is still going on.

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 27 +++++++++++++++++++++++----
 fs/nfs/flexfilelayout/flexfilelayout.h |  6 +++++-
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ee24f65..fc7eb41 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -454,14 +454,23 @@ nfs4_ff_layout_calc_completion_time(struct rpc_task *task)
 	return ktime_sub(ktime_get(), task->tk_start);
 }
 
-static void
+static bool
 nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 			    struct nfs4_ff_layoutstat *layoutstat)
 {
 	static const ktime_t notime = {0};
+	ktime_t now = ktime_get();
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
-	cmpxchg(&mirror->start_time, notime, ktime_get());
+	cmpxchg(&mirror->start_time, notime, now);
+	cmpxchg(&mirror->last_report_time, notime, now);
+	if (ktime_to_ms(ktime_sub(now, mirror->last_report_time)) >=
+			FF_LAYOUTSTATS_REPORT_INTERVAL) {
+		mirror->last_report_time = now;
+		return true;
+	}
+
+	return false;
 }
 
 static void
@@ -498,10 +507,15 @@ static void
 nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested)
 {
+	bool report;
+
 	spin_lock(&mirror->lock);
-	nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat);
+	report = nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
 	spin_unlock(&mirror->lock);
+
+	if (report)
+		pnfs_report_layoutstat(mirror->lseg->pls_layout->plh_inode);
 }
 
 static void
@@ -521,10 +535,15 @@ static void
 nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested)
 {
+	bool report;
+
 	spin_lock(&mirror->lock);
-	nfs4_ff_layoutstat_start_io(mirror, &mirror->write_stat);
+	report = nfs4_ff_layoutstat_start_io(mirror , &mirror->write_stat);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
 	spin_unlock(&mirror->lock);
+
+	if (report)
+		pnfs_report_layoutstat(mirror->lseg->pls_layout->plh_inode);
 }
 
 static void
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 7e24887..6fcd8d5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -15,6 +15,9 @@
  * due to network error etc. */
 #define NFS4_FLEXFILE_LAYOUT_MAX_MIRROR_CNT 4096
 
+/* LAYOUTSTATS report interval in ms */
+#define FF_LAYOUTSTATS_REPORT_INTERVAL (60000L)
+
 struct nfs4_ff_ds_version {
 	u32				version;
 	u32				minor_version;
@@ -62,6 +65,7 @@ struct nfs4_ff_layoutstat {
 };
 
 struct nfs4_ff_layout_mirror {
+	struct pnfs_layout_segment	*lseg; /* back pointer */
 	u32				ds_count;
 	u32				efficiency;
 	struct nfs4_ff_layout_ds	*mirror_ds;
@@ -75,7 +79,7 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
-	struct pnfs_layout_segment	*lseg; /* back pointer */
+	ktime_t				last_report_time;
 };
 
 struct nfs4_ff_layout_segment {
-- 
1.8.3.1

