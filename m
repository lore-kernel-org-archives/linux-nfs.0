Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792879916;
	b=f7qriGs5o9x7DuzcOJBhwQt5u7HuAAiiNrNwsRy2SAv0wp+3vd4l0LVW90E64E3Uozfg
	 JMdX+cnSx3IjFQi8YhIecI+FcbWbNfrb9/csRce7UNLaBovERfFCAKWZxbNKCsAIpG1ZM
	 9K8ea5s/spINzx7LgPdMipH1z+JgMhq54hFfR254pbEUIjjid1Ep8+5aJ1P+YH8pU6KjZ
	 95/XpIXA8oqm4SFLq9eh9RDCFQ6sKkTXiUEDR+9w9ip68JNY+R0Re1zlZPmeWoSrkuTJ4
	 9cr76CNmGU+esLHdpcyhzhvv+kcmH9g0v59K2IwCfCJkTYxd+PeWGLkh6ipOzW1GbbA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792879916;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Nkmr3kD+iOFE6eqQ744hZb3n/K7IlKbFrJJL5zbx4VQ=;
	b=3R6YIj8wJN+wFzhZ9ysm0Cd0HYariv0BUvoJc6ehH2luHEtiVi1jYeibIPlLnaf4X+yx
	 oA/SlIawrjgFbuNdjdtfIWgtPSiqi279CdXmy3zxToMyUd7nzZTTqFKN4J+zTvA+fNCg8
	 1WhNZ3vIwjaptKO76TgfMIpZsfMOADZe+J0reJLR1/rocXB2V2ac2XxBpS4N0xooqoDCu
	 8igqfsXVpZl/uRAseldx1XZlxujmh6274LZXpIPVCF+tK3VjvOnhEZdEruoRX1tqW+7OY
	 Oz5MCwRns/vU/15W37lRRTr4MPPQPyY757tRyIKWn70fW9uMWOCAp4Y2nhXhFkMIq2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iB9+h97l;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 296E5606A326;
	Sat, 24 Oct 2026 22:11:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iB9+h97l
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DB491F01829;
	Sat, 24 Oct 2026 22:11:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792879915;
	bh=Nkmr3kD+iOFE6eqQ744hZb3n/K7IlKbFrJJL5zbx4VQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iB9+h97lnqbFIUEl6O6yT3Xb13lPC+ZbQKXE9IlFhn5LhuWI8PD02Oz1MpQNBmJne
	 oxNS8VI3btkX9YItlGn9QKGgatxCJcJp+QEyL2H2BehjH3PGGrgx1AKbirxeroFhai
	 74OdaAYjGNzDIl76wRdapycLGUfxnNFyOlnlaJDC8oXBo4B9LZeMVo3Tn5I7Iq8ay7
	 WPtsrf8y9mvV7a5IoazqW6LpKVNrvYvwW8OO5p01kW/Ij4M9W33S2AvTW1QXyNhyHn
	 GsBrDgnTlOX2v7P4C3OzrbWJBWVH/J5EUYRPMGPfauTtPXegfAYePAyv1ul5HDqZfF
	 I3HdFZacSjiqA==
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
Subject: [PATCH v9 2/6] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Date: Sat, 24 Oct 2026 18:11:48 -0400
Message-ID: <20261024221152.6965-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261024221152.6965-1-snitzer@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
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
index 18e999053bae0..111b452629796 100644
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

