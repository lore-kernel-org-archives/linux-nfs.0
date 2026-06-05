Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD95072617;
	Fri,  5 Jun 2026 20:40:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780692037; cv=none; b=UVnexZi+cG4rAe8EH/toVVTUR5GDIA2pcgB9g/8o8+D6HdnnWGE+99PKFWO7Z1MQf2tPbIF6unRTlMuUgBC3yURgSJ+ukNFiVa0/l1wtbZmfhrvtjLmVn55s4Nz9TtA2zgDjc7qjZqpz2U093NYTiwDlvG8E+QBKBoKknIHa7Fw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780692037; c=relaxed/simple;
	bh=U181sIx8IWzFvugv+s0bc4kG67hQ3+Gd0HjhWSh8H7g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dlhpU+j8QzjBlbncmmgJrC20VGqeLVpUSw3TWzM4bNpxqj+tD5AuUUB+7KabR7Se6tS+RQbnnPFmGFhysQU5aXsI4Xb5SIhHQP5hhGFKFeBDwA7PShkRtDRae1EAjPUkfRDVmkar2HDj+9QVCaZPNuZMKEkCYYU53NsrSiuqwDI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g7O87TgD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g7O87TgD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 275981F00893;
	Fri,  5 Jun 2026 20:40:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780692036;
	bh=lkEPqQMnYqU25uBaHEr5bE5EDkdta/kC1cX7xIpfoYw=;
	h=From:To:Cc:Subject:Date;
	b=g7O87TgDyt9VCTRn+4spwToKABrHVmDmDZKKM0Fdg8P/WdoX7fuUHas7RaOq3KP67
	 eBQPVpNA/39lIHDIYEjjmaCXZnJaJLL9y1kA8lIyoMMshyqD5OVZSzDukQZ+qXrb81
	 4a4ZkqfVhvEADe7Exi+BYJMLflMfIr4Vo9B/A9aDLpRb8ujwLiptb73Lvik5eAFqAx
	 Ym4fy9Z99RrD6voNGLzTHkhJ7JrSa1GTGIFbKe0gwjVY34j5IKk4mDbYYCnxE9Hf6L
	 k5oT/qKkJtPHBSjsXM0xE4TQceedcWDTLOwiw0Jxe9gvjJI269ajyQXSdYJ/qGclyK
	 1Lyx0KE/52n+A==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] xprtrdma: Convert send buffer free list to llist
Date: Fri,  5 Jun 2026 16:40:33 -0400
Message-ID: <20260605204033.62894-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

rpcrdma_buffer_get() and rpcrdma_buffer_put() both take rb_lock to
pop/push from the rb_send_bufs free list. Under high I/O concurrency
(e.g., nconnect=N with small random writes), this spinlock is contended
between the request submission path and the transport completion path.

Replace the list_head with an llist_head. The put side uses
lockless llist_add(), which is safe for concurrent producers. The
get side retains the spinlock to satisfy the llist single-consumer
contract portably; submitters continue to serialize there. Completion
handlers returning buffers no longer contend on rb_lock, eliminating
contention on the return path.

rb_lock remains for the MR free list and the tracking lists used
during setup and teardown. rb_free_reps already uses llist_head, so
the llist idiom is established in this structure. The precedent is the
data structure, not the locking: rb_free_reps serializes its single
consumer through the re_receiving gate in rpcrdma_post_recvs, whereas
rb_send_bufs serializes its consumer with rb_lock. Both satisfy the
llist single-consumer contract.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     | 32 ++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |  8 ++++----
 2 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 92c691d2521f..993bc5c444a4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1120,7 +1120,7 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 	INIT_LIST_HEAD(&buf->rb_all_mrs);
 	INIT_WORK(&buf->rb_refresh_worker, rpcrdma_mr_refresh_worker);
 
