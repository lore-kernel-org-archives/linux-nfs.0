Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646681;
	b=WpGLhyVK5uduO08IAFJwXTykFDmhXPcjiYxxbZJKZRrZ5Luws/KfLO9CoB27JlhQUcsd
	 IHTiIGekcGaNtu+mdgGJx9PY5QARZ56zZnmifMTHhDyxFSh1mJJT/XsNQXzvJRK+rE+r5
	 nCGGaECUUHo7oAbrIRoPcti53xW9ESoVq17g8/g21Nb3AAIHzspDFPdgGzE+Arnetd/Mx
	 mrdTgJbJGLwI7KiyvJe46/4iEt9DeO0L54+cZH0B7WKZKUyyETnY7R27Z5XMICDRCmGYO
	 kQawtJVWjPbl1VqI6ioYoGCyq8wyA/4+1aSE0B3o4QtUa/1RJX/XQux0Erlw2HN0b7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646681;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=9ier+WZxVudA46ihyOtYDN0Xx6gEZ0E7nBH7mOj6H98=;
	b=NKIfQ3U5XSNJyXd/yiNwh1fB9dizFmtxcqhQ5UbbShOm3+GiSeJObMjfcv5fwBPxmIg8
	 9l8+kEkh5t18SiUKXaoFlDGZ7LHApDVv74aCy8rGk4VYB1VBS2W7+E4TSPqLdOhuytpgQ
	 4STellXekMXzAT+CXpcBLCm0NfgyIsVAYLxwirKcW1VQyVqYTjzcTPZtfkQKTSOit9HCk
	 2z9Qdg0FuUy8uFUv+nSPqmimr8xKADsC+w5Ta3DddQYaY04u23EzhE8j/yhxAR49CJEn7
	 UC1UsXm8O5dRCvLZjt/mP9ZSZVIeIhxcReoB15nfJy7I2fdykl6hFN5zMPH5+T2w7Fw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=chO+Z5Sg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56A22606A32C
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=chO+Z5Sg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F0E2E1F00A23;
	Mon,  2 Nov 2026 19:11:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646681;
	bh=9ier+WZxVudA46ihyOtYDN0Xx6gEZ0E7nBH7mOj6H98=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=chO+Z5SgyM+e8+35xtH2lexQ5alRTuHUVQPzehTAqDe5pt2AjwfyJJL+v6RAahHC5
	 waKfxCh5CqikPAxctbZpquYxe9xyW2ek0CCTIpCZAjy7lcFUqdw6orLgB3M65nYj6n
	 Tgxn0DM0G9yi9TUmTnvxhQD8JncLfO/Tkm6XAflHX4W42z02lRMGigyDOvhoNIaGfi
	 ANRhq1TEegg6ozc5fWJJiOwFIuCPQnHdUk0EOkLWbI09A/mti7pxvV6tiHA6l+KO1I
	 tyy1ID0PLSL9pIRPaIwnJjwtlS2N42GSOjQidOlqYfRpbB+khvYr+fNhhseOpfoMHc
	 bdSnzOw3BpiaA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 09/11] NFSv4/flexfiles: drop NFS4_FF_MIRROR_STAT_AVAIL
Date: Mon,  2 Nov 2026 14:11:07 -0500
Message-ID: <20261102191109.13470-10-snitzer@kernel.org>
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

The "this needs reporting" hint was a bit in nfs4_ff_layout_mirror::flags,
set on every DS RPC and consumed once per report interval.  It was wrong
in both directions.

It cost too much.  set_bit() ran twice per RPC -- once from
nfs4_ff_layout_stat_io_start_{read,write}() and again from the matching
_end_ -- on a mirror-wide cacheline that every stripe of the mirror
shares.  That is the same false sharing the per-stripe lock was
introduced to remove, and after the preceding patches gave each direction
a line of its own it was the last write to the mirror's line left on the
hot path.  Two unconditional atomic read-modify-writes per RPC, at the
275k-450k RPC/s this series was measured at, to set a hint read once
every 60 seconds.

And it said too little.  The bit is per mirror, but the statistics it
gates are per stripe, and ff_layout_mirror_prepare_stats() tests it
inside the per-stripe loop.  The first stripe with a usable deviceid
cleared it, so every other stripe of that mirror hit the test_and_clear
and skipped.

  What the server sees today: for a mirror with N stripes, a LAYOUTSTATS
  report carries exactly one ff_layoutupdate4, for the lowest usable
  dss_id, no matter how many stripes are busy or how the I/O is spread
  across them.  Stripes 1..N-1 are reported only when the layout is
  returned.  For the 32-stripe RAID0 layout this series targets, the
  server is picking data servers on 1/32 of the picture, and always the
  same 1/32 -- a stripe that is idle while the other 31 are saturated
  reports zeros, and a stripe that is saturated while stripe 0 is idle
  never reports at all.

So drop the bit rather than fix it.  The reporting path already reads
ops_completed for both directions under their locks; remember what it
reported and skip a stripe whose count has not moved since.  That is
strictly more accurate than the flag was -- it is per stripe by
construction, and it cannot be left set by I/O that has already been
reported -- and it costs the I/O paths nothing.

  What the server sees after this patch: up to dev_limit
  ff_layoutupdate4 entries, one per stripe that has completed I/O since
  its own last report, in dss_id order.  The numbers themselves are
  unchanged -- same cumulative ops_completed and bytes_completed, same
  deviceid, same encoding -- there are just more of them, and they
  describe the stripes that did the work.  A stripe with no completions
  since its last report is now omitted rather than reported as an
  unchanged repeat; a server differencing successive reports sees the
  same thing either way.  LAYOUTRETURN still reports every stripe it can
  fit, as before.

