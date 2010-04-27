From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/9] lockd: Add /sys/fs/lockd
Date: Tue, 27 Apr 2010 14:58:30 -0400
Message-ID: <20100427185829.29074.77530.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:55014 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973Ab0D0S6c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:58:32 -0400
Received: by mail-pz0-f204.google.com with SMTP id 42so9187550pzk.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:58:32 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create the parent directory for all lockd-related sysfs entries.  The
directory is created when lockd.ko is loaded, and removed when it is
unloaded.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c              |   16 +++++++++++++---
 include/linux/lockd/lockd.h |    1 +
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f1bacf1..c84a7d5 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -75,6 +75,8 @@ static const int		nlm_port_min = 0, nlm_port_max = 65535;
 static struct ctl_table_header * nlm_sysctl_table;
 #endif
 
+struct kobject			*nlm_kobj;
+
 static unsigned long get_lockd_grace_period(void)
 {
 	/* Note: nlm_timeout should always be nonzero */
@@ -514,12 +516,19 @@ module_param(nlm_max_connections, uint, 0644);
 
 static int __init init_nlm(void)
 {
+	nlm_kobj = kobject_create_and_add("lockd", fs_kobj);
+	if (!nlm_kobj)
+		return -ENOMEM;
+
 #ifdef CONFIG_SYSCTL
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
-	return nlm_sysctl_table ? 0 : -ENOMEM;
-#else
-	return 0;
+	if (!nlm_sysctl_table) {
+		kobject_put(nlm_kobj);
+		return -ENOMEM;
+	}
 #endif
+
+	return 0;
 }
 
 static void __exit exit_nlm(void)
@@ -529,6 +538,7 @@ static void __exit exit_nlm(void)
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
 #endif
+	kobject_put(nlm_kobj);
 }
 
 module_init(init_nlm);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index a34dea4..56c749e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -196,6 +196,7 @@ extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
 extern u32			nsm_local_state;
+extern struct kobject		*nlm_kobj;
 
 /*
  * Lockd client functions

