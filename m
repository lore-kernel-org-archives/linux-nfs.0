Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09F774FD29C
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752096; cv=none; b=gyYCqWNGe5QCp1+8GZiZgsiqm8vlKjdls5EVhmgd88VxgNNbXGjCkPCDpLG+0JjhHBbMF/ClQ5YeDTO5Vd7J6DJIZ6vY/OaRIWG5QGhRCWTKOpROEfKFXPcZWX6pWxkF6BYTSC1iQCut/aJiU8Luvl3BT0qqx0Fqu74d6xWWm5E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752096; c=relaxed/simple;
	bh=ndp0dKQygu7J0h1iI8KDpk9FrMqHmDCaIvKQ1w9o6z0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=n/kwprh1Z8RXunhPoFlbmI6VmtBtpaAqLoqv8UqduqFCfGewxAHReEsZ2Up0PxkR2gc7/FOY6Y7h13vZ9ltHgIt3rKGki4HJrhIp/r4/XxXs2HlGgf8ZwT++FECRJcc9PhhrkP+SM93LllOhjMZWqD5c5IoPXPaMgzJVIW4s0KY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IdkcXSZw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IdkcXSZw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C57A71F00898;
	Fri, 18 Sep 2026 17:21:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752089;
	bh=Et0014LPxXBiOS7B11bhhTCvsKeh+lCl4607bnp0/c8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IdkcXSZwE6HE+pEyLfClnMy4EPcvEAwGXjIzAveDZcBeFA2vQb41x+8nZx51bE8tH
	 nUwC9yy7WCFXBMFHW8GQMJ3UIv9A8vXHQpFyzj6v1XjRkskKzsRJELIukKt+c2ppf0
	 3CObU+hHed6WQQsV/QwQOJDP1DMgVMvoDzkvu+fuCpyYKN17jwnNgz6PkubaWcFW94
	 VAwqwg6C3zwrJDs3Gcitv1FxIUlzFdz9PCnJgRFfmvUGHXzL49pmG1tGE2l3b8t5OQ
	 Dy8q2mgMe58VB9VPoLmrJThokLj0n8LF/x8rGQStfIP8zjELmWpsN6z0EQvUkbwIqP
	 iQPFXk3Kx5I4Q==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:14 -0400
Subject: [PATCH v5 02/11] SUNRPC: Assign a unique identifier to each
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-2-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4235; i=cel@kernel.org;
 h=from:subject:message-id; bh=ndp0dKQygu7J0h1iI8KDpk9FrMqHmDCaIvKQ1w9o6z0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMW9NteSXp23Sha2cMaJtiA32xvmk7IR+U6n
 QFB+ziqjbyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l8fVD/oDJZiZhmdBcqXgBnoR+c0a42cKR7Vvi4/G7TqyZrW/bQsgIOJnW/C4Tg8kH1a6vH5X8Cm
 IZooxz6uRnsaV4yVySSkHYfEX+vKgKmVAtDZwQ92ThPkKeOEEQAVcL+obgnKe47+a16lykfwhz5
 pt60ggnkQyWgbsIHMSRg0Rv5ePgj+zlkKXNdoUH8iVfJZ83v6ciSHGwaHKXk8NbUcnuu/N+JKIL
 hO/MbMBMDSIgjoRyMfmsfOZzfl5jEZoh5UHX7g5dmpSoP/VOUizoovA3UiD9xHibfNnVsHExzuE
 xogloP+sOdWnmjH1tm4w2Y6pT9ZV9Ypai3LjzToefz7W/tnOdHXSwk+fi67MDAm2AK4p060PH8d
 fYiGv77zEYOhZmTi2Tz4NV6xZpEZebfLgOiiYexsYTKQGIlMJNeU2Bk+h7nXYTXGy802suI1tOG
 EWi1ssZV0IY9IEBK6Egy3AGW2OwfUaR7cPA4Xozbq+zCoGUKJgGXYMhojxlcDh9+fEEehVjnm+8
 upltXxziUNzG9QbgC6KmQAUo6Mv+R6rR8yD8KR1XtgqLV8N9UT90vOXErcsJ9Ted7ulRj5M4X2y
 yWG9bqrOocKEcVd7cbvNCwZYZ9rdRbVYc5zbHO+ptM5+XbkCd2MIV4yJiAfkUOVxRDqa0ZRJjhD
 bNgS7mOEgMsjpiQ==
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

