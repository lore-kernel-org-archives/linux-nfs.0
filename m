Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801489;
	b=cTcpC067Tsi4J24SBosbFiG2c6cgBk/bUOOstrDvvR9yAT8jjWPW/ocl42MXFpAzDsoa
	 efJY0+8eC03WouF3L4iEzctXCP2fAhTCHuxXOMd1+Lu5vaYh9zA61vMqZ2s+p/M564474
	 Dd/8VENcBcWsWGKPjgqdIhDJAAVbLOM6eOcjTNT3eITENyNjs1xhk7/8us1vSLlZlBPQg
	 ddS6Ye23R+MgJCFX1SEGov7g0H1SjO4RVf0pe1cqD56rRpBw96hJkNbrnUOa4osHGKThW
	 3qLfrgx/f3Knugpryq9oJhQGbClfw+2pojB7FDe73TAbVl9bvvSv+7MFKV9DYNstOBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801489;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=H8BmcnzMiczpttE9N+WOKJQ5URVbokrYa0ycESGQ1tU=;
	b=tuaZMLEFpNd1tzTNRcrBZtIe5qk1ODNtj4UIKz7+yfghkzWqbssbAB6xiaI9XSyQqIvB
	 l0TBFaJUwOjoXTUoKPJ2cl0EAiu6fC0UDzQPTP/F3pc1GPa2zRXEgcEzrsIET51y3QIEm
	 +CBhDA/XAumCRxwSW4koxo/yBmK8wHQYm2WSQKLaEgidarZhaBn23G+ORZT82+2H/CmFp
	 kp9iW5503qfZmEbfzK6FosT0+gSCDU4b6zKbFS2k6HBrXJGXCYUIZi5II/+ukNXVQ33yy
	 yxdB0HY+TKU6ivKljKr43HgE/N6WJbyh2RDWiSwLG91b5Uu/UacyCNk7e1mWzIbqRuA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E6P9bnsm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4062A6082BC5;
	Wed,  4 Nov 2026 14:11:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E6P9bnsm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B3E61F000C1;
	Wed,  4 Nov 2026 14:11:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801489;
	bh=H8BmcnzMiczpttE9N+WOKJQ5URVbokrYa0ycESGQ1tU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E6P9bnsmMT1s2E3lYOj/LZUol3FV2Nvo2w/ghOf6PXrKhU/G+igVsZQB6VgqK+CSH
	 IadDnjzm29eWPH3U93laXPeoO3hMyoDiN4glnwFSl2A+MykfeqlEgjNmhU86/aW/Ia
	 efOCCUYK0v6trooaviYAnWGD8h+yEH3pLjfJ/y6vx611ofdDzLv9b36WM8qXbdKVix
	 0HksRx4D6BVjBUsCD6iAwGSWXQtDBZKdqV7v+2NWj/2gqTnOs2tljNI0L5aXkZ91xG
	 +b586cT6Vyn48D4FGAxIkq8bc/4r2SLHYe29M0BpGit/zFBrMhM989Pfpsk8YTi68m
	 kq8LiqRi4WCJA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:12 -0500
