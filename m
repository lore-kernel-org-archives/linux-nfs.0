Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 960A7492E57
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048504; cv=none; b=tJliMkAwH39LvBDJb4MfMKGFYLs55/AiDRq6wT0flssTY2V3m8DG6Tl0JxCCvJgnbkVRy2YzbVHxpWI1Kql+sORKDRmm/39ZxVe+PtpeCEAEp1colp8leQg3IVWzJdZhwhvgCIxOeJJnEFQGsxSgaK0LG2vXj+2gBkJZ9GlDPO0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048504; c=relaxed/simple;
	bh=H9XQetABM3xZbUtvivcF/+1IOXStqL2EtRsash9p0fM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=bwbO9G0Vx45eOCYSyK5T3niSkANYg3txF9R86tLUnTbwAp8QRffYPObrYzttM2AWLOnjn3l8R++bixhbss5vA4hfdQPawEIaxlm22goPhvsIWf6Xm74s6V8wVK5/UtgU/7zo9sivyt0MON3vRNwFcB9H3zXJrtOdrlXGmnjVrjA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ITDKZXK1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ITDKZXK1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF3BA1F000FF;
	Thu, 10 Sep 2026 13:55:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048502;
	bh=vlRQsaO58CgKWIZFdIN3RbnEsqIq0aSPi+VXK2gLAFM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ITDKZXK1n4qIjKD5bQUQip399mQXQDb7SmYB02CILFV+YsReuRPOAIPYKiCPtKHNS
	 p1EHbExYv8ZkkA365MW0dfeck8uuk/qSxZTVRwjJlCRmD+mYt6rfarClGOsebhudlJ
	 4FzxhRb96gE4Ne8bxJo/1J+mG5JY0mdMlbGwgrtENvtivMitfg3ehBvUhODQaT+Va+
	 DAqhYoUgCBGm326ghl1bxR52ydBBU6R5Ge1IwdxMAdtFAMc0an3MHOYyGjapmybUqV
	 QslNeLZPKgNrOqEyLNCs/LFcK0zgd9eVDPpkNO6wretk/nim8CQMTUvmvuYdJgHU02
	 ylkhD1knF905w==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:46 -0400
Subject: [PATCH v3 06/12] NFSD: Add reply-acknowledged callback
 infrastructure
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-6-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=14948; i=cel@kernel.org;
 h=from:subject:message-id; bh=H9XQetABM3xZbUtvivcF/+1IOXStqL2EtRsash9p0fM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqoraw2k8AezjPMlCs7ogCwaLh/zWCXvoyiTbc+
 nfByOVUptqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 l+HYEACprOhnuYNLEs13pOwqG989d8IVZ3ADt4rTQNvVCacGdkI0Y7lyiHnx5NX3L8q8+L45U7A
 0KOTeFqRZZ3nd+SPJC04p2rWvObfDZPfKMb94ItM0Kj2l4wJJIHZCLcIWtpKQ7Nco7AZyJhUjC4
 vVa0h0hpvw6xxeedKQZNWEONf+BCU/cFASqn6hm4QbGHcvlfOA1hCqmcYD7pBLgw2dn/Wq3VC5t
 JsvCfbekt5HYHYzjDI1fIkAIKiDlUKBIaMPgRzxBBsZzcfZNCkRkKnv2/juxMBojjSA60b7Ppgu
 XobduGtCvvx8ysqkOML9j2Ho9/PRXQu1awKN5cZCU4mIb76bUGf+lfWQt4oqT0jZI/zVD4fn1HV
 foCB4cMMtkdZNZaaur5fCfDFyJSNMg29j+iqwyyur4lyJnrNMcbifRscB5q4g3klfoaGHkgeMKA
 tWEc5GOXM1yvuTEV+I3h0ykq6WlM46imQSvFmhPllR27kfseKWFn72rPApJtlMtk0PmlSaemcyh
 jtMXM+1YgwLEedVrAI48Wi4ZL8BQtV2tTSNKoEoLdiEOsxNTy3LM7ouhLjCJPblWOFyF7fyyijL
 hlFc816mrEuyJodswIP5p4hT9cdXsIvAC3ciSm3T2X055NIeJVxwpExQJP2wOdSw6DtQbkJLKil
 3uqNLx/It2LhFcA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC retains an entry for RC_EXPIRE whether or not the client has
