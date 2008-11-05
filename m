From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] NLM: Documenting comments for public host cache functions
Date: Wed, 05 Nov 2008 16:52:43 -0500
Message-ID: <20081105215243.16549.69632.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62621 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbYKEVxD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:53:03 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Add documenting comments for remaining undocumented public
functions in fs/lockd/host.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   49 +++++++++++++++++++++++++++++--------------------
 1 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 015c787..f357a29 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -402,11 +402,17 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	return nlm_lookup_host(&ni);
 }
 
-/*
- * Create the NLM RPC client for an NLM peer
+/**
+ * nlm_bind_host - Create the NLM RPC client for an NLM peer
+ * @host: pointer to nlm_host to bind
+ *
+ * Creates a fresh RPC client if none exists for @host, or
+ * rebinds the existing RPC client if enough time has passed.
+ *
+ * Returns pointer to @host's RPC client if successful;
+ * otherwise NULL is returned if an error occurs.
  */
-struct rpc_clnt *
-nlm_bind_host(struct nlm_host *host)
+struct rpc_clnt *nlm_bind_host(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 
@@ -469,11 +475,12 @@ nlm_bind_host(struct nlm_host *host)
 	return clnt;
 }
 
-/*
- * Force a portmap lookup of the remote lockd port
+/**
+ * nlm_rebind_host - Schedules a fresh rpcbind of the remote lockd port
+ * @host: pointer to nlm_host to bind
+ *
  */
-void
-nlm_rebind_host(struct nlm_host *host)
+void nlm_rebind_host(struct nlm_host *host)
 {
 	dprintk("lockd: rebind host %s\n", host->h_name);
 	if (host->h_rpcclnt && time_after_eq(jiffies, host->h_nextrebind)) {
@@ -482,12 +489,14 @@ nlm_rebind_host(struct nlm_host *host)
 	}
 }
 
-/*
- * Increment NLM host count
+/**
+ * nlm_get_host - Increment NLM host count
+ * @host: pointer to nlm_host
+ *
  */
-struct nlm_host * nlm_get_host(struct nlm_host *host)
+struct nlm_host *nlm_get_host(struct nlm_host *host)
 {
-	if (host) {
+	if (host != NULL) {
 		dprintk("lockd: get host %s\n", host->h_name);
 		atomic_inc(&host->h_count);
 		nlm_reset_gc_timeout(host);
@@ -495,8 +504,9 @@ struct nlm_host * nlm_get_host(struct nlm_host *host)
 	return host;
 }
 
-/*
- * Release NLM host after use
+/**
+ * nlm_release_host - Release NLM host after use
+ * @host: pointer to nlm_host
  */
 void nlm_release_host(struct nlm_host *host)
 {
@@ -573,12 +583,12 @@ again:	mutex_lock(&nlm_host_mutex);
 	mutex_unlock(&nlm_host_mutex);
 }
 
-/*
- * Shut down the hosts module.
+/**
+ * nlm_shutdown_hosts - Shut down the hosts module.
+ *
  * Note that this routine is called only at server shutdown time.
  */
-void
-nlm_shutdown_hosts(void)
+void nlm_shutdown_hosts(void)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos;
@@ -620,8 +630,7 @@ nlm_shutdown_hosts(void)
  * This GC combines reference counting for async operations with
  * mark & sweep for resources held by remote clients.
  */
-static void
-nlm_gc_hosts(void)
+static void nlm_gc_hosts(void)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos, *next;

