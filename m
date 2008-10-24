From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/14] NSM: Move nsm_find() to fs/lockd/mon.c
Date: Fri, 24 Oct 2008 14:10:01 -0400
Message-ID: <20081024181001.23810.48438.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41623 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbYJXSLV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:21 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBG63009345
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:16 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9N6x3hL010235
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:15 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIA1nJ023895
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:01 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Start coalescing NSM-related functions into fs/lockd/mon.c by moving
the nsm_find() function (and associated static variables) into
fs/lockd/mon.c.

One minor change to nsm_release() -- it doesn't currently look
possible to call it with a NULL argument, so I'm removing that check.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   91 -------------------------------------------
 fs/lockd/mon.c              |   88 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    9 ++++
 3 files changed, 96 insertions(+), 92 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c7516ae..0fb0910 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -32,11 +32,6 @@ static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
 static void			nlm_gc_hosts(void);
-static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
-						const size_t salen,
-						const char *hostname,
-						const size_t hostname_len,
-						const int create);
 
 struct nlm_lookup_host_info {
 	const int		server;		/* search for server|client */
@@ -645,89 +640,3 @@ nlm_gc_hosts(void)
 
 	next_gc = jiffies + NLM_HOST_COLLECT;
 }
-
-
-/*
- * Manage NSM handles
- */
-static LIST_HEAD(nsm_handles);
-static DEFINE_SPINLOCK(nsm_lock);
-
-static struct nsm_handle *nsm_find(const struct sockaddr *sap,
-				   const size_t salen,
-				   const char *hostname,
-				   const size_t hostname_len,
-				   const int create)
-{
-	struct nsm_handle *nsm = NULL;
-	struct nsm_handle *pos;
-
-	if (!sap)
-		return NULL;
-
-	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
-		if (printk_ratelimit()) {
-			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
-					    "in NFS lock request\n",
-				(int)hostname_len, hostname);
-		}
-		return NULL;
-	}
-
-retry:
-	spin_lock(&nsm_lock);
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
-		goto found;
-	}
-	if (nsm) {
-		list_add(&nsm->sm_link, &nsm_handles);
-		goto found;
-	}
-	spin_unlock(&nsm_lock);
-
-	if (!create)
-		return NULL;
-
-	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
-	if (nsm == NULL)
-		return NULL;
-
-	memcpy(nsm_addr(nsm), sap, salen);
-	nsm->sm_addrlen = salen;
-	nsm->sm_name = (char *) (nsm + 1);
-	memcpy(nsm->sm_name, hostname, hostname_len);
-	nsm->sm_name[hostname_len] = '\0';
-	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
-				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
-	atomic_set(&nsm->sm_count, 1);
-	goto retry;
-
-found:
-	spin_unlock(&nsm_lock);
-	return nsm;
-}
-
-/*
- * Release an NSM handle
- */
-void
-nsm_release(struct nsm_handle *nsm)
-{
-	if (!nsm)
-		return;
-	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
-		list_del(&nsm->sm_link);
-		spin_unlock(&nsm_lock);
-		kfree(nsm);
-	}
-}
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4e7e958..a5c6ec4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -29,6 +29,9 @@ static struct rpc_program	nsm_program;
  */
 int				nsm_local_state;
 
+static				LIST_HEAD(nsm_handles);
+static				DEFINE_SPINLOCK(nsm_lock);
+
 /*
  * Common procedure for SM_MON/SM_UNMON calls
  */
@@ -69,6 +72,91 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 	return status;
 }
 
+/**
+ * nsm_find - Find a cached nsm_handle by name or address
+ * @sap: pointer to socket address of handle to find
+ * @salen: length of socket address
+ * @hostname: pointer to C string containing hostname to find
+ * @hostname_len: length of C string
+ * @create: one means create new handle if not found in cache
+ *
+ */
+struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
+			    const char *hostname, const size_t hostname_len,
+			    const int create)
+{
+	struct nsm_handle *nsm = NULL;
+	struct nsm_handle *pos;
+
+	if (!sap)
+		return NULL;
+
+	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
+		if (printk_ratelimit()) {
+			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
+					    "in NFS lock request\n",
+				(int)hostname_len, hostname);
+		}
+		return NULL;
+	}
+
+retry:
+	spin_lock(&nsm_lock);
+	list_for_each_entry(pos, &nsm_handles, sm_link) {
+		if (hostname && nsm_use_hostnames) {
+			if (strlen(pos->sm_name) != hostname_len
+			 || memcmp(pos->sm_name, hostname, hostname_len))
+				continue;
+		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
+			continue;
+
+		atomic_inc(&pos->sm_count);
+		kfree(nsm);
+		nsm = pos;
+		goto found;
+	}
+	if (nsm) {
+		list_add(&nsm->sm_link, &nsm_handles);
+		goto found;
+	}
+	spin_unlock(&nsm_lock);
+
+	if (!create)
+		return NULL;
+
+	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
+	if (nsm == NULL)
+		return NULL;
+
+	memcpy(nsm_addr(nsm), sap, salen);
+	nsm->sm_addrlen = salen;
+	nsm->sm_name = (char *) (nsm + 1);
+	memcpy(nsm->sm_name, hostname, hostname_len);
+	nsm->sm_name[hostname_len] = '\0';
+	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
+				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
+	atomic_set(&nsm->sm_count, 1);
+	goto retry;
+
+found:
+	spin_unlock(&nsm_lock);
+	return nsm;
+}
+
+/**
+ * nsm_release - Release an NSM handle
+ * @nsm: pointer to handle to be released
+ *
+ */
+void nsm_release(struct nsm_handle *nsm)
+{
+	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
+		list_del(&nsm->sm_link);
+		spin_unlock(&nsm_lock);
+		kfree(nsm);
+	}
+}
+
 /*
  * Set up monitoring of a remote host
  */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 4e713f9..a45be5d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -238,8 +238,15 @@ void		  nlm_release_host(struct nlm_host *);
 void		  nlm_shutdown_hosts(void);
 extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
 					unsigned int, u32);
-void		  nsm_release(struct nsm_handle *);
 
+/*
+ * Host monitoring
+ */
+struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
+					const char *hostname,
+					const size_t hostname_len,
+					const int create);
+void		  nsm_release(struct nsm_handle *nsm);
 
 /*
  * This is used in garbage collection and resource reclaim

