From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
Date: Fri, 16 Jan 2009 10:39:18 -0500
Message-ID: <20090116153918.13042.97707.stgit@ingres.1015granger.net>
References: <20090116153327.13042.80083.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:28285 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbZAPPlG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jan 2009 10:41:06 -0500
In-Reply-To: <20090116153327.13042.80083.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We just augmented the kernel's RPC service registration code so that
it automatically adjusts to what is supported in user space.  Thus we
no longer need the kernel configuration option to enable registering
RPC services with v4 -- it's all done automatically.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig     |   22 ----------------------
 fs/lockd/svc.c |    7 +++----
 2 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 51307b0..48ecb85 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1401,28 +1401,6 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
-config SUNRPC_REGISTER_V4
-	bool "Register local RPC services via rpcbind v4 (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
-	default n
-	help
-	  Sun added support for registering RPC services at an IPv6
-	  address by creating two new versions of the rpcbind protocol
-	  (RFC 1833).
-
-	  This option enables support in the kernel RPC server for
-	  registering kernel RPC services via version 4 of the rpcbind
-	  protocol.  If you enable this option, you must run a portmapper
-	  daemon that supports rpcbind protocol version 4.
-
-	  Serving NFS over IPv6 from knfsd (the kernel's NFS server)
-	  requires that you enable this option and use a portmapper that
-	  supports rpcbind version 4.
-
-	  If unsure, say N to get traditional behavior (register kernel
-	  RPC services using only rpcbind version 2).  Distributions
-	  using the legacy Linux portmapper daemon must say N here.
-
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 64f1c31..cc3bf45 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -56,12 +56,11 @@ unsigned long			nlmsvc_timeout;
  * If the kernel has IPv6 support available, always listen for
  * both AF_INET and AF_INET6 requests.
  */
-#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
-	defined(CONFIG_SUNRPC_REGISTER_V4)
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static const sa_family_t	nlmsvc_family = AF_INET6;
-#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+#else	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
 static const sa_family_t	nlmsvc_family = AF_INET;
-#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) && CONFIG_SUNRPC_REGISTER_V4 */
+#endif	/* CONFIG_IPV6 || CONFIG_IPV6_MODULE */
 
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),