Subject: [PATCH v8 12/14] NFSD: Evict acknowledged DRC entries
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
Message-Id: <20261104-duplicate-reply-cache-v8-12-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=13172; i=cel@kernel.org;
 h=from:subject:message-id; bh=X3OflmFLzvwPOhi9Y0tvYwh4MRYPEpiIY0hwUSGw/FE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0BVFTIY0jkYvq+cAZw1QwyP0vFrGN+haHL4
 35f1TrJlCqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 l2p8D/9ONEYDiRyLwJT6sHrAzCI0vCGwdKl2heqO4VDNrQIOP0gOSC3Xfbua+rKrzysDrzN7e4K
 VUNLIqJCGlsz7CisW0iwuI4SmoNIldED2vORtlPxGOw5RIaHdrea99mk1s9O+WnM98sHdtZmhrC
 ShIAQQvBfsUPd8IN6/8s6RJNS2i8gMPZsnn70Fl8D5Qsfogj5sUoTSGC5bv/hcEx5FVCs+sFV90
 9KAMUJ7ocVz5nYiM4XEadW15IItvWwqG/NdOdouB6ilLL+bSFOQGF6c4gA9Rvz4rJC/knPadRBD
 fmr6hyB/68NyMNdxiv9RZOx+clqSd0MP8LP27pXC+MS796ePHwbw4nqkO/5nwrr7ZbpbR/lYcSe
 mNPIcyxOXl0Jng5YZ7slDFboIpvSo9+2gLlNkdTLnZZCZUM06Q6rQnl4j49qxmqqlmVTvRKzpM9
 HE5sJSFEwqE4zkNDZlOea+T1mNiPj0UEuikNtBdV7Yc40FZ1by5Me3MOOxZrPck95Nvw+JLEUE8
 0X9XwkvoJac7iQUFGmxN/y4Ury7zawOPTYi5RSLWLHYYEQ5J0WKB635Z0BioFLJnxDr+qLohgwY
 4wlERdaBkXLt3K9ZU6k5orBnRg8xn7ivPLpDdJ2/jh4UYdZ3ISzWv1UZnoUlD0k1UGLNB0T4KB1
 H35Q6lvsrFTHw0Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A duplicate reply cache entry exists to answer a retransmit. Once
the client has received the reply, no retransmit of that XID can
follow, yet the entry stays in the cache until RC_EXPIRE elapses or
memory pressure forces it out. On a busy server the cache is mostly
replies the client already has.

Record each reply's transport position in its cache entry from the
sv_reply_sent hook, and compare it with the transport's acknowledged
position when a later request prunes the same bucket. An entry whose
position the peer has acknowledged is evicted before the age and
pressure checks run. Only entries that arrived on the current
request's transport are compared: the prune holds a reference on
that transport alone, so its acknowledged position is the only one
safe to read. The shrinker passes no transport and never evicts on
this basis. Entries from other connections interleave with this
one's in every bucket, and none of them can be acknowledged from
this request, so a walk that stopped at the first unexpired entry
would reach this connection's acknowledged entries only when they
are the oldest in the bucket. Past the first unexpired entry the
walk therefore continues, testing only for acknowledgment, to the
end of the bucket. The hash table is sized for a bucket of about
TARGET_BUCKET_SIZE entries, so the scan is short, and the shrinker,
which passes no transport, still stops at the first unexpired
entry.

Read the acknowledged position through svc_xprt_acked_pos() before
taking cache_lock, since the transport may sleep, and report the
lookup with svc_xprt_recv_done() under the lock, after the insert. A
prune by another thread on the same bucket runs under the same lock,
so the prune either sees this request still counted or runs after
the request has found its entry. A position the transport vouched
for before the lock stays safe under the lock: a retransmit arriving
later follows the acknowledgment.

A transport acknowledgment means the peer's transport holds the
reply, not that the RPC layer above it has read the reply. Two
retransmits can therefore find the entry already gone. A client that
discards unread socket data when it resets a connection retransmits
the call over the new connection. A client whose RPC timer fires
after the reply was acknowledged but before its RPC layer read it
retransmits the call on the same connection. The same-connection
retransmit executes the call again, but TCP delivers the first reply
ahead of the second, so the client completes the call with the first
reply and discards the second as an unknown XID. The re-execution is
visible only to a third party that reused the name in between. A
call still in progress when its retransmit arrives has sent no
reply, so its entry is not acknowledged and the retransmit is
dropped as before. Retention therefore ends at delivery rather than
at consumption. Only NFSv4.1 sessions close that gap.

A call read before its connection closed can still be stalled ahead
of its lookup while the retransmit on the new connection runs and
the retransmit's entry is acknowledged and evicted. The original
call then misses and runs the procedure again. No reply to the
original can reach the client, so drop a cacheable call at lookup
when its transport is dead. A call on a transport whose close NFSD
has not yet seen still runs. The per-transport accounting does not
cover that call.

Between nfsd_cache_update() and the hook the entry is pinned against
eviction, and the nfsd thread keeps its pointer in thread-local
state. Every nfsd_dispatch() path that leaves an entry in RC_DONE
returns 1, so svc_process() runs the hook whether it sends the reply
or drops it after svc_authorise() fails, and the pin is always
cleared. The drop and encode-error paths update with RC_NOCACHE,
which frees the entry without pinning it.

