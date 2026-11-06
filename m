Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923997;
	b=yrI/rXCWd27L0hmst+MtntusF2AYp7FQxlrLFa0ATxPVUefAtvzmYpurqM4+0A6OdoNT
	 oqAtobMoaGuobt/53AdXmp/CX2tGaUpkFuvfGgOgyF6m7qCX5XwnreqsuhSsBIIb6T3uB
	 wEoZr/DZIIkmHkjEO8s+HzFAQCyAF+VcSwM8UFjw3L48itqsvt7V2eDClfLx7pAzzBiAh
	 QKOXxrftTMA+zFW4Fldfrviwqxi7EsIX3CVXriEruXm/qdYGeS727p8vUSaVIEc7AwMLM
	 dGqz4OPC9Dz3J1bD9QjZnYPyP/DWYBoAX5a/Gr2GPbWVu1xpx3kZTlt4r3GJ1g/2N/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923997;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=zEMIDTKCvvZMK897dEqBE+NtLZOXLgoxzq6DTCl9cTM=;
	b=pIP+OLsRX8lcKwiTD/xHHkXiBAPqUXDjr/y1jcCMxGxLaU59n+Wqy/fJkFf0deqXeoWV
	 lHL/HcHgVNkRDB4TWg3EcmqYmjtRkoaIXIUpRKqmWB7X2LN1ouwKRE5lotQ8eDi1IYRI7
	 wFiF3tcLAMPcUV6/u1hasYD2UAGQmNR2HrfJsrp2H6MFGNO35nb3gjWXuskdLFPA0mZ1A
	 9385BJz8pk+Fsjg0vjYK4QQU7fpDyniX84ccrmbmaQlKBpl1puUm5Jkrtsx5xkLI6RbEs
	 y+kxFJTCRRlbvtu782C5cDyJbCaGuabKjhEGUrh0Jhdrmic+nQ15bAiHbJKjq+Lf1BA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fKrB2Z9T;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49A55606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fKrB2Z9T
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A27881F008A1;
	Fri,  6 Nov 2026 00:13:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923996;
	bh=zEMIDTKCvvZMK897dEqBE+NtLZOXLgoxzq6DTCl9cTM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fKrB2Z9TIxwpqFIQJSnEi2E3Qxmv/TxA1VeYkl81OxKBJy/D9QFxpO+JOQs+fQzYD
	 KMPNuG6kSaNwMOXaFdNiLG2jzp9IUI6iZ5ICcj9RpsCqXXlmSyFJG0DtgWmWZs6659
	 UDuhNsix+Hit7x4UwAtBFjfPHkPwcswNdFSH19zjhwAPkcSA6Ul93GMt+aYomk0Md5
	 ep+/Gk47UXY5+1cMa9w3bYB/egLNIX1aai7+nn8dmR3lLXyBsGKkcDUC1yvYhVky47
	 o7KxgOEYlrWwNqidPU3kof+R0qz5/NCcIFHNOfzoFR97UFz4CdXX4jzOfVg7C1jUCJ
	 M3p0ZDcFaSnzw==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 11/12] NFSv4/flexfiles: take the report decision out of the critical section
Date: Thu,  5 Nov 2026 19:12:48 -0500
Message-ID: <20261106001251.73472-12-snitzer@kernel.org>
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

When an I/O to a data server starts, the stripe lock also covered the
decision to send a LAYOUTSTATS report.  That decision reads the mirror
and the layout header, divides in ktime_to_ms(), and does a cmpxchg on
ffl->last_report_time.  None of it is data that the lock protects.

Move the decision into nfs4_ff_layoutstat_report_due() and call it,
and nfs4_ff_layoutstat_set_start_time(), after the unlock.  The lock now
covers two writes to one cacheline.  The order of the updates and the
report does not change.

nfs4_ff_layoutstat_end_io() loses its unused dss_info argument.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 49 ++++++++++++++------------
 1 file changed, 27 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index b4d4971816145..f3f4573880d98 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -739,32 +739,36 @@ nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
 		try_cmpxchg64(&dss_info->start_time, &unset, now);
 }
 
-/*
- * Account for an I/O about to be sent to this stripe, and return true if a
- * LAYOUTSTATS report is due.
- */
-static bool
-nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			    struct nfs4_ff_layoutstat *layoutstat,
+/* Account for an I/O about to be sent to this stripe. */
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
+ * Is a LAYOUTSTATS report due?  Called outside the statistics locks, which
+ * protect none of this.  last_report_time is shared by every mirror and
+ * stripe of the layout: the cmpxchg winner reports.
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
 
-	/* Shared by every mirror and stripe: the cmpxchg winner reports. */
 	last_report = READ_ONCE(ffl->last_report_time);
 	if (ktime_to_ms(ktime_sub(now, last_report)) < report_interval)
 		return false;
@@ -774,8 +778,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 
 /* Account for an I/O that has completed on this stripe. */
 static void
-nfs4_ff_layoutstat_end_io(struct nfs4_ff_layout_ds_stripe *dss_info,
-			  struct nfs4_ff_layoutstat *layoutstat,
+nfs4_ff_layoutstat_end_io(struct nfs4_ff_layoutstat *layoutstat,
 			  __u64 requested,
 			  __u64 completed,
 			  ktime_t time_completed,
@@ -809,10 +812,11 @@ nfs4_ff_layout_stat_io_start_read(struct inode *inode,
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
@@ -827,7 +831,7 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
 
 	spin_lock(&dss_info->read_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->read_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->read_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->read_stat.lock);
@@ -843,10 +847,11 @@ nfs4_ff_layout_stat_io_start_write(struct inode *inode,
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
@@ -865,7 +870,7 @@ nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		requested = completed = 0;
 
 	spin_lock(&dss_info->write_stat.lock);
-	nfs4_ff_layoutstat_end_io(dss_info, &dss_info->write_stat,
+	nfs4_ff_layoutstat_end_io(&dss_info->write_stat,
 				  requested, completed,
 				  ktime_get(), task->tk_start);
 	spin_unlock(&dss_info->write_stat.lock);
-- 
2.52.0

