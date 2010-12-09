Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:59801 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab0LIQsW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:48:22 -0500
Received: by gxk19 with SMTP id 19so1559138gxk.11
        for <linux-nfs@vger.kernel.org>; Thu, 09 Dec 2010 08:48:21 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] lockd: define host_for_each{_safe} macros
To: linux-nfs@vger.kernel.org
Date: Thu, 09 Dec 2010 11:48:19 -0500
Message-ID: <20101209164819.4513.71032.stgit@matisse.1015granger.net>
In-Reply-To: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
References: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

We've got a lot of loops like this, and I find them a little easier to
read with the macros.  More such loops are coming.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
[ cel: Forward-ported to 2.6.37 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |  107 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 55 insertions(+), 52 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index ed0c59f..cada3a1 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -26,6 +26,18 @@
 #define NLM_HOST_COLLECT	(120 * HZ)
 
 static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
+
+#define for_each_host(host, pos, chain, table) \
+	for ((chain) = (table); \
+	     (chain) < (table) + NLM_HOST_NRHASH; ++(chain)) \
+		hlist_for_each_entry((host), (pos), (chain), h_hash)
+
+#define for_each_host_safe(host, pos, next, chain, table) \
+	for ((chain) = (table); \
+	     (chain) < (table) + NLM_HOST_NRHASH; ++(chain)) \
+		hlist_for_each_entry_safe((host), (pos), (next), \
+						(chain), h_hash)
+
 static unsigned long		next_gc;
 static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
@@ -453,28 +465,26 @@ void nlm_host_rebooted(const struct nlm_reboot *info)
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
 again:	mutex_lock(&nlm_host_mutex);
-	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash) {
-			if (host->h_nsmhandle == nsm
-			 && host->h_nsmstate != info->state) {
-				host->h_nsmstate = info->state;
-				host->h_state++;
-
-				nlm_get_host(host);
-				mutex_unlock(&nlm_host_mutex);
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
+	for_each_host(host, pos, chain, nlm_hosts) {
+		if (host->h_nsmhandle == nsm
+		 && host->h_nsmstate != info->state) {
+			host->h_nsmstate = info->state;
+			host->h_state++;
+
+			nlm_get_host(host);
+			mutex_unlock(&nlm_host_mutex);
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
 	mutex_unlock(&nlm_host_mutex);
@@ -497,13 +507,11 @@ nlm_shutdown_hosts(void)
 
 	/* First, make all hosts eligible for gc */
 	dprintk("lockd: nuking all hosts...\n");
-	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash) {
-			host->h_expires = jiffies - 1;
-			if (host->h_rpcclnt) {
-				rpc_shutdown_client(host->h_rpcclnt);
-				host->h_rpcclnt = NULL;
-			}
+	for_each_host(host, pos, chain, nlm_hosts) {
+		host->h_expires = jiffies - 1;
+		if (host->h_rpcclnt) {
+			rpc_shutdown_client(host->h_rpcclnt);
+			host->h_rpcclnt = NULL;
 		}
 	}
 
@@ -515,12 +523,10 @@ nlm_shutdown_hosts(void)
 	if (nrhosts) {
 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
 		dprintk("lockd: %d hosts left:\n", nrhosts);
-		for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-			hlist_for_each_entry(host, pos, chain, h_hash) {
-				dprintk("       %s (cnt %d use %d exp %ld)\n",
-					host->h_name, atomic_read(&host->h_count),
-					host->h_inuse, host->h_expires);
-			}
+		for_each_host(host, pos, chain, nlm_hosts) {
+			dprintk("       %s (cnt %d use %d exp %ld)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires);
 		}
 	}
 }
@@ -538,29 +544,26 @@ nlm_gc_hosts(void)
 	struct nlm_host	*host;
 
 	dprintk("lockd: host garbage collection\n");
-	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash)
-			host->h_inuse = 0;
-	}
+	for_each_host(host, pos, chain, nlm_hosts)
+		host->h_inuse = 0;
 
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources();
 
-	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
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
-			nrhosts--;
+	for_each_host_safe(host, pos, next, chain, nlm_hosts) {
+		if (atomic_read(&host->h_count) || host->h_inuse
+		 || time_before(jiffies, host->h_expires)) {
+			dprintk("nlm_gc_hosts skipping %s "
+				"(cnt %d use %d exp %ld)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires);
+			continue;
 		}
+		dprintk("lockd: delete host %s\n", host->h_name);
+		hlist_del_init(&host->h_hash);
+
+		nlm_destroy_host(host);
+		nrhosts--;
 	}
 
 	next_gc = jiffies + NLM_HOST_COLLECT;

