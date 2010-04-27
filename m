From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/9] lockd: Add /sys/fs/lockd/mon
Date: Tue, 27 Apr 2010 14:59:10 -0400
Message-ID: <20100427185909.29074.64031.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:55014 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169Ab0D0S7P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:59:15 -0400
Received: by mail-pz0-f204.google.com with SMTP id 42so9187550pzk.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:59:15 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add parent directory to contain entries representing each entry in
lockd's nsm_handles cache.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c              |   27 +++++++++++++++++++++++++++
 fs/lockd/svc.c              |    8 ++++++++
 include/linux/lockd/lockd.h |    2 ++
 3 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e301546..6e16a28 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -57,6 +57,8 @@ static				DEFINE_SPINLOCK(nsm_lock);
 u32	__read_mostly		nsm_local_state;
 int	__read_mostly		nsm_use_hostnames;
 
+static struct kobject		*nsm_handles_kobj;
+
 static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 {
 	return (struct sockaddr *)&nsm->sm_addr;
@@ -393,6 +395,31 @@ void nsm_release(struct nsm_handle *nsm)
 	}
 }
 
+/**
+ * nsm_init - Called when lockd module is loaded
+ *
+ */
+int nsm_init(void)
+{
+	nsm_handles_kobj = kobject_create_and_add("monitor", nlm_kobj);
+	if (nsm_handles_kobj == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+/**
+ * nsm_shutdown - Called when lockd module is about to be unloaded
+ *
+ */
+void nsm_shutdown(void)
+{
+	if (!list_empty(&nsm_handles)) {
+		printk(KERN_WARNING "NSM handles remain at shutdown");
+		return;
+	}
+	kobject_put(nsm_handles_kobj);
+}
+
 /*
  * XDR functions for NSM.
  *
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 148623d..1b484bf 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -525,9 +525,16 @@ static int __init init_nlm(void)
 		return -ENOMEM;
 	}
 
+	if (nsm_init()) {
+		nlm_host_shutdown();
+		kobject_put(nlm_kobj);
+		return -ENOMEM;
+	}
+
 #ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
 	if (!nlm_sysctl_table) {
+		nsm_shutdown();
 		nlm_host_shutdown();
 		kobject_put(nlm_kobj);
 		return -ENOMEM;
@@ -544,6 +551,7 @@ static void __exit exit_nlm(void)
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
 #endif
+	nsm_shutdown();
 	nlm_host_shutdown();
 	kobject_put(nlm_kobj);
 }
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index bdb87a6..8622a28 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -239,6 +239,8 @@ void		  nlm_host_rebooted(const struct nlm_reboot *);
 /*
  * Host monitoring
  */
+int		  nsm_init(void);
+void		  nsm_shutdown(void);
 int		  nsm_monitor(const struct nlm_host *host);
 void		  nsm_unmonitor(const struct nlm_host *host);
 

