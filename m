Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297185;
	b=uMFATT9HqohYnZ0IaziauHQYiAtK5x4EwurAOMNSwOikRSUj5y0a28c8Aj+FOC2qZOfT
	 z/fk/hKIO5bjVNhScLae/XNLXjGbFrcWVvijFyvPTYqUuhSpXzYPgfxJ8FFv0Lhs0gns3
	 vI/ecKOzTDhN0YI7tRRUuW2ZOlMa+f/LLsoTRChssyLuSgVPKVPqoIfz3gKk6a254+4rs
	 4SIHYSHj0UpAKf4oqZU9Jc2t9co1yA0hPqxZhP9QZ+s6cHYamQEG5lmoiNPIhmqSxwXd2
	 JyKnolTUtsoiTdoM1ByhGo8Zk4fZhNXp23H2GpJ45vjeHyxMxN90/5yuOSU7++Sufig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297185;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=06ndftjTrqkyH2N9l/IwhaDCPszsK/TwhNypTiU6nyc=;
	b=tm46MmkaeGF0x6Ce3UX0WfpXi1vm5I5Be8gKxel44Hs+ysGDP5xdQNtOEOdJiB6wHjnn
	 3BSQe+4Sz4OHgwg0nYmHwD3wjaYu0rv5K9vhJJgvKH2CwjB7wIf55J85VJnQiLHfC1y2c
	 m8cEdrl9yiVBpBw016N28P4OE2yVvFeQw6qWuphliS/MSpfTSEj0s90I72KDHNPps2OWF
	 Us+Fi0poYn/Z9Xiey2ueNhKPbl0Thg7hDC2MpQBO+b5HeF9NsxY4At2m4mmeeK+Rzc4Rq
	 hKVaYFh6YQKt2gJvPWsMjK3K+ZrhehBRMykZPU01m2jEJO5g+hcDRHeyaVn1CKaTwTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dvPP6uJp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19165606A329
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dvPP6uJp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F4ED1F031E2;
	Thu, 29 Oct 2026 18:06:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297184;
	bh=06ndftjTrqkyH2N9l/IwhaDCPszsK/TwhNypTiU6nyc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dvPP6uJprGGgNfsqQgUDJASMPgKd0Ksp6KceRovlgMzhMKeUI8tsW9M8656o9wXVR
	 qMNV/rOHGT2iFE7JgZzIzKqmcGuWUvbKiF92QLVgWR0eLnA1OK39LxpnDqWz88KrgC
	 t4VFG2y5B1ZeCyqgLkrssKDzihbj4uor+TUtKxC3EUnGQdXC90B/+KBjUowqZKfSPC
	 OWMSkp2078c8dW+imlA+2VqKilSDYaem+TtR09XgXZV5orXU/Yij685SzWERcnYyTr
	 iQ5Q7vMsF3QHN9ktOzQscP2FbFQ4nY462De+7YEVv3+RH1XKIWu2wDKNWbybuFvTd4
	 D57TctSb99cYw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:09 -0400
Subject: [PATCH v7 03/13] SUNRPC: Assign a unique identifier to each
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
Message-Id: <20261029-duplicate-reply-cache-v7-3-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4369; i=cel@kernel.org;
 h=from:subject:message-id; bh=q7PUarJVPI9m7Bbf0coAz0dBNm93rjrKJNnBKcEwCb4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44sc2So651lj2094sdzXP/nrOZSpOnLmBFcJx
 b/PMA+IZhuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 ly34D/9LSVKf8y/nn6dqmbq0PBIheNesjYG07rqh+ymsjoYT9H+Gk4RPziVLJWPVvDqToaAL4zx
 i7sLR6QJpTpTqMYJ8ly0U7dMEihyJNM7hmDJKTS8pTykj7euP3uvbWn5jmRgg2Ccy3lvsluJw1J
 Z7wN54NZ4i0nkLoiKVf94G7dhlLcpaJPx5QEsqoflO1IbuccaXzlCIJ89wJIjj9umqbFfERlMvW
 PWCdwQQvC2E4ld9ZojMeo3sxfX5RkfqVNa2rfgklPi2nu4z1voZciROnB2VZlIhzAzgk9VKtOYp
 LwMTs+qAfbUzIosSd6gql5JM6ADOJMk+Be8YpRwQ0vcnPHfJX1nOfJwAi/r4JC1fCwDbmnP7KHU
 vjR6vuLT8wclABsYZ9EB+uwHMTwqVX+jJ0PwQMvNAUij2HNwVJaMhYlAX4D2FCC25+E19XE4WIi
 CFr/009SL5hza0I+ZZsMGuLtD35yg7k8XNEIpxn3VnICmCq7PXK7fbzI6G3QqwmVIYXtAXnlr9t
 WO4hinO3ZFgafJq0a1KLihyS1KjIpcS/NOW6ijUsuJmeCk2Qg4aTvNcBsDo6vG0kjVC++EjHAz9
 IcSBFSOcLaMQuGpBez1dm6jM4MHs78l5Tkq1VulHYWbn7hkT1yUhV1tiXxbN5HqpeFfyrx2SGMg
 qA8o6CRXEvtrmFQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A consumer that associates state with a transport without holding a
reference cannot detect ABA collisions: once a transport is freed,
SLUB may hand out a new svc_xprt at the same address.

Assign each transport a 64-bit identifier from a global sequential
counter in svc_xprt_init(). The counter cannot wrap within the
lifetime of a transport, so two live transports never share an
identifier and a consumer needs no release when the transport is
freed. The NFSD duplicate reply cache is the first consumer.

Assisted-by: LLM
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
index 076c624fe675..3eb5dc6cc330 100644
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
+ * @xprt->xpt_id is never reused: a 64-bit counter does not wrap
+ * within the lifetime of a transport.
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

