Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C851493641
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048506; cv=none; b=RO13fAMofkY82BV/PcQ9ChiNFmZPc9ENbpuc2ZUc1H0sf7ZtID0eq30Kd6eCfwpoDio/nmYGgPVTBZwdUFqaMYytCTwk2GLNbMZGnoNKaZYE1LqVyIPYFeQAJQwNhuY61FSbjrxGiOiBxArBAyGbCJkOPCeKgqSKW8du6MioOvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048506; c=relaxed/simple;
	bh=rYzWrWy9piGXT5ZBmXaMiJlxMsdlf9SOXhgjZXKPiRQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=I1WD8KBiQkcUOqa2+mRgp6PDU/tb47ygyS/ChBh2n6MwYNntrLAWoajv3PFfTZEXuJN8ogxvb2JYfhVYrgNJbJVIwrTytQkST17oQPySQRmMmcykTSa1XKOGwmyRUhAGR6M/KIOI0pQSwuD5KNXO24rULF0E0BZX8TylKKJOLvg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hq33n/PW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hq33n/PW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69D591F000FF;
	Thu, 10 Sep 2026 13:55:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048505;
	bh=4TIFzW9rBS2GHNl8kj6jvS+gFSg0Ao6Ao574GB7bALQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hq33n/PW4QCDGzvaVLQQTzyZ6A0a+CnuWspUsPudEZ7oN2K3jiBLw3cYgvv/UrmwW
	 pQhvI30a844d8LWWNBhKHAZPgTddZZ4oDXgHddOUSWpaTAfmw7/Xp8WMUWeBL5nAq0
	 u2Mlh8UHSGLgFcB0/mLVJjYx02UTkL0sb8JdYUzFYtd/tOk4EfSXHTZwB74DVuZ7nd
	 DyXGzovkYFbB/jF+0CzLS+YiiwO6/D2yCQkd2DbRmfGBwm8k3apsReOqYBC6Y3vLLy
	 JXZsHGA5mLX+4QNwsyc37iPERYAbHFLJSDhVR7TOTKAIPEN1PS5mIK39XvV1dzswLT
	 bjpEta/FBlKpg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:49 -0400
Subject: [PATCH v3 09/12] SUNRPC: Record last-request timestamp on svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-9-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2778; i=cel@kernel.org;
 h=from:subject:message-id; bh=rYzWrWy9piGXT5ZBmXaMiJlxMsdlf9SOXhgjZXKPiRQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawIgfnLXkr0mSwjsHxbgnPNNJWaIBIz3fG5
 M4Y90WqMUqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 l/IeD/9QDidSw8vWB648UEchd/75kpwueXsF+xnwhIA5qIEt2oxvvCzzakGSRLgs6at01SUfFKz
 sEKixvb35DmYUvM3tsPFTCTOIDZ5VGc0bOUatEkAcnBWs1dzBo5yNdUH2aL0PjY7XNHaroekf2u
 yNgv/lkeKS+PTjTTJTDl8hlBZSvFGASve5DyQhngx29uZZJuy1w5bZdxuJMJtxxFAio7VTjUIMQ
 iM+PT21vp9EJRWl+cSsiT5wqf+UZ1qC4Qfhqk/ZbroOmwszJjbMDO/i6HkLbmqyskajoieeJUpC
 kH9FeCZumpE9e8vEQ47XrkGPuyou/bGYwqKYirGrF8eGJq7u1MocinfRZeL9an8xp13+CtAhrlj
 Eep7CUjehe0NeUHiq130Cha7UBCuHAJUJ/yqbr3T0mhsjn4La7g+7UT3ouz+O+7+4qAfzTK0U2I
 6zDA/Y7vQDRwmglTv3I0B+86ExdcUxXfE2mNYy0p8CHL8dbPMQNRqIhWPOToMmFttZotJ3sAJGz
 Kv4sz7CsgBRHK3FqJA5VjMVCGcdG7diJ+omIlQD4GoMC5P//hQ+DxzkMHhJlbfEErs07ydr+zNe
 Z6CU7AFrMcEsY1BQ6EIyxgr9hPgw/EWZH5I9zbyABlCjX3HpQbkHnsehNLruRJdg5jSsz2fTqre
 BrUotPtdJc3Whfg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

On a connection-oriented transport, the arrival of a later request
suggests the client received the prior reply. It is not proof: a
client with several requests outstanding sends the next one without
waiting for a reply.

Add xpt_last_recv to struct svc_xprt. svc_handle_xprt() samples
jiffies before calling xpo_recvfrom() and publishes the sample after
a successful receive. The DRC reads this value as a best-effort
signal that a completed reply has been delivered.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 net/sunrpc/svc_xprt.c           | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ec1dcb51c2a2..da234a078c5d 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -81,6 +81,7 @@ struct svc_xprt {
 	struct net		*xpt_net;
 	netns_tracker		ns_tracker;
 	const struct cred	*xpt_cred;
+	unsigned long		xpt_last_recv;	/* jiffies of last request */
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 	struct rpc_xprt_switch	*xpt_bc_xps;	/* NFSv4.1 backchannel */
 };
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 7e8ef4832421..f57dac54c8dc 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -230,6 +230,7 @@ bool svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_KERNEL);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+	xprt->xpt_last_recv = jiffies;
 
 	if (xa_alloc_cyclic(&sn->svc_xprt_ids, &id, xprt,
 			    XA_LIMIT(1, UINT_MAX), &sn->svc_xprt_id_next,
@@ -901,6 +902,8 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		svc_xprt_received(xprt);
 	} else if (svc_xprt_reserve_slot(rqstp, xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
+		unsigned long recv_time = jiffies;
+
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred)
 			len = svc_deferred_recv(rqstp);
@@ -916,6 +919,17 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 
 		clear_bit(XPT_OLD, &xprt->xpt_flags);
 
+		/*
+		 * A deferred request arrived before its deferral, so its
+		 * replay does not advance the timestamp. recv_time was
+		 * sampled before xpo_recvfrom() released XPT_BUSY.
+		 * time_after() keeps a slow thread from pushing the
+		 * timestamp past requests received since then.
+		 */
+		if (!rqstp->rq_deferred &&
+		    time_after(recv_time, READ_ONCE(xprt->xpt_last_recv)))
+			WRITE_ONCE(xprt->xpt_last_recv, recv_time);
+
 		rqstp->rq_chandle.defer = svc_defer;
 
 		if (serv->sv_stats)

-- 
2.55.0

