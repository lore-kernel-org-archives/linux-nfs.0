Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646671;
	b=CRSjGBLcML5E46h3lkoS4O4SCqn/PxK2s0kyTMWfpw8xW3sHlVYVmA6NHsJZY6P5R2HE
	 uaY7GOr+By5+LbR8jyJxW1XKi8O2XsJYtuokCRdytWRqbA6e0fwAfov79Ym8t7I8+PL/O
	 QeuSPOkynBR6p5aTfYHanzgEPEz3Wijh8RYpb4W0d+EOJDbRnBWsL+Ga9pFJmb4nNayKr
	 yKrRfWB8MHSIYhab8ygkDsnUN4quMF2W4MG4QpCoHhRP1RgPhkP3/ZAFNa2QpUYbiOTsT
	 IiZ1IrXQznG54aGHnXJFs1gp4hrUyMTcnSU9lZSoucR4wiQm9M4krgWJYMI75mlOe1Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646671;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=mKtZb/Ox9QwtvjfZxOjB6c9+8ROumITLAvdpeWdECcY=;
	b=WiUHLZPUleet7o7L4PD72D5zG7fksJ2aA6WhxtbviSGeSSROH66q70HVlTTjH4SnS8T4
	 JLEJuIfd8tU93KIkUqsybFLpAj7fKCQsm/DrjPwbQwSHD5U0NnFvUZIIVjeLActEjSP2U
	 mJa0yRrGMuZgAN+X9/sJsS3wH5mIS6mK8ytk6ysQTXr3f2XsztfErozcBVoNcGfqWm113
	 dnvIALGkBe1ga56PDTScBhG8nLHHxTfbXgovlMxzMxdTWdVFDQFdz+3KdkMJU8dXCCQir
	 sULnVlDB+460hDaNZDp842CJmAEXGKE3fRbjq/l0oHxdOScNdtMo1KSu1CvEYpfkedQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QT74ruZ4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EE7E606A326
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QT74ruZ4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 316501F00A18;
	Mon,  2 Nov 2026 19:11:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646671;
	bh=mKtZb/Ox9QwtvjfZxOjB6c9+8ROumITLAvdpeWdECcY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QT74ruZ4HAL6PKA6ClTZaT7KM/4pSLTsLJLRkwPfAhf3r+HgzF6V2mO9+tjNi+TQW
	 3DlWFV+DxfwKoyvzJq074DYUf0poZ2GkXjipDaI9UPLGyrdpqYV9bfROKvNeKzzZnN
	 JytTEDJKhF/Abs4NMb1iW0smc7rERROK880/JWEP1Pln5UnJNUPNrSEHDUaF6tV0Qo
	 C5H1l42AlpgPjf5ecV4JQGlcty37QACGHeh5fKdsCPSYtQzf9KfT3gZhYEy+PqPDDF
	 2IX6dko4+/hrYw+DGi0fge30VsNj9BJLNddenL6GVM4Zc06fIyAApHLh0CFvw7vDAk
	 mF5ThQTK+yH5g==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 01/11] NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
Date: Mon,  2 Nov 2026 14:10:59 -0500
Message-ID: <20261102191109.13470-2-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

Since striped layouts were introduced, a mirror owns an array of
struct nfs4_ff_layout_ds_stripe and each stripe carries its own
read_stat and write_stat.  The lock protecting those statistics stayed
behind in the mirror, so every DS RPC in the layout serialises on the
same spinlock twice: once in ff_layout_{read,write}_prepare_common()
and again on completion in ff_layout_{read,write}_count_stats().

For a RAID0-style layout (one mirror, many stripes) that lock is
effectively per-file, and striping then multiplies RPC parallelism
without multiplying lock parallelism.

On a 64-core client reading a single file from a 32-stripe layout with
a 128KiB stripe unit (2MB O_DIRECT reads, ~36.7 GB/s, ~275k NFSv3 READ
RPCs/s, i.e. ~550k acquisitions/s of one lock), perf reports 45% of all
CPU in native_queued_spin_lock_slowpath, and lock:contention_begin
attributes 73% of the contention events to the two layoutstats paths:

  36.4%  rpc_exit_task -> ff_layout_read_count_stats ->
         ff_layout_read_record_layoutstats_done -> _raw_spin_lock
  36.3%  ff_layout_read_prepare_v3 ->
         ff_layout_read_record_layoutstats_start -> _raw_spin_lock

Move the lock into struct nfs4_ff_layout_ds_stripe, next to the
statistics it protects, so that I/O to different stripes no longer
contends.  The reporting paths take the same per-stripe lock.

NFS4_FF_MIRROR_STAT_AVAIL is a mirror-wide bit operation and does not
need the lock; set it outside the critical section so the mirror's
cacheline is not written under it.

ffl->last_report_time is shared by every mirror and stripe of a layout
and was already updated under different mirror locks, so it was never
serialised.  Make that explicit with a cmpxchg(): whichever racer wins
sends the LAYOUTSTATS report.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 45 +++++++++++++++-----------
 fs/nfs/flexfilelayout/flexfilelayout.h |  2 ++
 2 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9492d6bc1d1a7..bac0b7f559201 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -293,8 +293,10 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 		return NULL;
 	}
 
