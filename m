From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 08/12] lockd: move debugging warning into a separate function
Date: Wed,  5 Nov 2008 15:06:47 -0500
Message-ID: <1225915611-2401-8-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39497 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757561AbYKEUGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:55 -0500
In-Reply-To: <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will also save some duplicated code after splitting apart client
and server.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index bb3bf36..3fd7573 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -553,6 +553,21 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	}
 }
 
+static void warn_host_leak(struct host_table *table)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host	*host;
+
+	printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
+	dprintk("lockd: %d hosts left:\n", table->ht_num);
+	for_each_host(host, pos, chain, table) {
+		dprintk("       %s (cnt %d use %d exp %ld)\n",
+			host->h_name, atomic_read(&host->h_count),
+			host->h_inuse, host->h_expires);
+	}
+}
+
 /*
  * Shut down the hosts module.
  * Note that this routine is called only at server shutdown time.
@@ -582,15 +597,8 @@ nlm_shutdown_hosts(void)
 	mutex_unlock(&nlm_hosts.ht_mutex);
 
 	/* complain if any hosts are left */
-	if (nlm_hosts.ht_num) {
-		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
-		dprintk("lockd: %d hosts left:\n", nlm_hosts.ht_num);
-		for_each_host(host, pos, chain, &nlm_hosts) {
-			dprintk("       %s (cnt %d use %d exp %ld)\n",
-				host->h_name, atomic_read(&host->h_count),
-				host->h_inuse, host->h_expires);
-		}
-	}
+	if (nlm_hosts.ht_num)
+		warn_host_leak(&nlm_hosts);
 }
 
 /*
-- 
1.5.5.rc1

