From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 01/33] svc: Add an svc transport class
Date: Thu, 27 Sep 2007 00:01:36 -0500
Message-ID: <20070927050136.12677.36924.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVJ-0005ar-EL
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:37 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVO-0001c7-2a
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:42 -0700
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
---

 include/linux/sunrpc/debug.h    |    1 
 include/linux/sunrpc/svc_xprt.h |   31 +++++++++++++
 net/sunrpc/Makefile             |    3 +
 net/sunrpc/svc_xprt.c           |   94 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 128 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 3912cf1..092fcfa 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -21,6 +21,7 @@ #define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
 #define RPCDBG_SVCSOCK		0x0100
+#define RPCDBG_SVCXPRT		0x0100
 #define RPCDBG_SVCDSP		0x0200
 #define RPCDBG_MISC		0x0400
 #define RPCDBG_CACHE		0x0800
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
new file mode 100644
index 0000000..a9a3afe
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
+	struct svc_xprt_ops	xpt_ops;
+};
+
+int	svc_reg_xprt_class(struct svc_xprt_class *);
+int	svc_unreg_xprt_class(struct svc_xprt_class *);
+void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *);
+
+#endif /* SUNRPC_SVC_XPRT_H */
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 8ebfc4d..e37aa99 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -10,6 +10,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprt
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
index 0000000..f868192
--- /dev/null
+++ b/net/sunrpc/svc_xprt.c
@@ -0,0 +1,94 @@
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
+#include <asm/uaccess.h>
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
+static spinlock_t svc_xprt_class_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(svc_xprt_class_list);
+
+int svc_reg_xprt_class(struct svc_xprt_class *xcl)
+{
+	struct svc_xprt_class *cl;
+	int res = -EEXIST;
+
+	dprintk("svc: Adding svc transport class '%s'\n",
+		xcl->xcl_name);
+
+	INIT_LIST_HEAD(&xcl->xcl_list);
+	spin_lock(&svc_xprt_class_lock);
+	list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
+		if (xcl == cl)
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
+int svc_unreg_xprt_class(struct svc_xprt_class *xcl)
+{
+	struct svc_xprt_class *cl;
+	int res = 0;
+
+	dprintk("svc: Removing svc transport class '%s'\n", xcl->xcl_name);
+
+	spin_lock(&svc_xprt_class_lock);
+	list_for_each_entry(cl, &svc_xprt_class_list, xcl_list) {
+		if (xcl == cl) {
+			list_del_init(&cl->xcl_list);
+			goto out;
+		}
+	}
+	res = -ENOENT;
+ out:
+	spin_unlock(&svc_xprt_class_lock);
+	return res;
+}
+EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
+
+/*
+ * Called by transport drivers to initialize the transport independent
+ * portion of the transport instance.
+ */
+void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xpt)
+{
+	xpt->xpt_class = xcl;
+	xpt->xpt_ops = *xcl->xcl_ops;
+}
+EXPORT_SYMBOL_GPL(svc_xprt_init);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
