Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297193;
	b=l1A19NwADLDl+O8hmK6KLhwCLVW2994dHFqaSTwgMufcC/Ex8lYm5xenyxdsNIBVjkNJ
	 6Hjc1YfJYnEw3JR+ufFi9ZzVZCLC/PWUta4Cz1AQrfO/hv8RGUmf3G+W3edUsgqqd9pxG
	 QbPTILqulUat1ZCFLbBqRsnpnZJdZv1JZKeXt1jhNdnycNL4tXGZOGMiZWMcnOgdvsPa4
	 Ur8h4CqrstvoBNNf1L6Z89rW4zrzYsY+AhYt1TdJmMYCCIxgnNWyijrr56OKi35Y+22jx
	 lqakW0ozFDHvlhIlRHOSd3N6JY5L+9dG8KGTW6yEVwehqDRzwPhBSKqX0/UiAGyvhFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297193;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aQoJ0kdGX/KqOCXFrr+2y2vXrY+ucfKhkfqW8m5w8mE=;
	b=JdpxyRXGMFE8bir5Wgjj25xHtTJGa6jLlW2KYu5AP4zVZXAWuLaBfvzc1J5Z2XuzO8YI
	 phNbQ4yjuK2E435h+6rl59fvxcMOTPnCFNbEWX/Bsd75fuM+lV5IKxAGpK0UViyQ1RUmM
	 19fDunYbfb048e/6cuHC1ydA68Or83cssuh45R8e68BrVSwmeUO3P4MB8+6+cWTtMFtYi
	 mTMdiJ7xBw11JCwwvkwmP0fVD8C1GLyK0KZJgoTAFvxdDoy/vkhKsoOIo8wEHJjtGm98+
	 WcNXrfKPkOoVVT3R0LaB6Ay5N/seuw9C8s7bCip0yr8E14uafUAHNlqNe8K1wqrOAZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Y13P3kNM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD9E9606A32E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Y13P3kNM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF89C1F031EB;
	Thu, 29 Oct 2026 18:06:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297192;
	bh=aQoJ0kdGX/KqOCXFrr+2y2vXrY+ucfKhkfqW8m5w8mE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Y13P3kNMtZ/eCOy8PiXbocNUQQDGykWi1aoKLGY5DBig2NMFr5nla1lRxXAFNeq8Z
	 2W3p/JaabHf+pH+h5jApjQ70k7xZ26W5Ii1N6Hd3iqTnEVxkgpzX/tcw5H+DdCBjsZ
	 mzwN2V1Oo9ZINIv4v589AP+Lk3It2coa67EaaVT3Hl8Meb5nebthgvXtcsdjDuDS1S
	 h7Cvg4ApMJA2Uj0HUx1Zi7qKXcpOsM3GE8Y/JZt64SoHZchXt5DGH3JuHxbYJhRRke
	 su+/ESjUSotneMbpLouZr9hPS1SyPyj9gRRPPpLfX6ZmumkVHva50s3LHGlOXP1OnC
	 ugywe6EGGC0RA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:18 -0400
Subject: [PATCH v7 12/13] NFSD: Remove DRC checksum and payload_misses stat
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
Message-Id: <20261029-duplicate-reply-cache-v7-12-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=15165; i=cel@kernel.org;
 h=from:subject:message-id; bh=1WqRGpLOqEkIME7dChzhqOcbPfcFrVvCB81kHKuzpoI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scphcxKAe+HHJp38A090tZTSdQJiPZI4VTC
 bXxO6TPPJ6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l/lDD/4mPKmCzb+SMXK8Da2NUWVjDjBQnXqMF58c36LQYNpBGWZlaQ7Ta52BXtCqiCNEDd2IGtS
 Tov3JPdCixmpyW0udpR44dMdK46i+jJmWpq6Y+TZ+tE9O232xWRJRgWnU1fs4TRyc2d7WSq2s9w
 U3ompemJRofRYd+PA+rPK0ZVBiUDGL7FNMKKgE8sT+MeY2jojXVmXSLH32dTMUlJXTN7jiNV68V
 VJojA5Yo/7Gnv35LJxEaHAMIyynUhBLtyT5VwBMYZyoTUDi1luHSaOf5sooAu4Urz9AhZ7IJ3Bo
 CEysAH2iEF6eZzXm0ewnLnIGtXPmAlKSoOewiH5FQiLflFuh7KO5gExsHi9k5SPOZGqfTvkWft2
 UMGxTjIK03R2rQ7TiwNUy+zUXvlBWUkj00K7LWhperxTxt373tsB8nU+lbTrX2faAU1oW2nS4z2
 0zSP7Q5paAghIVddMc10y2GkgYpwFMAkGebkp7S0afto4jDpo3ck/3HUZHpXIj3YEdZka/qclln
 hZjNCpPM3gVrpMBFgWnR+TO2VzkSyEHtXbWvjCo1GMW4J7MpfUpbHWCqKpqUiB4qWvS7uQZc8Wa
 tePjuc1TbtyZThoAMu7snj6LvqJtW72ztBFrzcBvYUDG8R8tnOIVA6ocfa06fKaDYU/WNr/67VA
 nv+5DOxbyiwg4tA==
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