received the reply. TCP and RDMA can confirm delivery, which would
allow the entry to be evicted much earlier.

Early eviction is safe because a client retransmits a request only
when its reply never arrived. Once the transport confirms the reply
reached the client, no retransmit of that XID can follow, so the
entry can never again satisfy a lookup. A reply still in flight
when a connection drops is never confirmed, so the entries a
reconnecting client retransmits against keep their full RC_EXPIRE
retention.

Add a callback and opaque private pointer on struct svc_serv so a
transport can report reply delivery without depending on NFS types.
The report carries an opaque cookie naming the entry by XID,
transport identifier, and generation. The generation guards XID
reuse: without it a stale report could mark a successor entry
delivered, evicting a reply the client never received. The handler
caps its newest-first bucket walk because a client chooses which
bucket its XIDs hash to and could otherwise pin cache_lock with an
unbounded walk.

A transport that reports on replies sets XPT_REPLY_ACK, and its
entries are marked c_ack_pending until the report arrives, so an
eviction reason that only guesses at delivery can defer to it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/cache.h                 | 10 +++--
 fs/nfsd/nfscache.c              | 86 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfssvc.c                | 10 ++---
 fs/nfsd/trace.h                 | 34 ++++++++++++++++
 include/linux/sunrpc/svc.h      | 48 +++++++++++++++++++++++
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/trace/events/sunrpc.h   |  1 +
 7 files changed, 180 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 5fbf1bc37c03..8ad23a1fcb57 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -36,8 +36,11 @@ struct nfsd_cacherep {
 	struct list_head	c_lru;
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
-				c_secure : 1;	/* req came from port < 1024 */
+				c_secure : 1,	/* req came from port < 1024 */
+				c_acked : 1,	/* reply delivery confirmed */
+				c_ack_pending : 1; /* transport will report */
 	unsigned int		c_xprt;		/* svc_xprt that carried req */
+	u32			c_ack_gen;	/* uniquifies the ack cookie */
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
@@ -80,10 +83,11 @@ enum {
 /* Checksum this amount of the request */
 #define RC_CSUMLEN		(256U)
 
+svc_ack_cookie_t nfsd_cache_ack_cookie(const struct nfsd_cacherep *rp);
 int	nfsd_drc_slab_create(void);
 void	nfsd_drc_slab_free(void);
-int	nfsd_reply_cache_init(struct nfsd_net *);
-void	nfsd_reply_cache_shutdown(struct nfsd_net *);
+int	nfsd_reply_cache_init(struct nfsd_net *, struct svc_serv *);
+void	nfsd_reply_cache_shutdown(struct nfsd_net *, struct svc_serv *);
 int	nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 			  unsigned int len, struct nfsd_cacherep **cacherep);
 void	nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 10fdc60f9bb9..b0231c659237 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -39,12 +39,15 @@ struct nfsd_drc_bucket {
 };
 
 static struct kmem_cache	*drc_slab;
+static atomic_t			drc_ack_gen;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 static unsigned long nfsd_reply_cache_count(struct shrinker *shrink,
 					    struct shrink_control *sc);
 static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
 					   struct shrink_control *sc);
