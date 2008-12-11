From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] NLM: Remove "create" argument from nsm_find()
Date: Thu, 11 Dec 2008 17:55:44 -0500
Message-ID: <20081211225544.21468.24852.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17135 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759423AbYLKW4Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:16 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: nsm_find() now has only one caller, and that caller
unconditionally sets the @create argument. Thus the @create
argument is no longer needed.

Since nsm_find() now has a more specific purpose, pick a more
appropriate name for it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    4 ++--
 fs/lockd/mon.c              |   23 +++++++++--------------
 include/linux/lockd/lockd.h |    6 +++---
 3 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 230de93..e5a65df 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -159,8 +159,8 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
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
index c6ab263..0dd309d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -241,24 +241,22 @@ static void nsm_init_private(struct nsm_handle *nsm)
 }
 
 /**
- * nsm_find - Find or create a cached nsm_handle
+ * nsm_get_handle - Find or create a cached nsm_handle
  * @sap: pointer to socket address of handle to find
  * @salen: length of socket address
  * @hostname: pointer to C string containing hostname to find
  * @hostname_len: length of C string
- * @create: one means create new handle if not found in cache
  *
- * Behavior is modulated by the global nsm_use_hostnames variable
- * and by the @create argument.
+ * Behavior is modulated by the global nsm_use_hostnames variable.
  *
- * Returns a cached nsm_handle after bumping its ref count, or if
- * @create is set, returns a fresh nsm_handle if a handle that
- * matches @sap and/or @hostname cannot be found in the handle cache.
- * Returns NULL if an error occurs.
+ * Returns a cached nsm_handle after bumping its ref count, or
+ * returns a fresh nsm_handle if a handle that matches @sap and/or
+ * @hostname cannot be found in the handle cache.  Returns NULL if
+ * an error occurs.
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
@@ -298,9 +296,6 @@ retry:
 	}
 	spin_unlock(&nsm_lock);
 
-	if (!create)
-		return NULL;
-
 	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
 	if (nsm == NULL)
 		return NULL;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 5e3ad92..1ccd49e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -247,10 +247,10 @@ void		  nlm_host_rebooted(const struct nlm_reboot *);
 int		  nsm_monitor(const struct nlm_host *host);
 void		  nsm_unmonitor(const struct nlm_host *host);
 
-struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
+struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
+					const size_t salen,
 					const char *hostname,
-					const size_t hostname_len,
-					const int create);
+					const size_t hostname_len);
 struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 void		  nsm_release(struct nsm_handle *nsm);
 

