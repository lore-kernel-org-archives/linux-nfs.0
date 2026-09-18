Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2207C51AFE6
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752106; cv=none; b=dRucNZrKP8dC0G5nBKujvsqA/OJy4jsgQkwtFWEZlTrUmXcuUmrDdekSBGg8LCyYp079jjuTocOeScKY1AldXrYjHv0CgxZzmU4qHb2UkGZMwfBaZc5u4+iD+XakwNyL1mEFIehkMS/utEby3JCn5bQ0kwbD1682Cl0bpHsd+GI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752106; c=relaxed/simple;
	bh=BWe2J5TMsgA8UnLnjjU9LTydQ3QfGFaytAvAzU36cMc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=GkuMZ6niYXGNiBpiiQEDI/mDmcS1XGtnNZj71ZPdbKPUZctp+VnY7WGePlCnpmY7Qdktq1bbt7N12IZoXM0pWlpVbbxRXcGMpDETxPkx+M40oo14MehT0xCtKbtp+tqk3/VNcwZmz6lTwI4yqFre/bs21ZfC81FJZbUt+WTeHME=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C+mxxns7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C+mxxns7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 403FD1F0089B;
	Fri, 18 Sep 2026 17:21:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752091;
	bh=r5D6Mfen+6C8DMPske3KjBLun/39EjaTG07HYxjbpOE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=C+mxxns7SzQhqeb/Ny2ACrd50QFp1iVWr7E2HnX/YsGQhrfuDTi7oupvea06T25d3
	 kArBB6ohmcFdqaUyH/WAOfhNDkEv9jEEpC4WeuDX82AWJydnFDLf8v2fk5X8dXH6AQ
	 YPOee/U9k4JC/ywa6Fz8aaMfYVamhBa9eWXmte/jqD11Nn8gMQPDGKSKlDie/+Ji8a
	 3zyr8NocQC8UGMyP6H/Ca6l+xw6cyKFzziaB1nrdRs10Njl3tYOg7HhA3ZGItGIY87
	 uXgxOyZoLrR7uk3AAA3gzIlGnX4WCGTs9ef2O2OP3zEFKUqdw6Sp6i2+2I8wOd3BGJ
	 VO9t0RMolb+dw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:17 -0400
Subject: [PATCH v5 05/11] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-5-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2839; i=cel@kernel.org;
 h=from:subject:message-id; bh=BWe2J5TMsgA8UnLnjjU9LTydQ3QfGFaytAvAzU36cMc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWnt2zFophtmpLXtuoarKCcGoFW3WaRtQfH
 n4xzNJDZj6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l7lMD/4yPyX9FwjM2meTENn+Enzdrr8/7lYu2rnfaWpNbuOSKq2eByiFPeP3HSnlhQ8yMHPZb4O
 qzdlH+TygZ8YXlrxaVrkrjReYo/l3mTlJcivhI1yxXWGOK+a+X7mOXa/OR0Lm877j/09+Sc6Yl1
 aZxUgZgAktUAxPzwc3LnZP+uPgAS9M/6Whe1OZF1OgXVhtvPHdhod0VMBk7CMoun6pUZtpohdIT
 fFTRFwW/1W6aoYsJL7jZoQCz1R824mnakauTgf/JuWxyFRYNgDdRiNZXDiJ0Sf/K85BEvs5v+q7
 2CWbjq9AkjZEbnXaz8psOV5tA9DLzGjqDXPlgcLWstuL7slcQQCydlpfyzQB/BfMVksyMuOKQZ1
 7DHYuoMAFJpkKAqlSw2W/O0C32Pel3Cft5RedTB+MzOVfly1O0mZG3KSKWI48Js5fr9GZ4HNl9J
 9Bs65qQpnIPxygS+DhHkl1UrrXvsgxiTjxuseV9PX/QB17SqmD9Bddz2JRCsEvWCRDip/xOPpcS
 eYn66fhHtQSECmrRRPOC03SH/hPanY7f3/XQjWZ+C8NtkV7h0o3oOPk71D+o09n4ZfnqVOUpcqm
 NTd8m7ZUbPv+iGtlnxhKH2WaNGliJFsteraou8zyVDx7VGwtlzMSK6PWDRTlaZcW87zJxWN2Sn/
 4MTvp+H2gNS7eCg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure and expiry,
and neither emits a trace event, so there is no way to see which
reason is retiring entries or how old they are when it happens. A
further eviction reason needs the same visibility.

Add an event class that records the cache population, the XID, the
transport, and the entry's age, and define an event for each
eviction reason.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  8 ++++++--
 fs/nfsd/trace.h    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index be0b27af8ff0..4d0101e93add 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -275,10 +275,14 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
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
 		break;
 
 evict:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 2ae7f150a72c..ed4efcfa3961 100644
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
+		__field(u64, xprt)
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
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x xprt=%llu age=%lu",
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

