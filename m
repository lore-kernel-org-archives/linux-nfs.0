Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297192;
	b=oW+2Wxd38ED60mKwK9gd212kSA9NL1rhyAM/H05Aqqwm0zKmLmwJKbOhpvEFTSYDP0kT
	 bz9XmJZ6Ya1nWZpd7lz4kB5f0eD7AHJmBGQxR4tMhCeGh3uESiPuEvxf+jz2eY5itg3+h
	 TjiBa+Eo9xRyvlnem45xBe9/FQJOKBFFiNUkBa6ieYlMAVYLfTngLNfgdkoWbCZOgiaJl
	 VW54HL5zU+TX6plc1zctvVGAR+HrmoNwdRipl/YK6uQSc5QOTV362ax18H8QhhA93wp0T
	 xJAqUPQy7L1iNpcmMtURxdJD+VnLGfKIgVjT/C1RT5f2CD4p2OfT7DWTDCTJdWYqQCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297192;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9a1T8nqj45HccpiRvxijWooNqwLk5E52bZrH4yXIYJw=;
	b=VOOyF3s6R72k6vW5KSKO6r8BfXA9O/KLmW+poUgCmAe0gg9EAjCPLKQTpUBwhSe8a+ul
	 fkAJYr/TDKhdZhVMvjCQJafESJ43hMM3RD1Cso0BIDzIKvEX+t7SmmxuSc0OucBomGzPq
	 JdwYLjD+vMO56A+qN3ot3lq0dll0Mth50nBGYPk4MBuU/UyDfl/tJaM9fcxuzzLf/MvVM
	 +2woVHFLJ+wjrvkXZW6GQQ/t9QINYacx6NOEryuoMLTVDsMhvVtV0QywmvKvX6QAPSBSt
	 Qu3bgdIzbJ2uay1ZTQTpAKp2A1/v0omxIKNSdy87t3LTPfy7aZq7PqdCx7Pz/cBpd/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DPiYuYKM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A929606A330
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DPiYuYKM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0E1701F01825;
	Thu, 29 Oct 2026 18:06:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297191;
	bh=9a1T8nqj45HccpiRvxijWooNqwLk5E52bZrH4yXIYJw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DPiYuYKMaq9g9ATJXXjs5s+1Jk8gELa2/0JF1gQ7odqjgMFaHJJVxf0bZag6LlXCg
	 UmPYZ2k9ThKVjD9iKIWoWsJOrauKRblfjnQ6c4MzxepZRZQXkA9s3ZiWs2pEACgY/q
	 4KXiv7WKdkOMv2ogj0dACW2UOlVnobETeqjdCvlHV4TBhN/MxBgEyBqLYF+dta8RdX
	 nexvgpDP1VHsK9EfmmWzUaUNo9o6/PfO6xaXETW1ZNLbV9zwi9yzxemwJ4gT2AO4A8
	 n6i0rtISEn2Zia0WQXxq5ohd6IyLNXmcUyNT8mgom8Fv13Epcur0V3Epa1cHqvm587
	 MUB1WhDoEngJw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:17 -0400
