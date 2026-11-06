Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923993;
	b=rxHMB08dX4XENXKUmnPIQA/ESiFEQBhUwPa3yCttQO7YMH3aEteb+alA3AR0aNEpQuub
	 FtYAJvxXAGiJqrpRPQPTFuGgK8AW9R33GB9W4DXzEtToNAF8f1LJbE7ZZhbfy+Yi5TNZN
	 As/ERVhkQpg0BzWuJqkptWpMy23BhM0WvTfmQiFy/w/UpQynj+IRF4RDbvblAuKpG1YT+
	 vgfZzQEiis+DGkw5xQWcgQmVZnzkU6+49h00jvx1T1EXNYkE4Z16sVYQCubtAyboODDsB
	 3E1n2idXd6sA4DwRHfgknhK+gYznVuaGJ5gMf9bx3/EVGlrbUvW4V89wf/GeQaWNQpQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923993;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=PVz+O5Vf4bD4A+inYD+ODT07hY5AV+B+fg3VxKfeLBo=;
	b=PR4a47fE/OGz7eob/YNt+Csn0NATRwTi6swxlhjxdEMNuMw9vuMS/PoWnIn1Vhu2SXbq
	 nyWGA3VIlCMRdvBflDhvPCa+0hZEg5Glv6w7zZc4ARz86oJaO9kpMjq719+TmXYS+WAzR
	 /Io0sTmRH3ovx2sS3DELpJBiSn9vWDsPDx0SSpCpZG2g0FZAAWxkkRsh63Y9kD0iLoTBZ
	 TTYfJfNkMri3rZfJL40rtu4HBQuHG75Tqaj4tMQaDldPPW/ZvX5QER0TPpY9PqJhiX4Eo
	 od87f/7dcN0UAaMc8sxMY/+TfnnjES+PZ7aBYPXTCAM8DN9j9YSlOZJFWsb2nTRDkjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uhx57UFN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41671606A326
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uhx57UFN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A5F711F008BE;
	Fri,  6 Nov 2026 00:13:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923992;
	bh=PVz+O5Vf4bD4A+inYD+ODT07hY5AV+B+fg3VxKfeLBo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Uhx57UFNTkok0e8hcEbvxAGvTAlre6KxKeJECRBcx88BatiU5zDO5P3AZ6tDGQ+pR
	 xISc+tppdGxxWbJ82m/eM/aScwGsPZPdblLGxXY9Bsk6z7R0RgkroiMEi9WfY4+q9F
	 i6b/Le0u+VK+X4Q5HqomqkXNKanTzWsOctgWsmJZtR7KRSdKXRBz9AqiJjRniHdCbV
	 e15sTk9KsFj+99TDtZm4s38Xm5ztxzDrOgLofJJwUrlkQ1CgFAvxg7S1K/CB6X7fKD
	 bGsTTeq3iOGDJp8/Ryv/K1PXcjbVpn+PWjoNNZ/zBCygLMgLjxE0pux1sMnx7uReI9
	 PmWhz/+2bLX3w==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 08/12] NFSv4/flexfiles: give each direction its own lock and cacheline
Date: Thu,  5 Nov 2026 19:12:45 -0500
Message-ID: <20261106001251.73472-9-snitzer@kernel.org>
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

A read uses only read_stat and a write only write_stat, but both take
the same stripe lock, and an I/O dirties two cachelines.

Move the lock into struct nfs4_ff_layoutstat, with the in-flight count,
and replace nfs4_ff_busy_timer with a ktime_t.  The structure is then
exactly 64 bytes:

        spinlock_t             lock              4
        int                    ops_in_flight     4
        struct nfs4_ff_io_stat io_stat          48
        ktime_t                busy_start_time   8

Align it to a cacheline.  An I/O now dirties one line, and a read and a
write to one stripe share neither a lock nor a line.  The stripe
shrinks from 384 to 320 bytes, still a multiple of 64 and of 128.

The reporting paths take the two locks in turn.  The statistics are
advisory and were never sampled atomically with in-flight I/O.

With CONFIG_DEBUG_SPINLOCK or CONFIG_PROVE_LOCKING, spinlock_t is larger
and the structure takes two lines.  This affects only the packing.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 53 ++++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h | 26 ++++++-------
 2 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 877a9cc3f46be..192f0bd4918f9 100644
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
 
@@ -752,9 +753,9 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 	s64 report_interval = FF_LAYOUTSTATS_REPORT_INTERVAL;
 	ktime_t last_report;
 
-	lockdep_assert_held(&dss_info->lock);
+	lockdep_assert_held(&layoutstat->lock);
 
-	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
+	nfs4_ff_start_busy_timer(layoutstat, now);
 	layoutstat->io_stat.bytes_requested += requested;
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
@@ -784,13 +785,13 @@ nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
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
@@ -807,10 +808,10 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
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
@@ -826,11 +827,11 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
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
 
@@ -843,10 +844,10 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
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
@@ -866,11 +867,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
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
 
@@ -3083,11 +3084,13 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
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
@@ -3163,16 +3166,18 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
index a8f357a7000d0..76ff6575119d1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -63,23 +63,21 @@ struct nfs4_ff_io_stat {
 	ktime_t				aggregate_completion_time;
 };
 
-/* Both members are protected by the enclosing stripe's lock */
-struct nfs4_ff_busy_timer {
-	ktime_t start_time;
-	int ops_in_flight;
-};
-
+/* One direction's statistics for one stripe, with the lock that guards them */
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
 
 /* Caller must hold the lock guarding this nfs4_ff_layoutstat. */
 static inline __u64
 nfs4_ff_ops_requested(const struct nfs4_ff_layoutstat *layoutstat)
 {
-	return layoutstat->io_stat.ops_completed +
-	       layoutstat->busy_timer.ops_in_flight;
+	return layoutstat->io_stat.ops_completed + layoutstat->ops_in_flight;
 }
 
 struct nfs4_ff_layout_mirror;
@@ -95,12 +93,10 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
-	/* Protects read_stat and write_stat below */
-	spinlock_t			lock ____cacheline_aligned_in_smp;
-	struct nfs4_ff_layoutstat	read_stat;
-	struct nfs4_ff_layoutstat	write_stat;
 	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
 	ktime_t				start_time;
+	struct nfs4_ff_layoutstat	read_stat;
+	struct nfs4_ff_layoutstat	write_stat;
 };
 
 struct nfs4_ff_layout_mirror {
-- 
2.52.0

