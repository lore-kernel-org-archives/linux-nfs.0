From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 32/33] svc: Add /proc/sys/sunrpc/transport files
Date: Thu, 27 Sep 2007 00:02:41 -0500
Message-ID: <20070927050241.12677.39588.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalWN-0005kn-DL
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:43 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWR-0005a8-2C
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:48 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Add a file that when read lists the set of registered svc
transports.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/debug.h    |    1 +
 include/linux/sunrpc/svc_xprt.h |    2 +-
 net/sunrpc/svc_xprt.c           |   28 ++++++++++++++++++++++++++++
 net/sunrpc/sysctl.c             |   37 +++++++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 10709cb..89458df 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -88,6 +88,7 @@ enum {
 	CTL_SLOTTABLE_TCP,
 	CTL_MIN_RESVPORT,
 	CTL_MAX_RESVPORT,
+	CTL_TRANSPORTS,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index a0fbb4f..e4ce4e1 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -80,5 +80,5 @@ static inline void svc_xprt_get(struct s
 }
 void	svc_delete_xprt(struct svc_xprt *xprt);
 void	svc_close_xprt(struct svc_xprt *xprt);
-
+int	svc_print_xprts(char *buf, int maxlen);
 #endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 1a7cde0..99c47c8 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -93,6 +93,34 @@ int svc_unreg_xprt_class(struct svc_xprt
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
 static inline void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 738db32..8642f6f 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -18,6 +18,7 @@ #include <asm/uaccess.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/svc_xprt.h>
 
 /*
  * Declare the debug flags here
@@ -27,6 +28,8 @@ unsigned int	nfs_debug;
 unsigned int	nfsd_debug;
 unsigned int	nlm_debug;
 
+char 		xprt_buf[128];
+
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
@@ -48,6 +51,32 @@ rpc_unregister_sysctl(void)
 	}
 }
 
+static int proc_do_xprt(ctl_table *table, int write, struct file *file,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	char tmpbuf[sizeof(xprt_buf)];
+	int len;
+	if ((*ppos && !write) || !*lenp) {
+		*lenp = 0;
+		return 0;
+	}
+	if (write)
+		return -EINVAL;
+	else {
+
+		len = svc_print_xprts(tmpbuf, sizeof(tmpbuf));
+		if (!access_ok(VERIFY_WRITE, buffer, len))
+			return -EFAULT;
+
+		if (__copy_to_user(buffer, tmpbuf, len))
+			return -EFAULT;
+	}
+
+	*lenp -= len;
+	*ppos += len;
+	return 0;
+}
+
 static int
 proc_dodebug(ctl_table *table, int write, struct file *file,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -145,6 +174,14 @@ static ctl_table debug_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dodebug
 	},
+	{
+		.ctl_name	= CTL_TRANSPORTS,
+		.procname	= "transports",
+		.data		= xprt_buf,
+		.maxlen		= sizeof(xprt_buf),
+		.mode		= 0444,
+		.proc_handler	= &proc_do_xprt,
+	},
 	{ .ctl_name = 0 }
 };
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
