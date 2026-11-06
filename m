Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794007757;
	b=QLuI8prZL+BHTiEyeQRGP7X2WN8ecEZNGxiX6xp82Px2gVF9NpIBG5IQxTCNDca5XIPq
	 +Ygd0+9+vMtALCfOVR5ngKMwZ2bWfIRNa3pVjsjICGZvSUucExET7L6yJzgTKEKyiCjah
	 Al+rYv4Z4M4LxP7jA5KuKv3yxt9eF7/XQHRj/CklCtp6UDpE3gHSFZ/Njz0MovITYwRfJ
	 8Hh8mtqH/CePwoe//WJVTOFxjZ9zFhm0Bu4ikN0jxB62wYA8SLRHIFVMHb6f2iJI6gSAR
	 Nz2QeJXKhUyP49/tO+DGbIPPTtZvaAGIpnSB3ZmLU07n2OFJtD53YtUA4zLW62ygcoA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794007757;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=kYFZ4z5szhiqDJbXWSopTHfSV9a6JuHSLqqLGY/dIEk=;
	b=Rb1c+T6xzN5dF1gvIA5M6Eb8d0w1+MEDM42NifFatl5oQ7g7IjpDXbG7+M1FpZUmoDVv
	 LffPka892sP7HKB4JG+dtIrX/9w2zWCqTEoXjaCTwqJvl5nq+0TkC/gLUs/P12rQpcq/8
	 mqOeClAOYF4tG4ZnzGTjrp80QD7l8CjTtdUkH82VZ7Pp8kdG9riruc3fOx7H23lZ4ek82
	 K9q1Pm70ndXSrH5WWxQi0fpM8bkcJ7eg/VyybHDkB/2bSK6hwFiOjE8Nue8RG0ucV5UWi
	 fIA8fxYHxhRhbR7JcYIxsSn9qtQmpPVuKPuBqb70DtqBepjrRvpJdesP7OGOLK3rJYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=4gOnASRe;
	arc=none smtp.remote-ip=209.85.160.226
Received: from mail-qt1-f226.google.com (mail-qt1-f226.google.com [209.85.160.226])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 159B8606A32F
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 23:29:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 159B8606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=4gOnASRe
Received: by mail-qt1-f226.google.com with SMTP id d75a77b69052e-5364d86f7f0so13374561cf.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 15:29:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794007755; x=1794612555; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kYFZ4z5szhiqDJbXWSopTHfSV9a6JuHSLqqLGY/dIEk=;
        b=4gOnASReIVciaxo3njGypltszkdh/surDKmgTSuXPLUl9cDHcIi7TYWn+/sG5m1E17
         3i4KjwsKbBfy57AK5POWl0G3kuv6NHNMEslRXjWZHcWfE9PK/yHh3LtlINRWskbOpBiu
         gtEiGhLubK63hGhy5GBpIFQ2pocbsBom67lBpL2plmTg6kxWSOFBtqWoLfd7OtWnJpwf
         5tVT65eSrNrJJ8mB4jB4abz6jEgqbu3cgKwkhPAizMP/S4uOSJ2pEV28Ztl96tZwS/cK
         VcRQZfTEugGbD0nmfwAG8sQ1C6zPrco2ZSs6qE2zKuRSxTTc8oxJPSsGZOt2KpOJrA4d
         FAOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794007755; x=1794612555;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kYFZ4z5szhiqDJbXWSopTHfSV9a6JuHSLqqLGY/dIEk=;
        b=v+MWFUBLinPslKHLrJPtbDC9maFiLtNWw+Pfg0X3G+im/UREemwixnoBJCeSVVZL4w
         iFBvy+eJ0wXDPXdKb0H671BiW9zZW+OVm3ViTvaTYrp5h3uJs377r9zC4fozEDcRlEOA
         m/853GkUMU8Yjn6YPelW24bofhi090nZ6imgh+TA61ll2gFnHcjpEvItDWFhUYq9pxd5
         JHbtFUX0m7LRwJiciZ4rDZ7LJYzK8f22lq2vQQab8GhFxGpm2Hco4evA4lvw5msVgE66
         Qevb3tp6j4yzFrtUxK6v/lTBqkjxwvhWB5TShx2JULVsEh8kzv4beXSdKJi1e8Ltjc9J
         t3KA==
