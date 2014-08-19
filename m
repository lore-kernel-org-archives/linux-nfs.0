Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:37170 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSSik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:38:40 -0400
Received: by mail-qc0-f177.google.com with SMTP id x13so6730734qcv.36
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:38:39 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] lockd: add a /proc/fs/lockd/nlm_end_grace file
Date: Tue, 19 Aug 2014 14:38:26 -0400
Message-Id: <1408473509-14010-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new procfile that will allow a (privileged) userland process to
end the NLM grace period early. The basic idea here will be to have
sm-notify write to this file, if it sent out no NOTIFY requests when
it runs. In that situation, we can generally expect that there will be
no reclaim requests so the grace period can be lifted early.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/Makefile |  1 +
 fs/lockd/procfs.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/procfs.h | 28 ++++++++++++++++++++
 fs/lockd/svc.c    |  9 +++++++
 4 files changed, 114 insertions(+)
 create mode 100644 fs/lockd/procfs.c
 create mode 100644 fs/lockd/procfs.h

diff --git a/fs/lockd/Makefile b/fs/lockd/Makefile
index 6a0b351ce30e..9b320cc2a8cf 100644
--- a/fs/lockd/Makefile
+++ b/fs/lockd/Makefile
@@ -7,4 +7,5 @@ obj-$(CONFIG_LOCKD) += lockd.o
 lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
 	        svcshare.o svcproc.o svcsubs.o mon.o xdr.o
 lockd-objs-$(CONFIG_LOCKD_V4) += clnt4xdr.o xdr4.o svc4proc.o
+lockd-objs-$(CONFIG_PROC_FS) += procfs.o
 lockd-objs		      := $(lockd-objs-y)
diff --git a/fs/lockd/procfs.c b/fs/lockd/procfs.c
new file mode 100644
index 000000000000..dfd708fa43a3
--- /dev/null
+++ b/fs/lockd/procfs.c
@@ -0,0 +1,76 @@
+/*
+ * Procfs support for lockd
+ *
+ * Copyright (c) 2014 Jeff Layton <jlayton@primarydata.com>
+ */
+
+#include <linux/fs.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+
+#include "netns.h"
+#include "procfs.h"
+
+/*
+ * Just check to see if the data written is longer than zero length. We
+ * don't really care what's in the data, just that someone wrote something
+ * to the file.
+ */
+static ssize_t
+nlm_end_grace_write(struct file *file, const char __user *buf, size_t size,
+		    loff_t *pos)
+{
+	struct lockd_net *ln = net_generic(current->nsproxy->net_ns, lockd_net_id);
+
+	if (size > 0)
+		locks_end_grace(&ln->lockd_manager);
+
+	return size;
+}
+
+static ssize_t
+nlm_end_grace_read(struct file *file, char __user *buf, size_t size,
+		   loff_t *pos)
+{
+	struct lockd_net *ln = net_generic(current->nsproxy->net_ns, lockd_net_id);
+	char resp[3];
+
+	resp[0] = list_empty(&ln->lockd_manager.list) ? 'Y' : 'N';
+	resp[1] = '\n';
+	resp[2] = '\0';
+
+	return simple_read_from_buffer(buf, size, pos, resp, sizeof(resp));
+}
+
+static const struct file_operations lockd_end_grace_operations = {
+	.write		= nlm_end_grace_write,
+	.read		= nlm_end_grace_read,
+	.llseek		= default_llseek,
+	.owner		= THIS_MODULE,
+};
+
+int __init
+lockd_create_procfs(void)
+{
+	struct proc_dir_entry *entry;
+
+	entry = proc_mkdir("fs/lockd", NULL);
+	if (!entry)
+		return -ENOMEM;
+	entry = proc_create("nlm_end_grace", S_IRUGO|S_IWUSR, entry,
+				 &lockd_end_grace_operations);
+	if (!entry) {
+		remove_proc_entry("fs/lockd", NULL);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+void __exit
+lockd_remove_procfs(void)
+{
+	remove_proc_entry("fs/lockd/nlm_end_grace", NULL);
+	remove_proc_entry("fs/lockd", NULL);
+}
diff --git a/fs/lockd/procfs.h b/fs/lockd/procfs.h
new file mode 100644
index 000000000000..2257a1311027
--- /dev/null
+++ b/fs/lockd/procfs.h
@@ -0,0 +1,28 @@
+/*
+ * Procfs support for lockd
+ *
+ * Copyright (c) 2014 Jeff Layton <jlayton@primarydata.com>
+ */
+#ifndef _LOCKD_PROCFS_H
+#define _LOCKD_PROCFS_H
+
+#include <linux/kconfig.h>
+
+#if IS_ENABLED(CONFIG_PROC_FS)
+int lockd_create_procfs(void);
+void lockd_remove_procfs(void);
+#else
+static inline int
+lockd_create_procfs(void)
+{
+	return 0;
+}
+
+static inline void
+lockd_remove_procfs(void)
+{
+	return;
+}
+#endif /* IS_ENABLED(CONFIG_PROC_FS) */
+
+#endif /* _LOCKD_PROCFS_H */
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 3599c9ca28ae..f01a9aa01dff 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -36,6 +36,7 @@
 #include <linux/nfs.h>
 
 #include "netns.h"
+#include "procfs.h"
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
 #define LOCKD_BUFSIZE		(1024 + NLMSVC_XDRSIZE)
@@ -616,8 +617,15 @@ static int __init init_nlm(void)
 	err = register_pernet_subsys(&lockd_net_ops);
 	if (err)
 		goto err_pernet;
+
+	err = lockd_create_procfs();
+	if (err)
+		goto err_procfs;
+
 	return 0;
 
+err_procfs:
+	unregister_pernet_subsys(&lockd_net_ops);
 err_pernet:
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
@@ -630,6 +638,7 @@ static void __exit exit_nlm(void)
 {
 	/* FIXME: delete all NLM clients */
 	nlm_shutdown_hosts();
+	lockd_remove_procfs();
 	unregister_pernet_subsys(&lockd_net_ops);
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nlm_sysctl_table);
-- 
1.9.3

