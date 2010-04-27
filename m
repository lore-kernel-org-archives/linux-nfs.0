From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/9] lockd: Add /sys/fs/lockd/hosts/
Date: Tue, 27 Apr 2010 14:58:40 -0400
Message-ID: <20100427185839.29074.275.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:55014 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab0D0S6n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:58:43 -0400
Received: by mail-pz0-f204.google.com with SMTP id 42so9187550pzk.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:58:43 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add parent directory to contain directories representing entries in
lockd's host cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   46 +++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/svc.c              |    7 +++++++
 include/linux/lockd/lockd.h |    2 ++
 3 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index bb464d1..be3f87c 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -45,6 +45,10 @@ struct nlm_lookup_host_info {
 	const int		noresvport;	/* use non-priv port */
 };
 
+static struct kobject		*nlm_hosts_kobj;
+static struct kobject		*nlm_hosts_client_kobj;
+static struct kobject		*nlm_hosts_server_kobj;
+
 /*
  * Hash function must work well on big- and little-endian platforms
  */
@@ -567,3 +571,45 @@ nlm_gc_hosts(void)
 
 	next_gc = jiffies + NLM_HOST_COLLECT;
 }
+
+/**
+ * nlm_host_init - Called when lockd module is loaded
+ *
+ */
+int nlm_host_init(void)
+{
+	nlm_hosts_kobj = kobject_create_and_add("hosts", nlm_kobj);
+	if (nlm_hosts_kobj == NULL)
+		return -ENOMEM;
+
+	nlm_hosts_server_kobj = kobject_create_and_add("server", nlm_hosts_kobj);
+	if (nlm_hosts_server_kobj == NULL) {
+		kobject_put(nlm_hosts_kobj);
+		return -ENOMEM;
+	}
+
+	nlm_hosts_client_kobj = kobject_create_and_add("client", nlm_hosts_kobj);
+	if (nlm_hosts_client_kobj == NULL) {
+		kobject_put(nlm_hosts_server_kobj);
+		kobject_put(nlm_hosts_kobj);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+/**
+ * nlm_host_shutdown - Called when lockd module is about to be unloaded
+ *
+ */
+void nlm_host_shutdown(void)
+{
+	if (nrhosts != 0) {
+		printk(KERN_WARNING "NLM hosts remain at shutdown");
+		return;
+ 	}
+
+	kobject_put(nlm_hosts_client_kobj);
+	kobject_put(nlm_hosts_server_kobj);
+	kobject_put(nlm_hosts_kobj);
+}
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c84a7d5..148623d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -520,9 +520,15 @@ static int __init init_nlm(void)
 	if (!nlm_kobj)
 		return -ENOMEM;
 
+	if (nlm_host_init()) {
+		kobject_put(nlm_kobj);
+		return -ENOMEM;
+	}
+
 #ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
 	if (!nlm_sysctl_table) {
+		nlm_host_shutdown();
 		kobject_put(nlm_kobj);
 		return -ENOMEM;
 	}
@@ -538,6 +544,7 @@ static void __exit exit_nlm(void)
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
 #endif
+	nlm_host_shutdown();
 	kobject_put(nlm_kobj);
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 56c749e..2d89cdb 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -217,6 +217,8 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
 /*
  * Host cache
  */
+int		  nlm_host_init(void);
+void		  nlm_host_shutdown(void);
 struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 					const size_t salen,
 					const unsigned short protocol,

