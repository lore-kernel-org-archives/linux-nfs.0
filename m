Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989282;
	b=pqpRl4T71GPYJYf/qiv5S1RGv48T5WZvamZ1Ni9FyopnUBz9+agJPF0+uZ82O7m8MB5s
	 yiVY8weLMWRzmnriIza/oceJGvSMEK+mETTCehGNqttMEnMEfQZuYvudS98xfAI2xLa/I
	 PgaE9/iFbcm7gvT6Z1Uc6NMrDan8U6QuBO001WH24P5uVO++BPnDgaMvv9fvV6KwB0svB
	 y78rOCior/k5TPorO2Wj7NOIdL57cjta04Y6c4hMINP2UgWb9ne1vDQBgOrGQxtuHVp4P
	 qUx+8Rs2XwFwrPyjtUUhP3hKAInDE7lMZtRahmUoQqJEfVZM0ktJt/THjXoh8cx8O2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989282;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=wDHbbJjrPpyYi19DtLrJpM4yHCMFutZcycZysTg4Y78=;
	b=Q9QisBIaHmof+y69VGsIkV3UkFUAsBxq44B76bVpOdnDx8IRGQXaPKji+/oC5XSqDptL
	 zlBmNl1++IQeY9s1hXzyW9+g2l3a1+OpDOxGRaccXR62hotmfds3oOpe1gRfYcjV3eLel
	 Zq5Y2ADLI8DhXFPhHt7vPgze4FZZ8CKlps2Yw0bRdUMT//O94YuY18s8CMVowIzxtXNd6
	 LDHpxZsXbt7mv73PNx0SyadKHTodPGSv/8op+i0ZN5Ft8EYnmCqhLob+bZD+VijGyimj7
	 AFpajqslWElmuOuAiY3sbdNTHojHppvKAmSYJUB7MQoA0PjSYAxXLs1YTHtPI/j75Fg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="gc/eJPUE";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A238E606A330
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gc/eJPUE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4A2AC1F008BD;
	Fri,  6 Nov 2026 18:21:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989282;
	bh=wDHbbJjrPpyYi19DtLrJpM4yHCMFutZcycZysTg4Y78=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gc/eJPUE08mDqpPwhtzo2HLHDlNahWau+THl1PutPJatVDOC5v6U2pJy3vLgc0r+z
	 oUVZW5KOeYE7EZRp/SvpagPMmLax+aveNwWTpTox/IoC9+eQqM3Pdw4AuCg1HFJbOo
	 nxCqV4fnQY+JOrk5HvCbT5uKW6WFXcLG4ZN77KoACWW0wLLpd+i9/aeyH+Ah/8BGx0
	 pj97SvAhjHba4+SEIHLX9zgHkAlmxa0bLtCPUJOiG+UhOBoCuAYZGuQ6qCBdox91sQ
	 1Jpk4kdz14ani+rG+6YsjEZiDSFGYictK45kEpnzIa/opWLhyrpft1YLSFxmx7SLSJ
	 /XzjNkJuyJPOg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 11/12] NFSv4/flexfiles: take the report decision out of the critical section
Date: Fri,  6 Nov 2026 13:20:59 -0500
Message-ID: <20261106182105.78611-12-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106182105.78611-1-snitzer@kernel.org>
References: <20261106182105.78611-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

When an I/O to a data server starts, the stripe lock also covered the
decision to send a LAYOUTSTATS report.  That decision reads the mirror
and the layout header, divides in ktime_to_ms(), and does a cmpxchg on
ffl->last_report_time.  None of it is data that the lock protects.

Move the decision into nfs4_ff_layoutstat_report_due() and call it,
and nfs4_ff_layoutstat_set_start_time(), after the unlock.  The lock now
covers two writes to one cacheline.  The order of the updates and the
report does not change.

nfs4_ff_layoutstat_end_io() loses its unused dss_info argument.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 49 ++++++++++++++------------
 1 file changed, 27 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c61d32a7cbde..31d5dbd4debcc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -739,32 +739,36 @@ nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
 		atomic64_try_cmpxchg(&dss_info->start_time, &unset, now);
 }
 
-/*
- * Account for an I/O about to be sent to this stripe, and return true if a
- * LAYOUTSTATS report is due.
- */
-static bool
-nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			    struct nfs4_ff_layoutstat *layoutstat,
+/* Account for an I/O about to be sent to this stripe. */
+static void
+nfs4_ff_layoutstat_start_io(struct nfs4_ff_layoutstat *layoutstat,
 			    __u64 requested, ktime_t now)
+{
+	lockdep_assert_held(&layoutstat->lock);
+
+	nfs4_ff_start_busy_timer(layoutstat, now);
+	layoutstat->io_stat.bytes_requested += requested;
+}
+
+/*
+ * Is a LAYOUTSTATS report due?  Called outside the statistics locks, which
+ * protect none of this.  last_report_time is shared by every mirror and
+ * stripe of the layout: the cmpxchg winner reports.
+ */
+static bool
+nfs4_ff_layoutstat_report_due(struct nfs4_ff_layout_ds_stripe *dss_info,
+			      ktime_t now)
 {
 	struct nfs4_ff_layout_mirror *mirror = dss_info->mirror;
 	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	s64 last_report;
 
-	lockdep_assert_held(&layoutstat->lock);
-
-	nfs4_ff_start_busy_timer(layoutstat, now);
-	layoutstat->io_stat.bytes_requested += requested;
-
-	nfs4_ff_layoutstat_set_start_time(dss_info, now);
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
 		report_interval = (s64)layoutstats_timer * 1000LL;
 
-	/* Shared by every mirror and stripe: the cmpxchg winner reports. */
 	last_report = atomic64_read(&ffl->last_report_time);
 	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
 		return false;
@@ -774,8 +778,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 
 /* Account for an I/O that has completed on this stripe. */
 static void
-nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			  struct nfs4_ff_layoutstat *layoutstat,
+nfs4_ff_layoutstat_end_io(struct nfs4_ff_layoutstat *layoutstat,
 			  __u64 requested,
 			  __u64 completed,
 			  ktime_t time_completed,
@@ -809,10 +812,11 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 	bool report;
 
 	spin_lock(&dss_info->read_stat.lock);
-	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
-					     requested, now);
+	nfs4_ff_layoutstat_start_io(&dss_info->read_stat, requested, now);
 	spin_unlock(&dss_info->read_stat.lock);
 
+	nfs4_ff_layoutstat_set_start_time(dss_info, now);
+	report = nfs4_ff_layoutstat_report_due(dss_info, now);
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
 }
@@ -827,7 +831,7 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 
 	spin_lock(&dss_info->read_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->read_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->read_stat.lock);
@@ -843,10 +847,11 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	bool report;
 
 	spin_lock(&dss_info->write_stat.lock);
-	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
-					     requested, now);
+	nfs4_ff_layoutstat_start_io(&dss_info->write_stat, requested, now);
 	spin_unlock(&dss_info->write_stat.lock);
 
+	nfs4_ff_layoutstat_set_start_time(dss_info, now);
+	report = nfs4_ff_layoutstat_report_due(dss_info, now);
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
 }
@@ -865,7 +870,7 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		requested = completed = 0;
 
 	spin_lock(&dss_info->write_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->write_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->write_stat.lock);
-- 
2.52.0

