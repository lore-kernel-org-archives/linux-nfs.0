Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923992;
	b=aYTnpylMDKGnyl4yQKXDHmt+vrL9fjrmUX/1Xl3CEQeS2E1xpnK8HmAjw1zNgYfO0lTy
	 YfNcnB+ke/W1w+sOiiwAsgJIdkY3lpzZ4my0Ufekw+QDfQskp6tSPuMdGI85T64aCb0MN
	 p3+q1rlb1F1xZW93zqDXN8rgqMeFbON5qgnjrURmwmSuaadC2CKAIcZfbyTAXzIF2b6Zt
	 PNt+XG/ZKXPmWBtodNzbYgfPNqz+Mh5/axdv46U8PtYzbHnussmUYjoUNp9fLlAuG6TNZ
	 V4g3OicT3NICKksjjKdejnxOrCfkkwyFQsSVu8b9mbJW0Z4dWKo0pMiAB/BFjF0BSVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923992;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=XgYFI6XPOB2N4IcXu/UhA0oMNoTEZRV7OWpplSjhd68=;
	b=A/EmEZmlvplBD0+wLhuwf1RIUd88bIjQnTN3maA81FFmrUSkyXxeOP712XAi6ZReq6F2
	 pTzD+SRaIFLh+ROWoHl2ClVShuElsBDZ1AFXiUyAtz/qC6iH2zO9iJARoI0l3giD0a9aj
	 QJSktM+J4ouTHyQNv0059SBKw9lDD4i1r2PrZkw/OTd44CtJW1hk5ie5i/akt+L8hCADa
	 6wz1x5Y1eDQMN3e2b7WTdkm53kJCVCxpqJ1f92npx1jYtDAQCWaSmBiaY0lA8q84ZMy5u
	 Ml/XsUV7QxgJM2rKOpw5ji9DULDUdtlwD6lSN/9VF++j1w0xCku1esNIDG1CrGJceGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aW10m88C;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8973606A326
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aW10m88C
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6379D1F008A4;
	Fri,  6 Nov 2026 00:13:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923991;
	bh=XgYFI6XPOB2N4IcXu/UhA0oMNoTEZRV7OWpplSjhd68=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aW10m88CDmZ6JYjX+LJ+qGnoLcNyKZZF6Q5ANDQGaEE/KiZavTLxrw60kJqOuvM90
	 qA3bJf+e6NqJKGW7+4vQfJvz/eJiYe1Q27bYKe9zcm8marZ4n1Lg4iRr5zqHPy5IYL
	 3o1JqYMfIgrUvuXCY0eTYoeYO5WN6VrmJ/fP4whGfeR1AMmU8yd2kJYNiUOxNHZbp2
	 qgWWgUs1c8lcKEeiXJVvxZ6bF73zOTxmtUjfdAaOFS5zC/X0hZp2KPG5dh6uJRvpiT
	 gPejfLP5NhiqQQQd4XgYFkamWErMgdd8IwCAQ+Y8naoXLM2uq12bAdfGoQd6OUlGhV
	 9a4kr0I7GLwQA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 07/12] NFSv4/flexfiles: derive ffil_ops_requested rather than storing it
Date: Thu,  5 Nov 2026 19:12:44 -0500
Message-ID: <20261106001251.73472-8-snitzer@kernel.org>
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
index db8aa2bb92406..877a9cc3f46be 100644
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
index 8d24f94263b3a..a8f357a7000d0 100644
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

