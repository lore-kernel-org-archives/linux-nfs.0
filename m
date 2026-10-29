Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297189;
	b=yQrqS3sYomh5wf0D+N0/7d1ISxRn0erLFR9Vy95vWMrYNtRZPuFRuMh7JFCdDocw/jma
	 D7p+e+Lc/HhAvsw+SOIUnpactLM/C6eOWsmTgoUdeTv9K7k5UuK3C/mkzEe5aqvSakpS5
	 ByqNePnDiw5zEgaLmjLafacK/v+YZ6WTrIf5k3D4yeQrBjFALtNNSG5prhtqdEXxIryfC
	 vlo0COp7eHoPrhtj6Jlq2yKvR7Ek2wy/0O/uUboX+yZgLh6cngCoaw7ry6C9nJtfuWoDx
	 OdQyhz1I3oZRIr+ZqxFc87Ws5LbMs2yr5BbGCi6AlaVDKm6tFol568RevNFCKaGjqDQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297189;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zsA0a44aCu1yd4mT85kMmi5N0X6T+frsfl4c4RpJdYM=;
	b=m3ew4e4womiCUiznKYaMLY5eRoz53ju8kh2mHVDzREO4eblDlYypVKmyyeo7iRmSVG2d
	 zKXSpLjWdH1WN+R9dgKWj9bKBxgE6SYGdqKDD5MofgWsWmbPGt3uhJKxBlswtg1KUKp3H
	 DID+ZktQTsrqSEIDqr59b6dsb4CSyx0cGMgsUcddjZ2xFqXWTsUY68o1Bs9lKV8h5x6qn
	 6JrIRDqlmA1vJSNYs5apsxAGOMh7WX+gv8ZIqYMdQ9uwVEF7qHI7Zh5NPedzyvBQTELMM
	 +MqQR0FAemTqj3NKwefsdVVVSeSfaP36/v86f+WVsPaHOZsHLAgQtzUY4k48JLK0iOg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E4rKkRT5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89F1A606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E4rKkRT5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 77D461F031E1;
	Thu, 29 Oct 2026 18:06:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297189;
	bh=zsA0a44aCu1yd4mT85kMmi5N0X6T+frsfl4c4RpJdYM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E4rKkRT5O0/C24I2x9uqnVtKYOKzV/w01wgxqwlWD5ZqtIqLl7ViNDpB3tNagLZ+6
	 DLk3xLkFbpk1Dmo00oQRsnk3SQQPORbc6WHJIPIKhu6Kg6OiKC4/j+Ji4Ou3FVUQjR
	 pK5JsoHqi/retGm8jpdEep2zHJ+bXBEva485nDc+d1k5WYal3yWYrpaA6S/3QxnPBw
	 vcRwl5MQ1x1pq5EEEZs4ObRkhdtCMFhegtUIbeRwHuIr0vSo6yaD90HVlbDTjrv8aR
	 HfPs1QPcGOc0FsLuw7ZFmdbIyXkA+g60NusHdyBQpAqoov4L7lzQISJucFsYmnqJJU
	 qVeWS//Xc8Ytg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:14 -0400
Subject: [PATCH v7 08/13] SUNRPC: Publish reply positions for upper-layer
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
Message-Id: <20261029-duplicate-reply-cache-v7-8-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=11144; i=cel@kernel.org;
 h=from:subject:message-id; bh=HdVtNO4wVe7WRb3A3AhiosGyXAz3BPH2gTuFlxH5tDE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scZT2AYCRntut1BziohvAjWYxSM/+uB/x/8
 G90aTGI9KeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l4gvD/9P3UQCz6uEPvKrz/eKYIzCUHhVjjncyLdH0DLEv57C2pdhQ6fVjLHyDNpZ26xwIdMRhiN
 z7Nskfs3ZIOfR8cHItbW5XuRyUk1GISMSwAYjzBA2qXXW18J8RRTNkLvlPMbjBWq3yPGgwrdWRs
 t9KU2m0asAcwYa7+/upJ3T+iwHRGfAMNZQtGso3cjZb3/8sKWUxSV9wnRp+qMLaAwfo5ABbqCm9
 9HFVjDP5WbnYCT9aMp7vYEYEBsAiJm7rdwZxe2yboy2yRqperrUF11yibv1seHtldhVZ0BZQTbW
 m47gm4B4RlhW3ALkn7iEHi5uPgBh7+iwvHqIPuhkXUv8e4iooxxM6ijyH1+9E+J0G2w6g4sY74I
 RW9wT5QTPYFIvVIc/umbSj8ofXRQF/cd2XtBdMwOMPUKxv/AHfaUJs6fPMK1lsKwCCFwlmjbmtM
 nfaOM34UqzfGF/Dwwwv+yACGMOGIq3CJWpEq/qwE9SVF6cZFqY9PYOfa57TVokb/R4oN3nh6gln
 z1XjVHq0ntm8IbqGMIsGUL/qVD4I7XIHf1aIP0ZGOYVMyYZZcKMwYsxJZz/ne+3gbgTqGwXbbTI
 Z5AaHagaZ33NuZ1WHQhV1gj2fSS0JBqWrUahONoQkSu3ncQ4lrJUZMng7Yv7n0VaeXbk1PgcAeg
 7xVU6fuINd7EX9A==
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
transport (bytes for a stream, Send sequence for RDMA); a consumer
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
across a deferral. Publish the position through svc_xprt_acked_pos(),
so the transport can withhold the position while any request but the
caller's is counted. A request that never reaches a lookup is
uncounted when it is released.

