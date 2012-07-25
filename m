Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42943 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756724Ab2GYM53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 08:57:29 -0400
Subject: [PATCH v2 02/15] LockD: make garbage collector network namespace
	aware.
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Jul 2012 16:56:03 +0400
Message-ID: <20120725125603.24376.90230.stgit@localhost.localdomain>
In-Reply-To: <20120725125258.24376.82525.stgit@localhost.localdomain>
References: <20120725125258.24376.82525.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---
 fs/lockd/host.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 2c5f41b..991274a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -45,7 +45,7 @@ static unsigned long		next_gc;
 static unsigned long		nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
-static void			nlm_gc_hosts(void);
+static void			nlm_gc_hosts(struct net *net);
 
 struct nlm_lookup_host_info {
 	const int		server;		/* search for server|client */
@@ -345,7 +345,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	mutex_lock(&nlm_host_mutex);
 
 	if (time_after_eq(jiffies, next_gc))
-		nlm_gc_hosts();
+		nlm_gc_hosts(net);
 
 	chain = &nlm_server_hosts[nlm_hash_address(ni.sap)];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
@@ -588,7 +588,7 @@ nlm_shutdown_hosts_net(struct net *net)
 	}
 
 	/* Then, perform a garbage collection pass */
-	nlm_gc_hosts();
+	nlm_gc_hosts(net);
 	mutex_unlock(&nlm_host_mutex);
 }
 
@@ -623,27 +623,31 @@ nlm_shutdown_hosts(void)
  * mark & sweep for resources held by remote clients.
  */
 static void
-nlm_gc_hosts(void)
+nlm_gc_hosts(struct net *net)
 {
 	struct hlist_head *chain;
 	struct hlist_node *pos, *next;
 	struct nlm_host	*host;
-	struct net *net = &init_net;
 
-	dprintk("lockd: host garbage collection\n");
-	for_each_host(host, pos, chain, nlm_server_hosts)
+	dprintk("lockd: host garbage collection for net %p\n", net);
+	for_each_host(host, pos, chain, nlm_server_hosts) {
+		if (net && host->net != net)
+			continue;
 		host->h_inuse = 0;
+	}
 
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources(net);
 
 	for_each_host_safe(host, pos, next, chain, nlm_server_hosts) {
+		if (net && host->net != net)
+			continue;
 		if (atomic_read(&host->h_count) || host->h_inuse
 		 || time_before(jiffies, host->h_expires)) {
 			dprintk("nlm_gc_hosts skipping %s "
-				"(cnt %d use %d exp %ld)\n",
+				"(cnt %d use %d exp %ld net %p)\n",
 				host->h_name, atomic_read(&host->h_count),
-				host->h_inuse, host->h_expires);
+				host->h_inuse, host->h_expires, host->net);
 			continue;
 		}
 		nlm_destroy_host_locked(host);

