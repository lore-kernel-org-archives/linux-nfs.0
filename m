Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923998;
	b=bvV32GedWLlFpXoIkPk/4vg9gR7D9staOyLYuK6bRVfbosNlu25aBIlCDcKOyn+9wNt5
	 5v6R916maebvFveBFni0RrUNKClPWD8hn/iTskgxmfmDhMWVvc+qoAZNW6hrNuDUCPZFC
	 yeoxspJpFiprYmCRORCIBoWgiU9t4U5zLtq2Po+1BEbxKayW2vjLpjhfdChrkaFvzYeJ2
	 dTG+e0Gj3qxIHTa8vTPc64Jwl+EOxePYS3F8nBVwfl8egzWPA6S3gLOsGBYjothHWuL+n
	 HSP2HsGvHiWjQwFODUQXfsEtN/vnefj7Selq1+IgY4/AyiIqFBMhG6xtH0g5E9IVtNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923998;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=ongKTCtGb0Pcj3VTXHH/Su+cpQRpt0t9nhyyBbQwa3M=;
	b=OqtCRDND6llDmWJpriAYa3ZEql0VkgzTESU1CsMwA5vhXr66EjOqH9LYLRLDJpxabuK7
	 We+1WCUnmv30GBaLs9K+Y1R15DBbyKHyNc5KoupnMFdsw37PZR1Jg6S8eeX3mptm4qhlQ
	 IXOc47d0FAerG93He01O2OJwcSJRTcL/Tlu0cPHNkF4bd7l6JH0shQ/iz+INrIfgcr5TL
	 bvDqmJckE73aEv9SNOicOKmRVNaDLa9sGQ0TOZxKSS3/xp7Wl/iA4vTLsdhAIlxqNkC8w
	 Fneldq4hM/O4RfPDmRBURDR7NgAOUKKSK7D2spU3fcn/3kin74TSAl4VDq5dCetvXbg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="RFbkyAA/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 826A1606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RFbkyAA/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E4C4D1F008A6;
	Fri,  6 Nov 2026 00:13:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923998;
	bh=ongKTCtGb0Pcj3VTXHH/Su+cpQRpt0t9nhyyBbQwa3M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RFbkyAA/HcEqvzocFqte5B4iBiCsWkF/8rGkPBuagmHIVRSDk4an4NsS/Ao9dDIj2
	 W5SIpY83c/h06MsokEaich4ZiIqXhzQn/KhUSsxvcCU3eD1BtfZ3TKe8NaSbnrkT1b
	 tDSv54halaoAtN+9cWImT75XLm4icfo5/tDZUltzE1VDT6SKfGWnD10NuH3q4jcsZi
	 c46840MoE7rUGhFfA+WC1CXmTwyedXpuJ6hCoxI6rxc9Ox1qx4W9VwvO8lqKJHqZ12
	 rin907dCcxO/KfwqTgTbjfAqwWqJ1IuLgamn3rXen44eUDfje3SgldrZIHqgK961RX
	 mP1rcjez2krPw==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 12/12] NFSv4/flexfiles: share one helper for the start of a read and a write
Date: Thu,  5 Nov 2026 19:12:49 -0500
Message-ID: <20261106001251.73472-13-snitzer@kernel.org>
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

nfs4_ff_layout_stat_io_start_read() and
nfs4_ff_layout_stat_io_start_write() differ only in the statistics they
update.  Replace them with nfs4_ff_layout_stat_io_start(), which takes
the direction of the I/O.

No functional change.

Suggested-by: Anna Schumaker <anna@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 62 +++++++-------------------
 1 file changed, 17 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f3f4573880d98..a28224637d394 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -803,21 +803,21 @@ nfs4_ff_layoutstat_end_io(struct nfs4_ff_layoutstat *layoutstat,
 }
 
 static void
