Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:36379 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab0LIQsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:48:31 -0500
Received: by yxt3 with SMTP id 3so1487377yxt.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Dec 2010 08:48:31 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] lockd: reorganize nlm_host_rebooted
To: linux-nfs@vger.kernel.org
Date: Thu, 09 Dec 2010 11:48:28 -0500
Message-ID: <20101209164828.4513.47494.stgit@matisse.1015granger.net>
In-Reply-To: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
References: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Minor reorganization; no change in behavior.  This will save some
duplicated code after we split the client and server host caches.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
[ cel: Forward-ported to 2.6.37 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   58 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index cada3a1..2dbf139 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -441,6 +441,31 @@ void nlm_release_host(struct nlm_host *host)
 	}
 }
 
+static struct nlm_host *next_host_state(struct hlist_head *cache,
+					struct nsm_handle *nsm,
+					const struct nlm_reboot *info)
+{
+	struct nlm_host *host = NULL;
+	struct hlist_head *chain;
+	struct hlist_node *pos;
+
+	mutex_lock(&nlm_host_mutex);
+	for_each_host(host, pos, chain, cache) {
+		if (host->h_nsmhandle == nsm
+		    && host->h_nsmstate != info->state) {
+			host->h_nsmstate = info->state;
+			host->h_state++;
+
+			nlm_get_host(host);
+			mutex_unlock(&nlm_host_mutex);
+			goto out;
+		}
+	}
+out:
+	mutex_unlock(&nlm_host_mutex);
+	return host;
+}
+
 /**
  * nlm_host_rebooted - Release all resources held by rebooted host
  * @info: pointer to decoded results of NLM_SM_NOTIFY call
@@ -450,8 +475,6 @@ void nlm_release_host(struct nlm_host *host)
  */
 void nlm_host_rebooted(const struct nlm_reboot *info)
 {
-	struct hlist_head *chain;
-	struct hlist_node *pos;
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
@@ -464,30 +487,17 @@ void nlm_host_rebooted(const struct nlm_reboot *info)
 	 * lock for this.
 	 * To avoid processing a host several times, we match the nsmstate.
 	 */
-again:	mutex_lock(&nlm_host_mutex);
-	for_each_host(host, pos, chain, nlm_hosts) {
-		if (host->h_nsmhandle == nsm
-		 && host->h_nsmstate != info->state) {
-			host->h_nsmstate = info->state;
-			host->h_state++;
-
-			nlm_get_host(host);
-			mutex_unlock(&nlm_host_mutex);
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
+	while ((host = next_host_state(nlm_hosts, nsm, info)) != NULL) {
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
-	mutex_unlock(&nlm_host_mutex);
 	nsm_release(nsm);
 }
 

