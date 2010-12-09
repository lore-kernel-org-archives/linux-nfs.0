Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:44188 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab0LIQuN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:50:13 -0500
Received: by mail-gw0-f42.google.com with SMTP id 20so2209519gwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Dec 2010 08:50:13 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] lockd: Remove nlm_lookup_host()
To: linux-nfs@vger.kernel.org
Date: Thu, 09 Dec 2010 11:50:10 -0500
Message-ID: <20101209165010.4513.19156.stgit@matisse.1015granger.net>
In-Reply-To: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
References: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Remove the now unused helper nlm_lookup_host().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   69 -------------------------------------------------------
 1 files changed, 0 insertions(+), 69 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 43d8d0c..c054689 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -159,75 +159,6 @@ out:
 }
 
 /*
- * Common host lookup routine for server & client
- */
-static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
-{
-	struct hlist_head *chain;
-	struct hlist_node *pos;
-	struct nlm_host	*host;
-	struct nsm_handle *nsm = NULL;
-
-	mutex_lock(&nlm_host_mutex);
-
-	if (time_after_eq(jiffies, next_gc))
-		nlm_gc_hosts();
-
-	/* We may keep several nlm_host objects for a peer, because each
-	 * nlm_host is identified by
-	 * (address, protocol, version, server/client)
-	 * We could probably simplify this a little by putting all those
-	 * different NLM rpc_clients into one single nlm_host object.
-	 * This would allow us to have one nlm_host per address.
-	 */
-	chain = &nlm_server_hosts[nlm_hash_address(ni->sap)];
-	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!rpc_cmp_addr(nlm_addr(host), ni->sap))
-			continue;
-
-		/* See if we have an NSM handle for this client */
-		if (!nsm)
-			nsm = host->h_nsmhandle;
-
-		if (host->h_proto != ni->protocol)
-			continue;
-		if (host->h_version != ni->version)
-			continue;
-		if (host->h_server != ni->server)
-			continue;
-		if (ni->server && ni->src_len != 0 &&
-		    !rpc_cmp_addr(nlm_srcaddr(host), ni->src_sap))
-			continue;
-
-		/* Move to head of hash chain. */
-		hlist_del(&host->h_hash);
-		hlist_add_head(&host->h_hash, chain);
-
-		nlm_get_host(host);
-		dprintk("lockd: nlm_lookup_host found host %s (%s)\n",
-				host->h_name, host->h_addrbuf);
-		goto out;
-	}
-
-	host = nlm_alloc_host(ni, nsm);
-	if (unlikely(host == NULL))
-		goto out;
-
-	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
-	host->h_srcaddrlen = ni->src_len;
-	hlist_add_head(&host->h_hash, chain);
-
-	nrhosts++;
-
-	dprintk("lockd: nlm_lookup_host created host %s\n",
-			host->h_name);
-
-out:
-	mutex_unlock(&nlm_host_mutex);
-	return host;
-}
-
-/*
  * Destroy an nlm_host and free associated resources
  *
  * Caller must hold nlm_host_mutex.

