Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989281;
	b=hpDa7Y9Wk+sKeTr6dUsUcONoJpj1xMZGqqOSDhogOq05NLdf/uKINNLDcd+/ALOwoiLs
	 ycAXQBU38KOlZ5cvPwJ0tw+ovORk6Ytte8Ufb64EMmTH99XY+4SHwCHCcK5bSqTamuteY
	 gqZu3hG3gwSLDSUgC2heUmXBoLJb7ZpIsBe9lwASX+WbimRx91mFa6VEGTlxytZHxxNbp
	 NvccaEkPpRIKEhcfOQmEO3OyQ+IvhbzTAQEVWyU9r4+CGEnEG+JzpoRr9CAnH1o5RXb56
	 Jq+rZ8czFnfUZnn789mmLwxsAGMnyTAZLNrQB/H/XexQ/b1hiQXGxRfYlNewLvdEbVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989281;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=YudkBWy1+rVlebJSZ/KadLsTbGs/OOhfMvzgTOm38Is=;
	b=JOgT6HDGqbAlhPZjh8wpr7IEmXLeUuprWBv2IfHKg24ojLvx+vdewo1PMNA1bRxas+gm
	 zMKK7154TvReYGy4eLInr6o0C+cPi3LgG9BKa70/FhFIvUi3G5kKWTu+UU5PFNK89XR8I
	 F8TaWy8P5qPYdFLBOaAAEZDNYnnHbca7PXPrO235cwQiZNnIEydlRcMejxncE93MdW824
	 BH5MWv72KiBaELqlwqEPcXw7A6O/VX6oG8wkyCn+I++fUk8uUB6hMMj6Paw3qEDUyKoGc
	 P/YZbYzRGFzZC4w1rk7jJikOyUyOyiHwp9KAqZyoZR5G6n4c8YcLkYZu61ouViBa3qQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XdWhq5Gm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86FB9606A337
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XdWhq5Gm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0FBFD1F008A4;
	Fri,  6 Nov 2026 18:21:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989281;
	bh=YudkBWy1+rVlebJSZ/KadLsTbGs/OOhfMvzgTOm38Is=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XdWhq5GmGcNvNOeo5bAqqNHT9jyPaK0jDhedQLTI35AE1nKz3RhjZhpxjeIklluqC
	 ypHiah8Ne1+5tOON9z9uX6WliX3ELAGeiwjTTo6op+HvjKWv45R+nxi4U7wThwN3Hj
	 xMeY2dGLtPFlKDFvjihyx1q8Y+dC+19r33ohA2EEwCPlahDlzkVaMw6n89TATfoADM
	 fxxriMVe87TxtNPbmLvoc8o7LuUgeCp+x9R2OV5kr/Urdi2/GbsqEu7qUKNZr8akj2
	 tldeuQQV2+wI7vnWDAmMEwp12MGZF0B+4XV7KJRawrnmq2P4Om0aQJwziFsUufKAPq
	 YaYCn15mVVUvw==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 10/12] NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a mirror's stripes
Date: Fri,  6 Nov 2026 13:20:58 -0500
Message-ID: <20261106182105.78611-11-snitzer@kernel.org>
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

Both callers of ff_layout_mirror_prepare_stats() limit a report to four
ff_layoutupdate4 entries, and the scan of mirror->dss[] stops when the
limit is reached.  On a mirror with more than four busy stripes, every
report contains the same four stripes, and the others are reported only
at LAYOUTRETURN.

Record where each mirror's scan stopped, and start the next scan there.
The index moves past each stripe that gets a slot, and idle stripes do
not use a slot.  So every busy stripe is reported within
ceil(busy_stripes / 4) report intervals.  The values and the encoding
do not change.

The mirror loop gets the same dev_limit test as the stripe loop, so a
full report stops the scan.

[jonathan.flynn: read dss_report_index once per mirror, before the
 stripe loop.  Reading it again in the loop skipped stripes and could
 report one stripe twice.]
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 15 ++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4f27b1ea8b621..5c61d32a7cbde 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -3136,14 +3136,21 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	struct nfs4_ff_layout_ds_stripe *dss_info;
 	struct nfs4_ff_layout_ds *mirror_ds;
 	__u64 read_count, read_bytes, write_count, write_bytes, ops;
-	int i = 0, dss_id;
+	u32 dss_id, scanned, base;
+	int i = 0;
 
 	rcu_read_lock();
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
-		for (dss_id = 0; dss_id < mirror->dss_count; ++dss_id) {
-			dss_info = &mirror->dss[dss_id];
+		if (i >= dev_limit)
+			break;
+		base = mirror->dss_report_index;
+		for (scanned = 0; scanned < mirror->dss_count; ++scanned) {
 			if (i >= dev_limit)
 				break;
+			dss_id = base + scanned;
+			if (dss_id >= mirror->dss_count)
+				dss_id -= mirror->dss_count;
+			dss_info = &mirror->dss[dss_id];
 			mirror_ds = rcu_dereference(dss_info->mirror_ds);
 			if (IS_ERR_OR_NULL(mirror_ds))
 				continue;
@@ -3167,6 +3174,8 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 			if (!refcount_inc_not_zero(&mirror->ref))
 				continue;
 			dss_info->last_reported_ops = ops;
+			mirror->dss_report_index =
+				dss_id + 1 < mirror->dss_count ? dss_id + 1 : 0;
 			/* The pin holds a reference; it is exchanged out only
 			 * under i_lock.  Put in ff_layout_free_layoutstats().
 			 */
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 69dfdcfb9664d..a08b08f33ad84 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -108,6 +108,7 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layout_ds_stripe *dss;
 	refcount_t			ref;
 	u32				report_interval;
+	u32				dss_report_index;
 };
 
 struct nfs4_ff_layout_segment {
-- 
2.52.0

