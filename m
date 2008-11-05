From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 11/12] lockd: split client and server host lists
Date: Wed,  5 Nov 2008 15:06:50 -0500
Message-ID: <1225915611-2401-11-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-8-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-9-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-10-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757578AbYKEUG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:56 -0500
In-Reply-To: <1225915611-2401-10-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate out client and server host lists.  Most logic is just
duplicated, but note that the garbage-collection logic is slightly
different for the two, since the client doesn't need to do the mark and
sweep of all its hosts.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   59 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 588017f..73c2be2 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -45,8 +45,11 @@ struct host_table {
 		hlist_for_each_entry_safe((host), (pos), (next), (chain), \
 								h_hash)
 
-static struct host_table nlm_hosts = {
-	.ht_mutex = __MUTEX_INITIALIZER(nlm_hosts.ht_mutex)
+static struct host_table nlm_clients = {
+	.ht_mutex = __MUTEX_INITIALIZER(nlm_clients.ht_mutex)
+};
+static struct host_table nlm_servers = {
+	.ht_mutex = __MUTEX_INITIALIZER(nlm_servers.ht_mutex)
 };
 static unsigned long		next_gc;
 
@@ -158,8 +161,9 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 	struct nsm_handle *nsm;
+	struct host_table *table = ni->server ? &nlm_servers : &nlm_clients;
 
-	mutex_lock(&nlm_hosts.ht_mutex);
+	mutex_lock(&table->ht_mutex);
 
 	if (time_after_eq(jiffies, next_gc))
 		nlm_gc_hosts();
@@ -171,17 +175,16 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	 * different NLM rpc_clients into one single nlm_host object.
 	 * This would allow us to have one nlm_host per address.
 	 */
-	chain = &nlm_hosts.ht_chains[nlm_hash_address(ni->sap)];
+	chain = &table->ht_chains[nlm_hash_address(ni->sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
 		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
 
+		BUG_ON(host->h_server != ni->server); /* XXX */
 		if (host->h_proto != ni->protocol)
 			continue;
 		if (host->h_version != ni->version)
 			continue;
-		if (host->h_server != ni->server)
-			continue;
 		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
@@ -237,7 +240,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	INIT_LIST_HEAD(&host->h_granted);
 	INIT_LIST_HEAD(&host->h_reclaim);
 
-	nlm_hosts.ht_num++;
+	table->ht_num++;
 
 	nlm_display_address((struct sockaddr *)&host->h_addr,
 				host->h_addrbuf, sizeof(host->h_addrbuf));
@@ -248,7 +251,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 			host->h_name);
 
 out:
-	mutex_unlock(&nlm_hosts.ht_mutex);
+	mutex_unlock(&table->ht_mutex);
 	return host;
 }
 
@@ -540,15 +543,15 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	 * lock for this.
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
-	while ((host = next_host_state(&nlm_hosts, nsm, new_state)) != NULL) {
-		if (host->h_server) {
-			/* We're server for this guy, just ditch
-			 * all the locks he held. */
-			nlmsvc_free_host_resources(host);
-		} else {
-			/* He's the server, initiate lock recovery. */
-			nlmclnt_recovery(host);
-		}
+	while ((host = next_host_state(&nlm_servers, nsm, new_state)) != NULL) {
+		/* We're server for this guy, just ditch
+		 * all the locks he held. */
+		nlmsvc_free_host_resources(host);
+		nlm_release_host(host);
+	}
+	while ((host = next_host_state(&nlm_clients, nsm, new_state)) != NULL) {
+		/* He's the server, initiate lock recovery. */
+		nlmclnt_recovery(host);
 		nlm_release_host(host);
 	}
 }
@@ -617,18 +620,23 @@ void
 nlm_shutdown_hosts(void)
 {
 	dprintk("lockd: shutting down host module\n");
-	mutex_lock(&nlm_hosts.ht_mutex);
+	mutex_lock(&nlm_servers.ht_mutex);
+	mutex_lock(&nlm_clients.ht_mutex);
 
 	/* First, make all hosts eligible for gc */
-	expire_hosts(&nlm_hosts);
+	expire_hosts(&nlm_clients);
+	expire_hosts(&nlm_servers);
 
 	/* Then, perform a garbage collection pass */
 	nlm_gc_hosts();
-	mutex_unlock(&nlm_hosts.ht_mutex);
+	mutex_unlock(&nlm_clients.ht_mutex);
+	mutex_unlock(&nlm_servers.ht_mutex);
 
 	/* complain if any hosts are left */
-	if (nlm_hosts.ht_num)
-		warn_host_leak(&nlm_hosts);
+	if (nlm_clients.ht_num)
+		warn_host_leak(&nlm_clients);
+	if (nlm_servers.ht_num)
+		warn_host_leak(&nlm_servers);
 }
 
 /*
@@ -644,13 +652,16 @@ nlm_gc_hosts(void)
 	struct nlm_host	*host;
 
 	dprintk("lockd: host garbage collection\n");
-	for_each_host(host, pos, chain, &nlm_hosts)
+	for_each_host(host, pos, chain, &nlm_servers)
 		host->h_inuse = 0;
 
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources();
 
-	nlm_gc_table(&nlm_hosts);
+	nlm_gc_table(&nlm_servers);
+
+	/* Note client doesn't need mark/sweep logic: */
+	nlm_gc_table(&nlm_clients);
 }
 
 /*
-- 
1.5.5.rc1

