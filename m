Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792422450;
	b=HbR9Kn6E4KE2nsocudWYwF+MCAwsPP+q6HRF4TXq9d9WDOWjM9uSiygixVVf8jGRDcEs
	 Rd2kyKXnRuSNatQBR6GohrnK1DCd7GT7U20dKYs5Fe0xNKbknR2SpwFB3osUPuSNjs51q
	 hu0lwPlCVSk1YfFD3T6Gx4Zlq1lTrD/ryuKeCUQ5vGdaoKd9n2oIhhDLTrHJXhbi1CoyT
	 ZhGcisx5R1zetJlDd6Cm2fQZXK0bJbAgTOjm1CFZWV0QoIajOH9C7kxGtOai7ItQ3EwY/
	 GFk7L2l+yXYz0kwY03qgVSCZKbqkqRfvlw+EYh942Bdvt2DfkycSjf5sBb1OJ5ZHrWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792422450;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=KYIFZnbJ/tQXvMmHyoqaiwEU9dnEoX51wTobPwpbUYk=;
	b=MAyylYJx2KEkGmAg2agDowo2Ujn/ZkCx6AoHlMQnxqKcg6i0/ZDX/S5DBi45jIV/zsau
	 JIiT/+Afx0ySx1W/ZVjLnNozSZOma6oGdPtQP+QIzR1JyEOvm7Wl/GZVmL7EbBtCx/w3E
	 m1a/ZjaXWc07zVICMxWqzLY6rIf1NiKeKs3XvmAh1qcugtfXue0ZP1hbXa02MM0uFmXiP
	 VnFw432mMUbUYPw2W1XMAB2WFUXcFj0FcjkjZ6ovbCPCqL3ZgHZOKV96xLtVdGBEdKXLt
	 1TvxCPfkBR4vVqJo+ogA5XknnBuFAdnN2GjYeiIYFpDP7qZIcOzvqFM5qK2aH+xaHTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Q7/5HC2y";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B68036083439;
	Mon, 19 Oct 2026 15:07:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q7/5HC2y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3EE711F000C4;
	Mon, 19 Oct 2026 15:07:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792422449;
	bh=KYIFZnbJ/tQXvMmHyoqaiwEU9dnEoX51wTobPwpbUYk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Q7/5HC2yuwRStW9uT0uRx6ddM3dspudm2S30vTdZhfxrJmdHNXGuppUxH6i1DtdhH
	 XjJjNTLHPLxrW+qWvrEpd8QN+onnmwyIgNnBd0fQwuSdK92xPdtwMt1w7M4+Xwq/mn
	 f2iPBxoQzG7PyD7Pe9C0ddHHi4/2k5vc/xBQBeN3Jth1U9QUpRRAYBhKd3j951VokQ
	 /sZR+wL4hUIgfRCuk/OZ791Cf+jBc8dVRwgXpTXGpeKjA+vV2F30ax7BGlHDmLNjPB
	 QO4zLIX/y1ygzGKb0ZtRKtxszT+/Cz4bUJLMDo/w8DN5pAkzhrfg/g0lPdI+dMDHY4
	 K/2eHdhpPreFw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 2/6] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Date: Mon, 19 Oct 2026 11:07:21 -0400
Message-ID: <20261019150725.1507-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261019150725.1507-1-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
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

The per-bdi_writeback WB_DONTCACHE_DIRTY counter drives how much the
flusher writes back in response to an IOCB_DONTCACHE kick, but it is
not reported anywhere, so the DONTCACHE dirty backlog can only be
inferred from MemFree/Cached movement.

Report it as BdiDontcacheDirty in /sys/kernel/debug/bdi/<dev>/stats
and as WbDontcacheDirty in the per-wb stats, next to the
Reclaimable line.  Use wb_stat_sum() rather than wb_stat() to fold in
the per-cpu batches: the flusher targets the summed value and small
backlogs would otherwise read as zero.

Fixes: 88d6f128d06d ("mm: track DONTCACHE dirty pages per bdi_writeback")
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Matthew Wilcox (Oracle) <willy@infradead.org>
Cc: linux-mm@kvack.org
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/backing-dev.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 18e999053bae..b8a2c27e07fa 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -46,6 +46,7 @@ struct wb_stats {
 	unsigned long nr_dirty_time;
 	unsigned long nr_writeback;
 	unsigned long nr_reclaimable;
+	unsigned long nr_dontcache_dirty;
 	unsigned long nr_dirtied;
 	unsigned long nr_written;
 	unsigned long dirty_thresh;
@@ -78,6 +79,12 @@ static void collect_wb_stats(struct wb_stats *stats,
 
 	stats->nr_writeback += wb_stat(wb, WB_WRITEBACK);
 	stats->nr_reclaimable += wb_stat(wb, WB_RECLAIMABLE);
+	/*
+	 * Sum the per-cpu batches: the dontcache flusher targets this
+	 * counter via wb_stat_sum() and small backlogs would otherwise
+	 * read as zero here.
+	 */
+	stats->nr_dontcache_dirty += wb_stat_sum(wb, WB_DONTCACHE_DIRTY);
 	stats->nr_dirtied += wb_stat(wb, WB_DIRTIED);
 	stats->nr_written += wb_stat(wb, WB_WRITTEN);
 	stats->wb_thresh += wb_calc_thresh(wb, stats->dirty_thresh);
@@ -125,6 +132,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
+		   "BdiDontcacheDirty:  %10lu kB\n"
 		   "BdiDirtyThresh:     %10lu kB\n"
 		   "DirtyThresh:        %10lu kB\n"
 		   "BackgroundThresh:   %10lu kB\n"
@@ -139,6 +147,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "state:              %10lx\n",
 		   K(stats.nr_writeback),
 		   K(stats.nr_reclaimable),
+		   K(stats.nr_dontcache_dirty),
 		   K(stats.wb_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
@@ -163,6 +172,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
 		   "WbCgIno:           %10lu\n"
 		   "WbWriteback:       %10lu kB\n"
 		   "WbReclaimable:     %10lu kB\n"
+		   "WbDontcacheDirty:  %10lu kB\n"
 		   "WbDirtyThresh:     %10lu kB\n"
 		   "WbDirtied:         %10lu kB\n"
 		   "WbWritten:         %10lu kB\n"
@@ -179,6 +189,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
 #endif
 		   K(stats->nr_writeback),
 		   K(stats->nr_reclaimable),
+		   K(stats->nr_dontcache_dirty),
 		   K(stats->wb_thresh),
 		   K(stats->nr_dirtied),
 		   K(stats->nr_written),
-- 
2.52.0