X-Forwarded-Encrypted: i=1; AKwUvBz3Z+BhHMwcI9RBpZLWiGkiMhg3MOZh/qPP0ioJbD8atXK4aavLhgtIQBNUvNmsQQ7394C6Erx0xZ0=@vger.kernel.org
X-Gm-Message-State: APuU4Z/ZWST8/Eoijotr8lbwdlC37dJQuKb27MS8FOXN3j+YK5Ek54sM
	+V2Vb28k0DwvwqabGdmz2YplhoviracSwPwWfjhps35k3Wbi94hMJNnTsid4iTa5pA2Jr9QWIXC
	WJb1/g/90Q8WYhjUQBXG8m9F8gw7WSmO6JxQH
X-Gm-Gg: AYBFou1b24yncFoZ2n3FZXG7GQrpkiS0TOqu+vv+SK5yjPDBVywfuB1tYIesZ5sBNNK
	X5foe45piK1Rc1PSB+ZHb09bRgTHWzZfEb7NPiMja0DHcaqij9pDjaDA++ZBgHJB+Fq4OOeaWZW
	9v+gRsyOO69igqT6vj5NNfIqGjBpB26pzuJwEPhuKiWTqb45EYcrum/rzP7nUdz8m7++RaURbFb
	R5tjM1SbDxBfmjoWs3VHT/ICk6vfJcbTT6WjI0agRzpSuvsAkvINfZEOhZ45K+X6MFfBEl7fbXe
	OmFsc+1gDdUEIuh/HJcy70cyNlFh8GNOyD1N6C4ZxoLxtgHlaDDf7vgUQ6m2dhDIld33Ny9EgST
	RjZVA+7MOF8+dqUmhoYGRd7kfNw7TIRdFeSyJKsk=
X-Received: by 2002:a05:622a:2a07:b0:536:83ab:68e7 with SMTP id d75a77b69052e-54e0fdf35dbmr63814461cf.7.1794007754958;
        Fri, 06 Nov 2026 15:29:14 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id d75a77b69052e-54e233cc815sm460371cf.6.2026.11.06.15.29.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 15:29:14 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 3C501340357;
	Fri,  6 Nov 2026 15:28:44 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com
Subject: [PATCH v3 1/2] SUNRPC: add request-scoped disconnects when cancelling tasks
Date: Fri,  6 Nov 2026 23:28:42 +0000
Message-ID: <20261106232844.2176820-2-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261106232844.2176820-1-tmenninger@everpuredata.com>
References: <20261106232844.2176820-1-tmenninger@everpuredata.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

rpc_cancel_tasks() allows callers to cancel a selected set of RPC tasks,
but callers that also need to tear down the connection currently have to
disconnect at the rpc_clnt level.

That is broader than necessary for clients with multiple transports. A
cancelled request is associated with a specific rpc_xprt and records the
connection generation on which it was transmitted in rq_connect_cookie.

Add rpc_cancel_tasks_and_disconnect() to cancel matching tasks and mark
matching requests that remain on the transport transmit or receive queues
for conditional transport disconnect when the request is released.

Store the disconnect indication in struct rpc_rqst rather than struct
rpc_task. An RPC task can release one request and later acquire another,
so task-scoped state could otherwise be consumed by a successor request
and disconnect the wrong transport generation.

After cancelling matching tasks, walk the client's transports and mark
matching requests belonging to that client that remain on the transmit
or receive queues. An rpc_xprt may be shared by multiple rpc_clnt
instances, so requests belonging to other clients are not marked.

When a marked request is released, consume the marker under the existing
transport_lock critical section. If the request was transmitted, call
xprt_conditional_disconnect_locked() with its rq_connect_cookie. The
disconnect is skipped if that cookie no longer matches the transport's
current connection generation.

