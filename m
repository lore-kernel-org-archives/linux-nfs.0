From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/11] NSM: More clean up of nsm_get_handle()
Date: Thu, 11 Dec 2008 17:55:59 -0500
Message-ID: <20081211225559.21468.82627.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37026 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759553AbYLKW4t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:49 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refactor nsm_get_handle() so it is organized the same way that
nsm_reboot_lookup() is.

There is an additional micro-optimization here.  This change moves the
"hostname & nsm_use_hostnames" test out of the list_for_each_entry()
clause in nsm_get_handle(), since it is loop-invariant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   62 ++++++++++++++++++++++++++++++++------------------------
 1 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index f4a201b..6a48b3c 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -214,6 +214,16 @@ static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
 	return NULL;
 }
 
+static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
+{
+	struct nsm_handle *nsm;
+
+	list_for_each_entry(nsm, &nsm_handles, sm_link)
+		if (nlm_cmp_addr(nsm_addr(nsm), sap))
+			return nsm;
+	return NULL;
+}
+
 static struct nsm_handle *nsm_lookup_priv(const struct nsm_private *priv)
 {
 	struct nsm_handle *nsm;
@@ -282,8 +292,7 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 				  const size_t salen, const char *hostname,
 				  const size_t hostname_len)
 {
-	struct nsm_handle *nsm = NULL;
-	struct nsm_handle *pos;
+	struct nsm_handle *cached, *new = NULL;
 
 	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
 		if (printk_ratelimit()) {
@@ -296,38 +305,37 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 
 retry:
 	spin_lock(&nsm_lock);
-	list_for_each_entry(pos, &nsm_handles, sm_link) {
-
-		if (hostname && nsm_use_hostnames) {
-			if (strlen(pos->sm_name) != hostname_len
-			 || memcmp(pos->sm_name, hostname, hostname_len))
-				continue;
-		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
-			continue;
-		atomic_inc(&pos->sm_count);
-		kfree(nsm);
-		nsm = pos;
-		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
-				pos->sm_name, pos->sm_addrbuf,
-				atomic_read(&pos->sm_count));
-		goto found;
+
+	if (nsm_use_hostnames && hostname != NULL)
+		cached = nsm_lookup_hostname(hostname, hostname_len);
+	else
+		cached = nsm_lookup_addr(sap);
+
+	if (cached != NULL) {
+		atomic_inc(&cached->sm_count);
+		spin_unlock(&nsm_lock);
+		kfree(new);
+		dprintk("lockd: found nsm_handle for %s (%s), "
+				"cnt %d\n", cached->sm_name,
+				cached->sm_addrbuf,
+				atomic_read(&cached->sm_count));
+		return cached;
 	}
-	if (nsm) {
-		list_add(&nsm->sm_link, &nsm_handles);
+
+	if (new != NULL) {
+		list_add(&new->sm_link, &nsm_handles);
+		spin_unlock(&nsm_lock);
 		dprintk("lockd: created nsm_handle for %s (%s)\n",
-				nsm->sm_name, nsm->sm_addrbuf);
-		goto found;
+				new->sm_name, new->sm_addrbuf);
+		return new;
 	}
+
 	spin_unlock(&nsm_lock);
 
-	nsm = nsm_create_handle(sap, salen, hostname, hostname_len);
-	if (unlikely(nsm == NULL))
+	new = nsm_create_handle(sap, salen, hostname, hostname_len);
+	if (unlikely(new == NULL))
 		return NULL;
 	goto retry;
-
-found:
-	spin_unlock(&nsm_lock);
-	return nsm;
 }
 
 /**

