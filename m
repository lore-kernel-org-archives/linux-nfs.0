From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 8/9] sunrpc: add Kconfig option for CONFIG_SUNRPC_SMB
Date: Sun, 27 Sep 2009 12:50:29 -0400
Message-ID: <1254070230-13125-9-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:54603 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbZI0Q5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:12 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and the necessary Makefile bits so to compile support into the sunrpc
module.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/Kconfig       |   11 +++++++++++
 net/sunrpc/Makefile      |    1 +
 net/sunrpc/sunrpc_syms.c |    3 +++
 net/sunrpc/xprtsmb.c     |    7 +++++--
 4 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 443c161..63f5ee7 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -54,3 +54,14 @@ config RPCSEC_GSS_SPKM3
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
+
+config SUNRPC_SMB
+	bool "SMB/CIFS Transport for the SUNRPC Layer (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	help
+	    This option adds the ability for the kernels SUNRPC Layer to
+	    send and receive Sever Message Block (SMB) traffic. This
+	    protocol is widely used by Microsoft Windows servers for
+	    filesharing.
+
+	    If unsure, say N.
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 9d2fca5..691e62f 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -16,3 +16,4 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
+sunrpc-$(CONFIG_SUNRPC_SMB) += xprtsmb.o smb.o
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 8cce921..65b4dec 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -21,6 +21,7 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/xprtsock.h>
+#include <linux/sunrpc/xprtsmb.h>
 
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
@@ -45,6 +46,7 @@ init_sunrpc(void)
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
+	init_smb_xprt();
 	rpcauth_init_module();
 out:
 	return err;
@@ -54,6 +56,7 @@ static void __exit
 cleanup_sunrpc(void)
 {
 	rpcauth_remove_module();
+	cleanup_smb_xprt();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();
 	unregister_rpc_pipefs();
diff --git a/net/sunrpc/xprtsmb.c b/net/sunrpc/xprtsmb.c
index 585cf37..362600a 100644
--- a/net/sunrpc/xprtsmb.c
+++ b/net/sunrpc/xprtsmb.c
@@ -1691,7 +1691,8 @@ static struct xprt_class	xs_smb_transport = {
  * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
  *
  */
-int init_smb_xprt(void)
+int
+init_smb_xprt(void)
 {
 #ifdef RPC_DEBUG
 	if (!sunrpc_table_header)
@@ -1707,7 +1708,8 @@ int init_smb_xprt(void)
  * cleanup_socket_xprt - remove xprtsock's sysctls, unregister
  *
  */
-void cleanup_smb_xprt(void)
+void
+cleanup_smb_xprt(void)
 {
 #ifdef RPC_DEBUG
 	if (sunrpc_table_header) {
@@ -1718,3 +1720,4 @@ void cleanup_smb_xprt(void)
 
 	xprt_unregister_transport(&xs_smb_transport);
 }
+
-- 
1.6.0.6

