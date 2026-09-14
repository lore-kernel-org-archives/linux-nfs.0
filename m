Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB2D94825BF
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397150; cv=none; b=lEmp2NOlqGzj+e6T7u0mnunU9ZjxwcGq2yEBUTADAftZUBrEDyPlYlD+ky6YmnyXq/iBO/ZwqsCoHQbYO6bnhYMLQt/qiPFQISp/L7MSpEfMzik2DndWGk6rk4wi2+oZqJdQv95lCUbe+Ois+l6hAVG6w9AvnB6AmaoaJM4gLVA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397150; c=relaxed/simple;
	bh=qFgSD11t32KVJ00Y+T4g7GeZyz1nU+ZxupJl3n7K2Q4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ECbUyExtsCvmN23a+H5nNnZSk5jAgTnoTGRXyGIGxBGCxl31l+L+jFv3Mzi3SgklACmHtCPLM5EYyGJ33b5NWiGjeX9HyqUeUcOac8ey9X3dE4viiYOrTOpjdLFeVDHXyKc7syyiTXWo7ehKPaKnqHzgm5xMU+GurXNVXRauV00=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eUPWKIED; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eUPWKIED"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C20051F0089B;
	Mon, 14 Sep 2026 14:45:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397147;
	bh=XnKUfKjNzVT3HSt4csUcsZ2ZDd5vQQWkThKqaJ07Xu8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eUPWKIEDyh618WMWrjjkVB4X2VN/Ll383PN3qjkl9kS9AkIuQTt4LnXjQCM362AR3
	 zZwuoQNYtSNetbcxzF13fYKWtkbeAz67zUdFks3k23frZldV92IrCHLdUdH+4gi15P
	 z6FPJmxwbDDhnEEF6utpg3POzwhamHgka3CQGqdkxC1jRl1dDXwKTda5CYYllpELSw
	 9g3EpvXDl3gkX3FanUSXHGNn/pl+QzoZkuKfpN1DPZuTtpA3gXWb5/hKVnFGEi8c71
	 gnZr/cuEP8cAaONbJTW+ZE6c6L6pnPhIPxYY1gTFLiW2My3RUamCf7cscdt96HIKMH
	 0ewI/0jKNr7TA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:34 -0400
Subject: [PATCH v4 04/11] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-4-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2841; i=cel@kernel.org;
 h=from:subject:message-id; bh=qFgSD11t32KVJ00Y+T4g7GeZyz1nU+ZxupJl3n7K2Q4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiW+f3xWrA9zeFcTA7D6xTxVYV+ODS9ypeF+
 ZGJNsHfFn6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 l1ymD/9U0wiuDLxR9giTEc//wetcGO2WcOEwB0niAvRnWVZjga1nyuLhbKVvflgzeOW6nDLgZbp
 jGX1l9iWmnlGOkQn7kOle5DFJDRbfKd9Mx5ZRrF/veOzo1aK6LgNrhx9rSYGZw3PzQPeF2xXEYW
 C0PYwhnGgiivd9dJWXy76OwqKDJiVCnI/mtSs/yr0ib3EKOoUTnWwHmYZGDS190KkaXlRZlVPEu
 ueJsahW6pj3t+16mHbbnMevR8N5NDJPVpI4CwDXFqES/KQRW/9T5YU79owo05wVFD62NT9RA7le
 1rZCyVjT+qzFo1C5pL/XWZkxg4yi7k28km9GPML3IsgkZdECD2cJHxPUJTZgjVyuLv1D1+2M0zm
 WSRcq5w3ozIpUC7STp9tYIZLlNF9eDrpDspcix94xANBzNEYlcM+JFuCG4vybKrRpvIyCd+sWAx
 nfyEBQY7TS8l8UBY86AOQ3Zh0wIDsyzKu7XOcHuq5h8JS2VbL7stMvOCYeK8cszIxO66yeQSBIU
 j8iK1olWmCd9eIWKNtgmY8/hbKAZ6joDy/a81/dNP8MXylVXvMzWyjOH/ms9yanQy0gx+YNdzA1
 gZBa2iEBs0aJ2LFza5s1mc7+rJzyIyWw8+lEpf3aKunZI9VpFmYgtF8ly2g1AiU6KsXY5Plg4Cr
 u9I8wOLtRWVJn+Q==
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
index 716605dbc788..b9fe9662dcf0 100644
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
index 2ae7f150a72c..c92863027896 100644
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
+		__field(u32, xprt)
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