-nfs4_ff_layout_stat_io_start_read(struct inode *inode,
-		struct nfs4_ff_layout_mirror *mirror,
-		u32 dss_id,
-		__u64 requested, ktime_t now)
+nfs4_ff_layout_stat_io_start(struct inode *inode,
+			     struct nfs4_ff_layout_mirror *mirror,
+			     u32 dss_id, bool write,
+			     __u64 requested, ktime_t now)
 {
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
-	bool report;
+	struct nfs4_ff_layoutstat *layoutstat =
+		write ? &dss_info->write_stat : &dss_info->read_stat;
 
-	spin_lock(&dss_info->read_stat.lock);
-	nfs4_ff_layoutstat_start_io(&dss_info->read_stat, requested, now);
-	spin_unlock(&dss_info->read_stat.lock);
+	spin_lock(&layoutstat->lock);
+	nfs4_ff_layoutstat_start_io(layoutstat, requested, now);
+	spin_unlock(&layoutstat->lock);
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
-	report = nfs4_ff_layoutstat_report_due(dss_info, now);
-	if (report)
+	if (nfs4_ff_layoutstat_report_due(dss_info, now))
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
 }
 
@@ -837,25 +837,6 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	spin_unlock(&dss_info->read_stat.lock);
 }
 
-static void
-nfs4_ff_layout_stat_io_start_write(struct inode *inode,
-		struct nfs4_ff_layout_mirror *mirror,
-		u32 dss_id,
-		__u64 requested, ktime_t now)
-{
-	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
-	bool report;
-
-	spin_lock(&dss_info->write_stat.lock);
-	nfs4_ff_layoutstat_start_io(&dss_info->write_stat, requested, now);
-	spin_unlock(&dss_info->write_stat.lock);
-
-	nfs4_ff_layoutstat_set_start_time(dss_info, now);
-	report = nfs4_ff_layoutstat_report_due(dss_info, now);
-	if (report)
-		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
-}
-
 static void
 nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		struct nfs4_ff_layout_mirror *mirror,
@@ -1772,12 +1753,8 @@ static void ff_layout_read_record_layoutstats_start(struct rpc_task *task,
 		mirror->dss_count,
 		hdr->args.offset);
 
-	nfs4_ff_layout_stat_io_start_read(
-		hdr->inode,
-		mirror,
-		dss_id,
-		hdr->args.count,
-		task->tk_start);
+	nfs4_ff_layout_stat_io_start(hdr->inode, mirror, dss_id, false,
+				     hdr->args.count, task->tk_start);
 }
 
 static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
@@ -2002,12 +1979,8 @@ static void ff_layout_write_record_layoutstats_start(struct rpc_task *task,
 		mirror->dss_count,
 		hdr->args.offset);
 
-	nfs4_ff_layout_stat_io_start_write(
-		hdr->inode,
-		mirror,
-		dss_id,
-		hdr->args.count,
-		task->tk_start);
+	nfs4_ff_layout_stat_io_start(hdr->inode, mirror, dss_id, true,
+				     hdr->args.count, task->tk_start);
 }
 
 static void ff_layout_write_record_layoutstats_done(struct rpc_task *task,
@@ -2121,10 +2094,9 @@ static void ff_layout_commit_record_layoutstats_start(struct rpc_task *task,
 
 	idx = calc_mirror_idx_from_commit(cdata->lseg, cdata->ds_commit_index);
 	dss_id = calc_dss_id_from_commit(cdata->lseg, cdata->ds_commit_index);
-	nfs4_ff_layout_stat_io_start_write(cdata->inode,
-			FF_LAYOUT_COMP(cdata->lseg, idx),
-			dss_id,
-			0, task->tk_start);
+	nfs4_ff_layout_stat_io_start(cdata->inode,
+				     FF_LAYOUT_COMP(cdata->lseg, idx),
+				     dss_id, true, 0, task->tk_start);
 }
 
 static void ff_layout_commit_record_layoutstats_done(struct rpc_task *task,
-- 
2.52.0

