Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4A7648594F
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397155; cv=none; b=mvOgJqsZNNQZ/5gHYjYMZgN+OUe8XQeejSwpUM4WHLAqvVG9fomkLg0gpH1ypy3SHnp8lCvZPjvvj4PyxKB8k82bMpOyySGYM/7/2OnUGqcRta9saxYMY9xhTE1GBGydIiaLTWEQEZweQFCa2fazePLavoMPFMgK+OJH1qPUzEg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397155; c=relaxed/simple;
	bh=AKK/ygKbyxwzs3xdQAwDLMukSLT/mUGH8pelOa3BzxY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=X3OHs9z4RtkpvRuUU5BglCMYKWthsvWhEulvmtFLlQ+bcrG1RP7Ert/LQ5GDpkEdo0Ilf2y5aC6VRGw5Na/NGXPaGXfgMHfX0vvMzsqEFAN2ilsvEf1TelXQ+GEhkjg3ACpauzIvBGnfXCQ5Lv3gpQD7APUM2P9H2VXEwdio8Fk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Er13GMFC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Er13GMFC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ECE861F00893;
	Mon, 14 Sep 2026 14:45:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397151;
	bh=0g8UcLVhCFgN4L6zEuRioFOA9WUviyRxQECFDIEUXbU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Er13GMFCeFpMJ+cD8kyMlifZHSyFZvhBZHxlC98QckNXZG0IzWxNBLRbF50DPf/Ze
	 LAomdQ4Z2Vh5uHYk9I5vXqNoXk9wwFk2T09vVf+5RFzo584u7mm5XRWfn4sGCzkj8+
	 0vrTdQOluyP6+ZjrgY1B1k+FNtyrdQSOVp0UVorrJXQlF/3D2bKf8p+OhbTyfiMVHg
	 GbgWTRRtGALKYz+nTREt9T0G+MAShBupnHp1UFly/3yQsfNsvNi07se3ZM2cH9Ehsp
	 z8M62HloK7qkFxRhJdIdDCwkaFfWQSs1dV8Qaje6zB2go8+Cv6xB8ZMbfnnHvYO0u+
	 aiy+dessWx7Ig==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:39 -0400
Subject: [PATCH v4 09/11] NFSD: Evict acknowledged DRC entries
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-9-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=9582; i=cel@kernel.org;
 h=from:subject:message-id; bh=AKK/ygKbyxwzs3xdQAwDLMukSLT/mUGH8pelOa3BzxY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiX1mB2dK8FbJYOY+CtGjIQ1Xplj+iogavhQ
 ScqvNjuGgiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlwAKCRAzarMzb2Z/
 l2w+EACcsUDIAApZun7+7PWwMbn0fp2e/RL1NXduVldJLylnoqH29hDyNsbPSwgREAqhfQcWJ/L
 GOrhibT5CGj9G4KlN2B97sULEBh9Due42u+W53ecgdJ2dVqjHSLzL5f09af54dFpGOLnghLfnE3
 ihI5LwKHzC9fhM6gjD9bkCxhZGcxnbLsQdXAE5WOL6ySPJZNil3z5iPjYCu+kvlT58Nb6qasQ8X
 VXR++UpAetK9o5hNMz0E8bTm+Ud7+2zg7LbqwD7xJevQ1LHeP0ZKa23Y7FqwBAcGR89rlkJvdL4
 1fkluJctgklgo7SAScOPSBOUXUyA8I398/sm2hK5iWlloNB9pFl96zZ9LaHs65BH7dQv01igFty
 s7TQ2o47b715nLkgJpZYoG9Xlmn9ubuENknT46esftzf0SUp31t41lUYywSvUETVUycP2MhT1Cq
 Mc64ECYUjB7nUTxu9TVxDcTHzgvoocw/vAIL99Eq03LGc43VDpfJW+zincuLL1E2ACTW3N1kB19
 XUZJBoPmOr/Z3C+mONE2LBdeMvGSqm4IaxZZMe6hhYh33cia1tAUW4jh/gSwvuRONYWvvFHny71
 ft1K+xS60kOinosSfwgi6wvTzFYs+CXEit0SK1O+9RBq23Tes/upMbby4xt9qS7Y0+n2P97dnDs
 sVSLwQRiXsm7VqQ==
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
this basis.

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
 fs/nfsd/nfscache.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h     |  3 +++
 fs/nfsd/nfssvc.c   |  1 +
 fs/nfsd/trace.h    |  1 +
 5 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 90ecc270640c..935bed5fc843 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -36,8 +36,11 @@ struct nfsd_cacherep {
 	struct list_head	c_lru;
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
-				c_secure : 1;	/* req came from port < 1024 */
+				c_secure : 1,	/* req came from port < 1024 */
+				c_inflight : 1;	/* reply cached but not yet sent */
 	u32			c_xprt;		/* svc_xprt that carried req */
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
index e639c8c81c4d..d97eb5d43afc 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -110,6 +110,8 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
+		rp->c_inflight = 0;
+		rp->c_pos = 0;
 	}
 	return rp;
 }
@@ -256,13 +258,31 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
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
  * Remove and return no more than @max evictable entries in bucket @b,
  * visiting at most 4 * @max entries. @max must not be zero.
+ *
+ * @xprt is the transport of the current request, or NULL when the
+ * caller holds no transport. Only entries that arrived on @xprt can
+ * be evicted as acknowledged: the caller holds a reference on that
+ * transport alone, so it is the only xpt_acked_pos safe to read.
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
@@ -272,6 +292,12 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
+		if (rp->c_inflight)
+			goto next;
+		if (nfsd_cacherep_acked(rp, xprt)) {
+			trace_nfsd_drc_evict_acked(nn, rp);
+			goto evict;
+		}
 		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
 			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
@@ -343,7 +369,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 
 		spin_lock(&b->cache_lock);
 		nfsd_prune_bucket_locked(nn, b, sc->nr_to_scan - freed,
-					 &dispose);
+					 &dispose, NULL);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -517,7 +543,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 		goto found_entry;
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
-	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
+	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
 	spin_unlock(&b->cache_lock);
 
 	nfsd_cacherep_dispose(&dispose);
@@ -595,6 +621,7 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 		       int cachetype, __be32 *statp)
 {
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfsd_thread_local_info *ntli = rqstp->rq_private;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	struct nfsd_drc_bucket *b;
 	int		len;
@@ -641,10 +668,42 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
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
index 73205106b312..06d2a8bb9611 100644
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

