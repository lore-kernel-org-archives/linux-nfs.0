Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DE0649DB90
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996963; cv=none; b=V/mh3cuaUV4jtAUqLkQt/yqygKysuZ7zBejQjuM9/fJzvD2AdaT+XM3qLx2R9evBWT53nMxi+7Crh5FyflR+fwdE8k+sotlfBbS4w0VI5oXxUlGUbvGwbqWo32uOtGHXA41VK13uiRWwngujyut+AnszWlNkko3Jlsag4bvOleg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996963; c=relaxed/simple;
	bh=ndp0dKQygu7J0h1iI8KDpk9FrMqHmDCaIvKQ1w9o6z0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=YxXdjDniNZ1K3n9DChKHFWgF8MCJsPjwp7dY4laU/Yf7BokOVQsFNch5lEZltGr6B9QCG9IAxfcT3b/mr34g4eIF+Znyrsj2L+vENTm2KUM9mmjKObD5cP3Uj48mWmrlJdBLRqWeANWgsyh0JFd5YAI2TtRZMT+go0ndlbfE45Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TOqRx88G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TOqRx88G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 531CF1F000FF;
	Mon, 21 Sep 2026 13:22:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996962;
	bh=Et0014LPxXBiOS7B11bhhTCvsKeh+lCl4607bnp0/c8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TOqRx88GvtmGW//8pAdjkD7XLhZC2DpRZ02lBLGw29bq5Q/k+5GN199jzqaG0WLjC
	 bKgXnRszAMWbWYfpDgJJ+rf7rmUoyVKwWBsQ9YqPcaqCmUjseBVVjEd+UOnYhVRjBx
	 XO1v2uOJYM3YQpfT3CR0A8Z0PPmrVhS5tgb5cUqpDFiEbh/T5T1nukMrf7LYxckq5F
	 Zbh3rSPtpzE1h5/7XqJV2HEvJ9gHoupWER1fHONpDIlFJZhqU5AFnI8FxTU8IAlFLw
	 EpYZzAfOYyF+1O5yF71+o14Nhazn/HFbS5554aWVyhNEA6C+fggC6Xt0Z1DbkzToRH
	 u5fQzQPwSh2MA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:29 -0400
Subject: [PATCH v6 03/12] SUNRPC: Assign a unique identifier to each
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-3-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4235; i=cel@kernel.org;
 h=from:subject:message-id; bh=ndp0dKQygu7J0h1iI8KDpk9FrMqHmDCaIvKQ1w9o6z0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+dCGyzLqFG8Bv5BIKK/yuGTgPyE4HEoVwX4
 bcag4U0fSqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l36RD/40z3rTifWYzjdEgbRMR7+XWSjZeoTqOBHy7ZDikbiiXYy3ffkYniZC1d9Uvi1LoJeqHcG
 lyLuq15q1KEiS++l+dOzNhK2j3cFXERussSlUQOKPJCMpTHIBol7Uc861+Qrg9BjaaX3OdjUApO
 fNAcid4bl6LrggRpz1NMBzzrk+Pq4vZmIx2XKVJtSQEwo5lNZWQtRtNfs7D8nx1mtfH7VzYqhO4
 4nT2MQ4xGM1XuZbU1MALkZ8Ufk4sJverNLaJH9Cxt16PtRRJ1rxw2dYqH4tgvaWZjRfP1bd9TAB
 agc57IaDJctmdEdHr/FnpbBlwK61mOnts3y6fRFsMuxXifqy01c+oA9rodCafpksL1PPZFDbUJp
 8UZVPz+nXKvW7p+nV5Db4pa6+nZlqifDzc10Iv4Vx72xFSlT1u1u9d7RgWW0d7hAxwy5X6lOwbO
 mddOfud7tBgcucmaZ0azXrK1Nd2Hl7EWf+W1dRRBwI2YFq9CKWKObJrEniZEveVef0yMW+Vordf
 I/7KRkVFejDCXYbH4ukeT6E2BhiKrLn5gYZZC1r9PJiFDOgblGO9etcPBjkr1q8b3ekZZyid0z+
 YR4Xd53RNkmIbdZjyVYkLiTmvSm/aYN5T+bbMP9uIibXXVQT3UefCf9lmIvF0tJgPGgoQlmPiKt
 d67/ueWQiYIo7fg==
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
index d5634dd6d6cc..463ba8d77f0c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -26,6 +26,8 @@
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
 module_param(svc_rpc_per_connection_limit, uint, 0644);
 
+static atomic64_t svc_xprt_id_seq;
+
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -190,9 +192,17 @@ void svc_xprt_put(struct svc_xprt *xprt)
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
@@ -210,6 +220,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+	xprt->xpt_id = atomic64_inc_return(&svc_xprt_id_seq);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 

-- 
2.55.0

