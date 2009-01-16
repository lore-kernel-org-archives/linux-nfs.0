From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 4/5] NFS: Convert trace points to trace markers
Date: Fri, 16 Jan 2009 11:32:14 -0500
Message-ID: <4970B68E.4090602@RedHat.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: SystemTAP <systemtap@redhat.com>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4970B451.4080201@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

This the magic that converts the trace points into trace marks
so systemtap scripts can read the data. There is a good chance
these interfaces could change, but it should not effect the 
trace points define in the code.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux/kernel/trace/Makefile.orig	2009-01-14 15:54:20.000000000 -0500
+++ linux/kernel/trace/Makefile	2009-01-15 12:23:11.000000000 -0500
@@ -18,7 +18,7 @@ endif
 obj-$(CONFIG_FUNCTION_TRACER) += libftrace.o
 obj-$(CONFIG_RING_BUFFER) += ring_buffer.o
 
-obj-$(CONFIG_TRACING) += trace.o
+obj-$(CONFIG_TRACING) += trace.o trace_nfs.o
 obj-$(CONFIG_CONTEXT_SWITCH_TRACER) += trace_sched_switch.o
 obj-$(CONFIG_SYSPROF_TRACER) += trace_sysprof.o
 obj-$(CONFIG_FUNCTION_TRACER) += trace_functions.o
