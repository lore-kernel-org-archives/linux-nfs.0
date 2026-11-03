Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793740679;
	b=bG7m9Z+oa+/h4g+k0jwUIzpK3VhmGXF5+ZiCwJ1pB2kV6cVvAmuW80VcahJZ6Lt0wFux
	 c/5TmCmtph60uLovQb/TlJAijb6F/s8CDT6LAIZ4LCrLw9HViWA17HiDXwCL/DT5Rmm3U
	 TzPWLBNzalVJTnS2zueRgiiqe++4ca+KzUHrXW41FNisE+ZxX4NNIBze99xUu498Jb4/q
	 NGKGWEnxnySZ2v6vie+sR4btMTTa4k+b51ANmydqWkqBhfJvkJMsiBsbrtI/CPM9EPNiL
	 J5gTIJnz1Svi8G/8UujHlHQXgR5LhCJHNmIGICLSkwdm8O8gE/Q5leP3FgcbW5dz1nQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793740679;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=1+SeaVehwt396QnIHnWRn5MKZzC9W7QYhwhH8JQg6As=;
	b=pq4je+EJJAuId1E7y19g8jyyJ2dGaxkHQiI3EHeqOoDqm6bpQyByyRWJqD5vg5SBwxU0
	 gXu3wuCwiKh0QQA7wtvX3DLm0CdzEkreuxAyqIfB1upG2bJuBtsIzIBupefc0qHM48xQ/
	 tCsPUjj9v1rQvZjCu6XHAP0CRly37rRSTzxxtQymKYYO9FnrKjfC/RNYxEsZpszLMb+Wo
	 XGEgd9Tlg3HyeKFhopTgVzeWRyOqSGeNErISozAqx0AC5n2ppiP2ooVgaMg+qNsuK9B22
	 5/nQ9o3TfAZqQxgkiE5oslQKGiwPYjTvtp8/pETTDDBSA6ZkU94VWsMSfPzPi2Glp8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nsBBcQZv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99158606A329;
	Tue,  3 Nov 2026 21:17:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nsBBcQZv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 066C91F000C1;
	Tue,  3 Nov 2026 21:17:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793740679;
	bh=1+SeaVehwt396QnIHnWRn5MKZzC9W7QYhwhH8JQg6As=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nsBBcQZvBukrCr6ZOO/LZhZdwZ2UeCaaLrXBy7YduO+XZ+qdB+zZcZ+70hLRx0iym
	 LWa4m4h/8OIpWrMCwLZLT99KQSKS9bcqDa3xmfHUb8ym5/bamOIoBCQenlGGN0pZxq
	 uzi6woLgmZBihfj+KoQpnX5OjJ8Mflm1N6HJR/Fyfwh4N1tELoKYDuTqvaJ5Hi2xy2
	 +4MpPG5mOginkJf5dRid4rPNyc+GBAlewpMLkGEKcBjfUxRgAFakPkadlrVoqEWY6v
	 jsTKF7k2z1FXPHA5KwiowiwUo/Ifx4GCk1Dr5HFx9rZEgnwJZXrANlh9G7aHCwWRoV
	 UjAC280UkaWSQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: [PATCH v10 3/7] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Date: Tue,  3 Nov 2026 16:17:50 -0500
Message-ID: <20261103211754.35352-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261103211754.35352-1-snitzer@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
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
index fad1495d3b200..a09c21759fb9f 100644
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