Subject: [PATCH v7 11/13] NFSD: Evict acknowledged DRC entries
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
Message-Id: <20261029-duplicate-reply-cache-v7-11-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=12568; i=cel@kernel.org;
 h=from:subject:message-id; bh=cyoBFhZnVrKlF7TOFLj51yIfqg5Bomm4v0NjC3fuRxA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44schtRJaBKIZfoSDeEy276g2XkQKJvTmhkgM
 i2IWt/PwySJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l4WxD/9UW/VqPSfM3IO3y32hwYsOGizvfeUERxg8sAuDewB4J1XrXbMqjxIMaUVvX1L3wOkSil0
 yYD1TW4UUyrNSs3FYszea+siIp2pXXdo43yibFe5ruSFMzezpGSGH0NYHISv/wAwIQqxDQKNPGf
 iEbD3SMx7OwmGA6Ax90CSfzEMY7BQ1plpzGPr4roqk+995UuVhS271Rocijb3IY9b3FuVRAcHrc
 ayjtejFPRjb/YXHlOPsBjXGj0lSN3eDkbq0H493pR/LoHIGMmYYOHpTSp0p1N5RsjFAoZr7AiEx
 Lt5SXx1DAjmdejyKBMXBYsemGqCUtyvZksOVb6+emaq3W07u6RZjZEPoq++cI7oUGE1fBafBIXc
 XFl72XXiZPWWKxD6VAJYvQbZ/kFNbmBlsTZIFjbFsEPBOdLDInDVJdreHyfC+ausePFZC/ZABSl
 kgo0R2qE65pqDWaxRLEKqiWmwuxCsK95tA7KQpQYxVaZoDOyxzeoZ18EeorMlcwOJUGCDuAh5df
 xO8kM2l9jCy6SPzPCT5ESo93QROKSuE/4y+vneOtnZnoJ9yPVE1vXlcZs27rmLc3ZbF3IyP1dBj
 A1dVqLHfM8tKPl/HGGVF+gflt5/5kz/Yy6OZQCZyPcUPqcwqLqMhSSgFM3Px1ZHEHzkEtV0SFfO
 +jmXt2bVph7y/HA==
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
this basis. The walk still stops at the first entry that has neither
expired nor been acknowledged, so an acknowledged entry behind one
from another transport, or behind a UDP or TLS entry, stays until
that entry expires. Only the entries the existing walk reaches are
evicted here; a per-transport list of unacknowledged replies would
reach the rest.

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
retransmits the call on the same connection. In the second case the
call is executed again, but TCP delivers the first reply ahead of
the second, so the client completes the call with the first reply
and discards the second as an unknown XID. The re-execution is
visible only to a third party that reused the name in between. A
call still in progress when its retransmit arrives has sent no
reply, so its entry is not acknowledged and the retransmit is
dropped as before. Retention therefore ends at delivery rather than
at consumption; only NFSv4.1 sessions close that gap.

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

Assisted-by: LLM
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-11-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    |  6 +++-
 fs/nfsd/nfscache.c | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h     |  3 ++
 fs/nfsd/nfssvc.c   |  1 +
 fs/nfsd/trace.h    |  1 +
 5 files changed, 102 insertions(+), 5 deletions(-)

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
index 453ff718ff6c..a5d95fa17717 100644
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
@@ -258,13 +260,34 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
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
+ * safe to read. The walk stops at the first entry that has neither
+ * expired nor been acknowledged, so an acknowledged entry behind it
+ * stays until that entry expires.
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
@@ -274,6 +297,12 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
+		if (rp->c_inflight)
+			continue;
+		if (nfsd_cacherep_acked(rp, xprt, acked)) {
+			trace_nfsd_drc_evict_acked(nn, rp);
+			goto evict;
+		}
 		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
 			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
@@ -337,7 +366,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 			continue;
 
 		spin_lock(&b->cache_lock);
-		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
+		nfsd_prune_bucket_locked(nn, b, 0, &dispose, NULL, 0);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -488,8 +517,10 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	LIST_HEAD(dispose);
 	unsigned int entries;
 	int rtn = RC_DOIT;
+	u64 acked;
 
 	if (type == RC_NOCACHE) {
+		svc_xprt_recv_done(rqstp);
 		nfsd_stats_rc_nocache_inc(nn);
 		goto out;
 	}
@@ -501,17 +532,41 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
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
+	 * No reply can reach the client, and its retransmit on a new
+	 * transport may already have run and had its entry evicted.
+	 * Checked after the two sleeps above, so a close during either
+	 * is seen.
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
@@ -589,6 +644,7 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 		       int cachetype, __be32 *statp)
 {
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	struct nfsd_drc_bucket *b;
 	int		len;
@@ -635,10 +691,42 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
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
index b520b51692b0..0edbd4b9abae 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -51,9 +51,12 @@ extern atomic_t			nfsd_th_cnt;		/* number of available threads */
 
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
index 9151dfc8ddd9..562bb06bb1ef 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -681,6 +681,7 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 		return -ENOMEM;
 	}
 	serv->sv_tls = true;
+	serv->sv_reply_sent = nfsd_cache_reply_sent;
 
 	/* svc_bind() reads this, so set it first. */
 	serv->sv_no_rpcbind = no_rpcbind;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index b1ee0f468206..ad31d36c7c8d 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1747,6 +1747,7 @@ DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
 
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_acked);
 
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(

-- 
2.56.0

