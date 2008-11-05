From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] NLM: Move nlm_host initialization into a helper
Date: Wed, 05 Nov 2008 16:52:28 -0500
Message-ID: <20081105215227.16549.99231.stgit@ingres.1015granger.net>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12187 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbYKEVwu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:50 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refactor nlm_host initialization out of nlm_lookup_host() and
into a helper.  Move the dprintk() calls outside of the nlm_host mutex.

Group the nlm_host constructor and destructor functions together by
moving nlm_destroy_host() next to the new initialization helper, and
by unifying the way nrhosts is handled.

The global next_gc is renamed to be consistent with the other global
cache variables.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |  138 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 72 insertions(+), 66 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 753c831..4dfe250 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -26,8 +26,8 @@
 #define NLM_HOST_COLLECT	(120 * HZ)
 
 static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
-static unsigned long		next_gc;
-static int			nrhosts;
+static unsigned long		nlm_next_gc;
+static unsigned long		nlm_nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
@@ -164,6 +164,56 @@ void nlm_display_address(const struct sockaddr *sap, char *buf,
 	}
 }
 
+static struct nlm_host *nlm_init_host(struct nlm_lookup_host_info *ni,
+				      struct nsm_handle *nsm)
+{
+	struct nlm_host *host;
+
+	host = kmem_cache_alloc(nlm_host_cachep, GFP_KERNEL);
+	if (!host)
+		return NULL;
+
+	memcpy(nlm_addr(host), ni->sap, ni->salen);
+	host->h_addrlen		= ni->salen;
+	nlm_clear_port(nlm_addr(host));
+	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
+
+	host->h_name		= nsm->sm_name;
+	host->h_version		= ni->version;
+	host->h_proto		= ni->protocol;
+	host->h_reclaiming	= 0;
+	host->h_server		= ni->server;
+	host->h_inuse		= 0;
+	host->h_state		= 0;			/* pseudo NSM state */
+	host->h_nsmstate	= 0;			/* real NSM state */
+	host->h_pidcount	= 0;
+
+	atomic_set(&host->h_count, 1);
+	nlm_reset_rebind_timeout(host);
+	nlm_reset_gc_timeout(host);
+
+	host->h_nsmhandle	= nsm;
+
+	nlm_display_address((struct sockaddr *)&host->h_addr,
+				host->h_addrbuf, sizeof(host->h_addrbuf));
+	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
+				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
+
+	nlm_nrhosts++;
+	return host;
+}
+
+static void nlm_destroy_host(struct nlm_host *host)
+{
+	BUG_ON(!list_empty(&host->h_lockowners));
+	BUG_ON(atomic_read(&host->h_count));
+
+	nsm_unmonitor(host);
+	nlm_host_rpc_shutdown(host);
+	kmem_cache_free(nlm_host_cachep, host);
+	nlm_nrhosts--;
+}
+
 /*
  * Common host lookup routine for server & client
  */
@@ -176,7 +226,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 
 	mutex_lock(&nlm_host_mutex);
 
-	if (time_after_eq(jiffies, next_gc))
+	if (time_after_eq(jiffies, nlm_next_gc))
 		nlm_gc_hosts();
 
 	/* We may keep several nlm_host objects for a peer, because each
@@ -209,9 +259,11 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		hlist_add_head(&host->h_hash, chain);
 
 		nlm_get_host(host);
+		mutex_unlock(&nlm_host_mutex);
+
 		dprintk("lockd: nlm_lookup_host found host %s (%s)\n",
 				host->h_name, host->h_addrbuf);
-		goto out;
+		return host;
 	}
 
 	/*
@@ -221,77 +273,32 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	if (nsm)
 		atomic_inc(&nsm->sm_count);
 	else {
-		host = NULL;
 		nsm = nsm_get_handle(ni->sap, ni->salen,
 					ni->hostname, ni->hostname_len);
-		if (!nsm) {
+		if (nsm == NULL) {
+			mutex_unlock(&nlm_host_mutex);
+
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
-			goto out;
+			return NULL;
 		}
 	}
 
-	host = kzalloc(sizeof(*host), GFP_KERNEL);
-	if (!host) {
+	host = nlm_init_host(ni, nsm);
+	if (host == NULL) {
 		nsm_release(nsm);
+		mutex_unlock(&nlm_host_mutex);
+
 		dprintk("lockd: nlm_lookup_host failed; no memory\n");
-		goto out;
+		return NULL;
 	}
-	host->h_name	   = nsm->sm_name;
-	memcpy(nlm_addr(host), ni->sap, ni->salen);
-	host->h_addrlen = ni->salen;
-	nlm_clear_port(nlm_addr(host));
-	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
-	host->h_version    = ni->version;
-	host->h_proto      = ni->protocol;
-	host->h_rpcclnt    = NULL;
-	mutex_init(&host->h_mutex);
-	nlm_reset_rebind_timeout(host);
-	nlm_reset_gc_timeout(host);
-	atomic_set(&host->h_count, 1);
-	init_waitqueue_head(&host->h_gracewait);
-	init_rwsem(&host->h_rwsem);
-	host->h_state      = 0;			/* pseudo NSM state */
-	host->h_nsmstate   = 0;			/* real NSM state */
-	host->h_nsmhandle  = nsm;
-	host->h_server	   = ni->server;
-	hlist_add_head(&host->h_hash, chain);
-	INIT_LIST_HEAD(&host->h_lockowners);
-	spin_lock_init(&host->h_lock);
-	INIT_LIST_HEAD(&host->h_granted);
-	INIT_LIST_HEAD(&host->h_reclaim);
-
-	nrhosts++;
-
-	nlm_display_address((struct sockaddr *)&host->h_addr,
-				host->h_addrbuf, sizeof(host->h_addrbuf));
-	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
-				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
-
-	dprintk("lockd: nlm_lookup_host created host %s\n",
-			host->h_name);
 
-out:
+	hlist_add_head(&host->h_hash, chain);
 	mutex_unlock(&nlm_host_mutex);
-	return host;
-}
-
-/*
- * Destroy a host
- */
-static void
-nlm_destroy_host(struct nlm_host *host)
-{
-	BUG_ON(!list_empty(&host->h_lockowners));
-	BUG_ON(atomic_read(&host->h_count));
-
-	/*
-	 * Release NSM handle and unmonitor host.
-	 */
-	nsm_unmonitor(host);
 
-	nlm_host_rpc_shutdown(host);
-	kfree(host);
+	dprintk("lockd: created nlm_host %s (%s)\n",
+			host->h_name, host->h_addrbuf);
+	return host;
 }
 
 /**
@@ -592,9 +599,9 @@ nlm_shutdown_hosts(void)
 	mutex_unlock(&nlm_host_mutex);
 
 	/* complain if any hosts are left */
-	if (nrhosts) {
+	if (nlm_nrhosts != 0) {
 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
-		dprintk("lockd: %d hosts left:\n", nrhosts);
+		dprintk("lockd: %lu hosts left:\n", nlm_nrhosts);
 		for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
 			hlist_for_each_entry(host, pos, chain, h_hash) {
 				dprintk("       %s (cnt %d use %d exp %ld)\n",
@@ -639,9 +646,8 @@ nlm_gc_hosts(void)
 			hlist_del_init(&host->h_hash);
 
 			nlm_destroy_host(host);
-			nrhosts--;
 		}
 	}
 
-	next_gc = jiffies + NLM_HOST_COLLECT;
+	nlm_next_gc = jiffies + NLM_HOST_COLLECT;
 }

