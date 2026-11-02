Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646679;
	b=iRfyuB9lmuRSeGjUxWsaCm9Y1c6AF3iaJ9bXchs7EJA+DaCTXJf0EH81YPMWoN3o72pf
	 qNRxX4eK+CHUc6YUbHtOOeYMjg6Fzw+uURSKa4gJ81NZeuPgbmrJZ++Oj3INxYbL9K5pj
	 buleDFATJoYAJfnkZthNYH3wCLB0+MUK0Gn5a78ktTdZ+fhgt7VQ6Jc1RqBZyLdUaANtJ
	 JDgbM5Iw+3IMLjXAePVNU1wV+mEz2hBuRsu7nRsyKDQz7xgebQiHqGbNvw5KqmLh97ASE
	 KpG20JTBA5tgZksi2qc3tFKkR+moKVrUwkRmyvzT2ihSYIuOq6eGKBlZm4VW9pAf8CQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646679;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=3YqhUuPbq5IB7rxLAru54ANQqHa/8yPo9TlswHfsoOY=;
	b=AaFZwM7mUIxm6XBZEpoZE1iVcq7fjfrFXMmherkmSNrGfjpvZ0M7jX7e5v/uavsn1vPA
	 kF4h67AVI0j6A4fDMdswdScBnKAhbsKxE2RaFcS0sREhTIkkw7ifdDft9414S5r2qePqu
	 o04nsgDeqVxJd1/InUmpib3QP3m7h9waiiSjo7SESyfn2Xuh5FuML+PwMy8fCpHhrBWRa
	 PFigALJROq3dRMF+HZgDDzA/wCNlsIbkM2Ke1hyftwhvBMCWAtTUecr5mjd7fp0QItAMH
	 oZCql9zuATWeSrv13Ch+YNXCnIqVQGT83UGYJKEl7xlLvPy/jYB2rdclTuMZj23cpPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XJlyCWQ1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D96A6606A334
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XJlyCWQ1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 845B91F00A18;
	Mon,  2 Nov 2026 19:11:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646678;
	bh=3YqhUuPbq5IB7rxLAru54ANQqHa/8yPo9TlswHfsoOY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XJlyCWQ1bCsREClhw4I3GL5LUeiFjfPzIad7uwZRlQUivkHRifoN+7iJeJhBR3CB/
	 w8nz4OX2qx0zw4hp+DPgZfMzvjY6298y7Lv47gvnYTDTcgOXaBA+VaIYvEyLm9OS5e
	 KjSDFFmdpUyY7G/nOGMz2uz3+FjmE0yLT4P06a3RvvcA5o85blIif3d+1yLKO0d14T
	 MyHeaKv4GaQToIVH4qYyo8x/CYg5JrWEXpKGjzUm58BuwmyUllWogtojr5I9xzGIgg
	 zxMVz629esuKpuNrgY77hkKnqUgos+44TB+oZT2FzDUytSzkP3FB0A4PoCUPjddT4a
	 2uMW/9CSniRoQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 07/11] NFSv4/flexfiles: derive ffil_ops_requested rather than storing it
Date: Mon,  2 Nov 2026 14:11:05 -0500
Message-ID: <20261102191109.13470-8-snitzer@kernel.org>
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

nfs4_ff_io_stat::ops_requested carries no information that the stripe
does not already hold.  An op is in flight from the moment it is counted
as requested until it is counted as completed, and the previous patch
put both halves of that accounting in one place each, so

	ops_requested == ops_completed + ops_in_flight

holds at all times under the lock.

Drop the field and compute the value at encode time.  It had exactly one
producer and one consumer, the LAYOUTSTATS encoder, so nothing else
needs to change and the wire format is untouched -- ffil_ops_requested
is still a uint64, and nfs4_ff_ops_requested() returns __u64.
ff_layout_encode_io_latency() now takes the whole nfs4_ff_layoutstat,
since the in-flight count lives beside the statistics rather than in
them.

This takes 8 bytes off each direction's statistics, which is what lets
each direction fit in a cacheline of its own; see the next patch.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 12 +++++-------
 fs/nfs/flexfilelayout/flexfilelayout.h | 19 ++++++++++++++++++-
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index bfe8288a14a08..846544977cf30 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -764,7 +764,6 @@ nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_ds_stripe *dss_info,
 	lockdep_assert_held(&dss_info->lock);
 
 	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
-	layoutstat->io_stat.ops_requested++;
 	layoutstat->io_stat.bytes_requested += requested;
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
@@ -3066,12 +3065,13 @@ ff_layout_encode_nfstime(struct xdr_stream *xdr,
 
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
@@ -3101,11 +3101,9 @@ ff_layout_encode_ff_layoutupdate(struct xdr_stream *xdr,
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
index b0653a652d3b8..23f665fef4985 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -55,7 +55,6 @@ struct nfs4_ff_layout_ds_err {
 };
 
 struct nfs4_ff_io_stat {
-	__u64				ops_requested;
 	__u64				bytes_requested;
 	__u64				ops_completed;
 	__u64				bytes_completed;
@@ -78,6 +77,24 @@ struct nfs4_ff_layoutstat {
 	struct nfs4_ff_busy_timer busy_timer;
 };
 
+/*
+ * ffil_ops_requested is not stored.  An op is in flight from the moment it is
+ * counted as requested until it is counted as completed, so
+ *
+ *	ops_requested == ops_completed + ops_in_flight
+ *
+ * holds by construction; see nfs4_ff_layoutstat_start_io() and
+ * nfs4_ff_layoutstat_end_io(), which maintain both halves together.
+ *
+ * Caller must hold the lock guarding this nfs4_ff_layoutstat.
+ */
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

