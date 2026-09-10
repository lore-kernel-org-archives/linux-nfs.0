Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9C5D492531
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048507; cv=none; b=L8gZiT+0RSSqr5UPdPiPOVUU0iX58Cp4PDF6AOngu+ch8SlJ3vcb4BI3lDlVNfJ63hLBpdHPDvw6BqXTcfFxhVqwXoLSF4eVShtfShBgerZ44AjAZDARIVuaH3HrnZcXdG1shwTTOt7K3oDbzzz0AqRpm/1xZuiMS45BC4salpo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048507; c=relaxed/simple;
	bh=ybjux1yiDaMPnP4VAHc5zjjDAVmGOprs+mrpwjpILPA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=hJX660jF2Y1PWBclPnvuC4xAApJJXXmruVN7oe3czMg0BTii9HYy9+BGClmCI/L1RwYra5X6FKtPQHnP2xBueqMV2E0+v2O22+aKrPxVLxCiivZh2vjy0BpzSQuNq/j1om3D9Bt3TXAiDPQ/gXTojUtBAMLZDxPdLudnl6q1mjw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=U4FdGHzI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="U4FdGHzI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FD5D1F00893;
	Thu, 10 Sep 2026 13:55:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048505;
	bh=cObPJl368Eqjr9piVXKITRL5Pq9jh+FbMktoNwwxlfM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=U4FdGHzIGCCoucf+KrqyUpidygOnsw7+8gI+d0l/B5KF3uBwdse3xY1PTuRGlLl0m
	 tIztYIyS1VoF66hDsJB/dVnH21J18+nXIIF/MUE/x9Wfbo3SLMNTzQeJ4dkm/bskDG
	 6CDnt3yVPHcDQLFPBHZB36Z5A6NU4EtjynjNZV9vVut1TRAYRPUrwTl2bzR7GdQaZ0
	 n61nK/DoHrlaKRUoljR+D0y6dbB2kOTHGmaaAlrft47IryAZ5ssstXR8zdP7epjEiC
	 /Y3+4t3BDPX8Zu0YcPtrrw3tEg76vObAdhbfHnobMhqUv428GbGh4lqf19f05GSL9o
	 GI/SCdTmkefVA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:50 -0400
Subject: [PATCH v3 10/12] NFSD: Evict unacknowledged DRC entries via
 implied ACK
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-10-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=7791; i=cel@kernel.org;
 h=from:subject:message-id; bh=ybjux1yiDaMPnP4VAHc5zjjDAVmGOprs+mrpwjpILPA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawe1ywbNCfi0vQRDPq+0ekcP3fP8W4fUZAJ
 E5ocG92w3SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 l2cREACInaIPxl0+fJd6lsBgJk6An2UYyu8CbpYskAxFhfd9DE1uGo/Y2mkgB8PKlp3M4SLJaYE
 bRkHZarAZTgFiWqV8FRJujW3eswtfP7ovoxvuzJ6XC5c+hPHq4yPmIe2Gzpb4/wJ3nTUr3sqOxX
 zKUEHYWcSxIbydXUnHbKIDDGq6yd9bZeBcxEZygwE98q0/oW/w5s0WmRFQdWYD6vV2BdrtcnH5a
 4v7cMTcYbIsM6C57L5eZCvB23ArA/12d9Xmpp9XuJKE7OLIHNWE00dYFVIxLVooxWSKW4AiVreS
 R5NEr2AGgOt0sjb6eiH8hdftWAvAdJ6ExR02Il5AS7y9+5EqvBNr+bQ3eo/9KNx6PpFvq+xwBlL
 Uxiiongx/mKjQ7SSFsLKOW+tgRUzhYEh3MwuboNhhGfLwo/gJdOmAbQfZalcHDURV6VtO/VH1So
 0gwr0goc+DqEuwiuoAelndtwYHJx71eU+fNwCGRJXavzNSwUOdUJAVccKAxHubCMNtRp5+Zv2r3
 IiOQOEifuG2WjGyXHawjUdJslReKFlqs+funnV0iCKkLJdkNPx4L1hYZ75Vy5OOp+8D7t6LX2Az
 jPUdKBXBboDYMimKAmr9r46qQR6u1Co/6EC/bf3oBfX0On143+K5QT8XM8dqhAt4aEwRsY8XX0x
 bBGuTp1gPxOus5g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A transport reports reply delivery only while it is tracking the
reply. The TCP ring has a fixed size, so a burst leaves some
replies untracked, and a kTLS reply is untracked when part of its
record is still unsent. Entries for those replies stay in their
bucket until RC_EXPIRE elapses or the cache exceeds
max_drc_entries, lengthening every lookup that hashes there.

RFC 1813 Section 4.5 observes that on a connection-oriented
transport a duplicate request arises from reconnection, not from
within a live connection. A fresh request on a live TCP or RDMA
connection therefore means the client is not retransmitting an
earlier one. UDP offers no such signal.

The signal is not conclusive. An entry can be evicted while its
reply is still in flight, and a reconnect then executes the
request again. Memory pressure and RC_EXPIRE already open the
same window.

Add an XPT_ORDERED flag marking transports that offer the signal.
During bucket pruning, evict an RC_DONE entry when the current
request's transport is XPT_ORDERED, no delivery report is pending,
and its c_timestamp predates xpt_last_recv. Only that transport is
consulted, because it is the one the pruning thread holds a
reference to.

