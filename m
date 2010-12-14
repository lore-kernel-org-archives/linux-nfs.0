Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45794 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757715Ab0LNPGZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:06:25 -0500
Received: by mail-iw0-f174.google.com with SMTP id 9so869885iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:06:25 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/11] lockd: Rename nlm_hosts
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:06:22 -0500
Message-ID: <20101214150622.2736.23447.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

nlm_hosts now contains only server-side entries.  Rename it to match
convention of client side cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 0250b0e..87fbde1 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -25,7 +25,7 @@
 #define NLM_HOST_EXPIRE		(300 * HZ)
 #define NLM_HOST_COLLECT	(120 * HZ)
 
-static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
+static struct hlist_head	nlm_server_hosts[NLM_HOST_NRHASH];
 static struct hlist_head	nlm_client_hosts[NLM_HOST_NRHASH];
 
 #define for_each_host(host, pos, chain, table) \
@@ -184,7 +184,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	 * different NLM rpc_clients into one single nlm_host object.
 	 * This would allow us to have one nlm_host per address.
 	 */
-	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
+	chain = &nlm_server_hosts[nlm_hash_address(ni->sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
 		if (!rpc_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
@@ -428,7 +428,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	if (time_after_eq(jiffies, next_gc))
 		nlm_gc_hosts();
 
-	chain = &nlm_hosts[nlm_hash_address(ni.sap)];
+	chain = &nlm_server_hosts[nlm_hash_address(ni.sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
 		if (!rpc_cmp_addr(nlm_addr(host), ni.sap))
 			continue;
@@ -632,7 +632,7 @@ void nlm_host_rebooted(const struct nlm_reboot *info)
 	 * lock for this.
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
-	while ((host = next_host_state(nlm_hosts, nsm, info)) != NULL) {
+	while ((host = next_host_state(nlm_server_hosts, nsm, info)) != NULL) {
 		nlmsvc_free_host_resources(host);
 		nlmsvc_release_host(host);
 	}
@@ -660,7 +660,7 @@ nlm_shutdown_hosts(void)
 
 	/* First, make all hosts eligible for gc */
 	dprintk("lockd: nuking all hosts...\n");
-	for_each_host(host, pos, chain, nlm_hosts) {
+	for_each_host(host, pos, chain, nlm_server_hosts) {
 		host->h_expires = jiffies - 1;
 		if (host->h_rpcclnt) {
 			rpc_shutdown_client(host->h_rpcclnt);
@@ -676,7 +676,7 @@ nlm_shutdown_hosts(void)
 	if (nrhosts) {
 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
 		dprintk("lockd: %d hosts left:\n", nrhosts);
-		for_each_host(host, pos, chain, nlm_hosts) {
+		for_each_host(host, pos, chain, nlm_server_hosts) {
 			dprintk("       %s (cnt %d use %d exp %ld)\n",
 				host->h_name, atomic_read(&host->h_count),
 				host->h_inuse, host->h_expires);
@@ -697,13 +697,13 @@ nlm_gc_hosts(void)
 	struct nlm_host	*host;
 
 	dprintk("lockd: host garbage collection\n");
-	for_each_host(host, pos, chain, nlm_hosts)
+	for_each_host(host, pos, chain, nlm_server_hosts)
 		host->h_inuse = 0;
 
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources();
 
-	for_each_host_safe(host, pos, next, chain, nlm_hosts) {
+	for_each_host_safe(host, pos, next, chain, nlm_server_hosts) {
 		if (atomic_read(&host->h_count) || host->h_inuse
 		 || time_before(jiffies, host->h_expires)) {
 			dprintk("nlm_gc_hosts skipping %s "

