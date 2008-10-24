From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/14] NSM: Add nsm_lookup() function
Date: Fri, 24 Oct 2008 14:11:01 -0400
Message-ID: <20081024181101.23810.33419.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41758 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbYJXSL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:26 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBJhV009705
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:20 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9ODVg8t028259
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:17 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIB1E5024007
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:11:01 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 fs/lockd/host.c             |    8 +------
 fs/lockd/mon.c              |   48 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    1 +
 3 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 4949eb3..1ecec4f 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -501,18 +501,12 @@ void nlm_release_host(struct nlm_host *host)
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
index a4d2b9e..c38ef20 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -101,6 +101,29 @@ nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
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
  * passed to our statd via SM_MON, and returned via NLM_SM_NOTIFY,
@@ -188,6 +211,31 @@ found:
 }
 
 /**
+ * nsm_reboot_lookup - match NLM_SM_NOTIFY arguments to an nsm_handle
+ * @info: pointer to NLM_SM_NOTIFY arguments
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
+	if (cached)
+		atomic_inc(&cached->sm_count);
+
+	spin_unlock(&nsm_lock);
+
+	return cached;
+}
+
+/**
  * nsm_release - Release an NSM handle
  * @nsm: pointer to handle to be released
  *
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index d271169..46f5cee 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -251,6 +251,7 @@ struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
 void		  nsm_release(struct nsm_handle *nsm);
 int		  nsm_monitor(struct nlm_host *host);
 int		  nsm_unmonitor(struct nlm_host *host);
+struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 
 /*
  * This is used in garbage collection and resource reclaim

