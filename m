Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989270;
	b=yqZQBvu4HPHIpRflnWr8nUTcaSRiUE9If9pznO3OLlbJ7cdbehQzutLsG4Opn/pSuXCg
	 Ylv/tMr8fwfYTzfHcir97wC6nCutTW9BvIH9hes0QLyzZBcbrGxIG66OYnbPkSimoYlGh
	 6Xx4B7VpzbOdE0UVqEGSC4G+6PBhZHPmMoIYiEfdO7o1rS2UCHmc53Ai67RMoAPhGwxKT
	 c+UyybnBMrZtIx+v83ps1u3jiO61cS0psgkYsWPAhuSshbJ5dOxXS3mRN++Skx22UFvtP
	 OhcBs+zucPiaHJ09srblzs6K6Hzv+bpxTXem5FF1b2Eynk9xICpVErtPjt5aMkOiaCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989270;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=+8lYU+BRcgzZzjBdGzaXyMyXUEgyQdmX0xatQRK/spo=;
	b=v6Wpo+bgFI2oZSsGthsid9NL+UafnZ0fgDJzfmDf7i/vmecelQVaXZf7Gi811cAOMGBJ
	 jT1ENQiynszbjlhuE7Uz+hTWwkymoGlaEW6X87nJtHGc1OQvEdqnYa1RBjG6i3Rrq2wfJ
	 U2QILTSyORWAM5exPhePGz9z1S3Zl9wHssbN2d7MBkYMYpg3WgHTB7wApOdusVsDiD3mt
	 zEmKCDm6gTc/a7D0s99gzwqBuRkMz1GdKJuf7eeYj10uYWcwT2xOHhjiHJlXQvBccPViz
	 EEYMVGajw2rSVPFdwV9E2LBfxps0cW1Wk5xsX7ntxKoXmV96egYn4us1DGY8AIlS88A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EDi5Kn25;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C19EC606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EDi5Kn25
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 29F561F008A4;
	Fri,  6 Nov 2026 18:21:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989269;
	bh=+8lYU+BRcgzZzjBdGzaXyMyXUEgyQdmX0xatQRK/spo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EDi5Kn25C2XC5hIO6HQIowtguLvudRC9yII8Ye9Y8QQuLS2j+6N7ELm9PcQn+oUTG
	 cb27h9FTP6Y4oZb96dFyt2ymIss+WNQbR7WQ8zegD84IU3bh1R259qMTSu4junRr5e
	 pYEq23rbiPXt2brcT4BdmQsrOHjbFUoWQlZ+I29xDOTTiGHPTv7mEVyOe+mFXvRgWn
	 h6lCKPXQhERPIigo8UYiKca4UhKEVoNmg0RLCVUzDWQpNKcB//vbJEOti4n1SmgDNA
	 UYZbPWNJNrxV3NL6djra0dIGVtEdkbT4oVMKDRwXtz8586jWrLh6ZvOFgYvCrDqOld
	 /cC3NSX3nQ2hg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@hammerspace.com>
Subject: [PATCH v3 01/12] NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
Date: Fri,  6 Nov 2026 13:20:49 -0500
Message-ID: <20261106182105.78611-2-snitzer@kernel.org>
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

From: Jonathan Flynn <jonathan.flynn@hammerspace.com>

Each stripe of a mirror has its own read_stat and write_stat, but the
lock that protects them is in the mirror.  Every DS RPC takes that lock
twice: in ff_layout_{read,write}_prepare_common() and in
ff_layout_{read,write}_count_stats().  For a RAID0-style layout (one
mirror, many stripes) the lock is per file, so striping adds RPC
parallelism but no lock parallelism.

A 64-core client reads one file from a 32-stripe layout with a 128KiB
stripe unit (~36.7 GB/s, ~275k NFSv3 READ RPCs/s).  It spends 45% of its
CPU in native_queued_spin_lock_slowpath.  lock:contention_begin puts
73% of the contention events in the two layoutstats paths:

  36.4%  rpc_exit_task -> ff_layout_read_count_stats ->
         ff_layout_read_record_layoutstats_done -> _raw_spin_lock
  36.3%  ff_layout_read_prepare_v3 ->
         ff_layout_read_record_layoutstats_start -> _raw_spin_lock

