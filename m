Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923988;
	b=2hmBe+52cQGN+Eq8U0DV3cnsdZlII7wLoGLZeYqvzpO9VNNyUAJ3J6ogY7ENPSZcqgWA
	 2NgsPJdPWhVwFOldiuYjy3P2YvTH3H0M4wWhuio18kHKFjxUIRpNSkiRse0mGUd0HrZw2
	 MZ7LftxigqyGeNAa5Ng1ZcxduL6G2Ams76ket38M0zWZBCEvOxGIVqovpJCQbIvaf5xht
	 +wjwzuq9LUKCwK9chvFUiYOapBKmf4s5un3wXbKJKeUSvbXTj1PrXnuNtAxbUlB9Bm9vJ
	 3fxWQdzfpmWpEvJ9GRl0514BxH4wewTfJRu119yffxdTKyl0KPRXDbS/Tm/+IoCy5Uw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923988;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=cQqrHFvK3IFrylQylpqSRZYfwAUMMXMu1gYVTs+rw3k=;
	b=QHxlf0nfeQAqbcZDplIdrY49SaNAEeyGHX7dcxYP9S9D2fJeVxyAavbuQIacMeDNQeWH
	 OIO1X3t2vNTTvaW1DrWQoK7aqSLEFEhnuXBDQ7rfbbw+n0pSB58nO3yeimKzE/oexCWCs
	 R0T6A403MKxPjShhcHI7oJE6ul/7VcBIQQKeJjLXKm/ZVIhwAC3/NLW1o/rh7ZeI62PeL
	 /b6Qrz8AXYo/eZX45m3DZBHYhcccTq2QSYvJK0bDV2fmq4ONZVsBzd7HjdXGbv1h82vxc
	 nG2+t5IodSTdKg7Z/cxqxEtcnM8k7/rPnYqx+HN+/AuKJrW5e3yJLB3GyYVPjYecViw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TfbNdVa4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44F2F606A328
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TfbNdVa4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A51031F0089F;
	Fri,  6 Nov 2026 00:13:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923987;
	bh=cQqrHFvK3IFrylQylpqSRZYfwAUMMXMu1gYVTs+rw3k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TfbNdVa4A9kJ4n8XoEs9wyH26/0+FSir3iQ4nigEH+GE3q7YYUEDYCiCuhV6BGff/
	 e4xKhvJWAzhs2q1sWbLnm0GP+bYKmmvK9fMrw7huC3xE+9MVvAKPo9dt0ZBK/UH7fr
	 xFynhffO+682TPECILF0F3NnCkebZIDqZ4Va9w3goMngOeDfnqCDHpv/AhkZNmwai6
	 koxTnVfRFj+qbWLK5QAFnsTAfstqk9vBFazYgBUPBbpMZ2yBRH/JvLh/86sndN7KYJ
	 Q29bg3o1ca70o6jVB9Mv37+3tUA6VbAJCUeQVeJWPAqW6laJC89P7SPPyI7VSIv4xJ
	 vZXkDAzvwQXuQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 04/12] NFSv4/flexfiles: make dss_info->start_time write-once
Date: Thu,  5 Nov 2026 19:12:41 -0500
Message-ID: <20261106001251.73472-5-snitzer@kernel.org>
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

nfs4_ff_layoutstat_start_io() writes start_time under the stripe lock,
and ff_layout_encode_ff_layoutupdate() reads it without the lock.

ffl_duration is measured from the stripe's first I/O, so start_time is
written once and then only read.  Publish it with try_cmpxchg64() so
that the first I/O sets it, and read it with READ_ONCE().  Later I/O
sees the value is set and does not write it.  ffl->last_report_time is
already published this way.

start_time then does not depend on the stripe lock, which a later patch
splits in two.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 +++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3ca37e94dd053..eddedb1c6bf38 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -729,6 +729,17 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
 	return ktime_sub(now, start);
 }
 
+/* ffl_duration runs from the stripe's first I/O: publish start_time once. */
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
@@ -740,8 +751,7 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
 	ktime_t last_report;
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	if (!mirror->dss[dss_id].start_time)
-		mirror->dss[dss_id].start_time = now;
+	nfs4_ff_layoutstat_set_start_time(&mirror->dss[dss_id], now);
 	if (mirror->report_interval != 0)
 		report_interval = (s64)mirror->report_interval * 1000LL;
 	else if (layoutstats_timer != 0)
@@ -3083,7 +3093,7 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
 				 ktime_sub(ktime_get(),
-					   dss_info->start_time));
+					   READ_ONCE(dss_info->start_time)));
 	/* bool */
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(false);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 2797f120a8324..8119da3073423 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -87,10 +87,11 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
-	/* Protects read_stat, write_stat and start_time below */
+	/* Protects read_stat and write_stat below */
 	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
+	/* Published once by the first I/O; see nfs4_ff_layoutstat_set_start_time() */
 	ktime_t				start_time;
 };
 
-- 
2.52.0

