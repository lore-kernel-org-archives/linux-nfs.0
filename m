Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646675;
	b=UAu8cVyAQEkz8BPqs5trPBWumXVoCN20iKT6Hr3LCH4vlL47AmPmzwTv2GH9B3y8zkYs
	 tCJfPS5hsNbdJOHDo3qCAROnFOF4yxniDPlywCQbBzIs50f2A8cVYwoQCzgZt2tWMqFGM
	 C7B1VVp71633yQbHATraVJmdErhy+OpGW5PvZSAohD+nee76ZEH/hSvqycDJW/NnEN8BP
	 1ygYGhhtdN4RwDbF2kLB3CVQszwviCeP186lb9dukUal47wjilvS6PROFP1JDGdHoDdzt
	 3qlF9KH8WUCPRK/sUiGzo2QLnvdoBbJdAKZKTtL8tY7Eh5+RBa9eqbO8nmoJX7s1X9w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646675;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=vkttbWMg4xZZ8ySBRehreyAbpcBOjcmNQCJ308bLESY=;
	b=mUbYGDQAe6u11yZVYpNqccIgSNzlNg/ovsP8T0iTMgmVR5dcSLZndeDnBAP18L403Auc
	 i6sOVFgYVtWpu4uMPQqZk+9Z8AXSQker7ij30ZySbt9TM46hu+0UXJ489zqJdYCHyF4ZF
	 MAsmpE1MLeCfH+S9oAZjfeulThtG/Yt33Mwm5+6Hg77FJPXnpQ257rFw3JeZ77LhJB9yo
	 cYnAsUI+6RIkKeTflaG0/ZZM8YthRJzvblkZeVQiIqct5oY9XFI1PwCRMU+OOHwQlxeji
	 h3jA4MePeoI311QiWqrpIO0BZ5caqKKCvXfsMcAmTW7w9OhCVN4p0T2LIWIbT/RSq1Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QjEbMWaP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59E25606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QjEbMWaP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9EBF1F00A1C;
	Mon,  2 Nov 2026 19:11:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646675;
	bh=vkttbWMg4xZZ8ySBRehreyAbpcBOjcmNQCJ308bLESY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QjEbMWaP2ZXTQWpjr32fQm+q4sIXwhO0TMUBbCLiad5TtGouXa+BuHzo2TTwyPBjA
	 IlJwu12RZJVIgooQf8MEy9ClhiykJ57dP5RY3sCilwXR+WwybyhbHo9TvfmI+0jmES
	 /vZSRCiq0Rw/r0lYwoQE2BdSKDMfn3UDZwyU8serO5x5bwAkhOVM/6GVy1nkH9UhPL
	 7ftCCgLwvElMmbQEo32FYC3BGTnZbYKC9Li6qbRcnsH2lkacmmSjsJr2HMy1SzLN7+
	 yhIDR8jukgsqC4vDRuOjTFtA/X3OuK5eEt9evGY5/3gFJlYxhr0jzaaqBEp6g0FnDF
	 U50SlAT++TO1Q==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 04/11] NFSv4/flexfiles: make dss_info->start_time write-once
Date: Mon,  2 Nov 2026 14:11:02 -0500
Message-ID: <20261102191109.13470-5-snitzer@kernel.org>
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

start_time was written under the stripe lock in
nfs4_ff_layoutstat_start_io() and read outside it in
ff_layout_encode_ff_layoutupdate().  Pre-existing -- mirror->lock had the
same shape -- and benign, since it is a single naturally aligned 8 byte
value, but it is an unannotated race either way.

The lock is the wrong tool for it.  ffl_duration is measured from this
stripe's first I/O, so the field is written once and read-only for the
rest of the stripe's life.  Say that instead: publish it with
try_cmpxchg64() and let the first I/O win, and read it with READ_ONCE().
Only the first I/O to a stripe pays the read-modify-write; every one
after it short circuits on the READ_ONCE().

ffl->last_report_time two lines away is already published this way, so
the pattern is not new to this file.

This also stops start_time depending on there being exactly one lock per
stripe, which a later patch changes.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 21 ++++++++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fc1369df8439..7c328f2ec900d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -729,6 +729,22 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 	return ktime_sub(now, start);
 }
 
+/*
+ * ffl_duration is measured from this stripe's first I/O, so start_time is
+ * written once and read-only for the rest of the stripe's life.  Publish it
+ * with a cmpxchg and let the first I/O win, rather than depending on a lock
+ * that every reader would then have to take.
+ */
+static void
+nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe *dss_info,
+				  ktime_t now)
+{
+	ktime_t unset = 0;
+
+	if (!READ_ONCE(dss_info->start_time))
+		try_cmpxchg64(&dss_info->start_time, &unset, now);
+}
+
 static bool
 nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 			    u32 dss_id,
@@ -740,8 +756,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	ktime_t last_report;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	if (!mirror->dss[dss_id].start_time)
-		mirror->dss[dss_id].start_time = now;
+	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
@@ -3087,7 +3102,7 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
 				 ktime_sub(ktime_get(),
-					   dss_info->start_time));
+					   READ_ONCE(dss_info->start_time)));
 	/* bool */
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(false);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index f48860450cf28..658940979883a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -88,7 +88,7 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
 	/*
-	 * Protects read_stat, write_stat and start_time below.
+	 * Protects read_stat and write_stat below.
 	 *
 	 * Cacheline aligned so that the layoutstats accounting done on
 	 * every I/O to this stripe does not share cachelines with the
@@ -100,6 +100,7 @@ struct nfs4_ff_layout_ds_stripe {
 	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
+	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
 	ktime_t				start_time;
 };
 
-- 
2.52.0

