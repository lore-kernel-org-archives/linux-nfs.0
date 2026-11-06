Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923989;
	b=Y9XOrrRKvWfQz0aqeZSGtxMhihkowFMbBNG81UDR75ZRLFN8PfIohhfvl/fniA/Jq3Vh
	 I2SI/l0NCIoqJiLMYjfL4CgmfCQcbevX0+a49tM5p8TK/Ml9dIkAEpEg+8CravAiHiCPV
	 D8h+yv6lkj8w9bdIQqh5vkYy5U02pv8dI1acQ2YHLMk0un20N2tmS6Y52T5k7oJb5R3nb
	 /VaLLQ9pDYWvcmiwqZ5XtvQi+l5icHN5wqudoKZW84v8J7DESdykn7daEQjQY1nrt4vUp
	 bl5wb+sx1zwQ7tiIF9leoWbnnsXq9oeL3DkB3ouiN+7g1tqYhQC890TE79DmDRc2uqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923989;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=99hZ2ZSGv7Dy9qL3tl+rtCQZZLeD3lsIpKLq7mAsZc8=;
	b=MO0v2pSyrLrDn8W5Mlr/smKNpbYunjW8EzE6umt8troJEpSD744pU9n7hnHp3FdlD1pa
	 utYmsfa+7KOyz/pmb8+2R9fO+FFDQFXNsklcmKBIwOj40bz2LB6EbhnU2SOuMO4hd3eBf
	 tNmW4CV+ajP6a+8JUeGLuPHmuUX8cqwUvRJ8/QDZb/Ed58L8E+YodJLANu31cjWBLHPMf
	 YKffU9/GwybT9EiG6ziP6F+0j24YT9X3HgodOgqzbPrMuXi4JAjez2H0eACiZuXAyevkN
	 K2TRvJfwXPCJhKo7w/PMd4J30THO+ydFloGKjg5Q65YYpZyAg60cp9IxNkwh7bgP8tg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LVJ7nDQD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C17F606A328
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LVJ7nDQD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E2E0E1F008A6;
	Fri,  6 Nov 2026 00:13:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923989;
	bh=99hZ2ZSGv7Dy9qL3tl+rtCQZZLeD3lsIpKLq7mAsZc8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LVJ7nDQDrkqt3eoEYhr/nhSWWlfNCUwTo/5ukFM5+pxL7GNnIZA2/zwjZY/dscHDX
	 j50ov01/qWzZS+RwcVc2nRcOGV2LV2DJbtqXuZ8gql9t1qRRa5qv/XLkawrQ0wr6mK
	 8h6qIIZ0PDyBnwxjhTdwdPGBg3WvjYKiXMs1y5aAVENes0K2E/XBLRBPZWRSKaNvau
	 +8EPzaRkhM4PRMOfP/Uyu/TOT+mgcesDv40suPeY8XWYPae4j8UUFaCvnOexufGYcO
	 k10cjZCOZ7XLTd5zbyhRENruVdFriJlN4Jn4znCH/SQp2M8eqsR/2r9gSl1FitMaaY
	 rH/itGuc+bwOg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 05/12] NFSv4/flexfiles: drop the redundant atomic from the busy timer
Date: Thu,  5 Nov 2026 19:12:42 -0500
Message-ID: <20261106001251.73472-6-snitzer@kernel.org>
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

nfs4_ff_busy_timer::n_ops is an atomic_t, but the stripe lock already
serializes every access to it.  Make it a plain int.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 3 ++-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index eddedb1c6bf38..f5591d4451ab3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -711,9 +711,8 @@ static void
 nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	/* first IO request? */
-	if (atomic_inc_return(&timer->n_ops) == 1) {
+	if (++timer->n_ops == 1)
 		timer->start_time = now;
-	}
 }
 
 static ktime_t
@@ -721,8 +720,7 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 {
 	ktime_t start;
 
-	if (atomic_dec_return(&timer->n_ops) < 0)
-		WARN_ON_ONCE(1);
+	WARN_ON_ONCE(--timer->n_ops < 0);
 
 	start = timer->start_time;
 	timer->start_time = now;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8119da3073423..4b2aaa16ee597 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -64,9 +64,10 @@ struct nfs4_ff_io_stat {
 	ktime_t				aggregate_completion_time;
 };
 
+/* Both members are protected by the enclosing stripe's lock */
 struct nfs4_ff_busy_timer {
 	ktime_t start_time;
-	atomic_t n_ops;
+	int n_ops;
 };
 
 struct nfs4_ff_layoutstat {
-- 
2.52.0

