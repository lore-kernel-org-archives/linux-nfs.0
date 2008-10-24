From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] NLM: Remove "create" argument from nsm_find()
Date: Fri, 24 Oct 2008 14:11:23 -0400
Message-ID: <20081024181123.23810.65076.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14305 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169AbYJXSLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:39 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m9OIBZ7f008736
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:35 -0600
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O7nOPV002814
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:35 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIBNED024049
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:11:23 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: nsm_find() now has only one caller who always sets the
"create" argument, so it is no longer needed.  Since nsm_find() now
has a more specific function, pick a more appropriate name for it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    4 ++--
 fs/lockd/mon.c              |   12 ++++--------
 include/linux/lockd/lockd.h |    6 +++---
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 181cb26..db66bfb 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -207,8 +207,8 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		atomic_inc(&nsm->sm_count);
 	else {
 		host = NULL;
-		nsm = nsm_find(ni->sap, ni->salen,
-				ni->hostname, ni->hostname_len, 1);
+		nsm = nsm_get_handle(ni->sap, ni->salen,
+					ni->hostname, ni->hostname_len);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 78bc36c..d564b6f 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -149,17 +149,16 @@ static void nsm_init_private(struct nsm_handle *nsm)
 }
 
 /**
- * nsm_find - Find a cached nsm_handle by name or address
+ * nsm_get_handle - Find a cached nsm_handle by name or address
  * @sap: pointer to socket address of handle to find
  * @salen: length of socket address
  * @hostname: pointer to C string containing hostname to find
  * @hostname_len: length of C string
- * @create: one means create new handle if not found in cache
  *
  */
-struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
-			    const char *hostname, const size_t hostname_len,
-			    const int create)
+struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
+				  const size_t salen, const char *hostname,
+				  const size_t hostname_len)
 {
 	struct nsm_handle *nsm = NULL;
 	struct nsm_handle *pos;
@@ -197,9 +196,6 @@ retry:
 	}
 	spin_unlock(&nsm_lock);
 
-	if (!create)
-		return NULL;
-
 	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
 	if (nsm == NULL)
 		return NULL;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 46f5cee..052078c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -244,10 +244,10 @@ void		  nlm_host_rebooted(struct nlm_reboot *);
 /*
  * Host monitoring
  */
-struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
+struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
+					const size_t salen,
 					const char *hostname,
-					const size_t hostname_len,
-					const int create);
+					const size_t hostname_len);
 void		  nsm_release(struct nsm_handle *nsm);
 int		  nsm_monitor(struct nlm_host *host);
 int		  nsm_unmonitor(struct nlm_host *host);

