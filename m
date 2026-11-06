Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989278;
	b=KxXhpSc4xCfr+QuQn/cwQpcoBWmBgrbeaDEO0YStGDbut1pCTl4z8moLFvEN/9g71uBd
	 J2CYNaanS2xFJxWIaS/W7VBEhBCeH/XqkXGKRoGFjVGzkILgXUXlORTUWaOluCuQOQvHI
	 fETQ6VR5PwM/zT9T1E0YHKN+EZ00n6tGbmXlqH84Fz4L3UVb8UC4SbdqkuBiYg+Sai42w
	 bE3GejGsBR/SR99sKIQdPZCDgpspExgSgCAxlQIKoyTSJ6x+rEaK9s9mWcddlEPW9s5vS
	 WrTaj98dDvWhFSsrWM2XoPPH1AQmWIChumPV9GutdcIlaFh8vGvf17tIaFLxj0NBCBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989278;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=BrSAYCYrmQFEST5CyWegBWX0Hy0itSn4UGcQzhvPDuM=;
	b=Uhsuyg0oI3PUtPeDwigDT3WFaGzhov8BR8NUj3NEaLzHxDCede3cc0etYnfOZzF0dCkN
	 6nLuUsyR1W4iDvrMWPiqGTGLwLCIxXrtGAxVRkcKCkEjGXh1RK8UNdyuJIlzI9gnrVoaW
	 l58aDgcHTzXTKWB2TCySS8EDKAgTO6iuac5w0Qp82PWKs0rWKkTIdGgqG2c25PuyDA/21
	 yKIx6qMQv8skmcitOi427tBJRX+NnuDoIiC7zI8KvrAbBwRS47j1dbdDIR95GAEt3mVM6
	 lWnsDOZ6FmJVUgpT1Lcz2yfOzno3YsGVuiqPCcrW97SmWilZRrx58vsacVsJYP8XJQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jJVWjyCD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE36B606A332
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jJVWjyCD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5CF121F008BD;
	Fri,  6 Nov 2026 18:21:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989277;
	bh=BrSAYCYrmQFEST5CyWegBWX0Hy0itSn4UGcQzhvPDuM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jJVWjyCDWLKwSB8IGAgFb/l+i0i8MGqMsx2bM8+shok10pkVaDm0tNV9myYzfef63
	 fmdbp+LgEWtDF7U9mMyVnniuAgObKp0fR7JhZxMY4wgixz8L9WcqHVxEAASoQ4pMOi
	 ZCXMlhGqKRyf76zipTGPVdkJH+vrDUTlO70/+xYLGGLtAVOqh/PuGyPEGThyeDAbwT
	 4WH6J0Rk3dcSCu2oXR/Cog/nvpCEo20nACNOlN5LySmfi0iL5CU1vVGVSv3MKpNeIi
	 WIAishm3Y3gGgBbhJg8P0UZNtQlArokYj2Onpyhbx6eHKQYs/UzgRoY4A/ZUfHxM1i
	 gKWTKaGr3zIDA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 07/12] NFSv4/flexfiles: derive ffil_ops_requested rather than storing it
Date: Fri,  6 Nov 2026 13:20:55 -0500
Message-ID: <20261106182105.78611-8-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106182105.78611-1-snitzer@kernel.org>
References: <20261106182105.78611-1-snitzer@kernel.org>
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

An op is in flight from when it is counted as requested until it is
counted as completed.  After the previous patch both counts are kept
together under one lock, so

        ops_requested == ops_completed + ops_in_flight

at all times.  Drop nfs4_ff_io_stat::ops_requested and compute it when
LAYOUTSTATS is encoded.  The wire format does not change.

This removes 8 bytes from each direction's statistics, which the next
patch needs.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 12 +++++-------
 fs/nfs/flexfilelayout/flexfilelayout.h |  9 ++++++++-
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index a5460c6ec2b4d..23a8ae68aa5cc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -755,7 +755,6 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 	lockdep_assert_held(&dss_info->lock);
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	layoutstat->io_stat.ops_requested++;
 	layoutstat->io_stat.bytes_requested += requested;
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
@@ -3049,12 +3048,13 @@ ff_layout_encode_nfstime(struct xdr_stream *xdr,
 
 static void
 ff_layout_encode_io_latency(struct xdr_stream *xdr,
-			    struct nfs4_ff_io_stat *stat)
+			    const struct nfs4_ff_layoutstat *layoutstat)
 {
+	const struct nfs4_ff_io_stat *stat = &layoutstat->io_stat;
 	__be32 *p;
 
 	p = xdr_reserve_space(xdr, 5 * 8);
-	p = xdr_encode_hyper(p, stat->ops_requested);
+	p = xdr_encode_hyper(p, nfs4_ff_ops_requested(layoutstat));
 	p = xdr_encode_hyper(p, stat->bytes_requested);
 	p = xdr_encode_hyper(p, stat->ops_completed);
 	p = xdr_encode_hyper(p, stat->bytes_completed);
@@ -3084,11 +3084,9 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
 	xdr_encode_opaque(p, fh->data, fh->size);
 	/* ff_io_latency4 read */
 	spin_lock(&dss_info->lock);
-	ff_layout_encode_io_latency(xdr,
-				    &dss_info->read_stat.io_stat);
+	ff_layout_encode_io_latency(xdr, &dss_info->read_stat);
 	/* ff_io_latency4 write */
-	ff_layout_encode_io_latency(xdr,
-				    &dss_info->write_stat.io_stat);
+	ff_layout_encode_io_latency(xdr, &dss_info->write_stat);
 	spin_unlock(&dss_info->lock);
 	/* nfstime4 */
 	ff_layout_encode_nfstime(xdr,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 93fbc22b43c37..caa4c1e63063f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -55,7 +55,6 @@ struct nfs4_ff_layout_ds_err {
 };
 
 struct nfs4_ff_io_stat {
-	__u64				ops_requested;
 	__u64				bytes_requested;
 	__u64				ops_completed;
 	__u64				bytes_completed;
@@ -75,6 +74,14 @@ struct nfs4_ff_layoutstat {
 	struct nfs4_ff_busy_timer busy_timer;
 };
 
+/* Caller must hold the lock guarding this nfs4_ff_layoutstat. */
+static inline __u64
+nfs4_ff_ops_requested(const struct nfs4_ff_layoutstat *layoutstat)
+{
+	return layoutstat->io_stat.ops_completed +
+	       layoutstat->busy_timer.ops_in_flight;
+}
+
 struct nfs4_ff_layout_mirror;
 
 struct nfs4_ff_layout_ds_stripe {
-- 
2.52.0