This adds no lock acquisition to the normal request-release path.
Requests that were never transmitted do not trigger this additional
disconnect.

Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 include/linux/sunrpc/sched.h |   4 ++
 include/linux/sunrpc/xprt.h  |   5 ++
 net/sunrpc/clnt.c            |  94 ++++++++++++++++++++++++------
 net/sunrpc/sunrpc.h          |   8 +++
 net/sunrpc/xprt.c            | 107 +++++++++++++++++++++++++++++++++--
 5 files changed, 195 insertions(+), 23 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0dbdf3722537f..dbaad8b5f181c 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -230,6 +230,10 @@ unsigned long	rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
 				 bool (*fnmatch)(const struct rpc_task *,
 						 const void *),
 				 const void *data);
+unsigned long	rpc_cancel_tasks_and_disconnect(struct rpc_clnt *clnt, int error,
+						bool (*fnmatch)(const struct rpc_task *,
+								const void *),
+						const void *data);
 void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 005730623f3be..780eaa157a9f6 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -112,6 +112,11 @@ struct rpc_rqst {
 
 	ktime_t			rq_xtime;	/* transmit time stamp */
 	int			rq_ntrans;
+	bool                    rq_disconnect_on_release;
+						/*
+						 * protected by rq_xprt->transport_lock
+						 * while the request is active
+						 */
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	struct lwq_node		rq_bc_list;	/* Callback service list */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf826..5c33bf3fb4c34 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -901,29 +901,36 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_killall_tasks);
 
-/**
- * rpc_cancel_tasks - try to cancel a set of RPC tasks
- * @clnt: Pointer to RPC client
- * @error: RPC task error value to set
- * @fnmatch: Pointer to selector function
- * @data: User data
- *
- * Uses @fnmatch to define a set of RPC tasks that are to be cancelled.
- * The argument @error must be a negative error value.
- */
-unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
-			       bool (*fnmatch)(const struct rpc_task *,
-					       const void *),
-			       const void *data)
+struct rpc_cancel_disconnect_ctx {
+	bool (*fnmatch)(const struct rpc_task *task, const void *data);
+	const void *data;
+};
+
+static int rpc_mark_xprt_disconnect_on_release(struct rpc_clnt *clnt,
+					       struct rpc_xprt *xprt,
+					       void *arg)
+{
+	struct rpc_cancel_disconnect_ctx *ctx = arg;
+
+	xprt_mark_matching_reqs_disconnect_on_release(xprt, clnt,
+						      ctx->fnmatch,
+						      ctx->data);
+	return 0;
+}
+
+static unsigned long
+__rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
+		   bool (*fnmatch)(const struct rpc_task *,
+				   const void *),
+		   const void *data,
+		   bool disconnect)
 {
 	struct rpc_task *task;
 	unsigned long count = 0;
 
 	if (list_empty(&clnt->cl_tasks))
 		return 0;
-	/*
-	 * Spin lock all_tasks to prevent changes...
-	 */
+
 	spin_lock(&clnt->cl_lock);
 	list_for_each_entry(task, &clnt->cl_tasks, tk_task) {
 		if (!RPC_IS_ACTIVATED(task))
@@ -934,10 +941,63 @@ unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
 		count++;
 	}
 	spin_unlock(&clnt->cl_lock);
+
+	if (disconnect && count) {
+		struct rpc_cancel_disconnect_ctx ctx = {
+			.fnmatch = fnmatch,
+			.data = data,
+		};
+		rpc_clnt_iterate_for_each_xprt(clnt,
+					       rpc_mark_xprt_disconnect_on_release,
+					       &ctx);
+	}
 	return count;
 }
+
+/**
+ * rpc_cancel_tasks - try to cancel a set of RPC tasks
+ * @clnt: Pointer to RPC client
+ * @error: RPC task error value to set
+ * @fnmatch: Pointer to selector function
+ * @data: User data
+ *
+ * Uses @fnmatch to define a set of RPC tasks that are to be cancelled.
+ * The argument @error must be a negative error value.
+ */
+unsigned long rpc_cancel_tasks(struct rpc_clnt *clnt, int error,
+			       bool (*fnmatch)(const struct rpc_task *,
+					       const void *),
+			       const void *data)
+{
+	return __rpc_cancel_tasks(clnt, error, fnmatch, data, false);
+}
 EXPORT_SYMBOL_GPL(rpc_cancel_tasks);
 
