From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] SUNRPC: Add kernel build option to disable server-side
	use of rpcbind v3/v4
Date: Mon, 30 Jun 2008 18:46:09 -0400
Message-ID: <20080630224609.24887.20585.stgit@ellison.1015granger.net>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47572 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763464AbYF3WsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:48:08 -0400
In-Reply-To: <20080630224147.24887.18730.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
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
index 8cf8ee2..6148f4c 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1799,6 +1799,28 @@ config SUNRPC_XPRT_RDMA
 
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

