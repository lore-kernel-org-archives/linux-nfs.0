From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 07/12] lockd: reorganize nlm_host_rebooted
Date: Wed,  5 Nov 2008 15:06:46 -0500
Message-ID: <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39494 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757547AbYKEUGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:55 -0500
In-Reply-To: <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor reorganization; no change in behavior.  This will save some
duplicated code after we split apart the client and server host lists.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   59 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 1b90b49..bb3bf36 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -482,6 +482,31 @@ void nlm_release_host(struct nlm_host *host)
 	}
 }
 
+static struct nlm_host *next_host_state(struct host_table *table,
+				struct nsm_handle *nsm,
+				u32 new_state)
+{
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+	struct nlm_host *host = NULL;
+
+	mutex_lock(&table->ht_mutex);
+	for_each_host(host, pos, chain, table) {
+		if (host->h_nsmhandle == nsm
+				&& host->h_nsmstate != new_state) {
+			host->h_nsmstate = new_state;
+			host->h_state++;
+
+			nlm_get_host(host);
+			mutex_unlock(&table->ht_mutex);
+			goto out;
+		}
+	}
+out:
+	mutex_unlock(&table->ht_mutex);
+	return host;
+}
+
 /*
  * We were notified that the host indicated by address &sin
  * has rebooted.
@@ -492,8 +517,6 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 				unsigned int hostname_len,
 				u32 new_state)
 {
-	struct hlist_head *chain;
-	struct hlist_node *pos;
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
@@ -517,31 +540,17 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
 	 * lock for this.
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
-again:	mutex_lock(&nlm_hosts.ht_mutex);
-	for_each_host(host, pos, chain, &nlm_hosts) {
-		if (host->h_nsmhandle == nsm
-		 && host->h_nsmstate != new_state) {
-			host->h_nsmstate = new_state;
-			host->h_state++;
-
-			nlm_get_host(host);
-			mutex_unlock(&nlm_hosts.ht_mutex);
-
-			if (host->h_server) {
-				/* We're server for this guy, just ditch
-				 * all the locks he held. */
-				nlmsvc_free_host_resources(host);
-			} else {
-				/* He's the server, initiate lock recovery. */
-				nlmclnt_recovery(host);
-			}
-
-			nlm_release_host(host);
-			goto again;
+	while ((host = next_host_state(&nlm_hosts, nsm, new_state)) != NULL) {
+		if (host->h_server) {
+			/* We're server for this guy, just ditch
+			 * all the locks he held. */
+			nlmsvc_free_host_resources(host);
+		} else {
+			/* He's the server, initiate lock recovery. */
+			nlmclnt_recovery(host);
 		}
+		nlm_release_host(host);
 	}
-
-	mutex_unlock(&nlm_hosts.ht_mutex);
 }
 
 /*
-- 
1.5.5.rc1