-	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++)
+	for (u32 dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
+		spin_lock_init(&mirror->dss[dss_id].lock);
 		nfs_localio_file_init(&mirror->dss[dss_id].nfl);
+	}
 
 	return mirror;
 }
@@ -736,6 +738,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 {
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	struct nfs4_flexfile_layout *ffl = FF_LAYOUT_FROM_HDR(mirror->layout);
+	ktime_t last_report;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
 	if (!mirror->dss[dss_id].start_time)
@@ -744,13 +747,17 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
 		report_interval = (s64)layoutstats_timer * 1000LL;
-	if (ktime_to_ms(ktime_sub(now, ffl->last_report_time)) >=
-			report_interval) {
-		ffl->last_report_time = now;
-		return true;
-	}
 
-	return false;
+	/*
+	 * last_report_time is shared by every mirror and stripe of this
+	 * layout, so it was never serialised by the mirror lock either.
+	 * Make that explicit: whoever wins the cmpxchg() reports.
+	 */
+	last_report = READ_ONCE(ffl->last_report_time);
+	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
+		return false;
+
+	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
 }
 
 static void
@@ -794,13 +801,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 {
 	bool report;
 
-	spin_lock(&mirror->lock);
+	spin_lock(&mirror->dss[dss_id].lock);
 	report = nfs4_ff_layoutstat_start_io(
 		mirror, dss_id, &mirror->dss[dss_id].read_stat, now);
 	nfs4_ff_layout_stat_io_update_requested(
 		&mirror->dss[dss_id].read_stat, requested);
+	spin_unlock(&mirror->dss[dss_id].lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
-	spin_unlock(&mirror->lock);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -813,12 +820,12 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 		__u64 requested,
 		__u64 completed)
 {
-	spin_lock(&mirror->lock);
+	spin_lock(&mirror->dss[dss_id].lock);
 	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].read_stat,
 			requested, completed,
 			ktime_get(), task->tk_start);
+	spin_unlock(&mirror->dss[dss_id].lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
-	spin_unlock(&mirror->lock);
 }
 
 static void
@@ -829,7 +836,7 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 {
 	bool report;
 
-	spin_lock(&mirror->lock);
+	spin_lock(&mirror->dss[dss_id].lock);
 	report = nfs4_ff_layoutstat_start_io(
 		mirror,
 		dss_id,
@@ -838,8 +845,8 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	nfs4_ff_layout_stat_io_update_requested(
 		&mirror->dss[dss_id].write_stat,
 		requested);
+	spin_unlock(&mirror->dss[dss_id].lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
-	spin_unlock(&mirror->lock);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -856,11 +863,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 	if (committed == NFS_UNSTABLE)
 		requested = completed = 0;
 
-	spin_lock(&mirror->lock);
+	spin_lock(&mirror->dss[dss_id].lock);
 	nfs4_ff_layout_stat_io_update_completed(&mirror->dss[dss_id].write_stat,
 			requested, completed, ktime_get(), task->tk_start);
+	spin_unlock(&mirror->dss[dss_id].lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
-	spin_unlock(&mirror->lock);
 }
 
 static struct nfs4_ff_layout_ds *
@@ -3071,13 +3078,13 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	p = xdr_reserve_space(xdr, 4 + fh->size);
 	xdr_encode_opaque(p, fh->data, fh->size);
 	/* ff_io_latency4 read */
-	spin_lock(&dss_info->mirror->lock);
+	spin_lock(&dss_info->lock);
 	ff_layout_encode_io_latency(xdr,
 				    &dss_info->read_stat.io_stat);
 	/* ff_io_latency4 write */
 	ff_layout_encode_io_latency(xdr,
 				    &dss_info->write_stat.io_stat);
-	spin_unlock(&dss_info->mirror->lock);
+	spin_unlock(&dss_info->lock);
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
 				 ktime_sub(ktime_get(),
@@ -3153,7 +3160,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       NFS4_DEVICEID4_SIZE);
 			devinfo->offset = 0;
 			devinfo->length = NFS4_MAX_UINT64;
-			spin_lock(&mirror->lock);
+			spin_lock(&dss_info->lock);
 			devinfo->read_count =
 			    dss_info->read_stat.io_stat.ops_completed;
 			devinfo->read_bytes =
@@ -3162,7 +3169,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			    dss_info->write_stat.io_stat.ops_completed;
 			devinfo->write_bytes =
 			    dss_info->write_stat.io_stat.bytes_completed;
-			spin_unlock(&mirror->lock);
+			spin_unlock(&dss_info->lock);
 			devinfo->layout_type = LAYOUT_FLEX_FILES;
 			devinfo->ld_private.ops = &layoutstat_ops;
 			priv->dss_info = dss_info;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 09c3cd6964fd6..54aa492bc0bac 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -86,6 +86,8 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
+	/* Protects read_stat, write_stat and start_time below */
+	spinlock_t			lock;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
-- 
2.52.0

