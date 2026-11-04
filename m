Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801486;
	b=w2piOlIeScmyxJBiDXsT1N2iJ7RaKXDmDmmeULGIeIYxeriLOltUXLHR4uhX4mKSZc5g
	 QXaIK2Y4Z1flTNPBRWhRf5ptPJtQT7RQ0bulDD6gCvg6qUfSqGSpMlOJlxPCrZQrFntrm
	 fUppM4Qh32aou+k5EMGzx18a8npTo3GFtxpPeyBSXA8cD+PktSrLNrvqTad54Fp0+RtaR
	 POOUklZDiwYMTTPBQ2fJu0S2waH6W8f3/DtZycHX0wLjJGBvGVcUzX1gA9pr/1IAaoohJ
	 UZCnr5WhoSgcZPd/3edTeWHzDYAiBNbOu2Qewr/fZeTH/W1/sswcY0hH4vPOuughopQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801486;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=enY38Oq2A7kMvpKwm1AKaR2lxE1Xnu/WdFP/uy+yQhs=;
	b=dibrQYoNzFh4oDyjWkS8h8SRh2Ji7vvzW4mqm1lOY2qsh08FLjp5WSqB2mxusWHUoaVj
	 s2K3/yd7GJBhW63y8LV0ksz2ftnrN2Z4YvBJRQOI8ygtB09fWJrd9aGjyReS0IW3uJv6M
	 uMMyIvLtLmUWWmCPIiFYw779Ek42oCvmPKWdEv0uYcCyVtfnuLkDzlCQYQ7KHnc2qRDxo
	 AFuj7wJtsHbLk/LixJOYeB6Ge34aiRBB7QCRM/7NXyNiQ6qYNcjBxA72vHkIlDOo3warO
	 a3OD+UAi+0TbsqzAvkg0vp3nJ8ulhrxcHimN8t78QkRwSbTQmpO6Uoppvcnre07H19A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T2scHvA0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF6FC606EEA8;
	Wed,  4 Nov 2026 14:11:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T2scHvA0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7EB0B1F00A26;
	Wed,  4 Nov 2026 14:11:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801485;
	bh=enY38Oq2A7kMvpKwm1AKaR2lxE1Xnu/WdFP/uy+yQhs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=T2scHvA05T9qN+J3uX+KFqvfhP8SmUMdvqfid6iMPKZ1dJEIXg1BINKxzdOFU7o7t
	 Lw5Y2RBr8BaHMDXA0r6BAylXqSQbPCOrI6t8uz5beGUy56VaSYEquwYPuY2rmwiIBv
	 IbKW8HrIwbetcHa/NrwXW8wtOODwY7skMrdt68PvFqzpXBNihvuS2uS+6mRa4ZMXcz
	 ST+XPPnGggrifCHFLEdLqIi2qArg061mF/Ipj3n9bareI552FsDOjfFWBchHLsgIMH
	 zjrVZjsV53Iiv1RglEdSL9J0sPCZfdvvgEGDJzb/H9cPjPAZ72cr6NeiFFjC4iPTop
	 qiQaGSF3qS9BA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:09 -0500
