Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794510560;
	b=fHlR/F/6aQHw+BABG5MmrFeDEnowIuwCKDNKDAPofHu2zcXwqMkec9bwhZEEmg0kpfT1
	 h5/eOQ+cNkjAv1hNmRWnv3axiCfEdwH8YnuwR7R+aU3F+h7bXfpgG8iIFNp7dhBSV70WN
	 2Rt1T+PAgiRyVF60p5tLJS7WxUgaw2S5JjVTMIKnNQ+JtEYd3sPa/LizeRWoIDv8Py4wE
	 yV6Wwed0DAPVjKpzZ+Dmuoktukhd0WAUkEAi93g61jnkov+/aZ7mrssK/xvn9+UZPcUb2
	 Gbu0uXZeE2E0jNZ5ciKGyf8f0tyq4mbhM+BIaH2jx9wJMkWysKUdRqLuAsCDGtqQoWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794510560;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=1+SeaVehwt396QnIHnWRn5MKZzC9W7QYhwhH8JQg6As=;
	b=eXIuXPvn81kYzuB/4v1AK4rEZFGdsqshxms6h4Cw891jD9CchpAnRFvdwRVV4B6Edazo
	 JknHJWqbTAhCkDr+mn7qpkg79i8q/xf8PhpEyLzuq/6QQr8+GbGvz1f2YrBrikN1/oZB8
	 6aVMe2Vn3bE/ZGD1SoRcHNRBKC8s3A/FWVFGjbdDXm/Acw59NUx3QWdYd3TdR6TskU+rA
	 8R8V4CrsSEkDwNyEusjmp2flvFgbIN1umXmZrct++0/c+m3EA7daXxeaMB4XEfqN/vP47
	 0Fwq4IcV1ed3SyRXFgGUNg9o0Wkbu9XJqeNxiE5+u7JbnRzSD8FmAh0E/bLj/sN5HTQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mRRNG3IF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 205E7606A882;
	Thu, 12 Nov 2026 19:09:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mRRNG3IF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE0F61F000D4;
	Thu, 12 Nov 2026 19:09:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794510560;
	bh=1+SeaVehwt396QnIHnWRn5MKZzC9W7QYhwhH8JQg6As=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mRRNG3IF7VudZcwh4cqiVMNCUHH4sOIQkPODFYxjF6VVdN7Amv/1OT00M2ftUcuF9
	 EFIXVnWWcEt+0eXCmmNU8X+r2RnDVzuG6yfSf5Y/0M7ojHrS2yk8U239QZnI3qZ+Lk
	 6pR8RzV8tcebiPECs+5iBFoFf0yiyGcwr1ZghoutBg8hSmDyncKS27mRUTmnWqroyj
	 L/SKZp0FA859Q4W+eJP7ekc/fe9Mw8RBwFkiWG+xfjE6VToljzYbMiRZ6pDFU+2y4h
	 LF5KAJ8o2RQKKRtLOVtjbnm9D6+NC8KZTufBiQ30mbO0rgBhiX2YtfyO7SQvePeTqc
	 u45+zU/l1rX5Q==
From: Mike Snitzer <snitzer@kernel.org>
To: Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	linux-mm@kvack.org,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v12 3/7] mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
Date: Thu, 12 Nov 2026 14:09:06 -0500
Message-ID: <20261112190911.84702-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261112190911.84702-1-snitzer@kernel.org>
References: <20261112190911.84702-1-snitzer@kernel.org>
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

