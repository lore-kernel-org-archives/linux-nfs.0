Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801480;
	b=xumMzHhTTV+QusIXrT4l9hYJMMGkH+OMVDf27jr6LWqzTbzcbRrYXw1AW3xDv4Qx23Lr
	 smIsd0YdurKWqWHHV/Dg5YvNiuJ/yzJLozfq15Xi2D7UL7ExmFHVJxTvcz4nEbNc/uXSI
	 c/1RuUe9sbM/u6nqhwv3QaIrBU7t89pXBITiIudEx7th78V/IjupWDpk/wrMnbbZMD+19
	 rW+TgZbjjVWzVU+nRSFFzPzarce/PDW8Kz5qkpMcTxNaMVzm+MZu9wwvN7W5GVkDTIqlZ
	 xGPi0sphZJRi4b0WkNdyosR7VLnov41qUfGttwxd1nvyVxiI3GmIjDPzUK91aOy/1Tw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801480;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EvU7V2odlggodyOuH+rjPVBT9c0F1hREWOVj6LzgAHU=;
	b=kwdpaJ8AyD/Te/cZZQZ4MFP5hUfS/byvRvbs0K8AwNtUQyZ5ZqsZ4MSr/pycdynl4NC4
	 oN225MkmuBlypu5MipV+P95iSYfMAjMZeC4bPRCeQfWsWq9L8jKa38+LB7ztUyfooe56U
	 bFZQa9eQEE91mgCO0P5HiTvyhSqFXt4IHoX38KUEHr/ySAY9SrLnIgP20ywLZ9gzDTW63
	 uKlRuFAlorjuyhUFnTk/JZQNeFgRMEInb2vheXXO4O574LVLK8jLc+F+iZsAkab0Xec0e
	 vZxVbqnlmku5bjS9/anY7OrC2P7g8allxrOz2MIoWqv3MaK1nmVQ8jSZV7Wbia/h/wg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="f1/Ya/4e";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9CDB606D820;
	Wed,  4 Nov 2026 14:11:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=f1/Ya/4e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D62331F00A15;
	Wed,  4 Nov 2026 14:11:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801479;
	bh=EvU7V2odlggodyOuH+rjPVBT9c0F1hREWOVj6LzgAHU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=f1/Ya/4eOJ2q8MJNQN/5cVtHA6HWEulfG8WMJKoYjlZIngBFu7rxc4C+E67yegf5p
	 Qo1uQ9zXjw2XmABAxjpzc2rCKIQ0Aca6ebycsl7yDcWWtImVTIk3gsNyPLvghPa07q
	 HQvvWr+hHs+l+Ls854BhbY1KUxDEIVd3ZeO17ujskn5TwIZ6MTZJ63qVQ/A8cQZ/E9
	 Dq7TLIWF/ReTn15xSuyK+f+5M3QYJ6WFlCbpwF9KdZSkK4QbgWflC2D9b33lzWy8a+
	 VaK2y2nDrpbSAnezl+AzvHzhgfMAiFH9C7g/r21KsWF6wvD7YldRLgab3IfGRRYzyd
	 dG9ocN5pkkcOA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:04 -0500
Subject: [PATCH v8 04/14] SUNRPC: Assign a unique identifier to each
 svc_xprt
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
Message-Id: <20261104-duplicate-reply-cache-v8-4-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4290; i=cel@kernel.org;
 h=from:subject:message-id; bh=5xlo0KB7Khd0Ps2XgqBr7P43qEKbVgyFIrz9tdufqUU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0A8FRuARSlurbKmX/iib01bqrGKnzHSN0c+
 GLCwklg2bmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 lzCbD/45ksQpzD3NNfMbvop0RQuj87hr4ACAiKu/zdIURiQ15sgCNgOUdnBJhZwjRhECofqD/KR
 OzbX9U7dYV1sofNnbhtzjwg1Q7S4cYRzX1LMr1i/vuyd9CWoXiDtSA/UG3sUEV8wyLh+ecySQuV
 lTgWQNypLX0hK+lPpG3p9J79UxHFYp7C8/WaVfKFGesrYgWVQBolsMPmJfDSXLE63nGqOaDjU2o
 mzU2E087Ba4KxcXW3rcuT5ERQHbykJ3zbSRwsoKC4MFxcUTECMXCiTggiXmxE39APQaK3PnWvUd
 9doSXjXAZNtPQJP3+LxnHrRJmNPiFLEdkMfTqCLipU8GqpEVj8uSzrK03R0InEWCGUf/MVPx4Js
 LjVDP1zRadK8rvONIDydkTraKvC+PMT6bRqyFhlZEnGADcRu4btnQOKPhiryEVbKDr1J2hZKm0k
 l5SNnLgUk+JihRiqpzHYPdAOiGxi6Z5+987+xRhed2DsMMdwrR+6XaBvpKFIgZ1xFDAhJFtLTb5
 0gmG84Y8rLWhkf4qvhdz1b/UgdI8SYzQBW8OiOBJjps1k+Sq4ICzGl8ZV03/s3Anht+LOUfeWBk
 u3bdpQXi4MzTgjT/Ur/T5I8c5z3aDBY/HDhK+tneUQS5wCaEGulY6kW0Hy9mwI7gxit0bXbKCiO
 hwS4Y+xpbMeVrMg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A consumer that associates state with a transport without holding a