On svcrdma, handle_connect_req() zeroes the remote port in the DRC
key so a cached reply survives a reconnect, and implied-ACK
eviction can retire such an entry while the original connection is
still up. TCP gives up the same thing when a client re-binds its
reserved port.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c                       | 45 +++++++++++++++++++++++++++++---
 fs/nfsd/trace.h                          |  1 +
 include/linux/sunrpc/svc_xprt.h          |  1 +
 include/trace/events/sunrpc.h            |  1 +
 net/sunrpc/svcsock.c                     |  1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  1 +
 6 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 473bf825c37a..9f9baf7910ff 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -90,6 +90,36 @@ nfsd_hashsize(unsigned int limit)
 	return roundup_pow_of_two(limit / TARGET_BUCKET_SIZE);
 }
 
+/*
+ * A later request on @xprt is taken as evidence that the client
+ * received @rp's reply, because a client does not retransmit within
+ * a live connection. Only XPT_ORDERED transports qualify: a UDP
+ * client retransmits on timeout, and a datagram from any of the
+ * peers sharing the UDP svc_xprt would evict another client's reply.
+ *
+ * A pipelined client sends its next request before @rp's reply
+ * arrives, so while the transport is still going to report on that
+ * reply, wait for the report instead.
+ *
+ * c_timestamp is set after xpt_last_recv was recorded for @rp's own
+ * request, so a newer xpt_last_recv means a later request arrived.
+ */
+static bool nfsd_cacherep_implied_ack(struct svc_xprt *xprt,
+				      struct nfsd_cacherep *rp)
+{
+	unsigned long last_req;
+
+	if (!xprt || rp->c_xprt != xprt->xpt_id)
+		return false;
+	if (!test_bit(XPT_ORDERED, &xprt->xpt_flags))
+		return false;
+	if (rp->c_ack_pending)
+		return false;
+
+	last_req = READ_ONCE(xprt->xpt_last_recv);
+	return time_after(last_req, rp->c_timestamp);
+}
+
 static struct nfsd_cacherep *
 nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
 		    struct nfsd_net *nn)
@@ -337,10 +367,14 @@ static void nfsd_reply_ack(void *data, const svc_ack_cookie_t *cookie,
 /*
  * Remove and return no more than @max evictable entries in bucket @b,
  * visiting at most 4 * @max entries. @max must not be zero.
+ *
+ * @xprt is the transport the current request arrived on, or NULL when the
+ * caller has none.
  */
 static void
 nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
-			 unsigned int max, struct list_head *dispose)
+			 unsigned int max, struct list_head *dispose,
+			 struct svc_xprt *xprt)
 {
 	unsigned long expiry = jiffies - RC_EXPIRE;
 	struct nfsd_cacherep *rp, *tmp;
@@ -362,6 +396,11 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 			trace_nfsd_drc_evict_expired(nn, rp);
 			goto evict;
 		}
+		if (rp->c_state == RC_DONE &&
+		    nfsd_cacherep_implied_ack(xprt, rp)) {
+			trace_nfsd_drc_evict_implied_ack(nn, rp);
+			goto evict;
+		}
 		goto next;
 
 evict:
@@ -426,7 +465,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 
 		spin_lock(&b->cache_lock);
 		nfsd_prune_bucket_locked(nn, b, sc->nr_to_scan - freed,
-					 &dispose);
+					 &dispose, NULL);
 		spin_unlock(&b->cache_lock);
 
 		freed += nfsd_cacherep_dispose(&dispose);
@@ -599,7 +638,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 		goto found_entry;
 	*cacherep = rp;
 	rp->c_state = RC_INPROG;
-	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
+	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
 	spin_unlock(&b->cache_lock);
 
 	nfsd_cacherep_dispose(&dispose);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 0af3a8231fe4..c99b2a369d0d 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1597,6 +1597,7 @@ DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_acked);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
 DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_implied_ack);
 
 TRACE_EVENT(nfsd_drc_reply_acked,
 	TP_PROTO(
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index da234a078c5d..cc29a8db269b 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -103,6 +103,7 @@ enum {
 	XPT_KILL_TEMP,		/* call xpo_kill_temp_xprt before closing */
 	XPT_CONG_CTRL,		/* has congestion control */
 	XPT_REPLY_ACK,		/* reports reply delivery via svc_reply_acked */
+	XPT_ORDERED,		/* connection-oriented, in-order delivery */
 	XPT_HANDSHAKE,		/* xprt requests a handshake */
 	XPT_TLS_SESSION,	/* transport-layer security established */
 	XPT_PEER_AUTH,		/* peer has been authenticated */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index a9d42625c99b..e793e8ea322b 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1932,6 +1932,7 @@ TRACE_EVENT(svc_stats_latency,
 	svc_xprt_flag(KILL_TEMP)					\
 	svc_xprt_flag(CONG_CTRL)					\
 	svc_xprt_flag(REPLY_ACK)					\
+	svc_xprt_flag(ORDERED)						\
 	svc_xprt_flag(HANDSHAKE)					\
 	svc_xprt_flag(TLS_SESSION)					\
 	svc_xprt_flag(PEER_AUTH)					\
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a28905181589..94361e5a743e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1567,6 +1567,7 @@ static bool svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_REPLY_ACK, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_ORDERED, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		strcpy(svsk->sk_xprt.xpt_remotebuf, "listener");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 64e964ac941c..acf437516ae1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -219,6 +219,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	 */
 	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
 	set_bit(XPT_REPLY_ACK, &cma_xprt->sc_xprt.xpt_flags);
+	set_bit(XPT_ORDERED, &cma_xprt->sc_xprt.xpt_flags);
 
 	return cma_xprt;
 }

-- 
2.55.0

