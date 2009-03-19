From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/23] SUNRPC: Remove CONFIG_SUNRPC_REGISTER_V4
Date: Wed, 18 Mar 2009 20:47:51 -0400
Message-ID: <20090319004751.32404.28608.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:26640 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755768AbZCSAsk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:48:40 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 net/sunrpc/Kconfig |   22 ----------------------
 1 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 5592883..afd91c7 100644
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