+/**
+ * rpc_cancel_tasks_and_disconnect - cancel matching RPC tasks
+ * @clnt: Pointer to RPC client
+ * @error: RPC task error value to set
+ * @fnmatch: Pointer to selector function
+ * @data: User data
+ *
+ * Like rpc_cancel_tasks(), but after cancelling matching tasks, marks
+ * matching in-flight requests so that xprt_release() conditionally
+ * disconnects the connection generation on which each request was sent.
+ *
+ * @fnmatch is called while holding spinlocks and must not sleep.
+ *
+ * Returns the number of active tasks matched by @fnmatch.
+ */
+unsigned long
+rpc_cancel_tasks_and_disconnect(struct rpc_clnt *clnt, int error,
+				bool (*fnmatch)(const struct rpc_task *,
+						const void *),
+				const void *data)
+{
+	return __rpc_cancel_tasks(clnt, error, fnmatch, data, true);
+}
+EXPORT_SYMBOL_GPL(rpc_cancel_tasks_and_disconnect);
+
 static int rpc_clnt_disconnect_xprt(struct rpc_clnt *clnt,
 				    struct rpc_xprt *xprt, void *dummy)
 {
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index e3c6e3b63f0ba..11b9e5cead8e2 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -38,9 +38,17 @@ static inline int sock_is_loopback(struct sock *sk)
 
 struct svc_serv;
 struct svc_rqst;
+struct rpc_clnt;
+struct rpc_task;
+struct rpc_xprt;
 int rpc_clients_notifier_register(void);
 void rpc_clients_notifier_unregister(void);
 void auth_domain_cleanup(void);
 void svc_sock_update_bufs(struct svc_serv *serv);
 enum svc_auth_status svc_authenticate(struct svc_rqst *rqstp);
+void xprt_mark_matching_reqs_disconnect_on_release(struct rpc_xprt *xprt,
+						   const struct rpc_clnt *clnt,
+						   bool (*fnmatch)(const struct rpc_task *,
+								   const void *),
+						   const void *data);
 #endif /* _NET_SUNRPC_SUNRPC_H */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 48a3618cbb29f..c110806989c5d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -812,6 +812,17 @@ xprt_request_retransmit_after_disconnect(struct rpc_task *task)
 		!xprt_connected(xprt);
 }
 
+static void xprt_conditional_disconnect_locked(struct rpc_xprt *xprt,
+					       unsigned int cookie)
+	__must_hold(&xprt->transport_lock)
+{
+	if (cookie != xprt->connect_cookie)
+		return;
+	if (test_bit(XPRT_CLOSING, &xprt->state))
+		return;
+	xprt_schedule_autoclose_locked(xprt);
+}
+
 /**
  * xprt_conditional_disconnect - force a transport to disconnect
  * @xprt: transport to disconnect
@@ -827,12 +838,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
 {
 	/* Don't race with the test_bit() in xprt_clear_locked() */
 	spin_lock(&xprt->transport_lock);
-	if (cookie != xprt->connect_cookie)
-		goto out;
-	if (test_bit(XPRT_CLOSING, &xprt->state))
-		goto out;
-	xprt_schedule_autoclose_locked(xprt);
-out:
+	xprt_conditional_disconnect_locked(xprt, cookie);
 	spin_unlock(&xprt->transport_lock);
 }
 
