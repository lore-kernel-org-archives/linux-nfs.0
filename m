Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60FC74825B5
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397147; cv=none; b=vFaA+S77Op1WqX+LodW3221GDEDj2RIySyrCfam7iuLG6xDoY4OaFEZ2dfypVXDyXSlv/uHzkKyWIi0ph7v2Za4DejP/fGQkrUh498VpQex1Ug6T7vMIsgUHOErQcXTMO3Yrjjho0b8KhRaJIQ2NncO9Ft5ndunO/cC0+pGtj1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397147; c=relaxed/simple;
	bh=NbPhePj7OhsWFcF01OXnR8JRAy2oQf++RQWow0+SBaE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oxxNeB1IfGYQfQ1OmpdC6cPGmm3boRj+wiOmJ0qeJkzyuKvKqIHciJaPYFBVyYS6fjiYwJWgrqIwzcO/qHLuJd/fhnWEqYj/iom2RZzpvk+NHQALfnSvsp8cxu/OUF42QiVovx+NjTs++E0AgbKh5y/7zvkt9S9Nx7GVxHdb5No=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QpfztRgj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QpfztRgj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 45C851F00893;
	Mon, 14 Sep 2026 14:45:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397144;
	bh=CcWJQVBJjWGgHipHk0/BN9QrIT5g5DOZcInTjxTLZGs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QpfztRgjiZd0tgrYMVnUKYFmF84teVtnTTErWyU0MJSHbYLGkJ7QMmUOaCB1KuDMT
	 aK9SFbuCm9BdLgsfToW1l2Mi4ejT/ZftAsR4u6cnfjEX3yzN3JVv9b07aP8mlcPF7Z
	 EpuuY4n+j918MXViEDT8faL+QSA6JpvCe/owCv10ZyChDfDpuRAZ/f8lxC+6tNfkR6
	 nVlkKXlWblGzKKJKUj7RyfqgdiSPJ+/451RsOQ80yDZAYpZ7tHt0SRd/RmK1xQV/x1
	 o4p6EgPM23i4PepP3FcS0lbtC7U0QLaZB5yDAn5gAYjaQJ9Bnd7cFcEiIrcIB1sP8P
	 Js2wsBRZNdoVA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:31 -0400
Subject: [PATCH v4 01/11] SUNRPC: Assign a unique identifier to each
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-1-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=4353; i=cel@kernel.org;
 h=from:subject:message-id; bh=NbPhePj7OhsWFcF01OXnR8JRAy2oQf++RQWow0+SBaE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiW1zGBtxrdU35PQaitXv8RxzdzI38bZJfq1
 WeO9YZAJ2KJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 l7BpD/9hFnu3eHEfL7zjhDC3sa72un5EJlCkGUs5NJGQcUe/qVFxW415vF2lMAkAXl9mdywsRhE
 TxmEnSLRx2jng1rtfcc2exzYlBoF7QHawiMIaSE8eaCHQWtFrXSkEcUlEA3t6Lo0aRPdxmTjFuv
 hoEz/A9fGc5rWt7CjaMJHkfb93nfJ7qDF1bY5LlIaCFULNnxKBi3gS2+Audwv7KUe5YCAIAjqVF
 F8ZYVestFl+Q5ue8krI3GmW45+8dt+/Pcq3BbDV+1Dwabi214P7Q741HdEwL5cnnjXyhc5j83XM
 3MxvW9Fmm72zoYhHL1DroTGNvyXBdlC8QkcN3AST7wmdSnSSsag7wGiQNwTnTAQcHf526vkNe09
 I+viJzxFLuy2Q01/VF9Q6IaojN8Rffy3i/RTrOlWYMbxpBbS1eKJn+4FQIMs4uw2fg1NfJnKDbg
 R0JAIsX0fJSde7+abPYZ41qZd9PWwsfWcUNdU4Kz/Kc5Af6f8cMW0HKD4p4pGnclXgLDSOVCxaX
 mxvclegSgLCMX+ilOxijB+KrQXyCiWRMwTtWWazwAGKb+ZrpbK/M2EXZuyjIzmLuiTYcivvwzA1
 HlmM9eNQW9s+znGvwZ1Tp/Qd4Z3NhEaX6W0Sn9RbawqYUfDSwmeZP8rdUS8ZCU6+h2FC7j9v4sT
 3vvtNE6eesQsPiA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A consumer that associates state with a transport without holding a
reference cannot detect ABA collisions: once a transport is freed,
SLUB may hand out a new svc_xprt at the same address.

Assign each transport a 32-bit identifier from a global sequential
counter in svc_xprt_init(). An identifier is reused only after 2^32
further transports have been created, so a consumer whose
association is shorter-lived than that needs no release when the
transport is freed. The NFSD duplicate reply cache is the first
consumer. A 32-bit value fits the padding in its cache entry, and a
cache entry is retained for two minutes, not for 2^32 connections.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/trace/events/sunrpc.h   |  8 ++++++--
 net/sunrpc/svc_xprt.c           | 17 ++++++++++++++---
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 2af222f3ea2c..9f940c892eca 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -56,6 +56,7 @@ struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	const struct svc_xprt_ops *xpt_ops;
 	struct kref		xpt_ref;
+	u32			xpt_id;
 	ktime_t			xpt_qtime;
 	struct list_head	xpt_list;
 	struct lwq_node		xpt_ready;
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index ff855197880d..30d5fbb07e0a 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1986,7 +1986,8 @@ TRACE_EVENT(svc_xprt_create_err,
 		__sockaddr(server, (x)->xpt_locallen) \
 		__sockaddr(client, (x)->xpt_remotelen) \
 		__field(unsigned long, flags) \
-		__field(unsigned int, netns_ino)
+		__field(unsigned int, netns_ino) \
+		__field(u32, xpt_id)
 
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
+		"server=%pISpc client=%pISpc xpt_id=%u flags=%s"
 
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
index d5634dd6d6cc..f836a7aebd64 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -26,6 +26,8 @@
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
 module_param(svc_rpc_per_connection_limit, uint, 0644);
 
+static atomic_t svc_xprt_id_seq;
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
+ * @xprt->xpt_id is reused only after 2^32 further transports have
+ * been initialized.
+ *
+ * Context: Process context. May sleep.
  */
 void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 		   struct svc_xprt *xprt, struct svc_serv *serv)
@@ -210,6 +220,7 @@ void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	xprt->xpt_net = get_net_track(net, &xprt->ns_tracker, GFP_ATOMIC);
 	strcpy(xprt->xpt_remotebuf, "uninitialized");
+	xprt->xpt_id = atomic_inc_return(&svc_xprt_id_seq);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 

-- 
2.55.0