--- /dev/null	2009-01-08 09:11:53.943261863 -0500
+++ linux/kernel/trace/trace_nfs.c	2009-01-15 12:23:11.000000000 -0500
@@ -0,0 +1,135 @@
+/*
+ * kernel/trace/nfs-trace.c
+ *
+ * NFS tracepoint probes.
+ */
+
+#include <linux/autoconf.h>
+#include <linux/module.h>
+#include <linux/marker.h>
+
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/xprt.h>
+
+#include <trace/nfs.h>
+
+/*
+ * NFS mount probs 
+ */
+void probe_nfs_mount(struct file_system_type *fs_type,
+	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
+{
+	trace_mark(nfs_mount, "%p %x %p %p %p", 
+		fs_type, flags, dev_name, raw_data, mnt);
+}
+void probe_nfs_mount_data_null(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_null, "%p %d", data, err); 
+}
+void probe_nfs_mount_data_invalvers(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_invalvers, "%p %d", data, err); 
+}
+void probe_nfs_mount_data_invalsec(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_invalsec, "%p %d", data, err); 
+}
+void probe_nfs_mount_data_nomem(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_nomem, "%p %d", data, err); 
+}
+void probe_nfs_mount_data_noaddr(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_noaddr, "%p %d", data, err); 
+}
+void probe_nfs_mount_data_badfh(struct nfs_mount_data *data, int err)
+{
+	trace_mark(nfs_mount_data_badfh, "%p %d", data, err); 
+}
+void probe_nfs_mount_init_clnt(struct nfs_client *clp, int error) {
+
+	trace_mark(nfs_mount_init_clnt, "%p %d", clp, error);
+}
+void probe_nfs_mount_get_root(struct super_block *sb, 
+	struct nfs_server *server, struct nfs_fh *mntfh)
+{
+	trace_mark(nfs_mount_get_root, "%p %p %p", sb, server, mntfh);
+}
+void probe_nfs__mount_get_root_fhget(struct super_block *sb, 
+	struct nfs_server *server, int error)
+{
+	trace_mark(nfs__mount_get_root_fhget, "%p %p %d", sb, server, error);
+}
+void probe_nfs__mount_get_root_dummy_root(struct super_block *sb, 
+	struct nfs_server *server, int error)
+{
+	trace_mark(nfs__mount_get_root_dummy_root, "%p %p %d", sb, server, error);
+}
+void probe_nfs__mount_get_root_alias(struct super_block *sb, 
+	struct nfs_server *server, int error)
+{
+	trace_mark(nfs__mount_get_root_alias, "%p %p %d", sb, server, error);
+}
+
+void probe_nfs_create_rpc_client(struct nfs_client *clp,
+	const struct rpc_timeout *timeo, rpc_authflavor_t flavor,
+	int flags)
+{
+	trace_mark(nfs_create_rpc_client, "%p %p %d %d", 
+		clp, timeo, flavor, flags);
+}
+void probe_nfs_create_rpc_client_proto(struct nfs_client *clp, int error)
+{
+
+	trace_mark(nfs_create_rpc_client_proto, "%p %d", clp, error);
+}
+void probe_nfs_start_lockd(struct nfs_server *server, int error)
+{
+	trace_mark(nfs_start_lockd, "%p %d", server, error);
+}
+void probe_nfs_init_server_rpcclient(struct nfs_server *server, 
+	const struct rpc_timeout *timeo,
+	rpc_authflavor_t flavor)
+{
+	trace_mark(nfs_init_server_rpcclient, "%p %p %d", server, timeo, flavor);
+}
+void probe_nfs_init_server_rpcclient_clone(
+	struct nfs_server *server, int error) 
+{
+	trace_mark(nfs_init_server_rpcclient_clone, "%p %d", server, error);
+}
+void probe_nfs_init_server_rpcclient_auth(
+	struct nfs_server *server, int error)
+{
+	trace_mark(nfs_init_server_rpcclient_auth, "%p %d", server, error);
+}
+void probe_nfs_mount_init_srv(
+	struct nfs_server *server, int error)
+{
+	trace_mark(nfs_mount_init_srv, "%p %d", server, error);
+}
+
+void probe_nfs_probe_fsinfo(struct nfs_server *server, 
+	struct nfs_fh *mntfh, struct nfs_fattr *fattr)
+{
+	trace_mark(nfs_probe_fsinfo, "%p %p %p", server, mntfh, fattr);
+}
+void probe_nfs_probe_fsinfo_setcaps(struct nfs_server *server,
+	struct nfs_fh *mntfh, int error)
+{
+	trace_mark(nfs_probe_fsinfo_setcaps, "%p %p %d", server, mntfh, error);
+}
+void probe_nfs_probe_fsinfo_fsinfo(struct nfs_server *server, int error)
+{
+	trace_mark(nfs_probe_fsinfo_fsinfo, "%p %d", server, error);
+}
+void probe_nfs_create_server(struct nfs_server *server, 
+	struct nfs_fh *mntfh, int error)
+{
+	trace_mark(nfs_create_server, "%p %p %d", server, mntfh, error);
+}
+void probe_nfs_mount_sget(struct nfs_server *server, int error)
+{
+	trace_mark(nfs_mount_sget, "%p %d", server, error);
+}
--- /dev/null	2009-01-08 09:11:53.943261863 -0500
+++ linux/include/trace/nfs.h	2009-01-15 12:30:45.000000000 -0500
@@ -0,0 +1,99 @@
+#ifndef _TRACE_NFS_H
+#define _TRACE_NFS_H
+#include <linux/init.h>
+#include <linux/kernel.h>
+
+#include <linux/buffer_head.h>
+#include <linux/tracepoint.h>
+
+#include <linux/nfs_mount.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_xdr.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/sunrpc/auth.h>
+
+#include <linux/posix_acl.h>
+/*
+ * NFS mounting trace points
+ */
+DECLARE_TRACE(nfs_mount, 
+	TPPROTO(struct file_system_type *fs_type, int flags, 
+		const char *dev_name, void *raw_data, struct vfsmount *mnt),
+	TPARGS(fs_type, flags, dev_name, raw_data, mnt));
+
+DECLARE_TRACE(nfs_mount_data_null, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+DECLARE_TRACE(nfs_mount_data_invalvers, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+DECLARE_TRACE(nfs_mount_data_invalsec, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+DECLARE_TRACE(nfs_mount_data_nomem, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+DECLARE_TRACE(nfs_mount_data_noaddr, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+DECLARE_TRACE(nfs_mount_data_badfh, 
+	TPPROTO(struct nfs_mount_data *data, int err), TPARGS(data, err));
+
+DECLARE_TRACE(nfs_mount_get_root, 
+	TPPROTO(struct super_block *sb, struct nfs_server *server, 
+		struct nfs_fh *mntfh),
+	TPARGS(sb, server, mntfh));
+DECLARE_TRACE(nfs_mount_getroot, 
+	TPPROTO(struct super_block *sb, struct nfs_server *server, 
+		int error),
+	TPARGS(sb, server, error));
+DECLARE_TRACE(nfs_mount_get_root_fhget, 
+	TPPROTO(struct super_block *sb, struct nfs_server *server, 
+		int error),
+	TPARGS(sb, server, error));
+DECLARE_TRACE(nfs_mount_get_root_alias, 
+	TPPROTO(struct super_block *sb, struct nfs_server *server, 
+		int error),
+	TPARGS(sb, server, error));
+DECLARE_TRACE(nfs_mount_get_root_dummy_root, 
+	TPPROTO(struct super_block *sb, struct nfs_server *server, 
+		int error),
+	TPARGS(sb, server, error));
+
+DECLARE_TRACE(nfs_create_rpc_client, 
+	TPPROTO(struct nfs_client *clp, const struct rpc_timeout *timeo,
+		rpc_authflavor_t flavor, int flags),
+	TPARGS(clp, timeo, flavor, flags));
+
+DECLARE_TRACE(nfs_create_rpc_client_proto, 
+	TPPROTO(struct nfs_client *clp, int error), 
+	TPARGS(clp,error));
+//DECLARE_TRACE(nfs_create_rpc_client_client, TPPROTO(int error), TPARGS(error));
+DECLARE_TRACE(nfs_mount_init_clnt, 
+	TPPROTO(struct nfs_client *clp, int error), TPARGS(clp, error));
+DECLARE_TRACE(nfs_mount_init_srv, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+
+DECLARE_TRACE(nfs_mount_sget, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+
+DECLARE_TRACE(nfs_init_server_rpcclient, 
+	TPPROTO(struct nfs_server *server, const struct rpc_timeout *timeo, 
+		rpc_authflavor_t flavor),
+	TPARGS(server, timeo, flavor));
+DECLARE_TRACE(nfs_init_server_rpcclient_clone, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+DECLARE_TRACE(nfs_init_server_rpcclient_auth, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+
+DECLARE_TRACE(nfs_start_lockd, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+
+DECLARE_TRACE(nfs_probe_fsinfo, 
+	TPPROTO(struct nfs_server *server, struct nfs_fh *mntfh, 
+		struct nfs_fattr *fattr),
+	TPARGS(server, mntfh, fattr));
+DECLARE_TRACE(nfs_probe_fsinfo_fsinfo, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+DECLARE_TRACE(nfs_probe_fsinfo_setcaps, 
+	TPPROTO(struct nfs_server *server, int error), TPARGS(server, error));
+
+DECLARE_TRACE(nfs_create_server, 
+	TPPROTO(struct nfs_server *server, struct nfs_fh *mntfh, int error),
+	TPARGS(server, mntfh, error));
+#endif
