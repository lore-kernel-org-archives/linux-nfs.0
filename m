From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/11] lockd: Add /sys/fs/lockd
Date: Thu, 01 Apr 2010 15:02:26 -0400
Message-ID: <20100401190226.6395.86760.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:53828 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab0DATCc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:02:32 -0400
Received: by qw-out-2122.google.com with SMTP id 8so489291qwh.37
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:02:31 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
index 7d15051..94e0d4b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -76,6 +76,8 @@ static const int		nlm_port_min = 0, nlm_port_max = 65535;
 static struct ctl_table_header * nlm_sysctl_table;
 #endif
 
+struct kobject			*nlm_kobj;
+
 static unsigned long get_lockd_grace_period(void)
 {
 	/* Note: nlm_timeout should always be nonzero */
@@ -515,12 +517,19 @@ module_param(nlm_max_connections, uint, 0644);
 
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
@@ -530,6 +539,7 @@ static void __exit exit_nlm(void)
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

