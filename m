Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A34F519E08
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752106; cv=none; b=j2py1GtA6/WWk1CO/CYzY+dTERAp925PPAAD07rvf/YDXhUpwkplYw8V18UUbyPmf8EcJsY0sW3S375vwMkK9HlSpJKzqv5fa5rBjgt3xEQ5vE9zEIT7I+FUMfadlf5LXNrkV0/dLLgXiWQ8Ct5x167nI3k6vXfZOVfbC4l3wXY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752106; c=relaxed/simple;
	bh=CwBt6/CeG781IdPuL7egclHTt+AR5+9LgchVRkOyTSE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kwmQI64rCkaBiGP3flDXop/1JsQqCIk3teNutjJbnLT0frG/m+xKHvm8GVeR5JeQ6jCycemZsEh/aO7ahFOHXpcFXYL5x1+aTKuD/LApWLb6DylWFzG9Jm3jEh2hfa36KRxdzQF0/MlsrXcDi3mOov0Z8V+IhVtLPmBKcW9xIrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XAgYVEbH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XAgYVEbH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DEDF11F0089D;
	Fri, 18 Sep 2026 17:21:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752093;
	bh=/pmQJOcYYAuVh803FyZOitGrkehhhf2A+GBwIcryHQ0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XAgYVEbHxrv5QmJvAmjl9m7UHX44P3DHnyJqZN6BUwKDfeWQ9Wuc16PR9Rd933S5B
	 VSziq8ORB/UK+gxmITsHez6AKBmAILKxkh1dV0nij32X+BMg5ICyQd3GuUAlXL7orT
	 J7wMRbA9uVSHMp1VYI7xvVfbLuKrfFS19ZcQRN2pBpyZzpxyFVa/bd41hnInkEyiO/
	 SI3fmFAths2PA13hV6p6gugQe32DU7jGsxzIL3axMQ66CpqYtlRAndHfWznOOm6EDQ
	 vNta/gkDSSMoEcg7kD5HID6eHmgIgYqfRgUl3YzmlmXNNUEEdjUFLWwfG0IDvuEsl7
	 oh1/5QmxxY41w==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:19 -0400
Subject: [PATCH v5 07/11] SUNRPC: Publish reply positions for upper-layer
 consumers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-7-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4473; i=cel@kernel.org;
 h=from:subject:message-id; bh=CwBt6/CeG781IdPuL7egclHTt+AR5+9LgchVRkOyTSE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWRhiUx3MB1nO5cjlN4+qZ9xWN/myOtub5D
 DUPOu0EueiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l0PlEACIz1l6KvS1ESOynSyfKFIzHrIUcZnBIP/mqwE5UVGsrvXZKQqg4p55PNeQXm3MQQaH6aZ
 61ZvkajyBGMNiw6cjmsOp4iNN/evSGJ6bU+OM5kW6jJ30UFmZerPWoO02ae0OGB+LH/ZC95hrLe
 UxcWLC6B7BVXFfsaoLbAf1D4PXbzsfZxVP6R5I/YxMm/MAQ+mt6U7rvyyNjRFjDt0wDYFSRDgZ6
 TN/5jGXAiMXac+ag8sPANUtT6r2MZGXzjbfanRRD025mVL7aH21EpRgTvEyiaZ3HVLM8S8BILa4
 X9Dag09d95TTZwg7Q9OD3YSE1qZ1LqleyPw5emqTif3ZUuFFftBh/EpEOMYwKO07fbVoNMveM+X
 2drZDegXYgVvU8MZ3YQpzV+zt9FF8feLHeogjoP5FP1G/jMdyycAkM7La8yN3Q5eHN2ct9oUmZQ
 W56fGDZ+z3Ig58JhbelBZJIPD7Og/L/z1dmhn5G99mz+cGRYA0vDvC/mZuii+OYSpOpFqyE2Bsd
 BilNCrIrndYTs6mt6nyilIhhqqO+yqIWoYuokbwEtXlJEvFVq3FVWuNOL8FpGNFpvGEH8mYqFN/
 A5/LdavkMKIDYwrO+/20qZOi1wiuzgnN5UJyH/xPT2GY5BeM0iiJMwrEFnyj2AkiNxJZBi5DK30
 gHpNC0ftOFDuKgg==
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
index 52082d8ea6dd..7176c42f19d7 100644
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
index 463ba8d77f0c..1668d96ac9ff 100644
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