A reply that never reached the wire, or that went out over UDP,
keeps position zero and is retained for the full RC_EXPIRE interval.

Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-11-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    |   6 +++-
 fs/nfsd/nfscache.c | 104 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h     |   3 ++
 fs/nfsd/nfssvc.c   |   1 +
 fs/nfsd/trace.h    |   1 +
 5 files changed, 109 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 589ffe4762d5..894e0b61cbfc 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -36,8 +36,11 @@ struct nfsd_cacherep {
 	struct list_head	c_lru;
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
-				c_secure : 1;	/* req came from port < 1024 */
+				c_secure : 1,	/* req came from port < 1024 */
+				c_inflight : 1;	/* reply cached but not yet sent */
 	u64			c_xprt;		/* svc_xprt that carried req */
+	u64			c_pos;		/* reply's position on c_xprt;
+						 * 0 = never acknowledged */
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
@@ -88,6 +91,7 @@ int	nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 			  unsigned int len, struct nfsd_cacherep **cacherep);
 void	nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 			  int cachetype, __be32 *statp);
+void	nfsd_cache_reply_sent(struct svc_rqst *rqstp);
 int	nfsd_reply_cache_stats_show(struct seq_file *m, void *v);
 
 #endif /* NFSCACHE_H */
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 453ff718ff6c..d7120854dfad 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -112,6 +112,8 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
+		rp->c_inflight = 0;
+		rp->c_pos = 0;
 	}
 	return rp;
 }
@@ -258,22 +260,53 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 	return &nn->drc_hashtbl[hash];
 }
 
+static bool
+nfsd_cacherep_acked(const struct nfsd_cacherep *rp,
+		    const struct svc_xprt *xprt, u64 acked)
+{
+	return rp->c_state == RC_DONE && rp->c_pos && acked &&
+	       rp->c_xprt == xprt->xpt_id && rp->c_pos <= acked;
+}
+
 /*
  * Remove and return no more than @max expired entries in bucket @b.
  * If @max is zero, do not limit the number of removed entries.
+ *
+ * @xprt is the transport of the current request, or NULL when the
+ * caller holds no transport, and @acked is the position
+ * svc_xprt_acked_pos() returned for it, or zero. Only entries that
+ * arrived on @xprt can be evicted as acknowledged: the caller holds
+ * a reference on that transport alone, so it is the only position
+ * safe to read. Entries behind the first unexpired one are younger
+ * still, so from there the walk evicts only acknowledged entries,
+ * which can sit anywhere in the bucket behind other transports'
+ * entries.
+ *
+ * An in-flight entry is never evicted: its svc_rqst still points to
+ * it and nfsd_cache_reply_sent() will write to it.
  */
 static void
 nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
-			 unsigned int max, struct list_head *dispose)
+			 unsigned int max, struct list_head *dispose,
+			 struct svc_xprt *xprt, u64 acked)
 {
 	unsigned long expiry = jiffies - RC_EXPIRE;
 	struct nfsd_cacherep *rp, *tmp;
 	unsigned int freed = 0;
+	bool acked_only = false;
 
 	lockdep_assert_held(&b->cache_lock);
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
+		if (rp->c_inflight)
+			continue;
+		if (nfsd_cacherep_acked(rp, xprt, acked)) {
+			trace_nfsd_drc_evict_acked(nn, rp);
+			goto evict;
+		}
+		if (acked_only)
+			continue;
 		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
 			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
@@ -282,7 +315,10 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 			trace_nfsd_drc_evict_expired(nn, rp);
 			goto evict;
 		}
-		break;
+		if (!xprt)
+			break;
+		acked_only = true;
+		continue;
 
 evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
@@ -337,7 +373,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 			continue;
 
 		spin_lock(&b->cache_lock);
-		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
+		nfsd_prune_bucket_locked(nn, b, 0, &dispose, NULL, 0);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -488,8 +524,10 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	LIST_HEAD(dispose);
 	unsigned int entries;
 	int rtn = RC_DOIT;
