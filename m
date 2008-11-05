From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 06/12] lockd: define host_for_each{_safe} macros
Date: Wed,  5 Nov 2008 15:06:45 -0500
Message-ID: <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39493 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757525AbYKEUGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:55 -0500
In-Reply-To: <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've got a lot of loops like this, and I find them a little easier to
read with the macros.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |  108 ++++++++++++++++++++++++++++--------------------------
 1 files changed, 56 insertions(+), 52 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 199ca8c..1b90b49 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -32,6 +32,19 @@ struct host_table {
 	struct mutex ht_mutex;
 };
 
+#define for_each_host(host, pos, chain, table) \
+	for ((chain) = (table)->ht_chains; \
+			(chain) < (table)->ht_chains + NLM_HOST_NRHASH; \
+			++(chain)) \
+		hlist_for_each_entry((host), (pos), (chain), h_hash)
+
+#define for_each_host_safe(host, pos, next, chain, table) \
+	for ((chain) = (table)->ht_chains; \
+			(chain) < (table)->ht_chains + NLM_HOST_NRHASH; \
+			++(chain)) \
+		hlist_for_each_entry_safe((host), (pos), (next), (chain), \
+								h_hash)
+
 static struct host_table nlm_hosts = {
 	.ht_mutex = __MUTEX_INITIALIZER(nlm_hosts.ht_mutex)
 };
@@ -505,28 +518,26 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
 again:	mutex_lock(&nlm_hosts.ht_mutex);
-	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash) {
-			if (host->h_nsmhandle == nsm
-			 && host->h_nsmstate != new_state) {
-				host->h_nsmstate = new_state;
-				host->h_state++;
-
-				nlm_get_host(host);
-				mutex_unlock(&nlm_hosts.ht_mutex);
-
-				if (host->h_server) {
-					/* We're server for this guy, just ditch
-					 * all the locks he held. */
-					nlmsvc_free_host_resources(host);
-				} else {
-					/* He's the server, initiate lock recovery. */
-					nlmclnt_recovery(host);
-				}
-
-				nlm_release_host(host);
-				goto again;
+	for_each_host(host, pos, chain, &nlm_hosts) {
+		if (host->h_nsmhandle == nsm
+		 && host->h_nsmstate != new_state) {
+			host->h_nsmstate = new_state;
+			host->h_state++;
+
+			nlm_get_host(host);
+			mutex_unlock(&nlm_hosts.ht_mutex);
+
+			if (host->h_server) {
+				/* We're server for this guy, just ditch
+				 * all the locks he held. */
+				nlmsvc_free_host_resources(host);
+			} else {
+				/* He's the server, initiate lock recovery. */
+				nlmclnt_recovery(host);
 			}
+
+			nlm_release_host(host);
+			goto again;
 		}
 	}
 
@@ -549,13 +560,11 @@ nlm_shutdown_hosts(void)
 
 	/* First, make all hosts eligible for gc */
 	dprintk("lockd: nuking all hosts...\n");
-	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash) {
-			host->h_expires = jiffies - 1;
-			if (host->h_rpcclnt) {
-				rpc_shutdown_client(host->h_rpcclnt);
-				host->h_rpcclnt = NULL;
-			}
+	for_each_host(host, pos, chain, &nlm_hosts) {
+		host->h_expires = jiffies - 1;
+		if (host->h_rpcclnt) {
+			rpc_shutdown_client(host->h_rpcclnt);
+			host->h_rpcclnt = NULL;
 		}
 	}
 
@@ -567,12 +576,10 @@ nlm_shutdown_hosts(void)
 	if (nlm_hosts.ht_num) {
 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
 		dprintk("lockd: %d hosts left:\n", nlm_hosts.ht_num);
-		for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains + NLM_HOST_NRHASH; ++chain) {
-			hlist_for_each_entry(host, pos, chain, h_hash) {
-				dprintk("       %s (cnt %d use %d exp %ld)\n",
-					host->h_name, atomic_read(&host->h_count),
-					host->h_inuse, host->h_expires);
-			}
+		for_each_host(host, pos, chain, &nlm_hosts) {
+			dprintk("       %s (cnt %d use %d exp %ld)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires);
 		}
 	}
 }
@@ -590,29 +597,26 @@ nlm_gc_hosts(void)
 	struct nlm_host	*host;
 
 	dprintk("lockd: host garbage collection\n");
-	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash)
-			host->h_inuse = 0;
-	}
+	for_each_host(host, pos, chain, &nlm_hosts)
+		host->h_inuse = 0;
 
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources();
 
-	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry_safe(host, pos, next, chain, h_hash) {
-			if (atomic_read(&host->h_count) || host->h_inuse
-			 || time_before(jiffies, host->h_expires)) {
-				dprintk("nlm_gc_hosts skipping %s (cnt %d use %d exp %ld)\n",
-					host->h_name, atomic_read(&host->h_count),
-					host->h_inuse, host->h_expires);
-				continue;
-			}
-			dprintk("lockd: delete host %s\n", host->h_name);
-			hlist_del_init(&host->h_hash);
-
-			nlm_destroy_host(host);
-			nlm_hosts.ht_num--;
+	for_each_host_safe(host, pos, next, chain, &nlm_hosts) {
+		if (atomic_read(&host->h_count) || host->h_inuse
+		 || time_before(jiffies, host->h_expires)) {
+			dprintk("nlm_gc_hosts skipping %s"
+					" (cnt %d use %d exp %ld)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires);
+			continue;
 		}
+		dprintk("lockd: delete host %s\n", host->h_name);
+		hlist_del_init(&host->h_hash);
+
+		nlm_destroy_host(host);
+		nlm_hosts.ht_num--;
 	}
 
 	next_gc = jiffies + NLM_HOST_COLLECT;
-- 
1.5.5.rc1

