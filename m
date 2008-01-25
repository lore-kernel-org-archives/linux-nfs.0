From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 083/100] svc: Add /proc/sys/sunrpc/transport files
Date: Fri, 25 Jan 2008 18:17:03 -0500
Message-ID: <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762179AbYAYXSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:22 -0500
In-Reply-To: <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Add a file that when read lists the set of registered svc
transports.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc_xprt.c           |   28 ++++++++++++++++++++++++++++
 net/sunrpc/sysctl.c             |   31 +++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 405281e..01e71b7 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -79,6 +79,7 @@ void	svc_xprt_copy_addrs(struct svc_rqst *rqstp, struct svc_xprt *xprt);
 void	svc_close_xprt(struct svc_xprt *xprt);
 void	svc_delete_xprt(struct svc_xprt *xprt);
 int	svc_port_is_privileged(struct sockaddr *sin);
+int	svc_print_xprts(char *buf, int maxlen);
 
 static inline void svc_xprt_get(struct svc_xprt *xprt)
 {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 000c7dc..2e5b92a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -112,6 +112,34 @@ void svc_unreg_xprt_class(struct svc_xprt_class *xcl)
 }
 EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
 
+/*
+ * Format the transport list for printing
+ */
+int svc_print_xprts(char *buf, int maxlen)
+{
+	struct list_head *le;
+	char tmpstr[80];
+	int len = 0;
+	buf[0] = '\0';
+
+	spin_lock(&svc_xprt_class_lock);
+	list_for_each(le, &svc_xprt_class_list) {
+		int slen;
+		struct svc_xprt_class *xcl =
+			list_entry(le, struct svc_xprt_class, xcl_list);
+
+		sprintf(tmpstr, "%s %d\n", xcl->xcl_name, xcl->xcl_max_payload);
+		slen = strlen(tmpstr);
+		if (len + slen > maxlen)
+			break;
+		len += slen;
+		strcat(buf, tmpstr);
+	}
+	spin_unlock(&svc_xprt_class_lock);
+
+	return len;
+}
+
 static void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 2be714e..fd7cf59 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -18,6 +18,7 @@
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/svc_xprt.h>
 
 /*
  * Declare the debug flags here
@@ -48,6 +49,30 @@ rpc_unregister_sysctl(void)
 	}
 }
 
+static int proc_do_xprt(ctl_table *table, int write, struct file *file,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	char tmpbuf[256];
+	int len;
+	if ((*ppos && !write) || !*lenp) {
+		*lenp = 0;
+		return 0;
+	}
+	if (write)
+		return -EINVAL;
+	else {
+		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
+		if (!access_ok(VERIFY_WRITE, buffer, len))
+			return -EFAULT;
+
+		if (__copy_to_user(buffer, tmpbuf, len))
+			return -EFAULT;
+	}
+	*lenp -= len;
+	*ppos += len;
+	return 0;
+}
+
 static int
 proc_dodebug(ctl_table *table, int write, struct file *file,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -140,6 +165,12 @@ static ctl_table debug_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dodebug
 	},
+	{
+		.procname	= "transports",
+		.maxlen		= 256,
+		.mode		= 0444,
+		.proc_handler	= &proc_do_xprt,
+	},
 	{ .ctl_name = 0 }
 };
 
-- 
1.5.4.rc2.60.gb2e62