Acknowledgment-based eviction retires a TCP or RDMA entry once the
transport confirms delivery and a later request from the same
connection visits its bucket. Three kinds of entry outlast that: the
entries a connection has issued since it last visited each bucket,
entries from a connection the client has since closed, which no
later request can evict because their transport is gone, and UDP
entries. Those wait out RC_EXPIRE, or longer in a bucket that no
miss visits, since only a miss prunes expired entries. A collision
needs the same XID from the same address and port while the entry
lasts. The Linux NFS client's XIDs are sequential from a seed drawn
with get_random_u32(), so an XID recurs only after 2^32 calls, and
a rebooted client does not replay its previous sequence. A client
that restarts its sequence from a fixed value and rebinds its
previous source port while the entry lasts is unguarded, but a
client that repeats a live XID cannot reliably match replies to its
own calls anyway.

A call whose XID matches an entry sent on the same connection is
therefore a retransmit. TCP and RDMA deliver the queued reply or
drop the connection, so drop the call as though the entry were
still in progress rather than replaying it. A match from another
connection, or from UDP, is replayed as before.

Remove the checksum, the nfsd_drc_mismatch tracepoint, and the
payload_misses stat that counted checksum-detected collisions.
nfsd_dispatch() no longer snapshots the argument stream before
decoding, and with k_csum gone, struct nfsd_cacherep shrinks to 136
bytes.

The "payload misses" line disappears from
/proc/fs/nfsd/reply_cache_stats. No known userspace tool parses it.

Assisted-by: LLM
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-12-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 .../ABI/testing/procfs-nfsd-reply_cache_stats      | 11 +--
 fs/nfsd/cache.h                                    |  9 +-
 fs/nfsd/netns.h                                    |  2 -
 fs/nfsd/nfscache.c                                 | 96 ++++------------------
 fs/nfsd/nfssvc.c                                   | 10 +--
 fs/nfsd/stats.h                                    |  5 --
 fs/nfsd/trace.h                                    | 24 ------
 7 files changed, 23 insertions(+), 134 deletions(-)

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
index 894e0b61cbfc..3491a10524d7 100644
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
@@ -80,15 +78,12 @@ enum {
 /* Cache entries expire after this time period */
 #define RC_EXPIRE		(120 * HZ)
 
-/* Checksum this amount of the request */
-#define RC_CSUMLEN		(256U)
-
 int	nfsd_drc_slab_create(void);
 void	nfsd_drc_slab_free(void);
 int	nfsd_reply_cache_init(struct nfsd_net *);
 void	nfsd_reply_cache_shutdown(struct nfsd_net *);
-int	nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
-			  unsigned int len, struct nfsd_cacherep **cacherep);
+int	nfsd_cache_lookup(struct svc_rqst *rqstp,
+			  struct nfsd_cacherep **cacherep);
 void	nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 			  int cachetype, __be32 *statp);
 void	nfsd_cache_reply_sent(struct svc_rqst *rqstp);
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index fa3545963902..1d32846b1836 100644
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
index a5d95fa17717..12c9ab1c88c7 100644
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
@@ -90,8 +88,7 @@ nfsd_hashsize(unsigned int limit)
 }
 
 static struct nfsd_cacherep *
-nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
-		    struct nfsd_net *nn)
+nfsd_cacherep_alloc(struct svc_rqst *rqstp, struct nfsd_net *nn)
 {
 	struct nfsd_cacherep *rp;
 
@@ -110,7 +107,6 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_prot = rqstp->rq_prot;
 		rp->c_key.k_vers = rqstp->rq_vers;
 		rp->c_key.k_len = rqstp->rq_arg.len;
-		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
 		rp->c_inflight = 0;
 		rp->c_pos = 0;
@@ -376,68 +372,10 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
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
 
@@ -461,7 +399,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
 		parent = *p;
 		rp = rb_entry(parent, struct nfsd_cacherep, c_node);
 
-		cmp = nfsd_cache_key_cmp(key, rp, nn);
+		cmp = nfsd_cache_key_cmp(key, rp);
 		if (cmp < 0)
 			p = &parent->rb_left;
 		else if (cmp > 0)
@@ -490,28 +428,23 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
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
+ * On a miss, the entry created for this call is returned in
+ * @cacherep. On a hit, the cached reply is encoded into @rqstp's
+ * response.
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
@@ -525,13 +458,11 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
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
 	if (!rp) {
 		svc_xprt_recv_done(rqstp);
 		goto out;
@@ -587,6 +518,13 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	if (rp->c_state == RC_INPROG)
 		goto out_trace;
 
+	/*
+	 * The connection that carried the reply delivers it, so a
+	 * retransmit on that connection needs no replay.
+	 */
+	if (rp->c_pos && rp->c_xprt == rqstp->rq_xprt->xpt_id)
+		goto out_trace;
+
 	/* From the hall of fame of impractical attacks:
 	 * Is this a user who tries to snoop on the cache? */
 	rtn = RC_DOIT;
@@ -762,8 +700,6 @@ int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]));
 	seq_printf(m, "not cached:            %lld\n",
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]));
-	seq_printf(m, "payload misses:        %lld\n",
-		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]));
 	seq_printf(m, "longest chain len:     %u\n", nn->longest_chain);
 	seq_printf(m, "cachesize at longest:  %u\n", nn->longest_chain_cachesize);
 	return 0;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 562bb06bb1ef..f504a9386557 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -1074,7 +1074,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	const struct svc_procedure *proc = rqstp->rq_procinfo;
 	__be32 *statp = rqstp->rq_accept_statp;
 	struct nfsd_cacherep *rp;
-	unsigned int start, len;
 	__be32 *nfs_reply;
 
 	/*
@@ -1083,13 +1082,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
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
 
@@ -1103,7 +1095,7 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
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
index ad31d36c7c8d..f37f537f12fe 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1687,30 +1687,6 @@ TRACE_EVENT(nfsd_drc_found,
 
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
2.56.0

