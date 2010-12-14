Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50394 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0LNPF1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:05:27 -0500
Received: by iwn9 with SMTP id 9so869249iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:05:26 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/11] lockd: Add nlm_alloc_host()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:05:23 -0500
Message-ID: <20101214150523.2736.87862.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Refactor nlm_host allocation and initialization into a separate
function.  This will be the common piece of server and client nlm_host
lookup logic after the nlm_host cache is split.

Small change: use kmalloc() instead of kzalloc(), as we're overwriting
almost all fields in the new nlm_host struct with non-zero values
immediately after it is allocated.  An added benefit is we now have an
explicit reference to each field name where it is initialized (for all
you cscope fans out there).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |  110 +++++++++++++++++++++++++++++++++----------------------
 1 files changed, 65 insertions(+), 45 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 2dbf139..1911f34 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -100,6 +100,68 @@ static unsigned int nlm_hash_address(const struct sockaddr *sap)
 }
 
 /*
+ * Allocate and initialize an nlm_host.  Common to both client and server.
+ */
+static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
+				       struct nsm_handle *nsm)
+{
+	struct nlm_host *host = NULL;
+	unsigned long now = jiffies;
+
+	if (nsm != NULL)
+		atomic_inc(&nsm->sm_count);
+	else {
+		host = NULL;
+		nsm = nsm_get_handle(ni->sap, ni->salen,
+					ni->hostname, ni->hostname_len);
+		if (unlikely(nsm == NULL)) {
+			dprintk("lockd: %s failed; no nsm handle\n",
+				__func__);
+			goto out;
+		}
+	}
+
+	host = kmalloc(sizeof(*host), GFP_KERNEL);
+	if (unlikely(host == NULL)) {
+		dprintk("lockd: %s failed; no memory\n", __func__);
+		nsm_release(nsm);
+		goto out;
+	}
+
+	memcpy(nlm_addr(host), ni->sap, ni->salen);
+	host->h_addrlen    = ni->salen;
+	rpc_set_port(nlm_addr(host), 0);
+	host->h_srcaddrlen = 0;
+
+	host->h_rpcclnt    = NULL;
+	host->h_name	   = nsm->sm_name;
+	host->h_version    = ni->version;
+	host->h_proto      = ni->protocol;
+	host->h_reclaiming = 0;
+	host->h_server     = ni->server;
+	host->h_noresvport = ni->noresvport;
+	host->h_inuse      = 0;
+	init_waitqueue_head(&host->h_gracewait);
+	init_rwsem(&host->h_rwsem);
+	host->h_state      = 0;
+	host->h_nsmstate   = 0;
+	host->h_pidcount   = 0;
+	atomic_set(&host->h_count, 1);
+	mutex_init(&host->h_mutex);
+	host->h_nextrebind = now + NLM_HOST_REBIND;
+	host->h_expires    = now + NLM_HOST_EXPIRE;
+	INIT_LIST_HEAD(&host->h_lockowners);
+	spin_lock_init(&host->h_lock);
+	INIT_LIST_HEAD(&host->h_granted);
+	INIT_LIST_HEAD(&host->h_reclaim);
+	host->h_nsmhandle  = nsm;
+	host->h_addrbuf    = nsm->sm_addrbuf;
+
+out:
+	return host;
+}
+
+/*
  * Common host lookup routine for server & client
  */
 static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
@@ -150,55 +212,13 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		goto out;
 	}
 
-	/*
-	 * The host wasn't in our hash table.  If we don't
-	 * have an NSM handle for it yet, create one.
-	 */
-	if (nsm)
-		atomic_inc(&nsm->sm_count);
-	else {
-		host = NULL;
-		nsm = nsm_get_handle(ni->sap, ni->salen,
-					ni->hostname, ni->hostname_len);
-		if (!nsm) {
-			dprintk("lockd: nlm_lookup_host failed; "
-				"no nsm handle\n");
-			goto out;
-		}
-	}
-
-	host = kzalloc(sizeof(*host), GFP_KERNEL);
-	if (!host) {
-		nsm_release(nsm);
-		dprintk("lockd: nlm_lookup_host failed; no memory\n");
+	host = nlm_alloc_host(ni, nsm);
+	if (unlikely(host == NULL))
 		goto out;
-	}
-	host->h_name	   = nsm->sm_name;
-	host->h_addrbuf    = nsm->sm_addrbuf;
-	memcpy(nlm_addr(host), ni->sap, ni->salen);
-	host->h_addrlen = ni->salen;
-	rpc_set_port(nlm_addr(host), 0);
+
 	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
 	host->h_srcaddrlen = ni->src_len;
-	host->h_version    = ni->version;
-	host->h_proto      = ni->protocol;
-	host->h_rpcclnt    = NULL;
-	mutex_init(&host->h_mutex);
-	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
-	host->h_expires    = jiffies + NLM_HOST_EXPIRE;
-	atomic_set(&host->h_count, 1);
-	init_waitqueue_head(&host->h_gracewait);
-	init_rwsem(&host->h_rwsem);
-	host->h_state      = 0;			/* pseudo NSM state */
-	host->h_nsmstate   = 0;			/* real NSM state */
-	host->h_nsmhandle  = nsm;
-	host->h_server	   = ni->server;
-	host->h_noresvport = ni->noresvport;
 	hlist_add_head(&host->h_hash, chain);
-	INIT_LIST_HEAD(&host->h_lockowners);
-	spin_lock_init(&host->h_lock);
-	INIT_LIST_HEAD(&host->h_granted);
-	INIT_LIST_HEAD(&host->h_reclaim);
 
 	nrhosts++;
 

