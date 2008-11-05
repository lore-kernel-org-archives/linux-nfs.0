From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 01/12] lockd: fix inconsistent use of nsm_use_hostnames
Date: Wed,  5 Nov 2008 15:06:40 -0500
Message-ID: <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757490AbYKEUGy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:54 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nlm_lookup_host() there's an optimization that looks for matching nsm
handles at the same time as looking for hosts, so that if a host
isn't found but a matching nsm handle is, we save a second lookup for
the nsm handle.

The optimization (unlike nsm_find()) ignores nsm_use_hostnames, so may
give incorrect results when that parameter is set.  We could probably
find some way to fix this and keep the optimization, but it seems
unlikely to be very significant, so just skip it entirely.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9fd8889..e9069c2 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -138,7 +138,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	struct hlist_head *chain;
 	struct hlist_node *pos;
 	struct nlm_host	*host;
-	struct nsm_handle *nsm = NULL;
+	struct nsm_handle *nsm;
 
 	mutex_lock(&nlm_host_mutex);
 
@@ -157,10 +157,6 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
 			continue;
 
-		/* See if we have an NSM handle for this client */
-		if (!nsm)
-			nsm = host->h_nsmhandle;
-
 		if (host->h_proto != ni->protocol)
 			continue;
 		if (host->h_version != ni->version)
@@ -184,17 +180,12 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	 * The host wasn't in our hash table.  If we don't
 	 * have an NSM handle for it yet, create one.
 	 */
-	if (nsm)
-		atomic_inc(&nsm->sm_count);
-	else {
-		host = NULL;
-		nsm = nsm_find(ni->sap, ni->salen,
-				ni->hostname, ni->hostname_len, 1);
-		if (!nsm) {
-			dprintk("lockd: nlm_lookup_host failed; "
-				"no nsm handle\n");
-			goto out;
-		}
+	host = NULL;
+	nsm = nsm_find(ni->sap, ni->salen, ni->hostname, ni->hostname_len, 1);
+	if (!nsm) {
+		dprintk("lockd: nlm_lookup_host failed; "
+			"no nsm handle\n");
+		goto out;
 	}
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
-- 
1.5.5.rc1

