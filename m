From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 09/12] lockd: move garbage collection loop into separate function
Date: Wed,  5 Nov 2008 15:06:48 -0500
Message-ID: <1225915611-2401-9-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-8-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39499 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757566AbYKEUGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:55 -0500
In-Reply-To: <1225915611-2401-8-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code will later be shared.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 3fd7573..fa006af 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -553,6 +553,31 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	}
 }
 
+static void nlm_gc_table(struct host_table *table)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos, *next;
+	struct nlm_host *host;
+
+	for_each_host_safe(host, pos, next, chain, table) {
+		if (atomic_read(&host->h_count) || host->h_inuse
+				|| time_before(jiffies, host->h_expires)) {
+			dprintk("nlm_gc_hosts skipping %s"
+					" (cnt %d use %d exp %ld)\n",
+				host->h_name, atomic_read(&host->h_count),
+				host->h_inuse, host->h_expires);
+			continue;
+		}
+		dprintk("lockd: delete host %s\n", host->h_name);
+		hlist_del_init(&host->h_hash);
+
+		nlm_destroy_host(host);
+		table->ht_num--;
+	}
+
+	next_gc = jiffies + NLM_HOST_COLLECT;
+}
+
 static void warn_host_leak(struct host_table *table)
 {
 	struct hlist_head *chain;
@@ -610,7 +635,7 @@ static void
 nlm_gc_hosts(void)
 {
 	struct hlist_head *chain;
-	struct hlist_node *pos, *next;
+	struct hlist_node *pos;
 	struct nlm_host	*host;
 
 	dprintk("lockd: host garbage collection\n");
@@ -620,26 +645,9 @@ nlm_gc_hosts(void)
 	/* Mark all hosts that hold locks, blocks or shares */
 	nlmsvc_mark_resources();
 
-	for_each_host_safe(host, pos, next, chain, &nlm_hosts) {
-		if (atomic_read(&host->h_count) || host->h_inuse
-		 || time_before(jiffies, host->h_expires)) {
-			dprintk("nlm_gc_hosts skipping %s"
-					" (cnt %d use %d exp %ld)\n",
-				host->h_name, atomic_read(&host->h_count),
-				host->h_inuse, host->h_expires);
-			continue;
-		}
-		dprintk("lockd: delete host %s\n", host->h_name);
-		hlist_del_init(&host->h_hash);
-
-		nlm_destroy_host(host);
-		nlm_hosts.ht_num--;
-	}
-
-	next_gc = jiffies + NLM_HOST_COLLECT;
+	nlm_gc_table(&nlm_hosts);
 }
 
-
 /*
  * Manage NSM handles
  */
-- 
1.5.5.rc1

