From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
Date: Fri, 30 Jan 2009 15:11:27 -0500
Message-ID: <20090130201126.22301.59078.stgit@ingres.1015granger.net>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:34142 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbZA3ULv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:11:51 -0500
In-Reply-To: <20090130200021.22301.22618.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 fs/lockd/svc.c     |    6 +++---
 net/sunrpc/Kconfig |   22 ----------------------
 2 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 39ec7f2..db5acc3 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -58,11 +58,11 @@ unsigned long			nlmsvc_timeout;
  * if the ipv6 module was built but has been blacklisted, enable
  * this only if IPv6 support is built into the kernel.
  */
-#if defined(CONFIG_IPV6) && defined(CONFIG_SUNRPC_REGISTER_V4)
+#if defined(CONFIG_IPV6)
 static const sa_family_t	nlmsvc_family = AF_INET6;
-#else	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
+#else	/* CONFIG_IPV6 */
 static const sa_family_t	nlmsvc_family = AF_INET;
-#endif	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
+#endif	/* CONFIG_IPV6 */
 
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index dcef600..45e275a 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -17,28 +17,6 @@ config SUNRPC_XPRT_RDMA
 
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