+static void	nfsd_reply_ack(void *data, const svc_ack_cookie_t *cookie,
+			       bool delivered);
 
 /*
  * Put a cap on the size of the DRC based on the amount of available
@@ -110,6 +113,9 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		rp->c_key.k_len = rqstp->rq_arg.len;
 		rp->c_key.k_csum = csum;
 		rp->c_xprt = rqstp->rq_xprt->xpt_id;
+		rp->c_acked = 0;
+		rp->c_ack_pending = 0;
+		rp->c_ack_gen = 0;
 	}
 	return rp;
 }
@@ -121,6 +127,27 @@ static void nfsd_cacherep_free(struct nfsd_cacherep *rp)
 	kmem_cache_free(drc_slab, rp);
 }
 
+/*
+ * Zero is reserved so a populated cookie never compares equal to
+ * the all-zero cookie that marks an untracked reply.
+ */
+static u32 nfsd_cache_next_ack_gen(void)
+{
+	u32 gen = atomic_inc_return(&drc_ack_gen);
+
+	if (!gen)
+		gen = atomic_inc_return(&drc_ack_gen);
+	return gen;
+}
+
+svc_ack_cookie_t nfsd_cache_ack_cookie(const struct nfsd_cacherep *rp)
+{
+	return (svc_ack_cookie_t){
+		.id = ((u64)rp->c_xprt << 32) | (__force u32)rp->c_key.k_xid,
+		.gen = rp->c_ack_gen,
+	};
+}
+
 static unsigned long
 nfsd_cacherep_dispose(struct list_head *dispose)
 {
@@ -179,7 +206,7 @@ void nfsd_drc_slab_free(void)
 	kmem_cache_destroy(drc_slab);
 }
 
-int nfsd_reply_cache_init(struct nfsd_net *nn)
+int nfsd_reply_cache_init(struct nfsd_net *nn, struct svc_serv *serv)
 {
 	unsigned int hashsize;
 	unsigned int i;
@@ -210,6 +237,9 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 	}
 	nn->drc_hashsize = hashsize;
 
+	serv->sv_reply_ack = nfsd_reply_ack;
+	serv->sv_reply_ack_data = nn;
+
 	shrinker_register(nn->nfsd_reply_cache_shrinker);
 
 	return 0;
@@ -219,7 +249,7 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
 	return -ENOMEM;
 }
 
-void nfsd_reply_cache_shutdown(struct nfsd_net *nn)
+void nfsd_reply_cache_shutdown(struct nfsd_net *nn, struct svc_serv *serv)
 {
 	struct nfsd_cacherep *rp;
 	unsigned int i;
@@ -239,6 +269,8 @@ void nfsd_reply_cache_shutdown(struct nfsd_net *nn)
 	nn->drc_hashtbl = NULL;
 	nn->drc_hashsize = 0;
 
+	serv->sv_reply_ack = NULL;
+	serv->sv_reply_ack_data = NULL;
 }
 
 static void
@@ -256,6 +288,50 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net *nn)
 	return &nn->drc_hashtbl[hash];
 }
 
