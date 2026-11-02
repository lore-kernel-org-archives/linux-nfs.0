Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646677;
	b=LBCIoL2ChF0DpS9zVPYhrRjY2Cku8RrMRciHMgXPv2QlULOyW+S1xuA5dbyr3nCtLMr8
	 U039ez+EPVpXNnRXtohEWG5bPN65S0DbgBfmLmTrXvkjccXvxucQUIBx1Dx5f9SrZ30TY
	 CCr5jVYkeWNogb6k+cFFRC8ecXCEJ9f0N586yB76SzJAP+zs5aOVWCv300YSPRg5nOc/v
	 Y6CpT0zxPv2ePJOknheY4jxB98carxPA0o1K04+GmbkK0Z/pZ23oL0V3+3FAkuI1QzUcB
	 0lhOb5q2ohJpE/F7lwfIC0Cd/aTFHMfL8hujA78xcpAIaQa2N7iaw/hDbJzwMp99fhA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646677;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=03I8xl1nzW11ol+94ZnfDQ//mChS0Bsmi5P2fSHlOOc=;
	b=lIksyF0L+8RYwPwdeqWbbF11v8t7L1A7Qtjr0NIG8Q8nx6LCmRss/t/sQO+aqR7YUdtr
	 qKF1UYqrjGOfVbSw/x1M9JEoXpEUj/nAiPxay6jNntr0FL0MiGgldqPb/4yuAkcRuILHY
	 BKUcmttoMzcVGcPP0jQM2NY0BcVhgn+HrrZUds+nXD3QcLW7PoWRguklHtsdqptdVwJPr
	 fcZDXO2Nt2H0fK95hdx8XfJhGKShd6Ph6fLAhnhFO9hWpOaInK6dvW8Zh16+4yXZGeVRd
	 VexyZrrlgOQwgj01+lGIjZQ3X4WtNKuqFn/ZOno+fv+8qVEFN7eu6zFdurQHJS5dJyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ot2jhNay;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE203606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ot2jhNay
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 108191F00A1D;
	Mon,  2 Nov 2026 19:11:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646676;
	bh=03I8xl1nzW11ol+94ZnfDQ//mChS0Bsmi5P2fSHlOOc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ot2jhNay7FuxOJVQdqEVvjFM0Nm64p3ZZYaBcTg+4mzh6wuXduokSjv62ZN/DNDqO
	 hzuzLbxYbSJ4t9Iii0ZqjP5LfrcB3nCfj1v/TTYfpWF7mPnOA/5T8blOBwPgI++Ibx
	 yXikVw2LVSwTMu7eXp94qXaa89JvpQM1Lv86HrLFOK/T4BrOK2gD93Mkes9+iY9rbl
	 bH96EOf1J2bwV5tf+fkX4d/TIu9WCON/tKbQGD8wZ7R5d0mXIOj8jWKqYBvbZoZ3HM
	 Cozevb4dnQgX1Ao/CvHvyhoqPX8k4AqS7X/31TVzfvfQO/1lWsDUUI275QSimvmk2g
	 4b8dFLn7AptYg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 05/11] NFSv4/flexfiles: drop the redundant atomic from the busy timer
Date: Mon,  2 Nov 2026 14:11:03 -0500
Message-ID: <20261102191109.13470-6-snitzer@kernel.org>
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

nfs4_ff_busy_timer::n_ops is an atomic_t, but every access to it is
already serialised by the stripe lock:

  nfs4_ff_start_busy_timer() has one caller, nfs4_ff_layoutstat_start_io(),
  reached only from ff_layout_{read,write}_record_layoutstats_start()
  with dss[dss_id].lock held.

  nfs4_ff_end_busy_timer() has one caller,
  nfs4_ff_layout_stat_io_update_completed(), reached only from
  ff_layout_{read,write}_record_layoutstats_done() with the same lock
  held.

The two reporting paths, ff_layout_mirror_prepare_stats() and
ff_layout_encode_ff_layoutupdate(), take the stripe lock too and do not
touch n_ops at all.  There is no lockless reader.

So the atomic_inc_return()/atomic_dec_return() are locked read-modify-
writes on a line the CPU already owns exclusively -- pure serialisation
overhead, paid twice per DS RPC on the hottest path in this file, at the
275k-450k RPC/s the per-stripe lock work was measured at.

Make n_ops a plain int and document the locking on the struct.  Its size
is unchanged, so the stripe layout is unaffected.  The underflow check is
preserved.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++----
 fs/nfs/flexfilelayout/flexfilelayout.h | 6 +++++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7c328f2ec900d..6a474fa7b0446 100644
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
index 658940979883a..d97001abc0d22 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -64,9 +64,13 @@ struct nfs4_ff_io_stat {
 	ktime_t				aggregate_completion_time;
 };
 
+/*
+ * Both members are serialised by the enclosing stripe's
+ * nfs4_ff_layout_ds_stripe::lock; see nfs4_ff_{start,end}_busy_timer().
+ */
 struct nfs4_ff_busy_timer {
 	ktime_t start_time;
-	atomic_t n_ops;
+	int n_ops;
 };
 
 struct nfs4_ff_layoutstat {
-- 
2.52.0

