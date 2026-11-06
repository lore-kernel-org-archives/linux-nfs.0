Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989279;
	b=pMqY4+2uFde4sfAU/os8VFKSSQyDJUA5BtBUSvKtbOIkUR6jtItsx/SkOdDBdCvPAwi4
	 N6y+vaz0e2k/zfBMtiovQRHJEi/5ky5YLocmQGk9IJtGgQJN08u0jrHvvXDYFqmoKNl2R
	 hTOq2/YLOtfxorQl+FYOnZPID3AxUduObPsQ0yMjPdaHWUbmFmnhi13eLHBjq6L31XPjW
	 k50qfWhF85woWMhAwbpJpNZomM4B+rQll8cKhBiey3hx15vjEZQwxJjL8kPCJFEEmLLX5
	 JSvTuS9R/L4sYRxGFbA9A7YN/2mnhnLfzxYjLXWRmmcHB3rUc0ZZvvKYMic0wnK8ikQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989279;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=qbY5WtkfQ4z+sDtEl6EbWppwRKa1m/OZmQZ3mH7QX0k=;
	b=rX4XVbbJciMX39v2MeZ/PVYyThOfdDCe9C1nPNCSeU2DUsUbrl+5i1ftXhFzGEuh6v7z
	 yjkXDhKmWgnAQRbCNllOPyGZwJ1onTk9dC2f0s8ySjmifa/V465jvA0VwYIUat8HGPkj1
	 z/PDBzCcaIfG8MalQHevV6HJhZ6TFdYrgxhCiMFCTsX1BwDoAptO6941DgEL9WrQ7zUOx
	 a2VZmEfa7AEmr2V4yCCPmcuCDx20OsXW8axCyGUoegLVM7z/lXOMrLAbexahyLqnIo8Jp
	 Afscq1p9pSSfLOnT9pp8hxg4KH2VNeQxn5DF7FqC6jTyKFTAuOW1Wz9J6QRtkOwllJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJSnsisq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F22B0606A332
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NJSnsisq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8BC711F008BD;
	Fri,  6 Nov 2026 18:21:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989278;
	bh=qbY5WtkfQ4z+sDtEl6EbWppwRKa1m/OZmQZ3mH7QX0k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NJSnsisqVObvjReqGLb5ucWIsK1xXwlAeAOISyPJ8X/4JZmAfJ3Ac6DXz58YDTDxE
	 UefD+uhmt9G2o1Q8FeWmGoXhCREEUTnyMGp46nY2JAhu9+TT9l0nO5vfYHAMWCC9pE
	 l1hf5+Pzn2wQ83GidXISrEVIQebaGr0DrDLQZDSPi3Lk2/IliyBqoDlJZCDU0C2/zI
	 yUfGfY4PoCudoQ1LI0ZJSVDyPQowPKmySs0bKLgyVoG3Ib+3e1EQc+nI/IBdKLbgde
	 5FFArc1tNLBO2AdCL5qwJNK3N248emni+tD56GYwc5aBnQm2FDZZ1xk1PA7YEXXas4
	 NfqgAQp6OB7pw==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 08/12] NFSv4/flexfiles: give each direction its own lock and cacheline
Date: Fri,  6 Nov 2026 13:20:56 -0500
Message-ID: <20261106182105.78611-9-snitzer@kernel.org>
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
index 23a8ae68aa5cc..45bb2b15b728b 100644
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
 	s64 last_report;
 
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
index caa4c1e63063f..f8280fa991bb8 100644
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
 	atomic64_t			start_time;
+	struct nfs4_ff_layoutstat	read_stat;
+	struct nfs4_ff_layoutstat	write_stat;
 };
 
 struct nfs4_ff_layout_mirror {
-- 
2.52.0

