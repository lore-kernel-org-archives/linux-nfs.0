From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] SUNRPC: Add kernel build option to disable server-side
	use of rpcbind v3/v4
Date: Wed, 13 Aug 2008 18:40:32 -0400
Message-ID: <20080813224032.13068.70558.stgit@manray.1015granger.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30806 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbYHMWlq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:41:46 -0400
In-Reply-To: <20080813223653.13068.9467.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow distributions to use the legacy behavior until they integrate an
appropriate user-space rpcbind daemon that can support IPv6 RPC services.

I tried adding some logic to fall back if (un)registering with a v4
protocol request failed, but there are too many corner cases.  So I just
made it a compile-time switch that distributions can throw when they've
replaced portmapper with rpcbind.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index d387358..949e6d1 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1765,6 +1765,28 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
+config SUNRPC_REGISTER_V4
+	bool "Register local RPC services via rpcbind v4 (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	default n
+	help 
+	  Sun added support for registering RPC services at an IPv6
+	  address by creating two new versions of the rpcbind protocol
+	  (RFC 1833).
+
+	  This option enables support in the kernel RPC server for
+	  registering kernel RPC services via version 4 of the rpcbind
+	  protocol.  If you enable this option, you must run a portmapper
+	  daemon that supports rpcbind protocol version 4.
+
+	  Serving NFS over IPv6 from knfsd (the kernel's NFS server)
+	  requires that you enable this option and use a portmapper that
+	  supports rpcbind version 4.
+
+	  If unsure, say N to get traditional behavior (register kernel
+	  RPC services using only rpcbind version 2).  Distributions
+	  using the legacy Linux portmapper daemon must say N here.
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL

