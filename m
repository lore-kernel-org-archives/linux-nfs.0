Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2579737E5F5
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933890; cv=none; b=O9EtV0HQXvOu6PMzGySQaiSHKPAFKZw4HT7nBSmxZM9aFpRhlUvevd9NYp0AL7qijHCn42SqHOXN1UZQgLk3vUNjBZk7IHSc83kNZoErUDSUjBpV5tVX5ntLTQt206gG+3rdkfqauadRrxC2UhjsNL+FTf6eIN3/OsWcF+eOpCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933890; c=relaxed/simple;
	bh=oMuDR8QHgnD6y8iGXJwrBZT88kkXxNVfjmjdYAJwo+o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WHuQpITM97gL6EzsuA1vonTR1LI5/phBLQ5P6cD9/SlKLuEPgGwsRP0phpNnPbl4XXTpSLiPQSlrB97letErgwuto6dplJ4wS3Q8O7iniN3jk2Jp4kctCtV18FhHteYBgDJMYz3cFpRztulzzXpjTIfaNeHzFm9hYdz1FcW1jmQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PyaU6XDe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PyaU6XDe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FFB31F00A3D;
	Fri, 28 Aug 2026 16:18:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933889;
	bh=npWeS+OywFgnd4kYylUVyb/HY3nJALRGDWQBV9xWs0A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PyaU6XDepP2uX6tjSeUUzN6xmxfYEOyeS3KEoYYLTNY+4NfYM0oR7WijevIxF7C7o
	 F1KeuXKKCTBMhn+gVuLFJ65V/hpFB3s4H2cGFa94aGlXfZtOyp8DYWRzxnkJejrzfp
	 92mTdqwRoF4NptB7trVLDo8pmMqeeEiKywTi0nchVpcFSAkVvFFmmepLAI7mFt3ikM
	 RNEW+xhCoSiG+/8xRH7u2lM8VeXZaHWP9/S7hXiuAFRU/F5iSxMrbIeqycKUgFPWeP
	 W25J9NWHus8CrW36V/RoI7EsWLdlIPonuHmX36qVghp2RJYOFNlchrut+ZkaViWEhP
	 XpGj6VdskB1Sg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:58 -0400
Subject: [PATCH v2 6/7] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-6-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3063; i=cel@kernel.org;
 h=from:subject:message-id; bh=oMuDR8QHgnD6y8iGXJwrBZT88kkXxNVfjmjdYAJwo+o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS720Grtu9YAFXNY6HTFZ4tyGhaeomG350o7
 ZUZR4leAp+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0uwAKCRAzarMzb2Z/
 l3pFD/4nMNwGJ7f+WRffViglkVJetVQWyE+6AutfoKoTU1yeH/JFM5XZV0wktLk7e7O2lq0zTnu
 V1hqRlX6lEUUjO2TRknKV5baJqgKQDXQ4CQu1jI31lArpnq/xf8jVM1v7IQyjdDNzCVGNgPEKK+
 taEDPpGbsYdGpFTcuaBjT61OwFwGazgGaAO7hq8MjN3a/wgu2y6WMZDojurLXlohKoNvMhPrn1Q
 nTmwrTVfd55iusgsjIhi2ZkzPgJZ35Y78xHvyQmJmBWRz0riG1C2jvA9itxD6nf6zWpftuzYfV6
 zABkFjkQDSoXNzP7eG+qaFxWQLYC5ZODFdSLdUWeL3BwLL1sWb7apETpgfXRvqnlgI9vwi6qNck
 86s9N+cJWyxucAWTSkPuvdEomwQWW6/1VJv4KkrVBxCwAVD4TafXhoTIGtj6pYvH1V2GZVQek1h
 DUffVMx9+ftfoZeA6kbtIfYqLvQ2NDtQKj14RbH17ikKnxW3oWdKZ7EpwfjiMMKf5JZkhJw7wYk
 qjaruOV2HIgykqj79RpTj8lWL25HHDz+/qdWkeRSumiWLDTrchS/3aQ2yMs2xL/do3Yxwi+aU4h
 nzE4sKe9WYA/qXo6G0Lgwpr6UeRD4wTkb/FbZDqIKII7lOw7oEG30ysuQhUmtwNHNTC07fxVTbm
 RT2PrZCNI0xp5Mw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure, expiry, and
implied ACK, and none of these emit a trace event. There is no way to
confirm that implied-ACK eviction fires or to compare its rate with
the other paths.

Add a tracepoint for each eviction reason.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 12 +++++++++---
 fs/nfsd/trace.h    | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 7a09a79a2d6e..dfbcc75fbb12 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -304,13 +304,19 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
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
 		if (rp->c_state == RC_DONE &&
-		    nfsd_cacherep_implied_ack(xprt, rp))
+		    nfsd_cacherep_implied_ack(xprt, rp)) {
+			trace_nfsd_drc_evict_implied_ack(nn, rp);
 			goto evict;
+		}
 		/*
 		 * Only implied ACK evicts out of age order, and only on an
 		 * ordered transport; otherwise the first non-evictable entry
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 7d7a1483109a..c8468f67abe0 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1544,6 +1544,44 @@ TRACE_EVENT(nfsd_drc_mismatch,
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
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_implied_ack);
+
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(
 		const struct nfs4_client *clp,

-- 
2.55.0