+/*
+ * The generation match keeps a stale cookie from acknowledging a
+ * later entry that reuses the same XID and transport. The walk
+ * starts at the MRU end of the bucket LRU, where the entry for a
+ * just-sent reply sits. The visit cap bounds the time spent under
+ * cache_lock when a client packs the bucket; an entry missed under
+ * the cap is left to the other eviction reasons.
+ */
+static void nfsd_reply_ack(void *data, const svc_ack_cookie_t *cookie,
+			   bool delivered)
+{
+	struct nfsd_net *nn = data;
+	__be32 xid = (__force __be32)(u32)cookie->id;
+	unsigned int xpt_id = cookie->id >> 32;
+	unsigned int visited = 0;
+	struct nfsd_drc_bucket *b;
+	struct nfsd_cacherep *rp;
+	bool found = false;
+
+	b = nfsd_cache_bucket_find(xid, nn);
+	spin_lock(&b->cache_lock);
+	list_for_each_entry_reverse(rp, &b->lru_head, c_lru) {
+		if (++visited > 4 * TARGET_BUCKET_SIZE)
+			break;
+		if (rp->c_key.k_xid != xid)
+			continue;
+		if (rp->c_xprt != xpt_id)
+			continue;
+		if (rp->c_ack_gen != cookie->gen)
+			continue;
+		if (delivered)
+			rp->c_acked = 1;
+		rp->c_ack_pending = 0;
+		found = true;
+		break;
+	}
+	spin_unlock(&b->cache_lock);
+	if (trace_nfsd_drc_reply_acked_enabled())
+		trace_nfsd_drc_reply_acked(nn,
+					   atomic_read(&nn->num_drc_entries),
+					   be32_to_cpu(xid), xpt_id, delivered,
+					   found);
+}
+
 /*
  * Remove and return no more than @max evictable entries in bucket @b,
  * visiting at most 4 * @max entries. @max must not be zero.
@@ -272,6 +348,10 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
+		if (rp->c_state == RC_DONE && rp->c_acked) {
+			trace_nfsd_drc_evict_acked(nn, rp);
+			goto evict;
+		}
 		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
 			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
@@ -639,6 +719,8 @@ void nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
 	nfsd_stats_drc_mem_usage_add(nn, bufsize);
 	lru_put_end(b, rp);
 	rp->c_secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
+	rp->c_ack_pending = test_bit(XPT_REPLY_ACK, &rqstp->rq_xprt->xpt_flags);
+	rp->c_ack_gen = nfsd_cache_next_ack_gen();
 	rp->c_type = cachetype;
 	rp->c_state = RC_DONE;
 	spin_unlock(&b->cache_lock);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index c04ef9d180ce..d6687ffbec45 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -389,7 +389,7 @@ static int nfsd_startup_net(struct net *net, const struct cred *cred)
 	if (ret)
 		goto out_lockd;
 
-	ret = nfsd_reply_cache_init(nn);
+	ret = nfsd_reply_cache_init(nn, nn->nfsd_serv);
 	if (ret)
 		goto out_filecache;
 
@@ -404,7 +404,7 @@ static int nfsd_startup_net(struct net *net, const struct cred *cred)
 	return 0;
 
 out_reply_cache:
-	nfsd_reply_cache_shutdown(nn);
+	nfsd_reply_cache_shutdown(nn, nn->nfsd_serv);
 out_filecache:
 	nfsd_file_cache_shutdown_net(net);
 out_lockd:
@@ -417,7 +417,7 @@ static int nfsd_startup_net(struct net *net, const struct cred *cred)
 	return ret;
 }
 
-static void nfsd_shutdown_net(struct net *net)
+static void nfsd_shutdown_net(struct net *net, struct svc_serv *serv)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -427,7 +427,7 @@ static void nfsd_shutdown_net(struct net *net)
 
 		nfsd_export_flush(net);
 		nfs4_state_shutdown_net(net);
-		nfsd_reply_cache_shutdown(nn);
+		nfsd_reply_cache_shutdown(nn, serv);
 		nfsd_file_cache_shutdown_net(net);
 		if (test_bit(NFSD_NET_LOCKD_UP, &nn->flags)) {
 			lockd_down(net);
@@ -539,7 +539,7 @@ void nfsd_destroy_serv(struct net *net)
 	 * other initialization has been done except the rpcb information.
 	 */
 	svc_xprt_destroy_all(serv, net, true);
-	nfsd_shutdown_net(net);
+	nfsd_shutdown_net(net, serv);
 	svc_destroy(&serv);
 }
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index a07d3dc76f27..0af3a8231fe4 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1594,9 +1594,43 @@ DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
 	),							\
 	TP_ARGS(nn, rp))
 
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_acked);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
 
