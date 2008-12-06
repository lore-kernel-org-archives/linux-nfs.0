From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/27] NSM: Add nsm_lookup() function
Date: Fri, 05 Dec 2008 19:03:46 -0500
Message-ID: <20081206000346.24075.23426.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:30574 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbYLFAEm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:42 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new API to fs/lockd/mon.c that allows nlm_host_rebooted()
to lookup up nsm_handles via the contents of an nlm_reboot struct.

The new function is equivalent to calling nsm_find() with @create set
to zero, but it takes a struct nlm_reboot instead of separate
arguments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |   64 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    1 +
 2 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e0a799d..65fb904 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -202,6 +202,29 @@ void nsm_unmonitor(const struct nlm_host *host)
 	}
 }
 
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
 /*
  * Construct a unique cookie to match this nsm_handle to this monitored
  * host.  It is passed to the local rpc.statd via NSMPROC_MON, and
@@ -298,6 +321,47 @@ retry:
 }
 
 /**
+ * nsm_reboot_lookup - match NLMPROC_SM_NOTIFY arguments to an nsm_handle
+ * @info: pointer to NLMPROC_SM_NOTIFY arguments
+ *
+ * Returns a matching nsm_handle if found in the nsm cache; the returned
+ * nsm_handle's reference count is bumped and sm_monitored is cleared.
+ * Otherwise returns NULL if some error occurred.
+ */
+struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
+{
+	struct nsm_handle *cached;
+
+	spin_lock(&nsm_lock);
+
+	if (nsm_use_hostnames && info->mon != NULL)
+		cached = nsm_lookup_hostname(info->mon, info->len);
+	else
+		cached = nsm_lookup_priv(&info->priv);
+
+	if (unlikely(cached == NULL)) {
+		spin_unlock(&nsm_lock);
+		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
+				info->len, info->mon);
+		return cached;
+	}
+
+	atomic_inc(&cached->sm_count);
+	spin_unlock(&nsm_lock);
+
+	/*
+	 * During subsequent lock activity, force a fresh
+	 * notification to be set up for this host.
+	 */
+	cached->sm_monitored = 0;
+
+	dprintk("lockd: host %s (%s) rebooted, cnt %d\n",
+			cached->sm_name, cached->sm_addrbuf,
+			atomic_read(&cached->sm_count));
+	return cached;
+}
+
+/**
  * nsm_release - Release an NSM handle
  * @nsm: pointer to handle to be released
  *
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 2a3533e..5e3ad92 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -251,6 +251,7 @@ struct nsm_handle *nsm_find(const struct sockaddr *sap, const size_t salen,
 					const char *hostname,
 					const size_t hostname_len,
 					const int create);
+struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 void		  nsm_release(struct nsm_handle *nsm);
 
 /*

