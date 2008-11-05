From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/18] NSM: Move nsm_find() to fs/lockd/mon.c
Date: Wed, 05 Nov 2008 12:19:50 -0500
Message-ID: <20081105171950.6773.57153.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:19711 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbYKERU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:26 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Start coalescing NSM-related functions into fs/lockd/mon.c by moving
the nsm_find() function (and associated static variables) into
fs/lockd/mon.c.

Add dprintk()s (enabled via NLMDBG_MONITOR) to indicate when an
nsm_handle has been created, found, or destroyed.

It doesn't currently seem possible to call nsm_release() with a NULL
argument, so I'm removing that check.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |  102 ++++---------------------------------------
 fs/lockd/mon.c              |  101 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |   11 ++++-
 3 files changed, 120 insertions(+), 94 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 50b7787..50dcf79 100644
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
@@ -126,8 +121,15 @@ static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
 		snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
 }
 
-static void nlm_display_address(const struct sockaddr *sap,
-				char *buf, const size_t len)
+/**
+ * nlm_display_address - Convert sockaddr to presentation format
+ * @sap: pointer to socket address
+ * @buf: pointer to buffer to fill in
+ * @len: length of buffer
+ *
+ */
+void nlm_display_address(const struct sockaddr *sap, char *buf,
+			 const size_t len)
 {
 	switch (sap->sa_family) {
 	case AF_UNSPEC:
@@ -635,89 +637,3 @@ nlm_gc_hosts(void)
 
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
index d03d1ea..3811485 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -21,6 +21,8 @@
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
+static				LIST_HEAD(nsm_handles);
+static				DEFINE_SPINLOCK(nsm_lock);
 
 /*
  * Local NSM state
@@ -125,6 +127,105 @@ nsm_unmonitor(struct nlm_host *host)
 	return status;
 }
 
+/**
+ * nsm_find - Find or create a cached nsm_handle
+ * @sap: pointer to socket address of handle to find
+ * @salen: length of socket address
+ * @hostname: pointer to C string containing hostname to find
+ * @hostname_len: length of C string
+ * @create: one means create new handle if not found in cache
+ *
+ * Behavior is modulated by the global nsm_use_hostnames variable
+ * and by the @create argument.
+ *
+ * Returns a cached nsm_handle after bumping its ref count, or if
+ * @create is set, returns a fresh nsm_handle if a handle that
+ * matches @sap and/or @hostname cannot be found in the handle cache.
+ * Returns NULL if an error occurs.
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
+		spin_unlock(&nsm_lock);
+		kfree(nsm);
+		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
+				pos->sm_name, pos->sm_addrbuf,
+				atomic_read(&pos->sm_count));
+		return pos;
+	}
+
+	if (nsm) {
+		list_add(&nsm->sm_link, &nsm_handles);
+		spin_unlock(&nsm_lock);
+		dprintk("lockd: created nsm_handle for %s (%s)\n",
+				nsm->sm_name, nsm->sm_addrbuf);
+		return nsm;
+	}
+
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
+}
+
+/**
+ * nsm_release - Release an NSM handle
+ * @nsm: pointer to handle to be released
+ *
+ */
+void nsm_release(struct nsm_handle *nsm)
+{
+	if (!atomic_dec_and_lock(&nsm->sm_count, &nsm_lock))
+		return;
+
+	list_del(&nsm->sm_link);
+	spin_unlock(&nsm_lock);
+	dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
+			nsm->sm_name, nsm->sm_addrbuf);
+	kfree(nsm);
+}
+
 /*
  * Create NSM client for the local host
  */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 3e0b7a8..34f0101 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -229,6 +229,8 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 					const char *hostname,
 					const size_t hostname_len);
+void		  nlm_display_address(const struct sockaddr *sap,
+					char *buf, const size_t len);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
@@ -236,8 +238,15 @@ void		  nlm_release_host(struct nlm_host *);
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

