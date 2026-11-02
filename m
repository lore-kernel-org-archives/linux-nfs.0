Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646680;
	b=tCmvcWoQBbVfdLWTup/c/lQSIql5b5mEA40OAj5UgroQrPheG6MNuFJ4rIFdmxIWasJt
	 Fxcha8dzt5MDuM7pNVY9sZzEMYxlXTNYTRbuWJpFh2Wsh5XYVw+KB8BXAjenv9eNoGvhg
	 ro3sfSzWYBubVljLNlm6h5JzAdjDbaaYuSc+eZQds8KYlgYJN0NTiJad88HF07gWmlcbg
	 QNrW34DoBQAAt7TSf6dwxXJN1GVivmaDTsB5Y+NxK+C0t8hbWlDNfcXcgb6pWdsXekbK+
	 QOjP5GfJHGBc99BEmOleJv/et6mCYSXlaHDX2Dhcza8/tfUKG+aev6rcMpvaw6oOH6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646680;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=iz/mt3erEjtiAjp60etBrrl/ixDhZFWwxjTXYaA+AG8=;
	b=DG667+bd3NCoPD3vofW7pinZcABaMNYz3pRz29nbGvhKWNU5/QNMUmm1xea2pla8qlat
	 bZbbFNmSWk+630UkKqyGRTjAGz/D5aKiaNROu4nBAMQ02ClKk7SNMEHLyGOdqkL0bxf2R
	 AUCQrbTc80Le5EwSGQhfPpA/Wh6sQjUjIvnEJQQjJykBtSz8Qn394ULPj/EM5IJ/9yCZj
	 DtdLZkRIkn/AT03GAlifokAxopGlk71ez/INJEJh041k2S1RLk6V9jc1L3AJfat/0dnvf
	 5cjdmoYTBVpoU8wcf7xMEOUNXKjtY43gX5ac6nA4fj/a5gb/cY2haWNU/YPTYQPft+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IlF5Neod;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5001A606A32E
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IlF5Neod
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5EC31F00A27;
	Mon,  2 Nov 2026 19:11:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646679;
	bh=iz/mt3erEjtiAjp60etBrrl/ixDhZFWwxjTXYaA+AG8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=IlF5Neodp8QpGKV+ISnErpUQWDrDFYTC3Su+96vkMSNRlmXPpBgYfqCBTWJsMLi6q
	 GD9hsDSf4CwQc9DO00d1KINknrviLt/9oNbtXO0U1SpJlelxdjB2M1Rhivk0kxqj9V
	 UMYSelBjLnKqDnDcsh3D//H9/K6Ea5X+LM0SrahFKT70mXd3VA1cjANlqMQU7QHjvM
	 UC2keK4QZolGMiEFDbjmF2c5IXw5dGN2OQA5lQgAdbXRSJzhyGsQvx1K0DN9Mh0cgh
	 kZOcNV2aPfqswkDSBQMiu0QWkTeEqZgW/oNeippX27r4N47VCSji2wx9Q5s3y4jffX
	 tk5MjASH1FGNg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 08/11] NFSv4/flexfiles: give each direction its own lock and cacheline
Date: Mon,  2 Nov 2026 14:11:06 -0500
Message-ID: <20261102191109.13470-9-snitzer@kernel.org>
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

struct nfs4_ff_layout_ds_stripe shrinks from 384 bytes to 320, and an
I/O to a stripe now dirties one cacheline instead of two.  The 384 was
what "NFSv4/flexfiles: cacheline align the per-stripe layoutstats" had to
pay to get the array stride line aligned; this gets that back and takes
another 64 bytes off, on top of removing the last shared lock between the
two I/O directions.

Cacheline aligning the stripe's lock stopped stripes sharing lines with
each other, but within a stripe an I/O still dirtied more than one line,
and reads and writes still serialised on one spinlock.

The set one RPC touches is not the whole guarded region.  A read takes
the lock, bumps the in-flight count and updates every field of read_stat
-- bytes_requested and the busy timer on the way out, ops_completed,
bytes_completed, bytes_not_delivered and the two ktime_t sums on
completion -- while write_stat stays untouched, and a write is the mirror
image.  The two directions share nothing but the lock.

So stop sharing the lock.  Move it into struct nfs4_ff_layoutstat,
alongside the in-flight count and the statistics it guards, and fold
nfs4_ff_busy_timer in as a bare ktime_t.  With ops_requested derived
rather than stored, that comes to

	spinlock_t             lock              4
	int                    ops_in_flight     4
	struct nfs4_ff_io_stat io_stat          48
	ktime_t                busy_start_time   8

which is 64 bytes with no padding.  Align the structure to a cacheline
and each direction occupies one, exactly.

An I/O now dirties a single line, and a read and a write to the same
stripe touch neither the same lock nor the same line.  The two reporting
paths, ff_layout_mirror_prepare_stats() and
ff_layout_encode_ff_layoutupdate(), take each lock in turn; they need no
atomicity across the pair, as the statistics are advisory and were never
sampled atomically with respect to in-flight I/O anyway.

