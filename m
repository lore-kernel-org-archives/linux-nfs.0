From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 047/100] svc: Add an svc transport class
Date: Fri, 25 Jan 2008 18:16:27 -0500
Message-ID: <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
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
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079AbYAYXRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:44 -0500
In-Reply-To: <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

The transport class (svc_xprt_class) represents a type of transport, e.g.
udp, tcp, rdma.  A transport class has a unique name and a set of transport
operations kept in the svc_xprt_ops structure.

A transport class can be dynamically registered and unregisterd. The
svc_xprt_class represents the module that implements the transport
type and keeps reference counts on the module to avoid unloading while
there are active users.

The endpoint (svc_xprt) is a generic, transport independent endpoint that can
be used to send and receive data for an RPC service. It inherits it's
operations from the transport class.

A transport driver module registers and unregisters itself with svc sunrpc
by calling svc_reg_xprt_class, and svc_unreg_xprt_class respectively.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/debug.h    |    1 +
 include/linux/sunrpc/svc_xprt.h |   31 ++++++++++++++
 net/sunrpc/Makefile             |    3 +-
 net/sunrpc/svc_xprt.c           |   83 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 117 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/sunrpc/svc_xprt.h
 create mode 100644 net/sunrpc/svc_xprt.c

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 3912cf1..092fcfa 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -21,6 +21,7 @@
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
 #define RPCDBG_SVCSOCK		0x0100
+#define RPCDBG_SVCXPRT		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
 #define RPCDBG_CACHE		0x0800
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
new file mode 100644
index 0000000..fe8e787
--- /dev/null
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -0,0 +1,31 @@
+/*
+ * linux/include/linux/sunrpc/svc_xprt.h
+ *
+ * RPC server transport I/O
+ */
+
+#ifndef SUNRPC_SVC_XPRT_H
+#define SUNRPC_SVC_XPRT_H
+
+#include <linux/sunrpc/svc.h>
+
+struct svc_xprt_ops {
+};
+
+struct svc_xprt_class {
+	const char		*xcl_name;
+	struct module		*xcl_owner;
+	struct svc_xprt_ops	*xcl_ops;
+	struct list_head	xcl_list;
+};
+
+struct svc_xprt {
+	struct svc_xprt_class	*xpt_class;
+	struct svc_xprt_ops	*xpt_ops;
+};
+
+int	svc_reg_xprt_class(struct svc_xprt_class *);
+void	svc_unreg_xprt_class(struct svc_xprt_class *);
+void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+
+#endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 5c69a72..92e1dbe 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -11,6 +11,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    rpcb_clnt.o timer.o xdr.o \
-	    sunrpc_syms.o cache.o rpc_pipe.o
+	    sunrpc_syms.o cache.o rpc_pipe.o \
+	    svc_xprt.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
new file mode 100644
index 0000000..fe5270f
--- /dev/null
+++ b/net/sunrpc/svc_xprt.c
@@ -0,0 +1,83 @@
+/*
+ * linux/net/sunrpc/svc_xprt.c
+ *
+ * Author: Tom Tucker <tom@opengridcomputing.com>
+ */
+
+#include <linux/sched.h>
+#include <linux/errno.h>
+#include <linux/fcntl.h>
+#include <linux/net.h>
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/udp.h>
+#include <linux/tcp.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/file.h>
+#include <linux/freezer.h>
+#include <net/sock.h>
+#include <net/checksum.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/tcp_states.h>
+#include <linux/uaccess.h>
+#include <asm/ioctls.h>
+
+#include <linux/sunrpc/types.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/svc_xprt.h>
+
+#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
+
+/* List of registered transport classes */
+static DEFINE_SPINLOCK(svc_xprt_class_lock);
+static LIST_HEAD(svc_xprt_class_list);
+
+int svc_reg_xprt_class(struct svc_xprt_class *xcl)
+{
+	struct svc_xprt_class *cl;
+	int res = -EEXIST;
+
+	dprintk("svc: Adding svc transport class '%s'\n", xcl->xcl_name);
+
+	INIT_LIST_HEAD(&xcl->xcl_list);
+	spin_lock(&svc_xprt_class_lock);
+	/* Make sure there isn't already a class with the same name */
+	list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
+		if (strcmp(xcl->xcl_name, cl->xcl_name) == 0)
+			goto out;
+	}
+	list_add_tail(&xcl->xcl_list, &svc_xprt_class_list);
+	res = 0;
+out:
+	spin_unlock(&svc_xprt_class_lock);
+	return res;
+}
+EXPORT_SYMBOL_GPL(svc_reg_xprt_class);
+
+void svc_unreg_xprt_class(struct svc_xprt_class *xcl)
+{
+	dprintk("svc: Removing svc transport class '%s'\n", xcl->xcl_name);
+	spin_lock(&svc_xprt_class_lock);
+	list_del_init(&xcl->xcl_list);
+	spin_unlock(&svc_xprt_class_lock);
+}
+EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
+
+/*
+ * Called by transport drivers to initialize the transport independent
+ * portion of the transport instance.
+ */
+void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
+{
+	memset(xprt, 0, sizeof(*xprt));
+	xprt->xpt_class = xcl;
+	xprt->xpt_ops = xcl->xcl_ops;
+}
+EXPORT_SYMBOL_GPL(svc_xprt_init);
-- 
1.5.4.rc2.60.gb2e62