Subject: [PATCH v8 09/14] SUNRPC: Publish reply positions for upper-layer
 consumers
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
Message-Id: <20261104-duplicate-reply-cache-v8-9-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=11347; i=cel@kernel.org;
 h=from:subject:message-id; bh=yfQcoMe2swRLucLwyzOJFbZqKnxmmBqDyRK0hvhc9fg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0BmQjXxx5dJXTPQOlEwh2bcY9OY+RJGSNFu
 MgJWbCuV9aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 l9n4EACFQ+4qeklYhMo5nZiL1vHrQdVu4kMGdpGjG3VCr+17AEqsnHNTO5yZk4QsPq8dRDu2SC5
 gX+GojYhoZ/M4t8wuxUW/G5im/LUQU82ysvUdseogmM41fGDuYPl0kuWvXuGt4TVUOKOoYgK+53
 zm9ne6iNLwKqMQnEA9LOY4ztXH5MxdX2m/m0n31bpj12GKV+jkG+gOWeYG3wOJcH5dO34iM3Hlx
 GyX0MrKsi1WXBm8GT07Ar+R2QUcmECIaSpYag8CUc8phGX1YBnzRsI1zDG3CqO6V3QrtQUNME4D
 QSjyKIMUwUTfY8wh62cs9Q+7Hvk2Jzmm0Q+gVesmYcBkIPrMKhd/LIj/m4BKPAK8cQRVYuBul4H
 j8sP2voPHywg+/PHp+gg7B85t/al5NWOl1vNsZMZLb6m22tgyNHkX2f8gNfVFj/wfgH7q2du7oJ
 D+pq2gVuBLWbdktsGWla49urlxdxA22RoUYjlsxOpVQGiFdLyrf2x8yQcfZHuRis3dEJjmEYhSe
 rt0RNajEOh0xHhXozi2Y/ntVsmNWn8XHcw74OUcDg8Y3gf1ZwIThqQMYO4ytgkZV6Yugu0m2Hrp
 aF+OB16kTa594ZUqFBMsKUXuz8gYx7TOIoJ7MaKiKbnVQxjBXD1bFGdEHvsP+dn1pQ2Ez5n4gD5
 P3vnbh00pc6Axgw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An RPC server's duplicate reply cache has to hold a cached reply
until the client has received it. SUNRPC gives an upper layer no way
to learn that, so a cache entry lives for the full retention
interval even when the reply was delivered at once.

Add two transport-neutral values that an upper layer can compare:
the position of each reply on its transport, recorded in the svc_rqst
by xpo_sendto(), and the position up to which the peer has
acknowledged, recorded on the svc_xprt. The units are private to the
transport (bytes for a stream, Send sequence for RDMA). A consumer
learns only whether one is less than or equal to the other. A reply
that xpo_sendto() does not hand to the wire keeps position zero and
is never reported as acknowledged.

The acknowledged position is an atomic64_t. A transport publishes it
outside any lock the consumer holds, and a torn 64-bit read on a
32-bit host could run ahead of the peer. A transport raises the
position through svc_xprt_advance_acked(), a plain read and store
that computes a maximum only while one context per transport
writes. A cmpxchg loop would make the helper safe from any context
at the cost of a locked instruction on every acknowledgment.

An acknowledgment proves the peer holds the reply, so no retransmit
of that call follows. A retransmit the peer sent before the reply
reached it precedes the acknowledgment in the byte stream and can
still be ahead of its lookup when the transport refreshes the
position: unread in the socket, or read and parked in
svc_authenticate(), which can sleep for seconds in the ip_map upcall
or defer the request. A consumer that evicts on the refreshed
position sends the retransmit through the procedure again.

Count a transport's requests from first read until the consumer
reports the lookup with svc_xprt_recv_done(), and carry the count
across a deferral. A revisited request repeats its lookup, so a
procedure that defers after the first lookup was reported puts the
request back under the count. Publish the position through
svc_xprt_acked_pos(), so the transport can withhold the position
while any request but the caller's is counted. A request that never
reaches a lookup is uncounted when it is released.

Add a per-service hook that runs once per request when its reply
phase ends, whether svc_send() sent the reply or svc_process()
dropped it, so an upper layer can record the reply's position
against its own state either way. On the drop path the position is
zero.

Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-8-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h      | 18 +++++++++++++
 include/linux/sunrpc/svc_xprt.h | 25 ++++++++++++++++++
 net/sunrpc/svc.c                |  3 +++
 net/sunrpc/svc_xprt.c           | 56 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 102 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b1dff5c8aa89..fc83b24934b0 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -59,6 +59,8 @@ enum {
 };
 
 
+struct svc_rqst;
+
 /*
  * RPC service.
  *
@@ -101,6 +103,13 @@ struct svc_serv {
 						 * connection */
 	bool			sv_bc_enabled;	/* service uses backchannel */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
+
+	/*
+	 * Called once per request after its reply phase, whether
+	 * xpo_sendto() succeeded, failed, or was never reached because
+	 * svc_process() dropped the reply. See rq_reply_pos.
+	 */
+	void			(*sv_reply_sent)(struct svc_rqst *rqstp);
 };
 
 /* This is used by pool_stats to find and lock an svc */
