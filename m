Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab1LUUe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:34:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/5] nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
Date: Wed, 21 Dec 2011 15:34:54 -0500
Message-Id: <1324499696-10318-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need a way to flag the nfs4_client as already being recorded on
stable storage so that we don't continually upcall.

The cl_cb_flags field is only using 2 bits right now, so repurpose that
to a generic flags field. Rename NFSD4_CLIENT_KILL to
NFSD4_CLIENT_CB_KILL to make it evident that it's part of the callback
flags. Add a mask that we can use for existing checks that look to see
whether any flags are set, so that the new STABLE flag doesn't
interfere.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c |   12 ++++++------
 fs/nfsd/state.h        |    8 +++++---
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7748d6a..dc5da6b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -756,7 +756,7 @@ void nfsd4_probe_callback(struct nfs4_client *clp)
 {
 	/* XXX: atomicity?  Also, should we be using cl_cb_flags? */
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
-	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
+	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	do_probe_callback(clp);
 }
 
@@ -915,7 +915,7 @@ void nfsd4_destroy_callback_queue(void)
 /* must be called under the state lock */
 void nfsd4_shutdown_callback(struct nfs4_client *clp)
 {
-	set_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags);
+	set_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags);
 	/*
 	 * Note this won't actually result in a null callback;
 	 * instead, nfsd4_do_callback_rpc() will detect the killed
@@ -966,15 +966,15 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 		clp->cl_cb_conn.cb_xprt = NULL;
 	}
-	if (test_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags))
+	if (test_bit(NFSD4_CLIENT_CB_KILL, &clp->cl_flags))
 		return;
 	spin_lock(&clp->cl_lock);
 	/*
 	 * Only serialized callback code is allowed to clear these
 	 * flags; main nfsd code can only set them:
 	 */
-	BUG_ON(!clp->cl_cb_flags);
-	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
+	BUG_ON(!(clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK));
+	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
 	c = __nfsd4_find_backchannel(clp);
 	if (c) {
@@ -1000,7 +1000,7 @@ void nfsd4_do_callback_rpc(struct work_struct *w)
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
 
-	if (clp->cl_cb_flags)
+	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
 
 	clnt = clp->cl_cb_client;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b07f5ea..1a21547 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -250,9 +250,11 @@ struct nfs4_client {
 
 	/* for v4.0 and v4.1 callbacks: */
 	struct nfs4_cb_conn	cl_cb_conn;
-#define NFSD4_CLIENT_CB_UPDATE	1
-#define NFSD4_CLIENT_KILL	2
-	unsigned long		cl_cb_flags;
+#define NFSD4_CLIENT_STABLE		(0)	/* client on stable storage */
+#define NFSD4_CLIENT_CB_UPDATE		(1)
+#define NFSD4_CLIENT_CB_KILL		(2)
+#define NFSD4_CLIENT_CB_FLAG_MASK	(0x6)
+	unsigned long		cl_flags;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
 #define NFSD4_CB_UP		0
-- 
1.7.1

