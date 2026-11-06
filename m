Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793923996;
	b=a/o2BtxkrabFukTtr5+OLq8U+PVvf/BJJC2ae1xf/oTebHHldzDtepl3a1DTfxHvp2Zf
	 Y6ALJT1f89flNDC/vcJZesWZX2jvoKssv3lvIIXaa6LL20UkMUlbeU26qN83lOGvFksyL
	 L9v7yWVFUM9rFoExw1SwFGWSBaDiEfCPdlo3uOchJvBTtnJyxO2X4dVkVve0QqLMT33ZK
	 RVyTDWozoYflvgGyO60NRpVlHxQmQr47Eeb6c8x0/PLkJ97wXMuVQfqXl+S5a0mB/WMyN
	 8Xy1QJutbBKOMWMuf6tVTNFzUwmwWo0ZTm4g88AGSFswqaaEBGpvnKO0cfTnfIwW0eQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793923996;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=3V7EkQIypRvjQegORdtKadadUPKRR5HE4JRoYCLlFlU=;
	b=yB0uTN5edpAOyd32nu0TAABzmWmftJmcArVk2YwLY29vD+ptF9jya3WdDAttlH35rSse
	 0Q9jlFA9rO9rQBQpScQGmWfUol1Z6Ww28BXUNJXrHsxi6k90sCp3yCr6g3r1Lnbrl/FCJ
	 SBNPbvbMLKKjNQA85aGWDUedUEmtsTs+v5eD6mROeOlSxjePUCfwKNfnedNsY0ODWttYY
	 RKN4t5hdO7bANDQBweGzvOU/n68WZsBI8d56Xy9ns9s6Dz05vO45jSjVwwy8d4d9ftyiD
	 rcqkwOgIyZMsU70zmxRAn7oHRCg7xacp60gg9ZaAGGeUeAWXxal1TtP+R7s7HzisxDg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gYW94LQ1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 133E6606A31B
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 00:13:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gYW94LQ1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6A4211F008A3;
	Fri,  6 Nov 2026 00:13:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793923995;
	bh=3V7EkQIypRvjQegORdtKadadUPKRR5HE4JRoYCLlFlU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gYW94LQ1qC9zY3vtw71alZHbkym0raNDdobzJQXua5932jOlL3yy4K8YxyMCLcwoO
	 7amKRYWmFUFH4A1ZG+iKAJtWf9avxHZBN4/Io5X1EqaK483xbMOAFxb05EP90F7Lw6
	 lcgXcMsXdi7CE8NFXnA9dNwWzxGImtFKO+IURVQ3typel1qv+LrW6yywrvuwu6oreT
	 GG7Vib9K5SvF9oDkz4jbPGY0sFG5f+p0yOqFtLrsW65NYiAWrQpT9pMqtQ/Gtv0Mbb
	 7ah5IlBpmook5yoyKcw+iasBaZXN3Ebj/92FXxW1q8q4BO7rjHWVN9s1NNkGHtsoNG
	 v0iYPV7H36Zkg==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v2 10/12] NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a mirror's stripes
Date: Thu,  5 Nov 2026 19:12:47 -0500
Message-ID: <20261106001251.73472-11-snitzer@kernel.org>
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
index 91600086526ee..b4d4971816145 100644
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
index df91165ba72ee..33ad85d1d07a2 100644
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

