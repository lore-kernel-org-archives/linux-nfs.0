Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923990;
	b=Zjhz73pOCSWF9wkN4UKI9pw0NH2gna2dhKj/WqQv7DxLlQfFGQg6AXpBvX1GbyY4OtEe
	 zXDBtLD6HumTfVrSCmw/kBNPj9+P3N+BAi/B6E9qFUEIk9t65OXPCi7VNp8riPS2BNAnn
	 IVefFNM+XoEJ4jbe9J7B83uWVUNEA+m3jXO7Mdya1bbetZpjZo97OM2kKjNjIx++zHgF3
	 0Kqj/RiKQrOZqNno0T9MJkjHLIL+QtzME9b2A/4IivHjKqgRnV+NXyVGx6PHpLT8ASnuw
	 yuP4tqLyaLjoPfJdICiIq0uh1DngTp1YgdeADoMc+y1R2JCKrdntvrUbTx3brC+ggQw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923990;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=yLWfP3Ey11uWj5jePOgWdDynu8B+Sy2aTiQATAOvNzo=;
	b=ViXDDao1F//lAeF4gXqLz2EtrrDlVqJR3wGB5Z7Xi7qvXzqZ4VFcotT51efIpn9pCx7B
	 No50jajpxl1W0mJudrtQFhONsQZ/CZhTG4lGzCQPilZkd3VvFDQlHnTsouBcPgnMx54ZW
	 jdWqdR01ezUTWNaTdXS3PZ8whbZZT2e1FYzDcVKYgGmuXwhZJEVKs7cFeGk+5Nwn54T5Y
	 S5qmtVnm+jgrt6KVoqEhpMYZSQjpKKUpYKYVSNekPLd47iJEKIV1UKKF4DYNU8YwIZYOb
	 x6GlzWoSEKKyJKy5jYnbVs5BHmZ2l1HDNySk9m28dhPLTzYusFWS1tMHqGJ3ZTPjCoA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fANjELIB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89114606A328
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fANjELIB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 307631F008A5;
	Fri,  6 Nov 2026 00:13:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923990;
	bh=yLWfP3Ey11uWj5jePOgWdDynu8B+Sy2aTiQATAOvNzo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fANjELIBrVb0N7YH7wLRAh736lgaPPYf9w+eRfNYtdA/J9xo6+chrkJlaOVo77S/S
	 A0cnsV34DTcxsGA9FESQcNCInANvASMJreYdk5MVFKcbtorW5Gz6XcsTvrnSciiU6y
	 KssWbpIL3umXC1/Ned2e7suw5hkBXuvQBNXycmStZOnLvsj3JCUFaeedos0juqG2z5
	 05cIAAGT9WvAXCqFnIC2samWvx4doDYa4Xto7Qfee62J7WdkPFXLep6v8M9MwpsBME
	 4WSdiz30jsbLo8Pc2f6pOAmYAI//XCP51gAL2xKSotep0IW5p417gP3cHmjIioRrSK
	 Fk5cdkDIdnamA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 06/12] NFSv4/flexfiles: pair the in-flight count with the layoutstats updates
Date: Thu,  5 Nov 2026 19:12:43 -0500
Message-ID: <20261106001251.73472-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106001251.73472-1-snitzer@kernel.org>
References: <20261106001251.73472-1-snitzer@kernel.org>
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

The in-flight count of the busy timer and the requested-side statistics
are two halves of one count, but the callers update them through two
helpers.  A new path could update one and not the other.

Fold nfs4_ff_layout_stat_io_update_requested() into
nfs4_ff_layoutstat_start_io(), and rename
nfs4_ff_layout_stat_io_update_completed() to
nfs4_ff_layoutstat_end_io().  Rename n_ops to ops_in_flight, which is
what it counts.

Both helpers now take the stripe, so they can assert the lock that
protects ops_in_flight.

No functional change.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 96 +++++++++++++-------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  2 +-
 2 files changed, 50 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f5591d4451ab3..db8aa2bb92406 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -711,7 +711,7 @@ static void
 nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	/* first IO request? */
-	if (++timer->n_ops == 1)
+	if (++timer->ops_in_flight == 1)
 		timer->start_time = now;
 }
 
@@ -720,7 +720,7 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	ktime_t start;
 
-	WARN_ON_ONCE(--timer->n_ops < 0);
+	WARN_ON_ONCE(--timer->ops_in_flight < 0);
 
 	start = timer->start_time;
 	timer->start_time = now;
@@ -738,18 +738,27 @@ nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
 		try_cmpxchg64(&dss_info->start_time, &unset, now);
 }
 
+/*
+ * Account for an I/O about to be sent to this stripe, and return true if a
+ * LAYOUTSTATS report is due.
+ */
 static bool
-nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
-			    u32 dss_id,
+nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 			    struct nfs4_ff_layoutstat *layoutstat,
-			    ktime_t now)
+			    __u64 requested, ktime_t now)
 {
-	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
+	struct nfs4_ff_layout_mirror *mirror = dss_info->mirror;
 	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
+	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	ktime_t last_report;
 
+	lockdep_assert_held(&dss_info->lock);
+
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
+	layoutstat->io_stat.ops_requested++;
+	layoutstat->io_stat.bytes_requested += requested;
+
+	nfs4_ff_layoutstat_set_start_time(dss_info, now);
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
@@ -763,27 +772,21 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
 }
 
+/* Account for an I/O that has completed on this stripe. */
 static void
-nfs4_ff_layout_stat_io_update_requested(struct nfs4_ff_layoutstat *layoutstat,
-		__u64 requested)
-{
-	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
-
-	iostat->ops_requested++;
-	iostat->bytes_requested += requested;
-}
-
-static void
-nfs4_ff_layout_stat_io_update_completed(struct nfs4_ff_layoutstat *layoutstat,
-		__u64 requested,
-		__u64 completed,
-		ktime_t time_completed,
-		ktime_t time_started)
+nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
+			  struct nfs4_ff_layoutstat *layoutstat,
+			  __u64 requested,
+			  __u64 completed,
+			  ktime_t time_completed,
+			  ktime_t time_started)
 {
 	struct nfs4_ff_io_stat *iostat = &layoutstat->io_stat;
 	ktime_t completion_time = ktime_sub(time_completed, time_started);
 	ktime_t timer;
 
+	lockdep_assert_held(&dss_info->lock);
+
 	iostat->ops_completed++;
 	iostat->bytes_completed += completed;
 	iostat->bytes_not_delivered += requested - completed;
@@ -802,14 +805,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 		u32 dss_id,
 		__u64 requested, ktime_t now)
 {
+	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 	bool report;
 
-	spin_lock(&mirror->dss[dss_id].lock);
-	report = nfs4_ff_layoutstat_start_io(
-		mirror, dss_id, &mirror->dss[dss_id].read_stat, now);
-	nfs4_ff_layout_stat_io_update_requested(
-		&mirror->dss[dss_id].read_stat, requested);
-	spin_unlock(&mirror->dss[dss_id].lock);
+	spin_lock(&dss_info->lock);
+	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
+					     requested, now);
+	spin_unlock(&dss_info->lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
@@ -823,11 +825,13 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 		__u64 requested,
 		__u64 completed)
 {
-	spin_lock(&mirror->dss[dss_id].lock);
-	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].read_stat,
-			requested, completed,
-			ktime_get(), task->tk_start);
-	spin_unlock(&mirror->dss[dss_id].lock);
+	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
+
+	spin_lock(&dss_info->lock);
+	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
+				  requested, completed,
+				  ktime_get(), task->tk_start);
+	spin_unlock(&dss_info->lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
@@ -837,18 +841,13 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 		u32 dss_id,
 		__u64 requested, ktime_t now)
 {
+	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 	bool report;
 
-	spin_lock(&mirror->dss[dss_id].lock);
-	report = nfs4_ff_layoutstat_start_io(
-		mirror,
-		dss_id,
-		&mirror->dss[dss_id].write_stat,
-		now);
-	nfs4_ff_layout_stat_io_update_requested(
-		&mirror->dss[dss_id].write_stat,
-		requested);
-	spin_unlock(&mirror->dss[dss_id].lock);
+	spin_lock(&dss_info->lock);
+	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
+					     requested, now);
+	spin_unlock(&dss_info->lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
@@ -863,13 +862,16 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		__u64 completed,
 		enum nfs3_stable_how committed)
 {
+	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
+
 	if (committed == NFS_UNSTABLE)
 		requested = completed = 0;
 
-	spin_lock(&mirror->dss[dss_id].lock);
-	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].write_stat,
-			requested, completed, ktime_get(), task->tk_start);
-	spin_unlock(&mirror->dss[dss_id].lock);
+	spin_lock(&dss_info->lock);
+	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
+				  requested, completed,
+				  ktime_get(), task->tk_start);
+	spin_unlock(&dss_info->lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 4b2aaa16ee597..8d24f94263b3a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -67,7 +67,7 @@ struct nfs4_ff_io_stat {
 /* Both members are protected by the enclosing stripe's lock */
 struct nfs4_ff_busy_timer {
 	ktime_t start_time;
-	int n_ops;
+	int ops_in_flight;
 };
 
 struct nfs4_ff_layoutstat {
-- 
2.52.0

