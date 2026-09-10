Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D92DD48A8C5
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048502; cv=none; b=RSKqH8XYfw0HipLYWabSneimkepr/t25EcobgQVFmpKCO3HLcriytHmQn4eR1gSIgzEOO321+lxPBZVneZQh+g/ggeST8iGYSs5MZNBtFp2dSBxo+E2kz7VTuiF2Ko2tg6nYX6TWd6VhxIe2NpMG8GB2G8DRwbV5ccGD6MewEGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048502; c=relaxed/simple;
	bh=95egkRBNxdfU2GWyiTTFYNx4R3HJAkfBde9/DL9iRHo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gQF7oNgT08ppPzHqEb3zdSxg/+vHJVW8BSvBE5KpN+NJHEcEIb1hTsnzrCwFNvXy38f/y01DD4nYWVFbdu2QZTg1SCHI3FWKdV1wezk1WW7NcWn+px7BRYalFExbH/0PvUaUGBnGkGRBwGG8sUw3Rl/3CkS+I132U1w1kzcYglo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=atusk0Pt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="atusk0Pt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3280E1F00899;
	Thu, 10 Sep 2026 13:55:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048500;
	bh=p8EY0W8xCLuYgyUlKFIXgS/u9fp46lY6Hx+mfwkDkHM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=atusk0Pt65hbUh1kaVs0oZqKjC4BRBU5P5EUiZL/2aUiQd/A+7im/MNq8APPVGEw6
	 3nnaUfB9SPqBKN5ErluMybAtPQQelVEQ7I2Z6QbSLWkl+6nxQA25MNuAnFWevTly4P
	 7N3fgbLY2XdLPGM5LiDaScc+AAD+qK9f7IHunkL9WEqS3u/KzSnldujES+wqLpCEgu
	 tAbjovIC8g76dLHj0Im1511gRrUOdx3G0ygASyANaAY8qAlTWaDtbLrLwdGdXHI0IP
	 Cm+XQkFBxqiEDpYqD6yAZfS6DvsOos4WZrDBnXbn4dNR+e812AKrzpRPzCLZuFDPy2
	 HuTUyd97+3ccA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:44 -0400
Subject: [PATCH v3 04/12] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-4-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2839; i=cel@kernel.org;
 h=from:subject:message-id; bh=95egkRBNxdfU2GWyiTTFYNx4R3HJAkfBde9/DL9iRHo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoravys5JS8E1FqJQZfyeNFmBmWNSg0DeXJT3A
 Ib+S9mXjgKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2rwAKCRAzarMzb2Z/
 l5CSEACz3fjoy1jSvYFCpUjfbEtJoo4InY/hRgcGpi9zmyV+Nh+ORwJJDn7uMfHd7uZk5q8Ob3V
 JzbQX9LYQ5KEilYsr+iIGKL+7ZTaLYpucA6KvN6Wv+ampFbThiBxdTGoVeXwkJM4pOLhDZVZCZk
 wfjf6Ip0eQtTa00CBxsKsc8QZBwSUmT3KmXLjbhdr+5/H+OxthFP+gxJTVoPQQHOE2cTFf955Wj
 hKQGOUcubeHYT93xpVyW2JkRi2/70zjiKHgCv0Ou03L7s/5pYXhOLLAF88vbeOdbH34uSEA2g9H
 WM1hapASGRrBaaKX0RSAqhDBHlCsJJ/Oxra0nosb+8FkiSH7uInsrbNALGLEjDEwXBU9v/jQFZR
 tJZDaL1/tkaBzWzm8wOT5lzq1KPwxWRXeaA9+u+QfTxI4+oewBq1p6s6xrdJpYkIrOrLpH2D9/G
 SvLwZP18Byro05cVuFeDyoae9a71qCzGwxiztcmcjMgMMrolMRN2NQwtGHq/zV0K4gucSOCdBpR
 T0N1IAxhAyCYS4eA4nrlVbZooCRn7QEwiFT3o9B8dBy3Iih3pL+vDN/GZZdAHH9KEmyZ0m8rRxJ
 trv1QChVxVvMUwOuydzy03j7nvCc81djePmIdM5Iwg2pV9qQpFGgsBwoK9h4uZ32AtRIiRVVKLV
 tsdgW3N6wufailg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure and expiry,
and neither emits a trace event, so there is no way to see which
reason is retiring entries or how old they are when it happens.
Eviction reasons that follow will need the same visibility.

Add an event class that records the cache population, the XID, the
transport, and the entry's age, and define an event for each
eviction reason.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  8 ++++++--
 fs/nfsd/trace.h    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index e6504e192dfa..ec8c40781cb2 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -272,10 +272,14 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
+			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
-		if (time_before_eq(rp->c_timestamp, expiry))
+		}
+		if (time_before_eq(rp->c_timestamp, expiry)) {
+			trace_nfsd_drc_evict_expired(nn, rp);
 			goto evict;
+		}
 		goto next;
 
 evict:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 2ae7f150a72c..255877e65d7c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1557,6 +1557,43 @@ TRACE_EVENT(nfsd_drc_mismatch,
 		__entry->ingress)
 );
 
+DECLARE_EVENT_CLASS(nfsd_drc_entry_class,
+	TP_PROTO(
+		const struct nfsd_net *nn,
+		const struct nfsd_cacherep *rp
+	),
+	TP_ARGS(nn, rp),
+	TP_STRUCT__entry(
+		__field(unsigned long long, boot_time)
+		__field(unsigned int, num_drc_entries)
+		__field(u32, xid)
+		__field(unsigned int, xprt)
+		__field(unsigned long, age)
+	),
+	TP_fast_assign(
+		__entry->boot_time = nn->boot_time;
+		__entry->num_drc_entries = atomic_read(&nn->num_drc_entries);
+		__entry->xid = be32_to_cpu(rp->c_key.k_xid);
+		__entry->xprt = rp->c_xprt;
+		__entry->age = time_is_after_jiffies(rp->c_timestamp) ?
+				1 : jiffies - rp->c_timestamp;
+	),
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x xprt=%u age=%lu",
+		__entry->boot_time, __entry->num_drc_entries,
+		__entry->xid, __entry->xprt, __entry->age)
+);
+
+#define DEFINE_NFSD_DRC_ENTRY_EVENT(name)			\
+DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
+	TP_PROTO(						\
+		const struct nfsd_net *nn,			\
+		const struct nfsd_cacherep *rp			\
+	),							\
+	TP_ARGS(nn, rp))
+
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(
 		const struct nfs4_client *clp,

-- 
2.55.0

