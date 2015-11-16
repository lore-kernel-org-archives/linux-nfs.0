Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38036 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbbKPQ6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Nov 2015 11:58:45 -0500
Received: by igbxm8 with SMTP id xm8so61436951igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 08:58:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Support server-supplied layoutstats sampling period
Date: Mon, 16 Nov 2015 11:58:42 -0500
Message-Id: <1447693122-16293-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some servers want to be able to control the frequency with which clients
report layoutstats, for instance, in order to monitor QoS for a particular
file or set of file. In order to support this, the flexfiles layout allows
the server to pass this info as a hint in the layout payload.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 +++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 03516c80855a..616817a46410 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -505,9 +505,17 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	}
 
 	p = xdr_inline_decode(&stream, 4);
-	if (p)
-		fls->flags = be32_to_cpup(p);
+	if (!p)
+		goto out_sort_mirrors;
+	fls->flags = be32_to_cpup(p);
+
+	p = xdr_inline_decode(&stream, 4);
+	if (!p)
+		goto out_sort_mirrors;
+	for (i=0; i < fls->mirror_array_cnt; i++)
+		fls->mirror_array[i]->report_interval = be32_to_cpup(p);
 
+out_sort_mirrors:
 	ff_layout_sort_mirrors(fls);
 	rc = ff_layout_check_layout(lgr);
 	if (rc)
@@ -603,7 +611,9 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 		mirror->start_time = now;
 	if (ktime_equal(mirror->last_report_time, notime))
 		mirror->last_report_time = now;
-	if (layoutstats_timer != 0)
+	if (mirror->report_interval != 0)
+		report_interval = (s64)mirror->report_interval * 1000LL;
+	else if (layoutstats_timer != 0)
 		report_interval = (s64)layoutstats_timer * 1000LL;
 	if (ktime_to_ms(ktime_sub(now, mirror->last_report_time)) >=
 			report_interval) {
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 2bb08bc6aaf0..dd353bb7dc0a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -85,6 +85,7 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
 	ktime_t				last_report_time;
+	u32				report_interval;
 };
 
 struct nfs4_ff_layout_segment {
-- 
2.5.0

