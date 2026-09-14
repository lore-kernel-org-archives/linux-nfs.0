Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4ABCF480DEC
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397151; cv=none; b=KLmkYqbnOZ/qwXHOhnKNQPWIg9us7+uMJrroXCXwU84H3iP+VRSdb1DG0bLUnbkdK3ELVlfSGzcEHiAj+z/UrQ4g1tFsuoXIwf8YVlBgix5uK8ZHk7A19W2Y/n3YHtZgEG48ylKftp+jIboJX5YuFXoccEznZKpB6tuunZt74/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397151; c=relaxed/simple;
	bh=V9rPnpRtOOw5rJ13EQmmnd2IrO2B1kfumto+2yEISLQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ddZvv9XAR92pmY5wneae9BCL4sWsH7ud51tEPYNlhEFWeYVGRd4IY2qwAJ5Qn8S4yCcqPJ5PH6XTb41UZ2DKzKCKeCmywYSz+C+BhaFDCZChgQOJWy2sEGxCs6rcXem/QJA3cJc9pUCfjjkrJeDptsd5EZ7AFzbg7h4E0sAXm5U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mWznDO3L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mWznDO3L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7597A1F00899;
	Mon, 14 Sep 2026 14:45:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397149;
	bh=5ZoJfITYmBsTTeypOa8DPiH1LUpNw84/f9lLt/U7gqo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mWznDO3LeoO2U+Ybotj8srXiTJLuV9IU7jQHBU+Di+DeHTM6K6F52hVuis7FEsb6a
	 119Y0QOkRCSEd5VTBfg+nu2luGvQy81VM15LHhiaAiD+Q570RDGx5zjLmEC8YZMfkG
	 Dvk6nMbz/Kw/7WHZygyc+HKMgkccHS92jGj3QWoo6rnF5IIV4plQuGJHaH5hmfkZBN
	 DseQdkIkwtS/UC5LkTq9wAIxiiCwHLXb6EFbu47RnIZyBmHS5djipFITALJyvTI6Fm
	 GfnSr+miJV1qjvi1p0bGwfItuCSXTYWA3t75qGLzR3vKYuSiINjjLQOU5JgPDKm6qN
	 9APiY9rR8jeZg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:36 -0400
Subject: [PATCH v4 06/11] SUNRPC: Publish reply positions for upper-layer
 consumers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-6-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4473; i=cel@kernel.org;
 h=from:subject:message-id; bh=V9rPnpRtOOw5rJ13EQmmnd2IrO2B1kfumto+2yEISLQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiWRo+uYcwTGufsZy68T8sk93yHFa6LbOEiF
 0zf0PB1OnqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 l3VAD/47WmxaYDyjKHD9rVKIJuNF4CyyZZ7TpkKDsaopeAbRN0KrNrNcc9YBlZZI6KoFl8wowXO
 ii9l0L1M4GyEFshP2UvScaUMjuKjJ5ni5I5PtB773J1mnJepXdma0BJXX4sTFxZtVcmmBtE09Ua
 Y1LBsRSwj9yAcxV4Rnn4JtkSkHx2y0+Rlgt9l4h0V5kyJbT68nUh7GCT0oxc5Nukf6oLjekY0BJ
 YpML8GRWRT9n5AVkJdTw6u4RKC9vvcwVrXc8GHBZcYg2Kdtwb7MZLi3hPduj06FE4Fi5gAXP6LL
 ZmnR/a6U9X+89n0JlqMs9hSmYZ9ud0wbTSEdknwW5Y+Z6hcbWHUI3TqN1sttl7lghyRG5bX0vvS
 l5y4CzgLzLPnagQwCkohMY+gl3J6b622QFjjngJXrUbCt0ZwcHjndh+m69KDzTLBlJshO0O4rql
 D+JbbjIYlWZ953q0gPAgoNzGFL+/+VWnuIy7LLWMGpl4xmSABItZyD9pMoSt8/pQCKWqesTWTeK
 OAKJ1Ep5dwKgLEGiMwU1vzmB/7bvd/8d6DGAyNbHwcW2abH7eQubZXDNpzoVI3OJkSzEJIbvKS8
 kSEGaGj0f5TZS+6vNUioIoNe/B42S3uINRWvmnJfM5UtpXw3FZkRy5VoVXz15YESMxTR4MOxTHO
 E8Pa+S34XnVud7g==
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
32-bit host could run ahead of the peer.

Add a per-service hook that runs once per request when its reply
phase ends, whether svc_send() sent the reply or svc_process()
dropped it, so an upper layer can record the reply's position
against its own state either way. On the drop path the position is
zero.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h      | 16 ++++++++++++++++
 include/linux/sunrpc/svc_xprt.h |  2 ++
 net/sunrpc/svc.c                |  3 +++
 net/sunrpc/svc_xprt.c           |  2 ++
 4 files changed, 23 insertions(+)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 24698856eb40..01036e093012 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -59,6 +59,8 @@ enum {
 };
 
 
+struct svc_rqst;
+
 /*
  * RPC service.
  *
@@ -96,6 +98,13 @@ struct svc_serv {
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
@@ -267,6 +276,13 @@ struct svc_rqst {
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
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 9f940c892eca..60be056a125d 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -66,6 +66,8 @@ struct svc_xprt {
 	atomic_t		xpt_reserved;	/* outq space rsvd, UDP only */
 	atomic_t		xpt_nr_rqsts;	/* Number of requests */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
+	atomic64_t		xpt_acked_pos;	/* replies up to this position
+						 * are acknowledged; 0 = none */
 	spinlock_t		xpt_lock;	/* protects sk_deferred
 						 * and xpt_auth_cache */
 	void			*xpt_auth_cache;/* auth cache */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f73412e123a1..9ef0661bb422 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1488,6 +1488,7 @@ svc_process_common(struct svc_rqst *rqstp)
 
 	/* Reset the accept_stat for the RPC */
 	rqstp->rq_accept_statp = NULL;
+	rqstp->rq_reply_pos = 0;
 
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
@@ -1733,6 +1734,8 @@ void svc_process(struct svc_rqst *rqstp)
 		goto out_baddir;
 
 	if (!svc_process_common(rqstp)) {
+		if (rqstp->rq_server->sv_reply_sent)
+			rqstp->rq_server->sv_reply_sent(rqstp);
 		svc_release_rqst(rqstp);
 		goto out_drop;
 	}
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f836a7aebd64..2154b2c52ccd 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1028,6 +1028,8 @@ void svc_send(struct svc_rqst *rqstp)
 	trace_svc_stats_latency(rqstp);
 
 	status = xprt->xpt_ops->xpo_sendto(rqstp);
+	if (xprt->xpt_server->sv_reply_sent)
+		xprt->xpt_server->sv_reply_sent(rqstp);
 
 	trace_svc_send(rqstp, status);
 }

-- 
2.55.0