pahole on flexfilelayout.o built with DWARF5, identical on x86_64, arm64
4K pages and arm64 64K pages:

  struct nfs4_ff_layoutstat {
          spinlock_t              lock;             /*    0     4 */
          int                     ops_in_flight;    /*    4     4 */
          struct nfs4_ff_io_stat  io_stat;          /*    8    48 */
          ktime_t                 busy_start_time;  /*   56     8 */
          /* size: 64, cachelines: 1, members: 4 */
  } __attribute__((__aligned__(64)));

  ktime_t                    start_time;  /*   136     8 */
  /* XXX 48 bytes hole */
  /* --- cacheline 3 boundary (192 bytes) --- */
  struct nfs4_ff_layoutstat  read_stat;   /*   192    64 */
  /* --- cacheline 4 boundary (256 bytes) --- */
  struct nfs4_ff_layoutstat  write_stat;  /*   256    64 */
  /* size: 320, cachelines: 5 */

start_time stays out of both lines, since it neither fits nor needs to.
"NFSv4/flexfiles: make dss_info->start_time write-once" removed its
dependence on any lock, and nothing writes it after the stripe's first
I/O, so its line never bounces; the same I/O already reads fh_versions,
stateid and the creds from the lines around it.  In the hole ahead of
read_stat it is free.

The array stride stays a multiple of 64 and of 128, so stripes remain
separated on implementations with a 128 byte coherency granule.

Note that CONFIG_DEBUG_SPINLOCK or CONFIG_PROVE_LOCKING fatten spinlock_t
enough to push nfs4_ff_layoutstat to 128 bytes and the stripe to 448.
Correctness is unaffected; such kernels simply do not get the packing.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 53 ++++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h | 46 +++++++++++-----------
 2 files changed, 52 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 846544977cf30..0b8562efabb24 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -293,7 +293,8 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 	}
 
 	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
-		spin_lock_init(&mirror->dss[dss_id].lock);
+		spin_lock_init(&mirror->dss[dss_id].read_stat.lock);
+		spin_lock_init(&mirror->dss[dss_id].write_stat.lock);
 		nfs_localio_file_init(&mirror->dss[dss_id].nfl);
 	}
 
@@ -708,22 +709,22 @@ static u32 calc_dss_id_from_commit(struct pnfs_layout_segment *lseg,
 }
 
 static void
-nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
+nfs4_ff_start_busy_timer(struct nfs4_ff_layoutstat *layoutstat, ktime_t now)
 {
 	/* first IO request? */
-	if (++timer->ops_in_flight == 1)
-		timer->start_time = now;
+	if (++layoutstat->ops_in_flight == 1)
+		layoutstat->busy_start_time = now;
 }
 
 static ktime_t
-nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
+nfs4_ff_end_busy_timer(struct nfs4_ff_layoutstat *layoutstat, ktime_t now)
 {
 	ktime_t start;
 
-	WARN_ON_ONCE(--timer->ops_in_flight < 0);
+	WARN_ON_ONCE(--layoutstat->ops_in_flight < 0);
 
-	start = timer->start_time;
-	timer->start_time = now;
+	start = layoutstat->busy_start_time;
+	layoutstat->busy_start_time = now;
 	return ktime_sub(now, start);
 }
 
@@ -761,9 +762,9 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	ktime_t last_report;
 
-	lockdep_assert_held(&dss_info->lock);
+	lockdep_assert_held(&layoutstat->lock);
 
-	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
+	nfs4_ff_start_busy_timer(layoutstat, now);
 	layoutstat->io_stat.bytes_requested += requested;
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
@@ -801,13 +802,13 @@ nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 	ktime_t completion_time = ktime_sub(time_completed, time_started);
 	ktime_t timer;
 
-	lockdep_assert_held(&dss_info->lock);
+	lockdep_assert_held(&layoutstat->lock);
 
 	iostat->ops_completed++;
 	iostat->bytes_completed += completed;
 	iostat->bytes_not_delivered += requested - completed;
 
-	timer = nfs4_ff_end_busy_timer(&layoutstat->busy_timer, time_completed);
+	timer = nfs4_ff_end_busy_timer(layoutstat, time_completed);
 	iostat->total_busy_time =
 			ktime_add(iostat->total_busy_time, timer);
 	iostat->aggregate_completion_time =
@@ -824,10 +825,10 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 	bool report;
 
-	spin_lock(&dss_info->lock);
+	spin_lock(&dss_info->read_stat.lock);
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
 					     requested, now);
