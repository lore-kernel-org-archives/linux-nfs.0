Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792723554;
	b=OtCF60WWUvMBaSy5fYGtdJOFkzRUw2XCBmBFHKtMRp2aNGCYjUgTXZcxEvib091wKfHL
	 LVLzey34k/13cZexXNBhY2mnNYV33VoGaRjboeIP9AzYi1NCeoykaGJ8804GUkbNuSOGa
	 KI2hiEE4AEqWEV+VVpaycDm7xMfI8l82nRPBkjiQMfSK7GUVBWaOTJzBhfOI6rVeKX/YW
	 fppUyt0rdMd/LoSSCyYDQ4x/SAVf/f7eOkekOUaBlRMEgsb1O5+vkbOlrRrDNUGQEK65e
	 WYm6r1oKwDEdG6ptZYFE8meYKBOgzpe2NESrHYFrYLEBB5zWmSQ0Yxhd3shFSb53wDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792723554;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Tt8+p15e9DQsEZ+hqO3OeNWZ+sire2qJlEmWhnAKgA8=;
	b=CljvqNY2C3x9g9YlQ93SzRbx8xjuOIAqkntVTnFnbH/vAG7aGQxOhMsqet4KfiVoB+WL
	 5ZsIgoxxinoVTJkxqKYkh3dc2jC1T7PYRIN6L51L17UDcX8YUmxuVvKZTqrCtno2WHFp/
	 N3PS+FPL34P6Ei6bTV9ulAyBYRYMhke0AvHxQdSbITiBkfSsyeN4ivcOzyDtcNGUu64Du
	 vA49Lq+7kYSauMFvJin8F274wQW7IbgFkWOOESsNizl0M7iQTFjQlvdwdcSrJFFPY/RPF
	 1yBC7kv/ny2zrMjehcExZCg8/49kk+XWcbeVbt6lHQv9jY65ogErpn/uBIQC3mTzU9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JiBFwphp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F342606A331;
	Fri, 23 Oct 2026 02:45:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JiBFwphp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BCC631F031E3;
	Fri, 23 Oct 2026 02:45:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792723554;
	bh=Tt8+p15e9DQsEZ+hqO3OeNWZ+sire2qJlEmWhnAKgA8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JiBFwphpQ2Zr9t9oVnbUSwSxH/ibLXGpQXw9XfkP/b8Kd1+3kWSUdZoZqHB5u86H8
	 h4a4iRVK3eNW2mS8lw3RrgQy2XqUjRtUZ/ICYL4oFywwJ6BRNwCCqQlpkg4UR3aHzj
	 8v92Oe67+bA8g2Oc+lPIN7UAVUoc/mXrMUv2AV/52ChRicBVrWjzsz5F5YT3YirBc/
	 l601up3GFLfdrCeqpBud6lxQhRXR29PlXTMQ3MNGwXPgMAjDq+w8h3VuD5a2a5Sjdz
	 43esOWe2b4ZRnne3cD7Ne6icV9zWQ8yG6iYUuB6VIcHnsfj7h02M0ZJTyZLfztEbjl
	 zIDj6jUROb+Lg==
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v8 3/7] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Date: Thu, 22 Oct 2026 22:45:44 -0400
Message-ID: <20261023024548.71123-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261023024548.71123-1-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 mm/backing-dev.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 18e999053bae..111b45262979 100644
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
@@ -78,6 +79,7 @@ static void collect_wb_stats(struct wb_stats *stats,
 
 	stats->nr_writeback += wb_stat(wb, WB_WRITEBACK);
 	stats->nr_reclaimable += wb_stat(wb, WB_RECLAIMABLE);
+	stats->nr_dontcache_dirty += wb_stat_sum(wb, WB_DONTCACHE_DIRTY);
 	stats->nr_dirtied += wb_stat(wb, WB_DIRTIED);
 	stats->nr_written += wb_stat(wb, WB_WRITTEN);
 	stats->wb_thresh += wb_calc_thresh(wb, stats->dirty_thresh);
@@ -125,6 +127,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
+		   "BdiDontcacheDirty:  %10lu kB\n"
 		   "BdiDirtyThresh:     %10lu kB\n"
 		   "DirtyThresh:        %10lu kB\n"
 		   "BackgroundThresh:   %10lu kB\n"
@@ -139,6 +142,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "state:              %10lx\n",
 		   K(stats.nr_writeback),
 		   K(stats.nr_reclaimable),
+		   K(stats.nr_dontcache_dirty),
 		   K(stats.wb_thresh),
 		   K(dirty_thresh),
 		   K(background_thresh),
@@ -163,6 +167,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
 		   "WbCgIno:           %10lu\n"
 		   "WbWriteback:       %10lu kB\n"
 		   "WbReclaimable:     %10lu kB\n"
+		   "WbDontcacheDirty:  %10lu kB\n"
 		   "WbDirtyThresh:     %10lu kB\n"
 		   "WbDirtied:         %10lu kB\n"
 		   "WbWritten:         %10lu kB\n"
@@ -179,6 +184,7 @@ static void wb_stats_show(struct seq_file *m, struct bdi_writeback *wb,
 #endif
 		   K(stats->nr_writeback),
 		   K(stats->nr_reclaimable),
+		   K(stats->nr_dontcache_dirty),
 		   K(stats->wb_thresh),
 		   K(stats->nr_dirtied),
 		   K(stats->nr_written),
-- 
2.52.0