Move the lock into struct nfs4_ff_layout_ds_stripe, next to the
statistics it protects, so that I/O to different stripes does not
contend.  The reporting paths take the same per-stripe lock.

Set NFS4_FF_MIRROR_STAT_AVAIL outside the lock: it is a mirror-wide bit
operation and needs no lock.

ffl->last_report_time is shared by every mirror and stripe of a layout,
so no single mirror lock ever protected it.  Make it an atomic64_t and
update it with atomic64_try_cmpxchg(): the caller that wins sends the
LAYOUTSTATS report.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 43 ++++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  4 ++-
 2 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9492d6bc1d1a7..7bd88f596e888 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -60,7 +60,7 @@ ff_layout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 		pnfs_init_ds_commit_info(&ffl->commit_info);
 		INIT_LIST_HEAD(&ffl->error_list);
 		INIT_LIST_HEAD(&ffl->mirrors);
-		ffl->last_report_time = ktime_get();
+		atomic64_set(&ffl->last_report_time, ktime_get());
 		ffl->commit_info.ops = &ff_layout_commit_ops;
 		return &ffl->generic_hdr;
 	} else
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
+	s64 last_report;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
 	if (!mirror->dss[dss_id].start_time)
@@ -744,13 +747,13 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
 		report_interval = (s64)layoutstats_timer * 1000LL;
-	if (ktime_to_ms(ktime_sub(now, ffl->last_report_time)) >=
-			report_interval) {
-		ffl->last_report_time = now;
-		return true;
-	}
 
-	return false;
+	/* Shared by every mirror and stripe: the cmpxchg winner reports. */
+	last_report = atomic64_read(&ffl->last_report_time);
+	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
+		return false;
+
+	return atomic64_try_cmpxchg(&ffl->last_report_time, &last_report, now);
 }
 
 static void
@@ -794,13 +797,13 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
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
@@ -813,12 +816,12 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
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
@@ -829,7 +832,7 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 {
 	bool report;
 
-	spin_lock(&mirror->lock);
+	spin_lock(&mirror->dss[dss_id].lock);
 	report = nfs4_ff_layoutstat_start_io(
 		mirror,
 		dss_id,
@@ -838,8 +841,8 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	nfs4_ff_layout_stat_io_update_requested(
 		&mirror->dss[dss_id].write_stat,
 		requested);
+	spin_unlock(&mirror->dss[dss_id].lock);
 	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
-	spin_unlock(&mirror->lock);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -856,11 +859,11 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
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
@@ -3071,13 +3074,13 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
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
@@ -3153,7 +3156,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       NFS4_DEVICEID4_SIZE);
 			devinfo->offset = 0;
 			devinfo->length = NFS4_MAX_UINT64;
-			spin_lock(&mirror->lock);
+			spin_lock(&dss_info->lock);
 			devinfo->read_count =
 			    dss_info->read_stat.io_stat.ops_completed;
 			devinfo->read_bytes =
@@ -3162,7 +3165,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			    dss_info->write_stat.io_stat.ops_completed;
 			devinfo->write_bytes =
 			    dss_info->write_stat.io_stat.bytes_completed;
-			spin_unlock(&mirror->lock);
+			spin_unlock(&dss_info->lock);
 			devinfo->layout_type = LAYOUT_FLEX_FILES;
 			devinfo->ld_private.ops = &layoutstat_ops;
 			priv->dss_info = dss_info;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 09c3cd6964fd6..3f94a08c30305 100644
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
@@ -120,7 +122,7 @@ struct nfs4_flexfile_layout {
 	struct pnfs_ds_commit_info commit_info;
 	struct list_head	mirrors;
 	struct list_head	error_list; /* nfs4_ff_layout_ds_err */
-	ktime_t			last_report_time; /* Layoutstat report times */
+	atomic64_t		last_report_time; /* Layoutstat report times */
 	unsigned long		flags;
 };
 
-- 
2.52.0