-	spin_unlock(&dss_info->lock);
+	spin_unlock(&dss_info->read_stat.lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
@@ -843,11 +844,11 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 {
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 
-	spin_lock(&dss_info->lock);
+	spin_lock(&dss_info->read_stat.lock);
 	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
-	spin_unlock(&dss_info->lock);
+	spin_unlock(&dss_info->read_stat.lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
@@ -860,10 +861,10 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 	bool report;
 
-	spin_lock(&dss_info->lock);
+	spin_lock(&dss_info->write_stat.lock);
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
 					     requested, now);
-	spin_unlock(&dss_info->lock);
+	spin_unlock(&dss_info->write_stat.lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
@@ -883,11 +884,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 	if (committed == NFS_UNSTABLE)
 		requested = completed = 0;
 
-	spin_lock(&dss_info->lock);
+	spin_lock(&dss_info->write_stat.lock);
 	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
-	spin_unlock(&dss_info->lock);
+	spin_unlock(&dss_info->write_stat.lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
@@ -3100,11 +3101,13 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	p = xdr_reserve_space(xdr, 4 + fh->size);
 	xdr_encode_opaque(p, fh->data, fh->size);
 	/* ff_io_latency4 read */
-	spin_lock(&dss_info->lock);
+	spin_lock(&dss_info->read_stat.lock);
 	ff_layout_encode_io_latency(xdr, &dss_info->read_stat);
+	spin_unlock(&dss_info->read_stat.lock);
 	/* ff_io_latency4 write */
+	spin_lock(&dss_info->write_stat.lock);
 	ff_layout_encode_io_latency(xdr, &dss_info->write_stat);
-	spin_unlock(&dss_info->lock);
+	spin_unlock(&dss_info->write_stat.lock);
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
 				 ktime_sub(ktime_get(),
@@ -3180,16 +3183,18 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       NFS4_DEVICEID4_SIZE);
 			devinfo->offset = 0;
 			devinfo->length = NFS4_MAX_UINT64;
-			spin_lock(&dss_info->lock);
+			spin_lock(&dss_info->read_stat.lock);
 			devinfo->read_count =
 			    dss_info->read_stat.io_stat.ops_completed;
 			devinfo->read_bytes =
 			    dss_info->read_stat.io_stat.bytes_completed;
+			spin_unlock(&dss_info->read_stat.lock);
+			spin_lock(&dss_info->write_stat.lock);
 			devinfo->write_count =
 			    dss_info->write_stat.io_stat.ops_completed;
 			devinfo->write_bytes =
 			    dss_info->write_stat.io_stat.bytes_completed;
-			spin_unlock(&dss_info->lock);
+			spin_unlock(&dss_info->write_stat.lock);
 			devinfo->layout_type = LAYOUT_FLEX_FILES;
 			devinfo->ld_private.ops = &layoutstat_ops;
 			priv->dss_info = dss_info;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 23f665fef4985..876fdb6999473 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -64,18 +64,22 @@ struct nfs4_ff_io_stat {
 };
 
 /*
- * Both members are serialised by the enclosing stripe's
- * nfs4_ff_layout_ds_stripe::lock; see nfs4_ff_{start,end}_busy_timer().
+ * One direction's statistics for one stripe, with the lock that guards them.
+ *
+ * Exactly one cacheline, and aligned to one, so that an I/O dirties a single
+ * line: the lock, the in-flight count and every counter it touches are all in
+ * here, and the other direction's copy is in a line of its own.  Adding to
+ * this structure, or letting CONFIG_DEBUG_SPINLOCK or CONFIG_PROVE_LOCKING
+ * fatten spinlock_t, spills it into a second line.
  */
-struct nfs4_ff_busy_timer {
-	ktime_t start_time;
-	int ops_in_flight;
-};
-
 struct nfs4_ff_layoutstat {
-	struct nfs4_ff_io_stat io_stat;
-	struct nfs4_ff_busy_timer busy_timer;
-};
+	/* Protects every other member of this structure */
+	spinlock_t			lock;
+	int				ops_in_flight;
+	struct nfs4_ff_io_stat		io_stat;
+	/* Start of the interval io_stat.total_busy_time accrues */
+	ktime_t				busy_start_time;
+} ____cacheline_aligned_in_smp;
 
 /*
  * ffil_ops_requested is not stored.  An op is in flight from the moment it is
@@ -91,8 +95,7 @@ struct nfs4_ff_layoutstat {
 static inline __u64
 nfs4_ff_ops_requested(const struct nfs4_ff_layoutstat *layoutstat)
 {
-	return layoutstat->io_stat.ops_completed +
-	       layoutstat->busy_timer.ops_in_flight;
+	return layoutstat->io_stat.ops_completed + layoutstat->ops_in_flight;
 }
 
 struct nfs4_ff_layout_mirror;
@@ -108,21 +111,18 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
+	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
+	ktime_t				start_time;
 	/*
-	 * Protects read_stat and write_stat below.
-	 *
-	 * Cacheline aligned so that the layoutstats accounting done on
-	 * every I/O to this stripe does not share cachelines with the
-	 * read-mostly members above, nor with the neighbouring stripes
-	 * in mirror->dss[]: aligning the first member of the guarded
-	 * set also rounds sizeof() up to a multiple of the cacheline,
-	 * which is what makes the array stride line-aligned.
+	 * A line each, and each carrying its own lock, so that a read and a
+	 * write to this stripe neither serialise against each other nor
+	 * share a line.  Their alignment also rounds this structure's
+	 * sizeof() up to a multiple of the cacheline, which is what keeps
+	 * the mirror->dss[] stride line-aligned and so stops stripe i
+	 * sharing a line with stripe i+1.
 	 */
-	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
-	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
-	ktime_t				start_time;
 };
 
 struct nfs4_ff_layout_mirror {
-- 
2.52.0

