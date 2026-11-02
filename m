Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646678;
	b=EtrJwjKDFmhhNofow4+O7xf+ffWrc25nWQeoEqggeyS6Q5KTJB9oDOjE1wjHck/vdnRp
	 uHeflrP86VFpQc5Vy1ieeGFnB7z/SNGtrdyfI5ut31slGj3TMv0S+ewCraEhX1dbPojE/
	 C44+z7NlECyAxdsC6xP+yvC8NXZc0xY9W9NSmikWa94XRxV9rEniatFJEz8WgPW45RUJE
	 Sd4NMrYzPZ7CALn8e7MU83W2rpyrJw2VvkspqycowDidlCjJAfApE5AA3l6U3BLt4Gxjx
	 9Y7QwL6r5qLlto7ZpQnovuXAjmvrkA0vNT5DVpWt3Qw2WPl6yzxRZlCXQ292TBrsd9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646678;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=j01HeAZS9JCAhvvRFiDL+FcouYrGZi4FELNXvOTCxIk=;
	b=vmAGYlSck4CyNNKtvwP7D/JYTat1JYjsN3NdfvDWEtVUrUEZP/Cyu+hKPuZ6tU84aozD
	 WHgYWtE7BKqJK6gIM6ovFiEaoZUgx8zugvhE46giTdJ4/SYXOKq/cGElrQJlEZkskdUJT
	 5wQ0Em66aLqNU0MfJQT7iDX5/B3Yrz+9iYA7qXKvWCEXkstEK4HKMr6irAK2/5TX9OL+A
	 e9MJdTimMJEV74VDx07GbjbvZFMhRrwlvtdk8ygcI7tmYmdlOGekxpPUlzXokuoeG8LBE
	 Kd8nE0mVoRaZrxJjQ71wJvNbA/7+I59W+cLw53WTHrtxb3T8XXAZXmplt2kJKJweoFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fqpfI4i0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9B9A606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fqpfI4i0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5174B1F00A16;
	Mon,  2 Nov 2026 19:11:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646677;
	bh=j01HeAZS9JCAhvvRFiDL+FcouYrGZi4FELNXvOTCxIk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fqpfI4i0iIuSmsb4zTVoEr9SiQDkgJDP97MucbZmdrPi8DnbB58ZA7zR48ym6cpMd
	 vnf4K6uVmw6HdUdB973BTY3h1lR+2ddm8FJIcjiFzQ59NtUABMMLN4ZZRgdTUWRNIJ
	 ScnQ6olt3PrQPir1SypP88DSvcwSm1KsvkJsgJPLUkhgjbOf7m4fZvYP7BvnSSUNOv
	 eJj8yGBP1SPHfCLJXcl0lE01amO9bh0YLkJ1sB7l9LLmaeH+OaQQDwOTzBRo4mdezp
	 WOd3ve8IJgBXPotGd0oK+xHN6jMWEhPxVQa2TkFoR6scuk+FQiEf2yiAoskO8siol0
	 S9omO24CtBbkQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 06/11] NFSv4/flexfiles: pair the in-flight count with the layoutstats updates
Date: Mon,  2 Nov 2026 14:11:04 -0500
Message-ID: <20261102191109.13470-7-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102191109.13470-1-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
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

The busy timer's in-flight op count and the requested-side statistics are
two halves of the same accounting, but they lived in two helpers that the
callers invoked back to back.  Nothing stopped a new requested-side path
from updating one and missing the other.

Fold nfs4_ff_layout_stat_io_update_requested() into
nfs4_ff_layoutstat_start_io() so both happen in one place, and rename
nfs4_ff_layout_stat_io_update_completed() to nfs4_ff_layoutstat_end_io()
for symmetry -- it already dropped the in-flight count alongside the
completed-side statistics.

Rename nfs4_ff_busy_timer::n_ops to ops_in_flight while here.  It is what
the field holds, and it makes its relationship to the op counters legible
at the point of use.

Both helpers now take the stripe rather than mirror + dss_id, which lets
them assert the lock they run under.  Since the previous patch made
ops_in_flight a plain int, that lock is the only thing keeping it
consistent, so assert it rather than document it; lockdep_assert_held()
compiles out without CONFIG_PROVE_LOCKING.  The callers get a dss_info
local, which is what they were open coding.

No functional change.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 104 ++++++++++++++-----------
 fs/nfs/flexfilelayout/flexfilelayout.h |   2 +-
 2 files changed, 58 insertions(+), 48 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 6a474fa7b0446..bfe8288a14a08 100644
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
@@ -743,18 +743,31 @@ nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
 		try_cmpxchg64(&dss_info->start_time, &unset, now);
 }
 
+/*
+ * Account for an I/O about to be sent to this stripe, and return true if a
+ * LAYOUTSTATS report is due.
+ *
+ * The in-flight count and the requested-side counters are bumped here
+ * together, so a new requested-side path cannot update one and miss the
+ * other.
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
@@ -772,27 +785,25 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
 }
 
+/*
+ * Account for an I/O that has completed on this stripe.  The in-flight count
+ * is dropped here, alongside the completed-side counters, for the same reason
+ * it is bumped in nfs4_ff_layoutstat_start_io().
+ */
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
@@ -811,14 +822,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
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
@@ -832,11 +842,13 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
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
 
@@ -846,18 +858,13 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
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
@@ -872,13 +879,16 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
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
index d97001abc0d22..b0653a652d3b8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -70,7 +70,7 @@ struct nfs4_ff_io_stat {
  */
 struct nfs4_ff_busy_timer {
 	ktime_t start_time;
-	int n_ops;
+	int ops_in_flight;
 };
 
 struct nfs4_ff_layoutstat {
-- 
2.52.0

