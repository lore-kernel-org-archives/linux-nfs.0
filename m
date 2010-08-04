Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43818 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757978Ab0HDUp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 16:45:59 -0400
Received: from [10.58.49.162] (cbob1-lxp.hq.netapp.com [10.58.49.162] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o74Kjws2028392
	for <linux-nfs@vger.kernel.org>; Wed, 4 Aug 2010 13:45:59 -0700 (PDT)
Message-ID: <4C59D1A3.5030406@netapp.com>
Date: Wed, 04 Aug 2010 16:46:27 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS use kernel DNS resolver
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Use the kernel DNS resolver to translate hostnames to IP addresses.
Create a new config option to choose between the legacy DNS resolver and the
new resolver.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..b1209ac 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -100,3 +100,19 @@ config NFS_FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
 	  the general filesystem cache manager
+
+config NFS_USE_LEGACY_DNS
+	bool "Use the legacy NFS DNS resolver"
+	depends on NFS_FS
+	help
+	  The kernel now provides a method for translating a host name into an
+	  IP address.  Select Y here if you would rather use your own DNS
+	  resolver script.
+
+	  If unsure, say N
+
+config NFS_USE_KERNEL_DNS
+	bool
+	depends on NFS_FS && !NFS_USE_LEGACY_DNS
+	select DNS_RESOLVER
+	default y
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index da7fda6..ec8989c 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -7,7 +7,7 @@ obj-$(CONFIG_NFS_FS) += nfs.o
 nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o nfs2xdr.o \
 			   direct.o pagelist.o proc.o read.o symlink.o unlink.o \
 			   write.o namespace.o mount_clnt.o \
-			   dns_resolve.o cache_lib.o
+			   dns_resolve.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
@@ -15,5 +15,6 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
+nfs-$(CONFIG_NFS_LEGACY_DNS) += cache_lib.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index 76fd235..a67e2a4 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -6,6 +6,28 @@
  * Resolves DNS hostnames into valid ip addresses
  */

+#ifdef CONFIG_NFS_USE_KERNEL_DNS
+
+#include <linux/sunrpc/clnt.h>
+#include <linux/dns_resolver.h>
+
+ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
+		struct sockaddr *sa, size_t salen)
+{
+	ssize_t ret;
+	char *ip_addr = NULL;
+	int ip_len;
+
+	ip_len = dns_query(NULL, name, namelen, NULL, &ip_addr, NULL);
+	if (ip_len > 0)
+		ret = rpc_pton(ip_addr, ip_len, sa, salen);
+	else
+		ret = -ESRCH;
+	kfree(ip_addr);
+	return ret;
+}
+#else
+
 #include <linux/hash.h>
 #include <linux/string.h>
 #include <linux/kmod.h>
@@ -346,3 +368,4 @@ void nfs_dns_resolver_destroy(void)
 	nfs_cache_unregister(&nfs_dns_resolve);
 }

+#endif
diff --git a/fs/nfs/dns_resolve.h b/fs/nfs/dns_resolve.h
index a3f0938..fe5c3b3 100644
--- a/fs/nfs/dns_resolve.h
+++ b/fs/nfs/dns_resolve.h
@@ -6,8 +6,21 @@

 #define NFS_DNS_HOSTNAME_MAXLEN	(128)

+
+#ifdef CONFIG_NFS_USE_KERNEL_DNS
+static inline int nfs_dns_resolver_init(void)
+{
+	return 0;
+}
+
+static inline void nfs_dns_resolver_destroy(void)
+{
+}
+#else
 extern int nfs_dns_resolver_init(void);
 extern void nfs_dns_resolver_destroy(void);
+#endif
+
 extern ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
 		struct sockaddr *sa, size_t salen);
