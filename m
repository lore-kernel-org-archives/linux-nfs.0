Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0E1F493641
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048508; cv=none; b=SV+Bu2x8uoXdEsLl64+eAeQFDXtfP5KeoYtQHsi1pjv4lyipbyUJFYTOFK+ylz7JFWg1fX5Fl+Der9G0jCVS2CS9Xb/XlVs3EOauqdQ1LxiXogmxgCbHQ/DPgNzwo6Bo5S8/PPm9UB76JXKnDxZuRBXHeGU7weC7Uys7i2J+81k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048508; c=relaxed/simple;
	bh=yjQWLxml7zgNawfw4tkSK/wk8hFUasbzgWSxq0+oNqU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=YZtnm8fwArmx7U+UXwr4kfISe+buozABF4cvWWX2JYHcf0HoDkfmew8t7pKL84AfQP2AyxNGhzVvU8JYXd7uGgx2fuz9u1J0ZzjuYrpp8i6K35d2+0J0mziFML2KvKhPi7ebtCK3jXIaHRV9dtrcz/VHXvx3EG46suoshlsTAXU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UuRAvYpR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UuRAvYpR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 18E201F00899;
	Thu, 10 Sep 2026 13:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048506;
	bh=lJWiuO2PytzPnkAIqnAkMvvFcM89BFBZ9GO5bgt3f68=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UuRAvYpRELapJAv+dWQc9E2OnkVD1SbaG2P2Jdvzf43tuiI4xko7lFNgMGksclgN/
	 34kJpAIismrOmWWQ0Zpk+YYtzv6JRybAxrH+WztJaI5p93xlc/RqAOFRhtz0ceRBAK
	 Cb6xy04h3/3iS/aKECI/6DdDzXUPLTOU619v01wBhomwtbWOuulHWDqJmfVM8uMr91
	 X1+jTVDagmsohyGAktNhHh8Qi4dEDH2K3XiLNYajwMpCFS/Pd/dmbPm6yAlhl+yS1R
	 rqWngnGIpTlPv0sK7moPw21BohLo461lKmQQ/GROWASSJIsdRLGfSmCxBqAXX0wRQi
	 vS6wUizIGDqlw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:51 -0400
Subject: [PATCH v3 11/12] NFSD: Remove DRC checksum and payload_misses stat
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-11-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=14738; i=cel@kernel.org;
 h=from:subject:message-id; bh=yjQWLxml7zgNawfw4tkSK/wk8hFUasbzgWSxq0+oNqU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawOdKXbRSmiyy8MpDsvarMB3G2x/byOgUl2
 irxgba8zs6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 lyoUD/93pVvaa6eQ0B8i1ykhOOpbSgSpN8La705WkE3pEBa5+Gn5hfE/eyCy22JYhsHiLObiZGR
 Ezp89GycIUzuUG4W4LtKvsqnGqOiYxXDNAedRAUjGaMxifla3fmCe0E/Pti2TbCqJVjpBO4AW3l
 /8afh6ANeYr/UnGaa6QLF7uashtRJMAwPAb9D1rtG28hFxCcL+Ora4EdphsDDmaKvML5/oeImYh
 VcsviK+YdiNVq+tZl6AHo13AxLV6q/EN5b+IoshMZ7vbuDwjJlr/V510wvjyKw4nX82FMDvEmKX
 WY4AOaCMxHRQNDvq3mRYAkHG47tE7AkR0STjdXPla2x+fdXBKpblkLtOFk41c8lbVbVXY+Dyia+
 yQwmytBXM63b6LLzSc7DrtrHXNUwDd3gFHUTwCh7JwqI5BtPo+Ve75fgYgFLox6PSkjexnIMe6C
 8CnTPgnmGSAnaLqzA24lcZsfRHZXa2hAQZC1ml3+wZU2r2nq5qkzUwEJ9WQLfFSHqd1cq9/aWrz
 ihT8GSZHXGojR9gHI9vAZ88M2SAZvDf4pOQg5WEAm71LuNE0o2djlHP/djH6JGUwXrgKF58QjmP
 2SV+EAP3tgJsIbkqN4zLl8IN0z5hOQv+Ui2TsGnRKjR5LMW7Tsvs1RigmzXGh7VDM4qyKjS0ZCr
 VMMnXAfy3oi1PTw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_csum() costs CPU on every non-idempotent request. It also
prevents the use of zero-copy RDMA receives for WRITE and SYMLINK
because the payload must be in the server's memory before the DRC
lookup can run.

