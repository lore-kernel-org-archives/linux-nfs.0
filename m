Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2237451AFFB
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752111; cv=none; b=pU0gJJJxMGff2X53wfaaHvvB/djMmGvG/JzG+NWO/mWMgxpH8lrJTxThGYrFMfJDSmd/X1AizqvRaOsWBltCbgQ6dQsIEOptjtirLpMK/S4ts3/nOC6K6OakPGUP228Snwrhlf6MnQBte5E/8uEyJ4uQRZRDVwBAY4GbjlenDc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752111; c=relaxed/simple;
	bh=RIynJ3UKXvsrQQ/wk4UTruQwzcoh9g7LoLs7Q02WonY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WRtrPheiKU8bjMuvqSjGCGkkrH0wVTSFuBqr1kWfSqvq2qF3RpCP5yQuwsBe8VDR8flWYEVjhYKHwzZGpmX0k81niGWHxMlr7nnqo5F82JzWPtyV/xbBXmlMrpExOeuwhR/mybX31h6tel/46tKDDJW1POvFdX4SQzuBdbFyiJw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nfJInSLh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nfJInSLh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5BCE71F008A0;
	Fri, 18 Sep 2026 17:21:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752096;
	bh=3npkeVuPgBtxvbz/upGPypmyOxrUu11p+PKqsfp2qKM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nfJInSLhvS2jM1i0QsnygS4M4dKcfqghPmb2KAbFGWzyAphetckH9wpaOdgNTdkBI
	 aQZ/MRldGMqXGXsH7k6tqbonn5bZVah+StAOLR2xdNgvEJPXCSIwzxMfuKH1zzHknr
	 YDlIdIh2tweiuch26mGzy7vdfp6nultjJoNfPVUv8UJkgOzLecrUobp4//U6Pna6OO
	 dW2stdziOBHkE6DIWZdw8lNIT2jN/CSwIVxa6Zis/kYtxVBkTl71ni2L0en7vxrMyx
	 FvwLHqHTQdsDupRRwYEkfC1d2ZtqOsULmLIkGVZX3nQAycs7PbCMXP0SbyXCTOPlDD
	 7065FV/1/JlyA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:22 -0400
Subject: [PATCH v5 10/11] NFSD: Evict acknowledged DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-10-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=10108; i=cel@kernel.org;
 h=from:subject:message-id; bh=RIynJ3UKXvsrQQ/wk4UTruQwzcoh9g7LoLs7Q02WonY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWb+abQFfWdgHOAARlOMHBRmzInVsIE1rkS
 X8FLxw5L6CJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 lwNBD/96cLjdUEp1t/y3aANf8RvXNf+KDVHBxAlC7BL6nWm2sQxQ+wY1wIf3nvktDucPACuCbvr
 z8Jw8i3OjWcNzsiESzzqpG605sm0u7R7GB3Y8CsfBh2pI2f3kaxjRfTBfdzHiCyerSc6vbHfYX0
 YZcHsergf1QeYES9B3EooSYtfSxKifvnLwhWLH7bsGf21wf2NDS+ODfO4otGJI7Fl2ionEx64mZ
 ePy0h5ak/ifG47QUTamMw2yiZ62O5LDT/OlOUWpDaYqSQZROlLkdZFgdX/+m0Iibd0DR11x4Z61
 HgxA1SpJTYpGZDE0quRfD0+5WztTv+MPzlXBXwc9x54QsRb4jxIZm30yexaqywOOfepocAAXls9
 fdnRFYYtkxDKl/wsKq0+XZfiq9//fOSDfsWGjKd8gWR5R0iAVNRuRCSIx9zCQfLupd0ZOV3KNqt
 x2Zcg/ggdDLHeHVOmN95ysYgNSgQKseW0a08Z6bEDkDhx7K4BT+Ksslc3P9XpnkMiC8rOg96LOp
 IYHwQjo1iix+xUWtcZG/GC93mJRKS+api8KRj5JCI4No81AE0jTndbRA240ONNOpa5juR/XUMtr
 4t9U4cpQKuMbog5x2kgcC9TOBe2LGnXoc2BYvbso5jpN515L91W9lXef5im+CRXXHT7t53cn7lN
 RurHpe4GoqOm4sA==
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
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h    |  6 ++++-
 fs/nfsd/nfscache.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h     |  3 +++
 fs/nfsd/nfssvc.c   |  1 +
 fs/nfsd/trace.h    |  1 +
 5 files changed, 75 insertions(+), 4 deletions(-)

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
index cd1011bd148d..41b8098d3528 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -113,6 +113,8 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
+		rp->c_inflight = 0;
+		rp->c_pos = 0;
 	}
 	return rp;
 }
@@ -259,13 +261,34 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 	return &nn->drc_hashtbl[hash];
 }
 
+static bool
+nfsd_cacherep_acked(const struct nfsd_cacherep *rp,
+		    const struct svc_xprt *xprt)
+{
+	return rp->c_state == RC_DONE && rp->c_pos && xprt &&
+	       rp->c_xprt == xprt->xpt_id &&
+	       rp->c_pos <= atomic64_read(&xprt->xpt_acked_pos);
+}
+
 /*
  * Remove and return no more than @max expired entries in bucket @b.
  * If @max is zero, do not limit the number of removed entries.
+ *
+ * @xprt is the transport of the current request, or NULL when the
+ * caller holds no transport. Only entries that arrived on @xprt can
+ * be evicted as acknowledged: the caller holds a reference on that
+ * transport alone, so it is the only xpt_acked_pos safe to read.
+ * The walk stops at the first entry that has neither expired nor
+ * been acknowledged, so an acknowledged entry behind it stays until
+ * that entry expires.
+ *
+ * An in-flight entry is never evicted: its svc_rqst still points to
+ * it and nfsd_cache_reply_sent() will write to it.
  */
 static void
 nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
-			 unsigned int max, struct list_head *dispose)
+			 unsigned int max, struct list_head *dispose,
+			 struct svc_xprt *xprt)
 {
 	unsigned long expiry = jiffies - RC_EXPIRE;
 	struct nfsd_cacherep *rp, *tmp;
@@ -275,6 +298,12 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
+		if (rp->c_inflight)
+			continue;
+		if (nfsd_cacherep_acked(rp, xprt)) {
+			trace_nfsd_drc_evict_acked(nn, rp);
+			goto evict;
+		}
 		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
 			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
@@ -338,7 +367,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 			continue;
 
 		spin_lock(&b->cache_lock);
-		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
+		nfsd_prune_bucket_locked(nn, b, 0, &dispose, NULL);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -512,7 +541,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 		goto found_entry;
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
-	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
+	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
 	spin_unlock(&b->cache_lock);
 
 	nfsd_cacherep_dispose(&dispose);
@@ -590,6 +619,7 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 		       int cachetype, __be32 *statp)
 {
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	struct nfsd_drc_bucket *b;
 	int		len;
@@ -636,10 +666,42 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
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
index a145294c59c8..0ae78ed00da4 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -53,9 +53,12 @@ extern atomic_t			nfsd_th_cnt;		/* number of available threads */
 
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
index c04ef9d180ce..6fc54399cb90 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -634,6 +634,7 @@ int nfsd_create_serv(struct net *net)
 		percpu_ref_exit(&nn->nfsd_net_ref);
 		return -ENOMEM;
 	}
+	serv->sv_reply_sent = nfsd_cache_reply_sent;
 
 	error = svc_bind(serv, net);
 	if (error < 0) {
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 631682a76f9c..7abd46e8a752 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1596,6 +1596,7 @@ DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
 
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_acked);
 
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(

-- 
2.55.0

