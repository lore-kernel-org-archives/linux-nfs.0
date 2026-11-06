Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923985;
	b=35qNz8n11mV2kT4f44g4W9SFmW0lReVJHjIX72MTuwNeOiIuPpBuq3rvUujW/WxFI+DA
	 kxb3pRbMLlllrvCvmrrmO9CGUcUZPMzqWgozsTX6oWjClXc3TazMAkoJieEnQj+6lw2Bn
	 WivKJyBBjNiwu90bITnHlCN0daFss1VkBQUXxJBJHFhQ9XEogEgi5LXYk8Zi6bWv9JrZ9
	 DqpmfSau0PJav0uOU9W5NTlBY1gt60Ah29s+TzGa//ziDIz0/NQdXuEZkm6rJ9iuN7BIF
	 9fUAskyDdO2dHk8EFtN23UuMm61i78/e6XN/yhY/NXFS9zSO8SG2HJhrD1yColivWKg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923985;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=a2ZhIEtkutpZzIXjPOe5SfuXe/L5KfmymAr1CLqay/E=;
	b=iNfTBDThULXtyCuvclQP6kIfjlvPnUNnW9S1vyPFtTs9Vx8bftZYNde82OHYIGpiLRae
	 TL9rvqjRF9Kt77Z0avaD98SighSJjzZhdC+JM02G9eoNIWQi6wTmUB2KTQYlv4JHfu41h
	 DjCpGbfM/V+zw18NYZwN+jcrWXHXfgG4aDzyEWTzp5GFXakHIhbhIres7V5eEjZ0yQtOl
	 dEq0DbNm1UKYnkLbZ+YWPZViY54cxlzfengCZtVaiteipftJhwm4jCW+ZUqeRsdLwa4op
	 r+h8XFbOR+7SngMqsULGc+eAwvHvkoHIQtpPsbY/iOu2PizAcPEeY/J8+bzbXxGjnFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TZEWO2B1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1D9A606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TZEWO2B1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 698881F008A1;
	Fri,  6 Nov 2026 00:13:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923984;
	bh=a2ZhIEtkutpZzIXjPOe5SfuXe/L5KfmymAr1CLqay/E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TZEWO2B1xCPfrGOLoA/msNNGb9MFXdZn78VaUWdQLi7yHOOrK1wyonDT4GjIy5Vtx
	 NW1GlFNBKXZrZyewm8HxCkNcU0LzvUgqyk/ZTId3JpOH+Mz1d42oW8WQlnnkRPfLV7
	 Uamf77JAnx1N5LF798RJyK4SVHUJ98eo8m6E4LXxKWDY0/4kcG4rP3a+ysJIAlT1ea
	 +46RFjyTqIBb3d+PDFbWxIrs9xeVvHIQBhqf78tG6XYtur23LMrA71xVcZtOL6Sqd7
	 Q8sGuzbaY8zi/Er1OlJTQFAmZgFBOotgBL799kvU6RQlTlcQvIMmcG1S8SqNL8bAeP
	 qb1Xsib3fNqjQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@hammerspace.com>
Subject: [PATCH v2 01/12] NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
Date: Thu,  5 Nov 2026 19:12:38 -0500
Message-ID: <20261106001251.73472-2-snitzer@kernel.org>
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
so no single mirror lock ever protected it.  Update it with a cmpxchg:
the caller that wins sends the LAYOUTSTATS report.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 41 ++++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  2 ++
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9492d6bc1d1a7..7b0e6bdf758fb 100644
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
+	last_report = READ_ONCE(ffl->last_report_time);
+	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
+		return false;
+
+	return try_cmpxchg64(&ffl->last_report_time, &last_report, now);
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