Commit 01a7decf7593 ("nfsd: keep a checksum of the first 256 bytes
of request") added the checksum when a growing cache made XID
collisions easier to hit. It is the only guard against a reused
XID: two calls with the same procedure and equal-length arguments
match on every other key field.

ACK-driven eviction retires a TCP or RDMA entry once the transport
confirms delivery, so a fresh XID rarely finds a resident entry to
collide with (~100/2^32 per request). A UDP entry can wait out
RC_EXPIRE, but the Linux NFS client seeds its XIDs from
get_random_u32(), so even a rebooted client does not replay its
previous sequence. A client that repeats a live XID cannot reliably
match replies to its own calls anyway.

An acknowledged entry stays in its bucket until the next prune
visits it, and a lookup matches it in the meantime. The client
already holds that reply, so treat a call carrying its XID as a
miss: evict the entry and insert the new one in its place.

Remove nfsd_cache_csum(), RC_CSUMLEN, and k_csum, along with the
nfsd_drc_mismatch tracepoint and the payload_misses stat that
counted checksum-detected collisions. Drop the start and len
parameters from nfsd_cache_lookup(), so nfsd_dispatch() no longer
snapshots the argument stream before decoding.

The "payload misses" line disappears from
/proc/fs/nfsd/reply_cache_stats. No known userspace tool parses it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +--
 fs/nfsd/cache.h                                    |   9 +-
 fs/nfsd/netns.h                                    |   2 -
 fs/nfsd/nfscache.c                                 | 103 +++++----------------
 fs/nfsd/nfssvc.c                                   |  10 +-
 fs/nfsd/stats.h                                    |   5 -
 fs/nfsd/trace.h                                    |  24 -----
 7 files changed, 28 insertions(+), 136 deletions(-)

diff --git a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats b/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
index 57ed5f8e6597..7a22ac7c1ccd 100644
--- a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
+++ b/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
@@ -19,19 +19,16 @@ Description:
 		cache misses             s64     Requests not found in cache
 		not cached               s64     Idempotent requests that
 		                                 bypass the cache
-		payload misses           s64     XID matched but request
-		                                 checksum did not
 		longest chain len        u32     Longest hash chain observed
 		cachesize at longest     u32     Cache size when longest
 		                                 chain was recorded
 		=======================  ======  ==========================
 
 		Counter fields (cache hits, cache misses, not cached,
-		payload misses, mem usage) are maintained with per-cpu
-		counters and may briefly show stale values under
-		concurrent load. There is no way to reset these
-		counters; consumers should compute rates by sampling
-		over time.
+		mem usage) are maintained with per-cpu counters and
+		may briefly show stale values under concurrent load.
+		There is no way to reset these counters; consumers
+		should compute rates by sampling over time.
 
 		New fields may be appended in future kernels. Parsers
 		should match on field name, not line position.
diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 8ad23a1fcb57..6bb57d20da84 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -22,9 +22,7 @@ struct nfsd_net;
  */
 struct nfsd_cacherep {
 	struct {
-		/* Keep often-read xid, csum in the same cache line: */
 		__be32			k_xid;
-		__wsum			k_csum;
 		u32			k_proc;
 		u32			k_prot;
 		u32			k_vers;
@@ -80,16 +78,13 @@ enum {
 /* Cache entries expire after this time period */
 #define RC_EXPIRE		(120 * HZ)
 
-/* Checksum this amount of the request */
-#define RC_CSUMLEN		(256U)
-
 svc_ack_cookie_t nfsd_cache_ack_cookie(const struct nfsd_cacherep *rp);
 int	nfsd_drc_slab_create(void);
 void	nfsd_drc_slab_free(void);
 int	nfsd_reply_cache_init(struct nfsd_net *, struct svc_serv *);
 void	nfsd_reply_cache_shutdown(struct nfsd_net *, struct svc_serv *);
-int	nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
-			  unsigned int len, struct nfsd_cacherep **cacherep);
+int	nfsd_cache_lookup(struct svc_rqst *rqstp,
+			  struct nfsd_cacherep **cacherep);
 void	nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 			  int cachetype, __be32 *statp);
 int	nfsd_reply_cache_stats_show(struct seq_file *m, void *v);
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0ce7da20aba3..30231b9027dd 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -39,8 +39,6 @@ enum nfsd_net_flag {
 };
 
 enum {
-	/* cache misses due only to checksum comparison failures */
-	NFSD_STATS_PAYLOAD_MISSES,
 	/* amount of memory (in bytes) currently consumed by the DRC */
 	NFSD_STATS_DRC_MEM_USAGE,
 	NFSD_STATS_RC_HITS,		/* repcache hits */
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 9f9baf7910ff..4ab6595a0bcd 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -13,10 +13,8 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/sunrpc/addr.h>
-#include <linux/highmem.h>
 #include <linux/log2.h>
 #include <linux/hash.h>
-#include <net/checksum.h>
 
 #include "nfsd.h"
 #include "nfserr.h"
@@ -121,8 +119,7 @@ static bool nfsd_cacherep_implied_ack(struct svc_xprt *xprt,
 }
 
 static struct nfsd_cacherep *
-nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
-		    struct nfsd_net *nn)
+nfsd_cacherep_alloc(struct svc_rqst *rqstp, struct nfsd_net *nn)
 {
 	struct nfsd_cacherep *rp;
 
@@ -141,7 +138,6 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_prot = rqstp->rq_prot;
 		rp->c_key.k_vers = rqstp->rq_vers;
 		rp->c_key.k_len = rqstp->rq_arg.len;
-		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
 		rp->c_acked = 0;
 		rp->c_ack_pending = 0;
@@ -475,68 +471,10 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	return freed;
 }
 
-/**
- * nfsd_cache_csum - Checksum incoming NFS Call arguments
- * @buf: buffer containing a whole RPC Call message
- * @start: starting byte of the NFS Call header
- * @remaining: size of the NFS Call header, in bytes
- *
- * Compute a weak checksum of the leading bytes of an NFS procedure
- * call header to help verify that a retransmitted Call matches an
- * entry in the duplicate reply cache.
- *
- * To avoid assumptions about how the RPC message is laid out in
- * @buf and what else it might contain (eg, a GSS MIC suffix), the
- * caller passes us the exact location and length of the NFS Call
- * header.
- *
- * Returns a 32-bit checksum value, as defined in RFC 793.
- */
-static __wsum nfsd_cache_csum(struct xdr_buf *buf, unsigned int start,
-			      unsigned int remaining)
-{
-	unsigned int base, len;
-	struct xdr_buf subbuf;
-	__wsum csum = 0;
-	void *p;
-	int idx;
-
-	if (remaining > RC_CSUMLEN)
-		remaining = RC_CSUMLEN;
-	if (xdr_buf_subsegment(buf, &subbuf, start, remaining))
-		return csum;
-
-	/* rq_arg.head first */
-	if (subbuf.head[0].iov_len) {
-		len = min_t(unsigned int, subbuf.head[0].iov_len, remaining);
-		csum = csum_partial(subbuf.head[0].iov_base, len, csum);
-		remaining -= len;
-	}
-
-	/* Continue into page array */
-	idx = subbuf.page_base / PAGE_SIZE;
-	base = subbuf.page_base & ~PAGE_MASK;
-	while (remaining) {
-		p = page_address(subbuf.pages[idx]) + base;
-		len = min_t(unsigned int, PAGE_SIZE - base, remaining);
-		csum = csum_partial(p, len, csum);
-		remaining -= len;
-		base = 0;
-		++idx;
-	}
-	return csum;
-}
-
 static int
 nfsd_cache_key_cmp(const struct nfsd_cacherep *key,
-		   const struct nfsd_cacherep *rp, struct nfsd_net *nn)
+		   const struct nfsd_cacherep *rp)
 {
-	if (key->c_key.k_xid == rp->c_key.k_xid &&
-	    key->c_key.k_csum != rp->c_key.k_csum) {
-		nfsd_stats_payload_misses_inc(nn);
-		trace_nfsd_drc_mismatch(nn, key, rp);
-	}
-
 	return memcmp(&key->c_key, &rp->c_key, sizeof(key->c_key));
 }
 
@@ -560,7 +498,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
 		parent = *p;
 		rp = rb_entry(parent, struct nfsd_cacherep, c_node);
 
-		cmp = nfsd_cache_key_cmp(key, rp, nn);
+		cmp = nfsd_cache_key_cmp(key, rp);
 		if (cmp < 0)
 			p = &parent->rb_left;
 		else if (cmp > 0)
@@ -589,28 +527,23 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
 /**
  * nfsd_cache_lookup - Find an entry in the duplicate reply cache
  * @rqstp: Incoming Call to find
- * @start: starting byte in @rqstp->rq_arg of the NFS Call header
- * @len: size of the NFS Call header, in bytes
  * @cacherep: OUT: DRC entry for this request
  *
- * Try to find an entry matching the current call in the cache. When none
- * is found, we try to grab the oldest expired entry off the LRU list. If
- * a suitable one isn't there, then drop the cache_lock and allocate a
- * new one, then search again in case one got inserted while this thread
- * didn't hold the lock.
+ * Preallocate a cache entry for the current call, then attempt to
+ * insert it.  If an existing entry matches, the preallocated entry
+ * is freed and the cached reply is returned.
  *
  * Return values:
  *   %RC_DOIT: Process the request normally
  *   %RC_REPLY: Reply from cache
  *   %RC_DROPIT: Do not process the request further
  */
-int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
-		      unsigned int len, struct nfsd_cacherep **cacherep)
+int nfsd_cache_lookup(struct svc_rqst *rqstp,
+		      struct nfsd_cacherep **cacherep)
 {
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct nfsd_cacherep	*rp, *found;
-	__wsum			csum;
 	struct nfsd_drc_bucket	*b;
 	int type = ntli->ntli_cachetype;
 	LIST_HEAD(dispose);
@@ -621,21 +554,29 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 		goto out;
 	}
 