+	u64 acked;
 
 	if (type == RC_NOCACHE) {
+		svc_xprt_recv_done(rqstp);
 		nfsd_stats_rc_nocache_inc(nn);
 		goto out;
 	}
@@ -501,17 +539,40 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	 * preallocate an entry.
 	 */
 	rp = nfsd_cacherep_alloc(rqstp, csum, nn);
-	if (!rp)
+	if (!rp) {
+		svc_xprt_recv_done(rqstp);
 		goto out;
+	}
+
+	/*
+	 * Read before taking cache_lock: the transport may sleep. A
+	 * position vouched for now stays safe to act on under the lock,
+	 * since a retransmit that arrives later follows the
+	 * acknowledgment.
+	 */
+	acked = svc_xprt_acked_pos(rqstp);
+
+	/*
+	 * No reply can reach the client, and the retransmit on a new
+	 * transport may already have run and had its entry evicted. The
+	 * test follows both sleeps above so a close during either is seen.
+	 */
+	if (svc_xprt_is_dead(rqstp->rq_xprt)) {
+		nfsd_cacherep_free(rp);
+		svc_xprt_recv_done(rqstp);
+		rtn = RC_DROPIT;
+		goto out;
+	}
 
 	b = nfsd_cache_bucket_find(rqstp->rq_xid, nn);
 	spin_lock(&b->cache_lock);
 	found = nfsd_cache_insert(b, rp, nn);
+	svc_xprt_recv_done(rqstp);
 	if (found != rp)
 		goto found_entry;
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
-	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
+	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt, acked);
 	spin_unlock(&b->cache_lock);
 
 	nfsd_cacherep_dispose(&dispose);
@@ -589,6 +650,7 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 		       int cachetype, __be32 *statp)
 {
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	struct nfsd_drc_bucket *b;
 	int		len;
@@ -635,10 +697,42 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 	rp->c_secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
+	rp->c_inflight = 1;
+	ntli->ntli_cacherep = rp;
 	spin_unlock(&b->cache_lock);
 	return;
 }
 
+/**
+ * nfsd_cache_reply_sent - record a reply's transport position
+ * @rqstp: RPC transaction whose reply phase has just ended
+ *
+ * Installed as the svc_serv's sv_reply_sent hook. A transport that
+ * does not publish positions (UDP), or a reply that svc_process()
+ * dropped after dispatch, leaves rq_reply_pos at zero, and the entry
+ * is then never evicted as acknowledged.
+ *
+ * Context: nfsd thread context. Takes and releases cache_lock.
+ */
+void nfsd_cache_reply_sent(struct svc_rqst *rqstp)
+{
+	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
+	struct nfsd_cacherep *rp = ntli->ntli_cacherep;
+	struct nfsd_drc_bucket *b;
+	struct nfsd_net *nn;
+
+	if (!rp)
+		return;
+	ntli->ntli_cacherep = NULL;
+
+	nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	b = nfsd_cache_bucket_find(rp->c_key.k_xid, nn);
+	spin_lock(&b->cache_lock);
+	rp->c_pos = rqstp->rq_reply_pos;
+	rp->c_inflight = 0;
+	spin_unlock(&b->cache_lock);
+}
+
 static int
 nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
 {
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 8b4bed37b46b..b4c8cafbe373 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -52,9 +52,12 @@ extern atomic_t			nfsd_th_cnt;		/* number of available threads */
 
 extern const struct seq_operations nfs_exports_op;
 
+struct nfsd_cacherep;
+
 struct nfsd_thread_local_info {
 	struct nfs4_client	**ntli_lease_breaker;
 	int			ntli_cachetype;
+	struct nfsd_cacherep	*ntli_cacherep;
 };
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d945944c1514..d32c70e31f8b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -697,6 +697,7 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 		goto out_put;
 	}
 	serv->sv_tls = true;
+	serv->sv_reply_sent = nfsd_cache_reply_sent;
 
 	/* svc_bind() reads this, so set it first. */
 	serv->sv_no_rpcbind = no_rpcbind;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 41a9407e3efa..dfb784a39712 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1748,6 +1748,7 @@ DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
 
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_acked);
 
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(

-- 
2.56.0

