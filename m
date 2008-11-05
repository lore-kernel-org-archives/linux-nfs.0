From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/18] NSM: Add nsm_lookup() function
Date: Wed, 05 Nov 2008 12:20:49 -0500
Message-ID: <20081105172049.6773.38419.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:36753 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbYKERVd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:33 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new function to fs/lockd/mon.c that allows nlm_host_rebooted()
to lookup up nsm_handles by their "priv".

This should not introduce a behavioral change, but finishes the job of
collecting all logic in fs/lockd/mon.c that cares what's inside an
nsm_private structure.

This will make it easier to modify the contents and interpretation of
the "priv" argument, but for now NLM and NSM should behave exactly as
they did before.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    8 +-----
 fs/lockd/mon.c              |   53 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    1 +
 3 files changed, 55 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 7f82c65..2c3406d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -498,18 +498,12 @@ void nlm_release_host(struct nlm_host *host)
  */
 void nlm_host_rebooted(struct nlm_reboot *info)
 {
-	__be32 *p = (__be32 *)&info->priv.data;
-	const struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-		.sin_addr.s_addr	= *p,
-	};
 	struct hlist_head *chain;
 	struct hlist_node *pos;
 	struct nsm_handle *nsm;
 	struct nlm_host	*host;
 
-	nsm = nsm_find((struct sockaddr *)&sin, sizeof(sin),
-			info->mon, info->len, 0);
+	nsm = nsm_reboot_lookup(info);
 	if (nsm == NULL) {
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
 				info->len, info->mon);
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index efbb2ea..612f0ea 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -175,6 +175,29 @@ int nsm_unmonitor(struct nlm_host *host)
 	return status;
 }
 
+static struct nsm_handle *nsm_lookup_priv(const struct nsm_private *priv)
+{
+	struct nsm_handle *nsm;
+
+	list_for_each_entry(nsm, &nsm_handles, sm_link)
+		if (memcmp(nsm->sm_priv.data, priv->data,
+					sizeof(priv->data)) == 0)
+			return nsm;
+	return NULL;
+}
+
+static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
+					      const size_t len)
+{
+	struct nsm_handle *nsm;
+
+	list_for_each_entry(nsm, &nsm_handles, sm_link)
+		if (strlen(nsm->sm_name) == len &&
+		    memcmp(nsm->sm_name, hostname, len) == 0)
+			return nsm;
+	return NULL;
+}
+
 /*
  * Construct a unique cookie to identify this nsm_handle.  It is
  * passed to our statd via NSMPROC_MON, and returned via
@@ -273,6 +296,36 @@ retry:
 }
 
 /**
+ * nsm_reboot_lookup - match NLMPROC_SM_NOTIFY arguments to an nsm_handle
+ * @info: pointer to NLMPROC_SM_NOTIFY arguments
+ *
+ * Returns a matching nsm_handle if found in the nsm cache; otherwise
+ * returns NULL;
+ */
+struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
+{
+	struct nsm_handle *cached;
+
+	spin_lock(&nsm_lock);
+
+	if (nsm_use_hostnames && info->mon)
+		cached = nsm_lookup_hostname(info->mon, info->len);
+	else
+		cached = nsm_lookup_priv(&info->priv);
+
+	if (cached) {
+		atomic_inc(&cached->sm_count);
+		spin_unlock(&nsm_lock);
+		dprintk("lockd: found nsm_handle for rebooted host %s (%s), "
+			"cnt %d\n", cached->sm_name, cached->sm_addrbuf,
+			atomic_read(&cached->sm_count));
+	} else
+		spin_unlock(&nsm_lock);
+
+	return cached;
+}
+
+/**
  * nsm_release - Release an NSM handle
  * @nsm: pointer to handle to be released
  *
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 8f6369d..09a600e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -251,6 +251,7 @@ struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
 void		  nsm_release(struct nsm_handle *nsm);
 int		  nsm_monitor(struct nlm_host *host);
 int		  nsm_unmonitor(struct nlm_host *host);
+struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 
 /*
  * This is used in garbage collection and resource reclaim