-	csum = nfsd_cache_csum(&rqstp->rq_arg, start, len);
-
 	/*
 	 * Since the common case is a cache miss followed by an insert,
 	 * preallocate an entry.
 	 */
-	rp = nfsd_cacherep_alloc(rqstp, csum, nn);
+	rp = nfsd_cacherep_alloc(rqstp, nn);
 	if (!rp)
 		goto out;
 
 	b = nfsd_cache_bucket_find(rqstp->rq_xid, nn);
 	spin_lock(&b->cache_lock);
 	found = nfsd_cache_insert(b, rp, nn);
-	if (found != rp)
-		goto found_entry;
+	if (found != rp) {
+		/*
+		 * The client already holds the reply for an acknowledged
+		 * entry, so a call carrying its XID is a new call.
+		 */
+		if (!found->c_acked)
+			goto found_entry;
+		trace_nfsd_drc_evict_acked(nn, found);
+		nfsd_cacherep_unlink_locked(nn, b, found);
+		list_add(&found->c_lru, &dispose);
+		nfsd_cache_insert(b, rp, nn);
+	}
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
 	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
@@ -804,8 +745,6 @@ int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]));
 	seq_printf(m, "not cached:            %lld\n",
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]));
-	seq_printf(m, "payload misses:        %lld\n",
-		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]));
 	seq_printf(m, "longest chain len:     %u\n", nn->longest_chain);
 	seq_printf(m, "cachesize at longest:  %u\n", nn->longest_chain_cachesize);
 	return 0;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d6687ffbec45..bc3e0e046bc2 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -1004,7 +1004,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	const struct svc_procedure *proc = rqstp->rq_procinfo;
 	__be32 *statp = rqstp->rq_accept_statp;
 	struct nfsd_cacherep *rp;
-	unsigned int start, len;
 	__be32 *nfs_reply;
 
 	/*
@@ -1013,13 +1012,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	 */
 	ntli->ntli_cachetype = proc->pc_cachetype;
 
-	/*
-	 * ->pc_decode advances the argument stream past the NFS
-	 * Call header, so grab the header's starting location and
-	 * size now for the call to nfsd_cache_lookup().
-	 */
-	start = xdr_stream_pos(&rqstp->rq_arg_stream);
-	len = xdr_stream_remaining(&rqstp->rq_arg_stream);
 	if (!proc->pc_decode(rqstp, &rqstp->rq_arg_stream))
 		goto out_decode_err;
 
@@ -1033,7 +1025,7 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	smp_store_release(&rqstp->rq_status_counter, rqstp->rq_status_counter | 1);
 
 	rp = NULL;
-	switch (nfsd_cache_lookup(rqstp, start, len, &rp)) {
+	switch (nfsd_cache_lookup(rqstp, &rp)) {
 	case RC_DOIT:
 		break;
 	case RC_REPLY:
diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index aabfbb1a9c71..4a556dfbf64a 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -97,11 +97,6 @@ static inline void nfsd_stats_io_write_add(struct nfsd_net *nn,
 					 amount);
 }
 
-static inline void nfsd_stats_payload_misses_inc(struct nfsd_net *nn)
-{
-	percpu_counter_inc(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]);
-}
-
 /**
  * nfsd_stats_drc_mem_usage_add - Add memory used by a cache item
  * @nn: target network namespace
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index c99b2a369d0d..b9d89a1e1c2e 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1536,30 +1536,6 @@ TRACE_EVENT(nfsd_drc_found,
 
 );
 
-TRACE_EVENT(nfsd_drc_mismatch,
-	TP_PROTO(
-		const struct nfsd_net *nn,
-		const struct nfsd_cacherep *key,
-		const struct nfsd_cacherep *rp
-	),
-	TP_ARGS(nn, key, rp),
-	TP_STRUCT__entry(
-		__field(unsigned long long, boot_time)
-		__field(u32, xid)
-		__field(u32, cached)
-		__field(u32, ingress)
-	),
-	TP_fast_assign(
-		__entry->boot_time = nn->boot_time;
-		__entry->xid = be32_to_cpu(key->c_key.k_xid);
-		__entry->cached = (__force u32)key->c_key.k_csum;
-		__entry->ingress = (__force u32)rp->c_key.k_csum;
-	),
-	TP_printk("boot_time=%16llx xid=0x%08x cached-csum=0x%08x ingress-csum=0x%08x",
-		__entry->boot_time, __entry->xid, __entry->cached,
-		__entry->ingress)
-);
-
 DECLARE_EVENT_CLASS(nfsd_drc_entry_class,
 	TP_PROTO(
 		const struct nfsd_net *nn,

-- 
2.55.0