@@ -272,6 +281,13 @@ struct svc_rqst {
 	unsigned int		bc_to_retries;
 	unsigned int		rq_status_counter; /* RPC processing counter */
 	void			*rq_private;	/* For use by the service thread */
+
+	/*
+	 * Transport position of this request's reply, set by
+	 * xpo_sendto(); zero when the reply did not reach the wire.
+	 * Comparable only with the xpt_acked_pos of the same svc_xprt.
+	 */
+	u64			rq_reply_pos;
 };
 
 /* bits for rq_flags */
@@ -282,6 +298,7 @@ enum {
 	RQ_DROPME,		/* drop current reply */
 	RQ_VICTIM,		/* Have agreed to shut down */
 	RQ_DATA,		/* request has data */
+	RQ_RECV_PENDING,	/* counted in xpt_recv_pending */
 };
 
 #define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
@@ -364,6 +381,7 @@ static inline void svc_thread_init_status(struct svc_rqst *rqstp, int err)
 struct svc_deferred_req {
 	u32			prot;	/* protocol (UDP or TCP) */
 	bool			secure;	/* RQ_SECURE of the original request */
+	bool			recv_pending; /* RQ_RECV_PENDING, carried over */
 	struct svc_xprt		*xprt;
 	struct sockaddr_storage	addr;	/* where reply must go */
 	size_t			addrlen;
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 52082d8ea6dd..aea98ddbfe52 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -28,6 +28,7 @@ struct svc_xprt_ops {
 	void		(*xpo_free)(struct svc_xprt *);
 	void		(*xpo_kill_temp_xprt)(struct svc_xprt *);
 	void		(*xpo_handshake)(struct svc_xprt *xprt);
+	u64		(*xpo_acked_pos)(struct svc_rqst *rqstp);
 };
 
 struct svc_xprt_class {
@@ -66,6 +67,10 @@ struct svc_xprt {
 	atomic_t		xpt_reserved;	/* outq space rsvd, UDP only */
 	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
+	atomic64_t		xpt_acked_pos;	/* replies up to this position
+						 * are acknowledged; 0 = none */
+	/* requests read but not yet past svc_xprt_recv_done() */
+	atomic_t		xpt_recv_pending;
 	spinlock_t		xpt_lock;	/* protects sk_deferred
 						 * and xpt_auth_cache */
 	void			*xpt_auth_cache;/* auth cache */
@@ -161,6 +166,24 @@ static inline bool svc_xprt_is_dead(const struct svc_xprt *xprt)
 		(test_bit(XPT_CLOSE, &xprt->xpt_flags) != 0);
 }
 
+/**
+ * svc_xprt_advance_acked - Raise a transport's acknowledged position
+ * @xprt: transport that sent the replies
+ * @pos: position the peer has acknowledged, in @xprt's own units
+ *
+ * Context: Any context. Callers must serialize against other writers
+ *	of @xprt's xpt_acked_pos.
+ * Return: %true if the position was raised, %false if @pos does not
+ *	exceed the recorded position.
+ */
+static inline bool svc_xprt_advance_acked(struct svc_xprt *xprt, u64 pos)
+{
+	if (pos <= atomic64_read(&xprt->xpt_acked_pos))
+		return false;
+	atomic64_set(&xprt->xpt_acked_pos, pos);
+	return true;
+}
+
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct net *, struct svc_xprt_class *, struct svc_xprt *,
@@ -175,6 +198,8 @@ int	svc_xprt_create(struct svc_serv *serv, const char *xprt_name,
 void	svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 			     bool unregister);
 void	svc_xprt_received(struct svc_xprt *xprt);
+void	svc_xprt_recv_done(struct svc_rqst *rqstp);
+u64	svc_xprt_acked_pos(struct svc_rqst *rqstp);
 void	svc_xprt_enqueue(struct svc_xprt *xprt);
 void	svc_xprt_put(struct svc_xprt *xprt);
 void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f261a4f47276..0dcb1085ecb1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1503,6 +1503,7 @@ svc_process_common(struct svc_rqst *rqstp)
 
 	/* Reset the accept_stat for the RPC */
 	rqstp->rq_accept_statp = NULL;
+	rqstp->rq_reply_pos = 0;
 
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
@@ -1748,6 +1749,8 @@ void svc_process(struct svc_rqst *rqstp)
 		goto out_baddir;
 
 	if (!svc_process_common(rqstp)) {
+		if (rqstp->rq_server->sv_reply_sent)
+			rqstp->rq_server->sv_reply_sent(rqstp);
 		svc_release_rqst(rqstp);
 		goto out_drop;
 	}
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 15c14d75ec12..4baeb82d02c0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -593,14 +593,57 @@ static void free_deferred(struct svc_xprt *xprt, struct svc_deferred_req *dr)
 	if (!dr)
 		return;
 
+	if (dr->recv_pending)
+		atomic_dec(&xprt->xpt_recv_pending);
 	xprt->xpt_ops->xpo_release_ctxt(xprt, dr->xprt_ctxt);
 	kfree(dr);
 }
 
+/**
+ * svc_xprt_recv_done - a request has been looked up in the reply cache
+ * @rqstp: request that has been looked up
+ *
+ * A transport counts each request from its read until this call, and
+ * svc_xprt_acked_pos() withholds the acknowledged position while the
+ * count is non-zero: a retransmit the peer sent before the
+ * acknowledgment may be among the requests counted. Call this once
+ * the request has been looked up, before the reply cache acts on the
+ * position. A request that never reaches a lookup is uncounted when
+ * it is released.
+ *
+ * Context: any context.
+ */
+void svc_xprt_recv_done(struct svc_rqst *rqstp)
+{
+	if (test_and_clear_bit(RQ_RECV_PENDING, &rqstp->rq_flags))
+		atomic_dec(&rqstp->rq_xprt->xpt_recv_pending);
+}
+EXPORT_SYMBOL_GPL(svc_xprt_recv_done);
+
+/**
+ * svc_xprt_acked_pos - acknowledged position the server may act on
+ * @rqstp: the request on whose behalf the position is read
+ *
+ * Context: process context. May take and release the socket lock.
+ * Return: the position up to which the peer has acknowledged replies
+ * and no earlier request can still be ahead of its lookup, or 0 when
+ * the transport publishes no position or cannot yet vouch for it.
+ */
+u64 svc_xprt_acked_pos(struct svc_rqst *rqstp)
+{
+	struct svc_xprt *xprt = rqstp->rq_xprt;
+
+	if (!xprt->xpt_ops->xpo_acked_pos)
+		return 0;
+	return xprt->xpt_ops->xpo_acked_pos(rqstp);
+}
+EXPORT_SYMBOL_GPL(svc_xprt_acked_pos);
+
 static void svc_xprt_release(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
+	svc_xprt_recv_done(rqstp);
 	xprt->xpt_ops->xpo_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
 	rqstp->rq_xprt_ctxt = NULL;
 
@@ -1037,6 +1080,8 @@ void svc_send(struct svc_rqst *rqstp)
 	trace_svc_stats_latency(rqstp);
 
 	status = xprt->xpt_ops->xpo_sendto(rqstp);
+	if (xprt->xpt_server->sv_reply_sent)
+		xprt->xpt_server->sv_reply_sent(rqstp);
 
 	trace_svc_send(rqstp, status);
 }
@@ -1352,6 +1397,13 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	}
 	dr->xprt_ctxt = rqstp->rq_xprt_ctxt;
 	rqstp->rq_xprt_ctxt = NULL;
+	/*
+	 * The revisit repeats the lookup, so a request a procedure
+	 * defers after its lookup was reported is counted again.
+	 */
+	if (!test_and_clear_bit(RQ_RECV_PENDING, &rqstp->rq_flags))
+		atomic_inc(&rqstp->rq_xprt->xpt_recv_pending);
+	dr->recv_pending = true;
 	trace_svc_defer(rqstp);
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
@@ -1386,6 +1438,10 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
 	 * it handled last. Restore the value computed at receive time.
 	 */
 	assign_bit(RQ_SECURE, &rqstp->rq_flags, dr->secure);
+	if (dr->recv_pending) {
+		set_bit(RQ_RECV_PENDING, &rqstp->rq_flags);
+		dr->recv_pending = false;
+	}
 
 	dr->xprt_ctxt = NULL;
 	svc_xprt_received(rqstp->rq_xprt);

-- 
2.56.0

