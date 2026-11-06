Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989280;
	b=xYrzDm2IdOXw2uW8LVfdQChlB/eKwA10vq55VzylkYkK46XFUr2d/e844KMf4ynuFLjl
	 rWC1GtTB0sZwqsgH98YdMxYxoRNjO1q/zkAjlc+y0KliqR347eqZvrF4NXYQxmgSwfgQr
	 KHrc9UxBn+YABPCbWKxfFpGAF8UnwLIZ4CXdt2hU9XlWspziCjfMKZpJbfDWg7oM+Bb52
	 YfCF7T4J+B9pMjrsSKGWOZWpaGSSpe3OLjeh6o/USY7RqQPi6K0Zfc8mP6wvh+VRXGEjT
	 xMlW+sXlcs1leRJw0zXwkufWHYF4dXsGfsnYnhBQkV7odQ+y3zlN21QCQ/4hIUMqaZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989280;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=UGGuMI7SsxIcI7RkVHBPawP6hV7jg++lEngHdpknNa8=;
	b=Vnbrl2Uwf/d8W03qcYhWXXtNKW17SyTfPbXKn9IgfYa8xmyrYAyqxoY9pWcplx4sJKju
	 vqvsg5U5Mut7w1E5ZUyiy0s92K2gVRWnkGm2EXhp2Cp9ucy4AXTikom80kpM7LGwSWTzY
	 bQRv6dk8X1drIUnV+HwYUVagyj80GyBaF8QL1AZKd8p3gNNBq/aAYzaBahO0YJSpS3D//
	 PR/dqqJp7pvMD5chB69pZRLl4uJqiZ3JoYtP+HF/HxoiTXwbNsI4Dg7142kebGBKXgsjb
	 C8Wd8lMaPN1RLFeZd+SeEoIvvqJZMONqGBQUXnU9IudD+nm29RX3xnF5f91NQHEuGIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oSWV9zkY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C5A5606A33A
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oSWV9zkY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C99901F00901;
	Fri,  6 Nov 2026 18:21:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989280;
	bh=UGGuMI7SsxIcI7RkVHBPawP6hV7jg++lEngHdpknNa8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=oSWV9zkYFPWc27W/CiTb4Vig53lEW3sAOwN4kgGu17Ixe2GjqgWPF8VhDMSoL5LpO
	 odMY9lrwxHD188oF2Za+s2ZcEL35P8gBL4/dzVDsr/3u4Q3iBA4tSyRA3OZjXEevNu
	 G+87oVVAdyPqMRRzO7zQeQ1Sb3WAEMpoS0tQ7ne4xuN5bAZzPtCI06WfD3CqnR39Ck
	 MosOAEdXfiHlCos+3/tXtJhiMVer9fnOyA7wF6UXFqMaudTLGsnMwsPTBIazfH0TEj
	 1T0oMbbGQ0Eyb0zroViiQ4yJv4uDRvjDgVBrEeUsilC/NQ4d+risIIyzmHhH3JTMm4
	 +i4OwYizmUxUg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 09/12] NFSv4/flexfiles: drop NFS4_FF_MIRROR_STAT_AVAIL
Date: Fri,  6 Nov 2026 13:20:57 -0500
Message-ID: <20261106182105.78611-10-snitzer@kernel.org>
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

Each DS RPC sets NFS4_FF_MIRROR_STAT_AVAIL twice, at start and at
completion.  These are two atomic operations per RPC on a cacheline that
all stripes of the mirror share.  The flag is read once per report
interval.

The flag also hides most stripes.  It is per mirror, but
ff_layout_mirror_prepare_stats() tests and clears it in the per-stripe
loop.  The first stripe clears it, so a LAYOUTSTATS report contains only
the lowest usable stripe of each mirror.

Remove the flag.  Record each stripe's completed ops when it is
reported, and skip a stripe whose count did not change.  A report then
contains each stripe that completed I/O since its last report, up to the
dev_limit of the caller.  The reported values do not change.
LAYOUTRETURN still reports every stripe that fits.

The new last_reported_ops is in an existing hole in the read-mostly part
of the stripe.  The I/O paths do not touch it, and the stripe stays 320
bytes.  Both callers of ff_layout_mirror_prepare_stats() hold the
inode's i_lock, which serializes it.

NFS4_FF_MIRROR_STAT_AVAIL was the only flag in
nfs4_ff_layout_mirror::flags, so remove that field too.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 38 ++++++++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h |  5 ++--
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 45bb2b15b728b..4f27b1ea8b621 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -812,7 +812,6 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->read_stat,
 					     requested, now);
 	spin_unlock(&dss_info->read_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -832,7 +831,6 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->read_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
 static void
@@ -848,7 +846,6 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
 	report = nfs4_ff_layoutstat_start_io(dss_info, &dss_info->write_stat,
 					     requested, now);
 	spin_unlock(&dss_info->write_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 
 	if (report)
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
@@ -872,7 +869,6 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->write_stat.lock);
-	set_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags);
 }
 
 static struct nfs4_ff_layout_ds *
@@ -3139,6 +3135,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_ff_layout_ds_stripe *dss_info;
 	struct nfs4_ff_layout_ds *mirror_ds;
+	__u64 read_count, read_bytes, write_count, write_bytes, ops;
 	int i = 0, dss_id;
 
 	rcu_read_lock();
@@ -3150,13 +3147,26 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
+			/* Skip a stripe with no completions since its last report */
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
@@ -3166,18 +3176,10 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
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
index f8280fa991bb8..69dfdcfb9664d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -95,6 +95,8 @@ struct nfs4_ff_layout_ds_stripe {
 	struct nfs_file_localio		nfl;
 	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
 	atomic64_t			start_time;
+	/* Completed ops, both directions, as of this stripe's last report */
+	__u64				last_reported_ops;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 };
@@ -105,12 +107,9 @@ struct nfs4_ff_layout_mirror {
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