@@ -1434,6 +1440,79 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+static bool
+xprt_request_matches(const struct rpc_rqst *req,
+		     const struct rpc_clnt *clnt,
+		     bool (*fnmatch)(const struct rpc_task *, const void *),
+		     const void *data)
+{
+	const struct rpc_task *task = req->rq_task;
+
+	return task && task->tk_client == clnt && fnmatch(task, data);
+}
+
+static void
+xprt_request_mark_disconnect_on_release(struct rpc_xprt *xprt,
+					struct rpc_rqst *req)
+	__must_hold(&xprt->queue_lock)
+{
+	spin_lock(&xprt->transport_lock);
+	req->rq_disconnect_on_release = true;
+	spin_unlock(&xprt->transport_lock);
+}
+
+/**
+ * xprt_mark_matching_reqs_disconnect_on_release - mark matching in-flight
+ *                                     requests for connection-generation
+ *                                     teardown at release
+ * @xprt: transport whose queues to walk
+ * @clnt: RPC client whose requests are eligible
+ * @fnmatch: selector called with the request's owning rpc_task
+ * @data: caller data forwarded to @fnmatch
+ *
+ * @fnmatch must not sleep and must be safe to call while xprt->queue_lock
+ * is held.
+ *
+ * Walks the transmit queue (including per-owner rq_xmit2 chains) and the
+ * receive tree under xprt->queue_lock and marks each matching rpc_rqst so
+ * that xprt_release() will conditionally disconnect the transport against
+ * that request's rq_connect_cookie. Requests remain eligible for marking
+ * while they are present on a transport queue. The marker is set under
+ * xprt->transport_lock, nested inside xprt->queue_lock, and xprt_release()
+ * consumes it with xprt->transport_lock held after removing queue membership.
+ *
+ * The @clnt qualification preserves the selection domain of
+ * rpc_cancel_tasks(). An rpc_xprt may be shared by multiple rpc_clnt
+ * instances, so requests belonging to other clients must not be marked.
+ */
+void
+xprt_mark_matching_reqs_disconnect_on_release(struct rpc_xprt *xprt,
+					      const struct rpc_clnt *clnt,
+					      bool (*fnmatch)(const struct rpc_task *,
+							      const void *),
+					      const void *data)
+{
+	struct rpc_rqst *req, *pos;
+	struct rb_node *n;
+
+	spin_lock(&xprt->queue_lock);
+	list_for_each_entry(req, &xprt->xmit_queue, rq_xmit) {
+		if (xprt_request_matches(req, clnt, fnmatch, data))
+			xprt_request_mark_disconnect_on_release(xprt, req);
+		list_for_each_entry(pos, &req->rq_xmit2, rq_xmit2) {
+			if (xprt_request_matches(pos, clnt, fnmatch, data))
+				xprt_request_mark_disconnect_on_release(xprt,
+									pos);
+		}
+	}
+	for (n = rb_first(&xprt->recv_queue); n; n = rb_next(n)) {
+		req = rb_entry(n, struct rpc_rqst, rq_recv);
+		if (xprt_request_matches(req, clnt, fnmatch, data))
+			xprt_request_mark_disconnect_on_release(xprt, req);
+	}
+	spin_unlock(&xprt->queue_lock);
+}
+
 /**
  * xprt_request_dequeue_xprt - remove a task from the transmit+receive queue
  * @task: pointer to rpc_task
@@ -1915,6 +1994,7 @@ xprt_request_init(struct rpc_task *task)
 	req->rq_rcv_buf.bvec = NULL;
 	req->rq_release_snd_buf = NULL;
 	req->rq_seqno_count = 0;
+	req->rq_disconnect_on_release = false;
 	xprt_init_majortimeo(task, req, task->tk_client->cl_timeout);
 
 	trace_xprt_reserve(req);
@@ -1991,6 +2071,20 @@ void xprt_release(struct rpc_task *task)
 	xprt = req->rq_xprt;
 	xprt_request_dequeue_xprt(task);
 	spin_lock(&xprt->transport_lock);
+	if (unlikely(req->rq_disconnect_on_release)) {
+		req->rq_disconnect_on_release = false;
+		/*
+		 * Dequeue may skip queue_lock. Pair with the fully ordered
+		 * test_and_clear_bit(RPC_TASK_NEED_XMIT) in
+		 * xprt_request_dequeue_transmit_locked() to order the runstate
+		 * check before reading the sender's rq_ntrans and
+		 * rq_connect_cookie updates.
+		 */
+		smp_rmb();
+		if (req->rq_ntrans > 0)
+			xprt_conditional_disconnect_locked(xprt,
+							   req->rq_connect_cookie);
+	}
 	xprt->ops->release_xprt(xprt, task);
 	if (xprt->ops->release_request)
 		xprt->ops->release_request(task);
@@ -2020,6 +2114,7 @@ xprt_init_bc_request(struct rpc_rqst *req, struct rpc_task *task,
 	task->tk_rqstp = req;
 	req->rq_task = task;
 	xprt_init_connect_cookie(req, req->rq_xprt);
+	req->rq_disconnect_on_release = false;
 	/*
 	 * Set up the xdr_buf length.
 	 * This also indicates that the buffer is XDR encoded already.
-- 
2.53.0

