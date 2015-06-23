Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35391 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbbFWLwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:41 -0400
Received: by pactm7 with SMTP id tm7so5616297pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:41 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-v2 06/10] pNFS/flexfiles: track when layout is first used
Date: Tue, 23 Jun 2015 19:52:00 +0800
Message-Id: <1435060324-13279-7-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
References: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that we can report cumulative time since the beginning
of statistics collection of the layout.

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 +++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index acbe677..05329ca 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -453,9 +453,13 @@ nfs4_ff_layout_calc_completion_time(struct rpc_task *task)
 }
 
 static void
-nfs4_ff_layoutstat_start_io(struct nfs4_ff_layoutstat *layoutstat)
+nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
+			    struct nfs4_ff_layoutstat *layoutstat)
 {
+	static const ktime_t notime = {0};
+
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
+	cmpxchg(&mirror->start_time, notime, ktime_get());
 }
 
 static void
@@ -493,7 +497,7 @@ nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested)
 {
 	spin_lock(&mirror->lock);
-	nfs4_ff_layoutstat_start_io(&mirror->read_stat);
+	nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
 	spin_unlock(&mirror->lock);
 }
@@ -516,7 +520,7 @@ nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
 		__u64 requested)
 {
 	spin_lock(&mirror->lock);
-	nfs4_ff_layoutstat_start_io(&mirror->write_stat);
+	nfs4_ff_layoutstat_start_io(mirror, &mirror->write_stat);
 	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
 	spin_unlock(&mirror->lock);
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index f7493f7..0e7366f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -74,6 +74,7 @@ struct nfs4_ff_layout_mirror {
 	spinlock_t			lock;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
+	ktime_t				start_time;
 };
 
 struct nfs4_ff_layout_segment {
-- 
1.8.3.1

