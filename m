Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646683;
	b=W19gwXobOMMpQeJYZw5l7Vo/u5/f0JaPZ4DDq+bnB1uZI8MqHQoUZWIPlG+SG0GdF0nA
	 XJn7t5bpy1i+OWvhnFY9AjY9YYuV5oc/cl6yQWYwxLP8DBNH7FXWmjHNtYLj6QeSJkE4G
	 Wjmj4fDMgfKZhs5lOLrqNpshWJx3YXc5dgu60dyuB+P5FyJwa+GTyb1LbCk25JRkwJaKX
	 eq640oL+TAaMthTP6RA7ykB/PZ2ItgpkPwOOkUtfGHsjjI3VnHjJsTr5PC1I0oRexRTQr
	 d6W6jpNB+a8tmWro3L78lIZqICmE75Iie/aKQU/gox+gf9ZGLm4MO874wwBeFjOnT/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646683;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=fQmksu8GFN8fKiS1uq41EywVFxHjHrvgyVInnd6J5no=;
	b=0PZ0/83gKhrb8eFzOEtkJtBTT/Rh5TOFJPg+mpfMqdQYgvCXXIj/C8HRVI8zhHEYQ4Oa
	 eo6IckheiFMgt1OPB09kezD33wp969UyZ6lF8g9Vmmdz4uu68QptVA7UricHcpVaKhHZP
	 h/nuk155xDppkFAg4pdl4OtNElKyZd/EguJn6IDmhg8+Dyg5vic6AsUzcJazYE8I4YMC+
	 +AjeIxi7b1ltvxGPfsc6zZe61MXJ/r/wqPoK+vrbEpoeYG+/YuoHGlB3ABvP2VkiDriZ8
	 Wuv03Mq2Ck6kCzwZcenRhZ7AUv24gU2ZODnxIsZaWiu4RRd6wQnNwrBKyUl0r2jyL5w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="hI/rRSJN";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8F3A606A327
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hI/rRSJN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4206D1F00A2A;
	Mon,  2 Nov 2026 19:11:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646682;
	bh=fQmksu8GFN8fKiS1uq41EywVFxHjHrvgyVInnd6J5no=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hI/rRSJNKwign0iiz2XCFlKCHIRnqpCAyRO2CgOsjzSFXHO/gmnV3F83HsU8QlZVU
	 O0JXppOtcj5QeiJbfdU4jEc27E16gGX5+xu6DmCee0acuWB5M6kE+kh3ikaKUc3PYk
	 04vMnoeyayC1sRDcdhH98Ocg+MhRFW5sH+4+ZoMy9ivpiE6GjFvU4uyFtUD628FUp9
	 ReRFPcLUXZACwB/72QDNCUNVH9Uuuould+PHsj9Qv6kmlMecZvoAGpvIm6qSVsA0B2
	 xJBt54xBMxsho6jjBPBm+iZ7hpAUt2OhvyMvlCuYOB46mPoCT02LvaPhoIs3PW1yWH
	 prXcNUq1Y/EBw==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 10/11] NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a mirror's stripes
Date: Mon,  2 Nov 2026 14:11:08 -0500
Message-ID: <20261102191109.13470-11-snitzer@kernel.org>
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

Both callers of ff_layout_mirror_prepare_stats() cap it at four
ff_layoutupdate4 entries -- PNFS_LAYOUTSTATS_MAXDEV for LAYOUTSTATS and
ARRAY_SIZE(ff_args->devinfo), which is FF_LAYOUTSTATS_MAXDEV, for
LAYOUTRETURN.  The scan walks mirror->dss[] from index 0 every time and
stops once the budget is spent.

  What the server sees without this patch: for a mirror with more than
  four busy stripes, the same low dss_ids every report, forever.  The
  previous patch widened that from one stripe to four -- it did not stop
  it being the same four.  On the 32-stripe RAID0 layout this series
  targets, stripes 4..31 are reported only when the layout is returned,
  so a data server that is only ever backing a high stripe index stays
  invisible to the server's placement decisions no matter how much I/O it
  does.