reference cannot detect ABA collisions: once a transport is freed,
SLUB may hand out a new svc_xprt at the same address.

Assign each transport a 64-bit identifier from a global sequential
counter in svc_xprt_init(). The counter does not wrap, so two
transports never share an identifier and a consumer needs no
release when the transport is freed. The NFSD duplicate reply cache
is the first consumer.

Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-3-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/trace/events/sunrpc.h   |  8 ++++++--
 net/sunrpc/svc_xprt.c           | 17 ++++++++++++++---
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 2af222f3ea2c..52082d8ea6dd 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -56,6 +56,7 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	const struct svc_xprt_ops *xpt_ops;
 	struct kref		xpt_ref;
+	u64			xpt_id;
 	ktime_t			xpt_qtime;
 	struct list_head	xpt_list;
 	struct lwq_node		xpt_ready;
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880d..77efe63d2c14 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1986,7 +1986,8 @@ TRACE_EVENT(svc_xprt_create_err,
 		__sockaddr(server, (x)->xpt_locallen) \
 		__sockaddr(client, (x)->xpt_remotelen) \
 		__field(unsigned long, flags) \
-		__field(unsigned int, netns_ino)
+		__field(unsigned int, netns_ino) \
+		__field(u64, xpt_id)
 
 #define SVC_XPRT_ENDPOINT_ASSIGNMENTS(x) \
 		do { \
@@ -1996,13 +1997,15 @@ TRACE_EVENT(svc_xprt_create_err,
 					  (x)->xpt_remotelen); \
 			__entry->flags = (x)->xpt_flags; \
 			__entry->netns_ino = (x)->xpt_net->ns.inum; \
+			__entry->xpt_id = (x)->xpt_id; \
 		} while (0)
 
 #define SVC_XPRT_ENDPOINT_FORMAT \
-		"server=%pISpc client=%pISpc flags=%s"
+		"server=%pISpc client=%pISpc xpt_id=%llu flags=%s"
 
 #define SVC_XPRT_ENDPOINT_VARARGS \
 		__get_sockaddr(server), __get_sockaddr(client), \
+		__entry->xpt_id, \
 		show_svc_xprt_flags(__entry->flags)
 
 TRACE_EVENT(svc_xprt_enqueue,
@@ -2024,6 +2027,7 @@ TRACE_EVENT(svc_xprt_enqueue,
 				  xprt->xpt_remotelen);
 		__entry->flags = flags;
 		__entry->netns_ino = xprt->xpt_net->ns.inum;
+		__entry->xpt_id = xprt->xpt_id;
 	),
 
 	TP_printk(SVC_XPRT_ENDPOINT_FORMAT, SVC_XPRT_ENDPOINT_VARARGS)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bcc867592f2d..15c14d75ec12 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -26,6 +26,8 @@
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
 module_param(svc_rpc_per_connection_limit, uint, 0644);
 
+static atomic64_t svc_xprt_id_seq;
+
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -191,9 +193,17 @@ void svc_xprt_put(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_put);
 
-/*
- * Called by transport drivers to initialize the transport independent
- * portion of the transport instance.
+/**
+ * svc_xprt_init - initialize transport-independent portion of a transport
+ * @net: network namespace in which the transport operates
+ * @xcl: transport class providing operations and metadata
+ * @xprt: svc_xprt to initialize
+ * @serv: RPC service that owns this transport
+ *
+ * @xprt->xpt_id is never reused: the 64-bit counter behind it does
+ * not wrap.
+ *
+ * Context: Process context. May sleep.
  */
 void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 		   struct svc_xprt *xprt, struct svc_serv *serv)
@@ -211,6 +221,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+	xprt->xpt_id = atomic64_inc_return(&svc_xprt_id_seq);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 

-- 
2.56.0

