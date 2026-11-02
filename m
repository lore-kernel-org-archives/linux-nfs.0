Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646684;
	b=ZsL+C+OPPoQkCnsxAcYQDZiNojw8w/y30M+bQUHMbN0cn5cgZINpJAEJIrSociDA66OT
	 eAl2pRv5XLebkeALVSmBwQnHmmXNbHrlWCv7fLNEoorWGWFXzE5yPI9aypM0oEMtN3v79
	 KG63d7fuiObUsh0LkuaIzQvSGHMyX8CVm3WxPazZlA3qrjn98yvGuRekYZCxQsEzpQvGr
	 Bs9qTi9SIhJxnogBt+LyxWwGKZKXOt66AhPDu8Ib+d6nIIVCphUwCGmhTS7r0kSxKOELS
	 LHUn8en4r/NmUeabKC9/YrY2jrET9OKOFLeE8lrFuQJsTvA3aJKiHSJBVXydlBKNWxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646684;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=0f52CaPubn0hXr80zWtC3wHk+yc039D0joGvN49SrAM=;
	b=j1C8BqhR+QM777efnZ7I9ljI7clIE3AhPrbO5EeWn576ZYpPTVAUbqUpRruHVJApb4cr
	 A1gi41TNjfOI3MLJ9BuMSsAMWT80OQv4FkNYaEha6qq1z5aYWwbQQYOecneQ7NG0bgu3Z
	 zMLDbIRKTN/cKG21FJKyu2excuMASyHRzuce4/UhzsZ4DkrrFw9+ZdcBzN+h2gHK6Ygra
	 Dk4wN1Rs/QMFzYBOcfOQG8tDPe88rZkrly7tKuUAHggPGVxx3J8c+R7OuU1f9BCvaWL/1
	 sP8p0f8mSrNGHMobyLLlsDsjVnZ5f4dLFD4KD28Br4qZNFezzvUIyfDVOjLGElmtmvw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mzsAWqKV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23133606A327
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mzsAWqKV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 801AE1F00A20;
	Mon,  2 Nov 2026 19:11:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646683;
	bh=0f52CaPubn0hXr80zWtC3wHk+yc039D0joGvN49SrAM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mzsAWqKVfO8huApIP/77Mp7tXee/PDLwbRZLlCn+/vZPtjDhPsBjL/sp93y4jEBTD
	 h3u59R22B5HmxFzkPiYchGrdjcL3KVnBZ3dC1JlT7xnqR0aScRSqpcnimdVw19Jmu2
	 Yp9vswvTe99Jml/ANnnIM1WWHns/k8GDY3sBh0LxbP4dLrnfkczxzKTa1GZ6DoC1O7
	 2RfIWLRibxJT7Nudszo1Ixy0s/I6E1PQk6EHSO10X3ma0IlLUU0N/8nKEPro8LVJ4u
	 udyM7wToytTIFI8OsIYqFFmhMOHqcKV8gAax21lq9+rAwg0Cp6QPJ25W0C1IjaxOar
	 YIWOF5HnaAUeg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 11/11] NFSv4/flexfiles: take the report decision out of the critical section
Date: Mon,  2 Nov 2026 14:11:09 -0500
Message-ID: <20261102191109.13470-12-snitzer@kernel.org>
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

Now that each direction's statistics are one cacheline behind their own
lock, what is left inside that lock matters.  On the requested side it was
not just the counters:

  - dss_info->mirror and mirror->layout, two pointer chases into other
    objects
  - mirror->report_interval, on the mirror's cacheline
  - the layoutstats_timer module parameter
  - ktime_to_ms(), a division
  - ffl->last_report_time, on the layout header's cacheline, plus a
    try_cmpxchg64() on it once per report interval
  - dss_info->start_time, on the stripe's read-mostly cacheline

None of that is covered by the lock, and none of it touches the data the
lock guards.  mirror->report_interval is written once when the layout
segment is decoded and read-only afterwards; ffl->last_report_time is
shared by every mirror and stripe of the layout and has carried its own
cmpxchg since the statistics moved to the stripe; start_time has been
write-once, published by cmpxchg, since "NFSv4/flexfiles: make
dss_info->start_time write-once".  So none of them were being protected,
they were only being waited for.

Split the report decision out into nfs4_ff_layoutstat_report_due() and
call it, and nfs4_ff_layoutstat_set_start_time(), after the unlock.  The
critical section becomes what it should be: bump the in-flight count,
add to bytes_requested.  Two writes, one cacheline, no dependent loads
into other objects and no division.

The reads themselves are unchanged and still happen once per RPC.  They
are on read-mostly lines, so they share rather than bounce and are not
worth eliminating without a profile that says otherwise; the point here
is only that an I/O no longer waits behind them.

Ordering is unchanged: the statistics are updated before the decision is
taken, as before, and pnfs_report_layoutstat() was already called after
the unlock.

nfs4_ff_layoutstat_end_io() loses its dss_info argument, unused since the
lock moved into nfs4_ff_layoutstat.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 60 +++++++++++++++-----------
 1 file changed, 35 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 591363e2cf460..90b3be4a94c80 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -745,39 +745,48 @@ nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
 }
 
 /*
- * Account for an I/O about to be sent to this stripe, and return true if a
- * LAYOUTSTATS report is due.
+ * Account for an I/O about to be sent to this stripe.
  *
  * The in-flight count and the requested-side counters are bumped here
  * together, so a new requested-side path cannot update one and miss the
- * other.
+ * other.  Everything this touches is in the cacheline the caller's lock
+ * guards; anything else belongs outside that lock.
  */
-static bool
-nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			    struct nfs4_ff_layoutstat *layoutstat,
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
+ * Is a LAYOUTSTATS report due?  Deliberately outside the statistics locks:
+ * none of this is covered by them, and all of it lives in other objects --
+ * mirror->report_interval and ffl->last_report_time, plus a division -- so
+ * running it under a lock would only lengthen a critical section that is
+ * otherwise two writes to one cacheline.
+ *
+ * last_report_time is shared by every mirror and stripe of this layout, so it
+ * was never serialised by the mirror lock either.  Make that explicit:
+ * whoever wins the cmpxchg() reports.
+ */
+static bool
+nfs4_ff_layoutstat_report_due(struct nfs4_ff_layout_ds_stripe *dss_info,
+			      ktime_t now)
 {
 	struct nfs4_ff_layout_mirror *mirror = dss_info->mirror;
 	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	ktime_t last_report;
 
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
 
-	/*
-	 * last_report_time is shared by every mirror and stripe of this
-	 * layout, so it was never serialised by the mirror lock either.
-	 * Make that explicit: whoever wins the cmpxchg() reports.
-	 */
 	last_report = READ_ONCE(ffl->last_report_time);
 	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
 		return false;
@@ -791,8 +800,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
  * it is bumped in nfs4_ff_layoutstat_start_io().
  */
 static void
-nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			  struct nfs4_ff_layoutstat *layoutstat,
+nfs4_ff_layoutstat_end_io(struct nfs4_ff_layoutstat *layoutstat,
 			  __u64 requested,
 			  __u64 completed,
 			  ktime_t time_completed,
@@ -826,10 +834,11 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
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
@@ -844,7 +853,7 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 
 	spin_lock(&dss_info->read_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->read_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->read_stat.lock);
@@ -860,10 +869,11 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
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
@@ -882,7 +892,7 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		requested = completed = 0;
 
 	spin_lock(&dss_info->write_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->write_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->write_stat.lock);
-- 
2.52.0