+TRACE_EVENT(nfsd_drc_reply_acked,
+	TP_PROTO(
+		const struct nfsd_net *nn,
+		unsigned int num_drc_entries,
+		u32 xid,
+		unsigned int xprt,
+		bool delivered,
+		bool found
+	),
+	TP_ARGS(nn, num_drc_entries, xid, xprt, delivered, found),
+	TP_STRUCT__entry(
+		__field(unsigned long long, boot_time)
+		__field(unsigned int, num_drc_entries)
+		__field(u32, xid)
+		__field(unsigned int, xprt)
+		__field(bool, delivered)
+		__field(bool, found)
+	),
+	TP_fast_assign(
+		__entry->boot_time = nn->boot_time;
+		__entry->num_drc_entries = num_drc_entries;
+		__entry->xid = xid;
+		__entry->xprt = xprt;
+		__entry->delivered = delivered;
+		__entry->found = found;
+	),
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x xprt=%u %s %s",
+		__entry->boot_time, __entry->num_drc_entries,
+		__entry->xid, __entry->xprt,
+		__entry->delivered ? "delivered" : "untracked",
+		__entry->found ? "found" : "stale")
+);
+
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(
 		const struct nfs4_client *clp,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 24698856eb40..8c9e27752698 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -58,6 +58,36 @@ enum {
 	SP_TASK_STARTING,	/* Task has started but not added to idle yet */
 };
 
+/*
+ * Opaque reply-acknowledgment cookie; field contents are
+ * upper-layer-specific. An all-zero cookie marks a reply that is
+ * not tracked. Cookies are copied by value under each consumer's
+ * own serialization and no field is accessed atomically.
+ */
+typedef struct {
+	u64	id;
+	u32	gen;
+} svc_ack_cookie_t;
+
+/**
+ * svc_ack_cookie_present - report whether a reply-ack cookie is populated
+ * @cookie: cookie to test
+ *
+ * Return: true when the upper layer requested tracking for the reply.
+ */
+static inline bool svc_ack_cookie_present(const svc_ack_cookie_t *cookie)
+{
+	return cookie->id != 0 || cookie->gen != 0;
+}
+
+/*
+ * Callback to report the fate of a reply's acknowledgment to an
+ * upper layer. @delivered is true when the transport has confirmed
+ * that the reply reached the client, and false when the transport
+ * has stopped tracking the reply and no confirmation will follow.
+ */
+typedef void (*svc_ack_fn_t)(void *data, const svc_ack_cookie_t *cookie,
+			     bool delivered);
 
 /*
  * RPC service.
@@ -96,6 +126,9 @@ struct svc_serv {
 						 * connection */
 	bool			sv_bc_enabled;	/* service uses backchannel */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
+
+	svc_ack_fn_t		sv_reply_ack;
+	void			*sv_reply_ack_data;
 };
 
 /* This is used by pool_stats to find and lock an svc */
@@ -106,6 +139,21 @@ struct svc_info {
 
 void svc_destroy(struct svc_serv **svcp);
 
+/**
+ * svc_reply_acked - report the fate of a reply's acknowledgment
+ * @serv: RPC service
+ * @cookie: opaque identifier for the reply
+ * @delivered: true if the reply reached the client, false if the
+ *	       transport will not report on this reply
+ */
+static inline void svc_reply_acked(struct svc_serv *serv,
+				   const svc_ack_cookie_t *cookie,
+				   bool delivered)
+{
+	if (serv->sv_reply_ack)
+		serv->sv_reply_ack(serv->sv_reply_ack_data, cookie, delivered);
+}
+
 /*
  * Maximum payload size supported by a kernel RPC server.
  * This is use to determine the max number of pages nfsd is
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c62f789e2900..ec1dcb51c2a2 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -101,6 +101,7 @@ enum {
 	XPT_LOCAL,		/* connection from loopback interface */
 	XPT_KILL_TEMP,		/* call xpo_kill_temp_xprt before closing */
 	XPT_CONG_CTRL,		/* has congestion control */
+	XPT_REPLY_ACK,		/* reports reply delivery via svc_reply_acked */
 	XPT_HANDSHAKE,		/* xprt requests a handshake */
 	XPT_TLS_SESSION,	/* transport-layer security established */
 	XPT_PEER_AUTH,		/* peer has been authenticated */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 180346e520ff..a9d42625c99b 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1931,6 +1931,7 @@ TRACE_EVENT(svc_stats_latency,
 	svc_xprt_flag(LOCAL)						\
 	svc_xprt_flag(KILL_TEMP)					\
 	svc_xprt_flag(CONG_CTRL)					\
+	svc_xprt_flag(REPLY_ACK)					\
 	svc_xprt_flag(HANDSHAKE)					\
 	svc_xprt_flag(TLS_SESSION)					\
 	svc_xprt_flag(PEER_AUTH)					\

-- 
2.55.0