Add a per-service hook that runs once per request when its reply
phase ends, whether svc_send() sent the reply or svc_process()
dropped it, so an upper layer can record the reply's position
against its own state either way. On the drop path the position is
zero.

Assisted-by: LLM
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-8-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h      | 18 ++++++++++++++
 include/linux/sunrpc/svc_xprt.h | 25 ++++++++++++++++++++
 net/sunrpc/svc.c                |  3 +++
 net/sunrpc/svc_xprt.c           | 52 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+)

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
index af8d87c1de83..d4b8aa685cfe 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1497,6 +1497,7 @@ svc_process_common(struct svc_rqst *rqstp)
 
 	/* Reset the accept_stat for the RPC */
 	rqstp->rq_accept_statp = NULL;
+	rqstp->rq_reply_pos = 0;
 
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
@@ -1742,6 +1743,8 @@ void svc_process(struct svc_rqst *rqstp)
 		goto out_baddir;
 
 	if (!svc_process_common(rqstp)) {
+		if (rqstp->rq_server->sv_reply_sent)
+			rqstp->rq_server->sv_reply_sent(rqstp);
 		svc_release_rqst(rqstp);
 		goto out_drop;
 	}
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 3eb5dc6cc330..81b13b8a3bc7 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -593,14 +593,58 @@ static void free_deferred(struct svc_xprt *xprt, struct svc_deferred_req *dr)
 	if (!dr)
 		return;
 
+	if (dr->recv_pending)
+		atomic_dec(&xprt->xpt_recv_pending);
 	xprt->xpt_ops->xpo_release_ctxt(xprt, dr->xprt_ctxt);
 	kfree(dr);
 }
 
+/**
+ * svc_xprt_recv_done - the server has matched a request against its state
+ * @rqstp: request that has been looked up
+ *
+ * A transport counts the requests it has read that the server has
+ * not yet compared with the replies it holds. While the count is
+ * non-zero, svc_xprt_acked_pos() withholds the transport's
+ * acknowledged position: a retransmit the peer sent before it received
+ * a reply may be among the requests counted, and it must find the
+ * reply cached. Call this once the request has been looked up, before
+ * the reply cache acts on the acknowledged position. A request that
+ * never reaches a lookup is uncounted when it is released.
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
 
@@ -1031,6 +1075,8 @@ void svc_send(struct svc_rqst *rqstp)
 	trace_svc_stats_latency(rqstp);
 
 	status = xprt->xpt_ops->xpo_sendto(rqstp);
+	if (xprt->xpt_server->sv_reply_sent)
+		xprt->xpt_server->sv_reply_sent(rqstp);
 
 	trace_svc_send(rqstp, status);
 }
@@ -1346,6 +1392,8 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	}
 	dr->xprt_ctxt = rqstp->rq_xprt_ctxt;
 	rqstp->rq_xprt_ctxt = NULL;
+	dr->recv_pending = test_and_clear_bit(RQ_RECV_PENDING,
+					      &rqstp->rq_flags);
 	trace_svc_defer(rqstp);
 	svc_xprt_get(rqstp->rq_xprt);
 	dr->xprt = rqstp->rq_xprt;
@@ -1380,6 +1428,10 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
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

