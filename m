Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801483;
	b=w8q7Um4IX4UJ11tcApWf/Qv7Iut5FALK64fNdHxvuqBqaBXtggeUG3yjzM5wsfauEtr7
	 1DgdBnRSxAfoh+N3XgBBAtbVAnPYZV7dgmkxaP9IzNykD4rnyJ83JtOlUS71i+XP00GgU
	 4zLP/vSvNz118VnTfIbDPfZosJGFGMvRhPXrV3SSTm4FvSdLqHkZyqy+2y5soqHsI022k
	 H57mPTJ6cz+n+8rHSI56srKhnXTbCqP/kj4EDmPVFPFXYMw2XDmuqvoF8M9RHM8DTpUa8
	 iOClhVYPT6AvkxSxzkA0/GamgX4QlAvR4N6ylkQGyFmlDoUIhYvZT273GZt6is/SS8g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801483;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=kk3LtOU/SZyyFRKggQhUUfnfHroM4MTcf5cjMtgmCbs=;
	b=bx0M1mZ+9kTLutZ58T88UqJLBw5Hy84K+faPE0TFm4H0hw0kkzCBiY0SZNsFJsQoRGn+
	 KeFYua959C3tyi6jBtDLp3KhLy6YnnxsrBdsQPWIlBrY/6nD/jYKzywl6VRU0obm8fIoH
	 ocLMzwmFooc7hMuxjXaMf9vR2RqDWb5lFFyc/hfWk+kE1rf1inIcLPdW0EXwIcTIVqiqL
	 X1dY3xBALpooonC48ozIwxM9yffwad2CGgaBjg/dr2Eru+ZcdJHvtgpQmMo5MP/O+GS7n
	 PevDX/4vqhS2Y3tgu4vOsi/pHyCu6yXqVEeP4o0jDf9FS1bvIKGLLBEh00C5aV6e3Rw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hy5R7cTM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77822606D80F;
	Wed,  4 Nov 2026 14:11:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hy5R7cTM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3ABB21F00A24;
	Wed,  4 Nov 2026 14:11:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801483;
	bh=kk3LtOU/SZyyFRKggQhUUfnfHroM4MTcf5cjMtgmCbs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hy5R7cTM+GOPz/6qwKIW332wc/+vMxwMtcSOyXkY5z9HKBkdOmERPoxO0pTv4QJCn
	 y8bMbhfKH5CT6qmg66wd9QRIcRYTNQI3Suy3FrvAjbPszrpNBfUWBHdrGR1Wr+4FlD
	 B5d51AQ1BXZBU1/G5fg1vmg5ZfLbBn9tWkc5wCbys5KkyLK+HXIA02Yrg1UMXR9Jar
	 3rQHecoG9hBDPaITdWviJgYhjfbVtlQ+clKusNKzy+/ZgdYpmZ+Au76PN6CHlm8S6J
	 6Imdjrg/KaXw1oOpuqNeLHEDxuHEmDN15B3ggzLEx/+Z+yzOFcv8gJ9qIFs29wy64G
	 IEyZ5tAAhnhMQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:07 -0500
Subject: [PATCH v8 07/14] NFSD: Add tracepoints for DRC entry eviction
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261104-duplicate-reply-cache-v8-7-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2955; i=cel@kernel.org;
 h=from:subject:message-id; bh=sqizHfHZXMsYB8F+Fzu7fu7O9HUeFsaLV5G5mg+Ak2E=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0AZlUPq1p04CJ80TsXRa4eCiTm1BFQN5wuw
 nwAAbTXux2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 l/aRD/4ikYijVGmTU3Bfu4koX+w9DM46DByZDaXH/vwQq2LOrp5mI3rnAGJdHkU6K2jYhiJ/89N
 LUQ+1n1/2g34eFBPBu3s39ndqnDjzPTXTpRT403cpcYcNXyx77MBlf5hCO5y2/BJvRoMx9T/3ec
 c82fuczJ5NU5G66zwoPqbDPaJ/ToK0ZiFQQXu/QmWrPn1cj/5Amgmt15BiB2OpZK9IAcGV1WW9N
 nNmKqVSRYZHuzZroLbQCYFhNvY79gGZu7XGzp6UGzlGyhHKy7FL2WlJSCOx9YRJh1J3qN9+tk+5
 kUvquztsvo7Q50Z0B81MCEOSydkpz9WUSEO3wAYSIuqQ79eBXIK3pE9uBVodFFbv+6DcaFyy82H
 mX1PQ693WA9YjrBqPWeg6OO2v7pfcjkoEFbR0ewGFobbRW3o1cW1md3pKS384gT+IeCAni2EHu9
 dA4dZnh4BbNDAZgc/aNjWradcdSroooqcxv+/rEGSUb5xBadyxN8pLgHIjNt/Rtdd+gAV/eeYo9
 ZIu7aDjxCe2nDdj5MrrnCuawg+8iwW2OjhrMAeJlS+8cw9RAd81ht95QoK6MJ1kXC5PSkZlvx7l
 x+C0gkAFp2thrxvQhBUpePQixHrFGWutz/B3BNVIpcDVGF3YjUlKMs96Pg8YyqS+pGK1jv4lgx4
 D+96NcKBvQnT2Ag==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure and expiry,
and neither emits a trace event, so there is no way to see which
reason is retiring entries or how old they are when it happens. A
further eviction reason needs the same visibility.

Add an event class that records the cache population, the XID, the
transport, and the entry's age, and define an event for each
eviction reason.

Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-6-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  8 ++++++--
 fs/nfsd/trace.h    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 988b955590cc..680025334f1f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -274,10 +274,14 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
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
index e58b753c1ebc..4a3623b3899a 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1709,6 +1709,43 @@ TRACE_EVENT(nfsd_drc_mismatch,
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
2.56.0

