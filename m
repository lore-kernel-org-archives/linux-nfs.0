Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:10896 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214Ab2EERYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:24:06 -0400
Subject: [PATCH RFC 05/13] Lockd: host complaining function introduced
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:22:08 +0400
Message-ID: <20120505172208.11559.61956.stgit@localhost.localdomain>
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just a small cleanup.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/host.c |   57 +++++++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 6c56090..8cbf53d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -572,6 +572,35 @@ void nlm_host_rebooted(const struct nlm_reboot *info)
 	nsm_release(nsm);
 }
 
+static void nlm_complain_hosts(struct net *net)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host	*host;
+
+	if (net) {
+		struct lockd_net *ln = net_generic(net, lockd_net_id);
+
+		if (ln->nrhosts == 0)
+			return;
+		printk(KERN_WARNING "lockd: couldn't shutdown host module for net %p!\n", net);
+		dprintk("lockd: %lu hosts left in net %p:\n", ln->nrhosts, net);
+	} else {
+		if (nrhosts == 0)
+			return;
+		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
+		dprintk("lockd: %lu hosts left:\n", nrhosts);
+	}
+
+	for_each_host(host, pos, chain, nlm_server_hosts) {
+		if (net && host->net != net)
+			continue;
+		dprintk("       %s (cnt %d use %d exp %ld net %p)\n",
+			host->h_name, atomic_read(&host->h_count),
+			host->h_inuse, host->h_expires, host->net);
+	}
+}
+
 void
 nlm_shutdown_hosts_net(struct net *net)
 {
@@ -598,18 +627,7 @@ nlm_shutdown_hosts_net(struct net *net)
 	nlm_gc_hosts(net);
 	mutex_unlock(&nlm_host_mutex);
 
-	/* complain if any hosts are left */
-	if (net) {
-		struct lockd_net *ln = net_generic(net, lockd_net_id);
-
-		printk(KERN_WARNING "lockd: couldn't shutdown host module for net %p!\n", net);
-		dprintk("lockd: %lu hosts left in net %p:\n", ln->nrhosts, net);
-		for_each_host(host, pos, chain, nlm_server_hosts) {
-			dprintk("       %s (cnt %d use %d exp %ld net %p)\n",
-				host->h_name, atomic_read(&host->h_count),
-				host->h_inuse, host->h_expires, host->net);
-		}
-	}
+	nlm_complain_hosts(net);
 }
 
 /*
@@ -619,22 +637,7 @@ nlm_shutdown_hosts_net(struct net *net)
 void
 nlm_shutdown_hosts(void)
 {
-	struct hlist_head *chain;
-	struct hlist_node *pos;
-	struct nlm_host	*host;
-
 	nlm_shutdown_hosts_net(NULL);
-
-	/* complain if any hosts are left */
-	if (nrhosts != 0) {
-		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
-		dprintk("lockd: %lu hosts left:\n", nrhosts);
-		for_each_host(host, pos, chain, nlm_server_hosts) {
-			dprintk("       %s (cnt %d use %d exp %ld net %p)\n",
-				host->h_name, atomic_read(&host->h_count),
-				host->h_inuse, host->h_expires, host->net);
-		}
-	}
 }
 
 /*

