Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36620 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbbHYBnM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 21:43:12 -0400
Received: by iodv127 with SMTP id v127so169963657iod.3
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 18:43:12 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4.2/pnfs: Make the layoutstats timer configurable
Date: Mon, 24 Aug 2015 21:43:06 -0400
Message-Id: <1440466986-36826-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1440466986-36826-3-git-send-email-trond.myklebust@primarydata.com>
References: <1440466986-36826-1-git-send-email-trond.myklebust@primarydata.com>
 <1440466986-36826-2-git-send-email-trond.myklebust@primarydata.com>
 <1440466986-36826-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow advanced users to set the layoutstats timer in order to lengthen
or shorten the period between layoutstat transmissions to the server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 Documentation/kernel-parameters.txt    | 9 +++++++++
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 ++++-
 fs/nfs/pnfs.c                          | 4 ++++
 fs/nfs/pnfs.h                          | 3 +++
 4 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1d6f0459cd7b..30d78b561574 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2279,6 +2279,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			The default parameter value of '0' causes the kernel
 			not to attempt recovery of lost locks.
 
+	nfs4.layoutstats_timer =
+			[NFSv4.2] Change the rate at which the kernel sends
+			layoutstats to the pNFS metadata server.
+
+			Setting this to value to 0 causes the kernel to use
+			whatever value is the default set by the layout
+			driver. A non-zero value sets the minimum interval
+			in seconds between layoutstats transmissions.
+
 	nfsd.nfs4_disable_idmapping=
 			[NFSv4] When set to the default of '1', the NFSv4
 			server will return only numeric uids and gids to
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 210352741177..738065674484 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -533,14 +533,17 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 			    ktime_t now)
 {
 	static const ktime_t notime = {0};
+	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
 	if (ktime_equal(mirror->start_time, notime))
 		mirror->start_time = now;
 	if (ktime_equal(mirror->last_report_time, notime))
 		mirror->last_report_time = now;
+	if (layoutstats_timer != 0)
+		report_interval = (s64)layoutstats_timer * 1000LL;
 	if (ktime_to_ms(ktime_sub(now, mirror->last_report_time)) >=
-			FF_LAYOUTSTATS_REPORT_INTERVAL) {
+			report_interval) {
 		mirror->last_report_time = now;
 		return true;
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 247c5a5d2d6b..3530bb703214 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2285,3 +2285,7 @@ out_put:
 }
 EXPORT_SYMBOL_GPL(pnfs_report_layoutstat);
 #endif
+
+unsigned int layoutstats_timer;
+module_param(layoutstats_timer, uint, 0644);
+EXPORT_SYMBOL_GPL(layoutstats_timer);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 02c27f93caf1..d3979dd1037a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -528,12 +528,15 @@ pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 					nfss->pnfs_curr_ld->id == src->l_type);
 }
 
+extern unsigned int layoutstats_timer;
+
 #ifdef NFS_DEBUG
 void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
 #else
 static inline void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id)
 {
 }
+
 #endif /* NFS_DEBUG */
 #else  /* CONFIG_NFS_V4_1 */
 
-- 
2.4.3