nfs4_ff_layout_ds_stripe::last_reported_ops is deliberately out in the
read-mostly region rather than in either nfs4_ff_layoutstat: it is
touched only by ff_layout_mirror_prepare_stats(), about once per report
interval, so it must not consume one of the 64 bytes an I/O dirties.  It
lands in the existing hole ahead of read_stat, so sizeof is still 320.
Both callers of ff_layout_mirror_prepare_stats() hold the inode's i_lock,
which serialises it; no new lock is needed.

NFS4_FF_MIRROR_STAT_AVAIL was the only bit ever defined on
nfs4_ff_layout_mirror::flags, so the field goes too.

Note that dev_limit is 4 in both callers, so N > 4 stripes still cannot
all be reported at once; the next patch rotates which ones are.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 43 +++++++++++++++-----------
 fs/nfs/flexfilelayout/flexfilelayout.h | 12 +++++--
 2 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0b8562efabb24..670780bb3d353 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -829,7 +829,6 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
 					     requested, now);
 	spin_unlock(&dss_info->read_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -849,7 +848,6 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->read_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
 static void
@@ -865,7 +863,6 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
 					     requested, now);
 	spin_unlock(&dss_info->write_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -889,7 +886,6 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->write_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
 static struct nfs4_ff_layout_ds *
@@ -3156,6 +3152,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_ff_layout_ds_stripe *dss_info;
 	struct nfs4_ff_layout_ds *mirror_ds;
+	__u64 read_count, read_bytes, write_count, write_bytes, ops;
 	int i = 0, dss_id;
 
 	rcu_read_lock();
@@ -3167,13 +3164,31 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			mirror_ds = rcu_dereference(dss_info->mirror_ds);
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
-			if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL,
-						&mirror->flags) &&
+
+			spin_lock(&dss_info->read_stat.lock);
+			read_count = dss_info->read_stat.io_stat.ops_completed;
+			read_bytes = dss_info->read_stat.io_stat.bytes_completed;
+			spin_unlock(&dss_info->read_stat.lock);
+			spin_lock(&dss_info->write_stat.lock);
+			write_count = dss_info->write_stat.io_stat.ops_completed;
+			write_bytes = dss_info->write_stat.io_stat.bytes_completed;
+			spin_unlock(&dss_info->write_stat.lock);
+
+			/*
+			 * Nothing has completed on this stripe since it last
+			 * reported, so do not spend one of the few devinfo
+			 * slots on repeating those numbers.  A LAYOUTRETURN is
+			 * the last chance to report and says everything.
+			 */
+			ops = read_count + write_count;
+			if (ops == dss_info->last_reported_ops &&
 			    type != NFS4_FF_OP_LAYOUTRETURN)
 				continue;
+
 			/* mirror refcount put in cleanup_layoutstats */
 			if (!refcount_inc_not_zero(&mirror->ref))
 				continue;
+			dss_info->last_reported_ops = ops;
 			/* The pin holds a reference; it is exchanged out only
 			 * under i_lock.  Put in ff_layout_free_layoutstats().
 			 */
@@ -3183,18 +3198,10 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			       NFS4_DEVICEID4_SIZE);
 			devinfo->offset = 0;
 			devinfo->length = NFS4_MAX_UINT64;
-			spin_lock(&dss_info->read_stat.lock);
-			devinfo->read_count =
-			    dss_info->read_stat.io_stat.ops_completed;
-			devinfo->read_bytes =
-			    dss_info->read_stat.io_stat.bytes_completed;
-			spin_unlock(&dss_info->read_stat.lock);
-			spin_lock(&dss_info->write_stat.lock);
-			devinfo->write_count =
-			    dss_info->write_stat.io_stat.ops_completed;
-			devinfo->write_bytes =
-			    dss_info->write_stat.io_stat.bytes_completed;
-			spin_unlock(&dss_info->write_stat.lock);
+			devinfo->read_count = read_count;
+			devinfo->read_bytes = read_bytes;
+			devinfo->write_count = write_count;
+			devinfo->write_bytes = write_bytes;
 			devinfo->layout_type = LAYOUT_FLEX_FILES;
 			devinfo->ld_private.ops = &layoutstat_ops;
 			priv->dss_info = dss_info;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 876fdb6999473..743957cd12300 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -113,6 +113,15 @@ struct nfs4_ff_layout_ds_stripe {
 	struct nfs_file_localio		nfl;
 	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
 	ktime_t				start_time;
+	/*
+	 * Completed ops, both directions, as of this stripe's last
+	 * LAYOUTSTATS report.  Touched only by
+	 * ff_layout_mirror_prepare_stats(), so roughly once per report
+	 * interval, and serialised by the inode's i_lock, which both of its
+	 * callers hold.  Deliberately out here rather than in either
+	 * nfs4_ff_layoutstat: it must not cost the I/O paths a cacheline.
+	 */
+	__u64				last_reported_ops;
 	/*
 	 * A line each, and each carrying its own lock, so that a read and a
 	 * write to this stripe neither serialise against each other nor
@@ -131,12 +140,9 @@ struct nfs4_ff_layout_mirror {
 	u32				dss_count;
 	struct nfs4_ff_layout_ds_stripe *dss;
 	refcount_t			ref;
-	unsigned long			flags;
 	u32				report_interval;
 };
 
-#define NFS4_FF_MIRROR_STAT_AVAIL	(0)
-
 struct nfs4_ff_layout_segment {
 	struct pnfs_layout_segment	generic_hdr;
 	u64				stripe_unit;
-- 
2.52.0

