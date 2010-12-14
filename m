Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:61018 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757715Ab0LNPGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:06:45 -0500
Received: by gxk19 with SMTP id 19so482684gxk.11
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:06:45 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] lockd: Remove nlm_lookup_host()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:06:41 -0500
Message-ID: <20101214150641.2736.25812.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
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
index 77ec21a..6d4aa8b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -163,75 +163,6 @@ out:
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