Remember where each mirror's scan stopped and resume there.  The cursor
advances past each stripe that actually fills a slot, so a report picks
up where its predecessor left off and idle stripes, which are skipped
without consuming a slot, do not stall the rotation.

  What the server sees with this patch: still up to four entries per
  report, but rotating, so every busy stripe of a mirror is reported
  within ceil(busy_stripes / 4) report intervals -- eight intervals, or
  about eight minutes at the default 60 second interval, for 32 busy
  stripes.  A given stripe's numbers therefore arrive less often than
  before but, unlike before, they arrive.  The values are unchanged:
  cumulative ops_completed and bytes_completed since the layout was
  granted, so a server differencing successive reports for a stripe still
  gets a correct delta, just over a longer window.  Nothing about the
  encoding, the deviceid or the ordering within a report changes.

The mirror loop gets the same dev_limit test as the stripe loop, so a
full report stops scanning instead of walking the remaining mirrors to
break immediately on each.

[jonathan.flynn: read dss_report_start once per mirror, before the stripe
 loop.  The loop advances it after each stripe it reports, so re-reading
 it moved the index twice: stripes were skipped, and on a mirror with
 stripes not yet written (and so skipped) the index wrapped back onto a
 stripe already reported.  That put the same deviceid in one ff_iostats4
 array twice with identical counters.]
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 22 +++++++++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  7 +++++++
 2 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 670780bb3d353..591363e2cf460 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -3153,14 +3153,28 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	struct nfs4_ff_layout_ds_stripe *dss_info;
 	struct nfs4_ff_layout_ds *mirror_ds;
 	__u64 read_count, read_bytes, write_count, write_bytes, ops;
-	int i = 0, dss_id;
+	u32 dss_id, scanned, base;
+	int i = 0;
 
 	rcu_read_lock();
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
-		for (dss_id = 0; dss_id < mirror->dss_count; ++dss_id) {
-			dss_info = &mirror->dss[dss_id];
+		if (i >= dev_limit)
+			break;
+		base = mirror->dss_report_start;
+		for (scanned = 0; scanned < mirror->dss_count; ++scanned) {
 			if (i >= dev_limit)
 				break;
+			/* Resume where the last report of this mirror left
+			 * off; one subtraction suffices to wrap, as both
+			 * terms are below dss_count.  Use the start as it
+			 * was on entry: this loop advances it for the next
+			 * report, and re-reading it would skip stripes and
+			 * wrap back onto one already reported.
+			 */
+			dss_id = base + scanned;
+			if (dss_id >= mirror->dss_count)
+				dss_id -= mirror->dss_count;
+			dss_info = &mirror->dss[dss_id];
 			mirror_ds = rcu_dereference(dss_info->mirror_ds);
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
@@ -3189,6 +3203,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			if (!refcount_inc_not_zero(&mirror->ref))
 				continue;
 			dss_info->last_reported_ops = ops;
+			mirror->dss_report_start =
+				dss_id + 1 < mirror->dss_count ? dss_id + 1 : 0;
 			/* The pin holds a reference; it is exchanged out only
 			 * under i_lock.  Put in ff_layout_free_layoutstats().
 			 */
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 743957cd12300..33724f2db5d62 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -141,6 +141,13 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layout_ds_stripe *dss;
 	refcount_t			ref;
 	u32				report_interval;
+	/*
+	 * dss[] index to begin the next LAYOUTSTATS scan of this mirror at,
+	 * so that a mirror with more stripes than a report has room for
+	 * rotates through them rather than always reporting the lowest.
+	 * Serialised by the inode's i_lock, like last_reported_ops.
+	 */
+	u32				dss_report_start;
 };
 
 struct nfs4_ff_layout_segment {
-- 
2.52.0

