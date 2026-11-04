Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801491;
	b=DTxaiPK8PgAkBnol5AUiOLFwsnu3p3krj5ypqJXke7gXTbPMbY8JFtjbJNp07kDLvNVX
	 MLo2nez0WLMn8MdHZ9zoSEr23Bp/EXIywxTEuwyq107+HuP/1TRzbWgxnCbV8DbUtEtpY
	 xp/ikJSkE+lf4owWGifK2FlskQILHUxe2XP5btXEoZGOvsMRK8ZbHgX0SfKYA+vO7bT19
	 r1cLhnnIfxwntTe0YsEhXx8coKLVIMNM7zbo9j17dozN9Frbiuhr1ATXkq9FJhNsG7vdw
	 cdI4ZWVrTkeDMMfKu5R41c9ZP9BPIj33tetDr1+ay/htY6yV6CNS43lXjLGjIM5DW8g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801491;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GAnmGwWsXq3H+XRclpeFYBDDHnAEZmk4z6p4k2ZYUKY=;
	b=XiTjPRcjP94/QuQW5VJbJWI0ih2dqiO6BrCEYZFwLIaAuCZ7wGTRu1VXyiRo884dHltU
	 kcUMphcjxsesoES7HNdvOtv8zky6ysmB7+xEdJII873ncHiVkOcgf+UCvd5q7w9EbFKGR
	 57204ezFtxrPq1Ahpl6OFhQlxkOodqw/wbred3XH6BhVrRVXi/FctAbohslOi4XYuYD3n
	 JqMvbA1FLewu5qZIt1UOigmcSYNDsobuLng10MPl26Y5pLsVklmFErwpKDIYeWe4pKrL/
	 Ip3Mgjd0/7jMFiFd234AWnjpcaITJHRTVuoAqnyqxDwi9rAsVTHO7A8POciy+ZPqcNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kQOIfJJQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8893C606D825;
	Wed,  4 Nov 2026 14:11:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kQOIfJJQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 57FF71F00A16;
	Wed,  4 Nov 2026 14:11:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801490;
	bh=GAnmGwWsXq3H+XRclpeFYBDDHnAEZmk4z6p4k2ZYUKY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kQOIfJJQX4wGl7P+x8uP1OdTy5C/k5NamIE2QUfLK5tAgE0TmJalVeyLT5Erhd2eU
	 xH1oRSCnPuYS3es0JaksY4bTyPUs6YLdVoNoXi3zoGcg+H6sLi14O9iPqLa8KnMzMY
	 iQK9qIMFj1y5PaLp8tNuAPNxHR9sNIck1QXjIF4nxo+RwMRq1zV+v7wuPEtUPkpP60
	 GcAvjsHLimMNLgS6BSSDkakGpldM9UBdY1OMQ1KMeTmyl8uV8phy3JW5LlJ+erURfJ
	 Mf8fv9JsV+LzfBypie8CeFqozdoX6vNgLblB8UT7BbMS5oJCfM+4tMSEVGV7D3ElNu
	 jDtqNehL09JYw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:13 -0500