-	INIT_LIST_HEAD(&buf->rb_send_bufs);
+	init_llist_head(&buf->rb_send_bufs);
 	INIT_LIST_HEAD(&buf->rb_allreqs);
 	INIT_LIST_HEAD(&buf->rb_all_reps);
 
@@ -1134,7 +1134,7 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 					 RPCRDMA_V1_DEF_INLINE_SIZE * 2);
 		if (!req)
 			goto out;
-		list_add(&req->rl_list, &buf->rb_send_bufs);
+		llist_add(&req->rl_node, &buf->rb_send_bufs);
 	}
 
 	init_llist_head(&buf->rb_free_reps);
@@ -1214,16 +1214,14 @@ static void rpcrdma_mrs_destroy(struct rpcrdma_xprt *r_xprt)
 void
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
+	struct rpcrdma_req *req, *next;
+	struct llist_node *node;
+
 	rpcrdma_reps_destroy(buf);
 
-	while (!list_empty(&buf->rb_send_bufs)) {
-		struct rpcrdma_req *req;
-
-		req = list_first_entry(&buf->rb_send_bufs,
-				       struct rpcrdma_req, rl_list);
-		list_del(&req->rl_list);
+	node = llist_del_all(&buf->rb_send_bufs);
+	llist_for_each_entry_safe(req, next, node, rl_node)
 		rpcrdma_req_destroy(req);
-	}
 }
 
 /**
@@ -1270,15 +1268,15 @@ void rpcrdma_reply_put(struct rpcrdma_buffer *buffers, struct rpcrdma_req *req)
 struct rpcrdma_req *
 rpcrdma_buffer_get(struct rpcrdma_buffer *buffers)
 {
-	struct rpcrdma_req *req;
+	struct llist_node *node;
 
+	/* Calls to llist_del_first are required to be serialized */
 	spin_lock(&buffers->rb_lock);
-	req = list_first_entry_or_null(&buffers->rb_send_bufs,
-				       struct rpcrdma_req, rl_list);
-	if (req)
-		list_del_init(&req->rl_list);
+	node = llist_del_first(&buffers->rb_send_bufs);
 	spin_unlock(&buffers->rb_lock);
-	return req;
+	if (!node)
+		return NULL;
+	return llist_entry(node, struct rpcrdma_req, rl_node);
 }
 
 /**
@@ -1291,9 +1289,7 @@ void rpcrdma_buffer_put(struct rpcrdma_buffer *buffers, struct rpcrdma_req *req)
 {
 	rpcrdma_reply_put(buffers, req);
 
-	spin_lock(&buffers->rb_lock);
-	list_add(&req->rl_list, &buffers->rb_send_bufs);
-	spin_unlock(&buffers->rb_lock);
+	llist_add(&req->rl_node, &buffers->rb_send_bufs);
 }
 
 /* Returns a pointer to a rpcrdma_regbuf object, or NULL.
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f879d9b9f57e..ae036719f840 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -332,7 +332,7 @@ enum {
 
 struct rpcrdma_buffer;
 struct rpcrdma_req {
-	struct list_head	rl_list;
+	struct llist_node	rl_node;
 	struct rpc_rqst		rl_slot;
 	struct rpcrdma_rep	*rl_reply;
 	struct xdr_stream	rl_stream;
@@ -374,14 +374,14 @@ rpcrdma_mr_pop(struct list_head *list)
 }
 
 /*
- * struct rpcrdma_buffer -- holds list/queue of pre-registered memory for
- * inline requests/replies, and client/server credits.
+ * struct rpcrdma_buffer -- holds pre-registered memory for inline
+ * requests/replies, and client/server credits.
  *
  * One of these is associated with a transport instance
  */
 struct rpcrdma_buffer {
 	spinlock_t		rb_lock;
-	struct list_head	rb_send_bufs;
+	struct llist_head	rb_send_bufs;
 	struct list_head	rb_mrs;
 
 	unsigned long		rb_sc_head;
-- 
2.54.0

