Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05C02483BEE
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776030; cv=none; b=ZSTZ6JHf/3bmEYfmZ1P/x4p2QRs3znXe7xYPd97RIVUjS/HcOYTxLZR3g3EULjJ/HAVa/b1XbH4S1/eCGoJXXgUhymgFnTw/gbwhWfakgDm1pjY8Ba1BX9YlPrtTIT7f5J85AnqevQbXnBuhnMp7qlRgKMSMxRwjTNk1W+psg8w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776030; c=relaxed/simple;
	bh=l4cBxzuRYFlOoZabb+gLgeW2NnpuDi9yTYhplYEm+V8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=piSk9DW/r86SAcyUTIK4RTv/BsoWwjVr2vJwza5HB+ykx6Tel4Cb2VGqZyLG3OqPHH4PX1b8NDZCNvJ6+ny4Yi6u03zEsqMW+/fpWmGyeD5CquZJaioKj5kNfzdKZ1hoCzWCvpUqGrKgrZawxyBPXFYMFW5lgXeIQZ0wixuT+6s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jGB+nWQ8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jGB+nWQ8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1FD7A1F00A3A;
	Wed, 26 Aug 2026 20:27:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776027;
	bh=tFYjo3QRRxVCDOS/xC4BXdagKUXqqSCb51hxcstsV14=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jGB+nWQ8+mVTXjMxQcoHI8nCFF+6Lxz42M71xj7UnaBA24Ys78IKvpxHAmqgOBdxU
	 srFbOS+MxZzlDFNDGZMevK9z1Ez4Z7VBrw+HTNTDO1H5D/2PYIROlngRgFOb/6GYhC
	 ac6BouQ4WdJyfM0bIuvoTZb/Eg2FqBWEZQft30kfBne7ZA+Vo/vGOvVqqcSsNHFix6
	 +U9YqABpj+7pgSSTOItQP1ZCeP2lPzRjoFNyeyisCdcw106yGX6byQoQ3Ki1njbdY8
	 EZU5+13lHYYhWv/kY7i2muZbRyE8o3l86jSA3n/1w4OCfoe31aEnGNOi+n/Qre3FvF
	 s1VQeCnc89G/Q==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 26 Aug 2026 16:26:56 -0400
Subject: [PATCH 6/7] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260826-duplicate-reply-cache-v1-6-b1d51e1af5c7@kernel.org>
References: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
In-Reply-To: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3181; i=cel@kernel.org;
 h=from:subject:message-id; bh=l4cBxzuRYFlOoZabb+gLgeW2NnpuDi9yTYhplYEm+V8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wV/pg7lElPiu0gjhyvzd9K/bi4VCFoY/tdv
 Qn8VsFsr1iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MFQAKCRAzarMzb2Z/
 l5hnD/9GN8qPLP6vzSalEtlmvW1ydP45YWSHmvccLhDOboB5f1BHKgxchPKybzG3oDwhipRYQDi
 hkp6p1La2Zl4XIw7FTHOBkYPtSj8drIwIW9lkbPPb2csOQXWxgFza3NIQEdQquEG97XZmYw1QfL
 ld+ZmBq4CcOir0pMCVtTIv30pg0UlwTTmLMZPUTW62PnTGp8QC/jOxpz4vV1gECgyILwAYfTGrU
 3mA4tWLsrA7OPbBrnf1teTqGGXr1X3Vt5q1i0cEOK9nOH8kjPAlvjfCRVyYubv+sk/wt+idmlD7
 KEJwXu9P8RdN4zYFUeyC0h6SUsFOZjVT+jKATlDQ1MZet48jIKUizFCN1AdQIpu1/4MJVkM+k61
 5oL7mkbgOMXLVdIOhUNkkX4EdcMrAwg2hoeE60DhpRLESQx3xJe5uG41zsxNEdPUN7lMt4pJDho
 FfEOsh6w7nAocr8IinVOOMcgjh7fiYIdE2aDgEtAx9uN0yJPHh38yYcbGmF05UPqwUifBeuenLU
 0uywktbSEHag0G6DQsW+0MP/BR1MZofVWbcF2EtNRfF0FoTfhhGXq/mR9F47lyT07Fqq9kPZJQT
 SURjkKDSAKl924BJ8alK5dT/d5r+0tYXIs7U9+7veldJFv314P3Jgq8rklYhwE/RoYgX6jetAm8
 i1tumZSQ8Cx7V9w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure, expiry, and
implied ACK, and none of these emit a trace event. There is no way to
confirm that implied-ACK eviction fires, compare its rate with the
other paths, or see when a transport mismatch keeps an otherwise
eligible entry in the cache.

Add a tracepoint for each eviction reason and one for the transport
mismatch case.

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
index 7d7a1483109a..f1d399b3e51c 100644
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
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x xprt=%u age=%ld",
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