Subject: [PATCH v8 13/14] NFSD: Remove DRC checksum and payload_misses stat
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
Message-Id: <20261104-duplicate-reply-cache-v8-13-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=15169; i=cel@kernel.org;
 h=from:subject:message-id; bh=zBIC+Pi5KI4m/qsnFGWRnpWXg2/SuwwCXID5RHO5o/Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0BaxxgHz6wz7uwe0qfGIs3NZe8RS23dbhWT
 VpRHniiTeqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 l5b3D/98tqSCxd1O81OgEskIrpRwNLFhAZV2AYuuK35mm0fTbPBWy3ErHvjpUH2qj/5qXTtq5Dh
 kCnhizjYGw6v0/nQZyxiaw0E3qemTbYjneTGCifsie0fjPsNYoJpy1yVOvzUmlMjsgV87U/b8O9
 +nOvP/oFVXSNiRYtuUHRMs9f15gxkiiZjW/1YXa3om4UpEW+xuRhPL+qN6wJ9acrN4Zunr0P5UN
 1hV3h4fLiUOrtVFH5NZ5Nz3HmmYzXCv+6UlbVJkXI3J5+2KqCpZaFosw4qHZF2g7PzHoNx7s6uh
 lIbByHLFLrdc55Piuxj3ax6x+gxUW8TcgqNbmh9EZyI7pQVg8W8JxDnugPQ8LaHn5LTEyq8xWMx
 2VqK6/naIreuaCJDAh8u6qfg1RarqD86yLRsCJJuSFP/KIK/GbJy3WNc5XqAeuMtjCvy4ux7yJB
 +5OOl+D6FcvzshtgFGvBUIQRzbxINDQ8YHACJj+ZjSUe6mnC57K6ekeBizX2qGKtzBSDDoO8p1R
 828BA+c1W/UtUapWCBkShNnm/JEyW8hvXIZBgSATxB7kmrykbL/2CeqJJEcu3gNlQVM5BdgViYh
 19R7FUYfYiuUlWcgyIa2m9YA8bYcIkGgCN9I5ooPswBNvkiweO5ecsZk9OqTjwJHHLL8T8gBdkU
 9ferkovBv2Z4I9Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_csum() costs CPU on every non-idempotent request. It also
prevents the use of zero-copy RDMA receives for WRITE and SYMLINK
because the payload must be in the server's memory before the DRC
lookup can run.

Commit 01a7decf7593 ("nfsd: keep a checksum of the first 256 bytes
of request") added the checksum when a growing cache made XID
collisions easier to hit. The checksum is the only guard against a
reused XID: two calls with the same procedure and equal-length
arguments match on every other key field.

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
index 16be473f2c04..cb236636bf48 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -40,8 +40,6 @@ enum nfsd_net_flag {
 };
 
 enum {
-	/* cache misses due only to checksum comparison failures */
-	NFSD_STATS_PAYLOAD_MISSES,
 	/* amount of memory (in bytes) currently consumed by the DRC */
 	NFSD_STATS_DRC_MEM_USAGE,
 	NFSD_STATS_RC_HITS,		/* repcache hits */
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index d7120854dfad..24621db25615 100644
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
@@ -383,68 +379,10 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
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
 
@@ -468,7 +406,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
 		parent = *p;
 		rp = rb_entry(parent, struct nfsd_cacherep, c_node);
 
-		cmp = nfsd_cache_key_cmp(key, rp, nn);
+		cmp = nfsd_cache_key_cmp(key, rp);
 		if (cmp < 0)
 			p = &parent->rb_left;
 		else if (cmp > 0)
@@ -497,28 +435,23 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfsd_cacherep *key,
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
@@ -532,13 +465,11 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
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
@@ -593,6 +524,13 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
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
@@ -768,8 +706,6 @@ int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]));
 	seq_printf(m, "not cached:            %lld\n",
 		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]));
-	seq_printf(m, "payload misses:        %lld\n",
-		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]));
 	seq_printf(m, "longest chain len:     %u\n", nn->longest_chain);
 	seq_printf(m, "cachesize at longest:  %u\n", nn->longest_chain_cachesize);
 	return 0;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d32c70e31f8b..33ee0baaa140 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -1094,7 +1094,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	const struct svc_procedure *proc = rqstp->rq_procinfo;
 	__be32 *statp = rqstp->rq_accept_statp;
 	struct nfsd_cacherep *rp;
-	unsigned int start, len;
 	__be32 *nfs_reply;
 
 	/*
@@ -1103,13 +1102,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
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
 
@@ -1123,7 +1115,7 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
 	smp_store_release(&rqstp->rq_status_counter, rqstp->rq_status_counter | 1);
 
 	rp = NULL;
-	switch (nfsd_cache_lookup(rqstp, start, len, &rp)) {
+	switch (nfsd_cache_lookup(rqstp, &rp)) {
 	case RC_DOIT:
 		break;
 	case RC_REPLY:
diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index d88d2229a4c7..6b95651cd55f 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -130,11 +130,6 @@ static inline void nfsd_stats_io_read_storage_add(struct svc_export *exp,
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
index dfb784a39712..fc70f542c40b 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1688,30 +1688,6 @@ TRACE_EVENT(nfsd_drc_found,
 
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

