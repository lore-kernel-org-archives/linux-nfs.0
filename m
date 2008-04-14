From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/24] SUNRPC: Add kernel build option to disable server-side
	use of rpcbind v3/v4
Date: Mon, 14 Apr 2008 12:29:35 -0400
Message-ID: <20080414162935.12741.98512.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55423 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759781AbYDNQaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:30:09 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 fs/Kconfig |   30 ++++++++++++++++++++++++++++--
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index f1bc33f..56e6fa5 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1772,7 +1772,7 @@ config SUNRPC_XPRT_RDMA
 	  If unsure, say N.
 
 config SUNRPC_BIND34
-	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
+	bool "Support for rpcbind v3 & v4 queries (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
 	default n
 	help
@@ -1785,13 +1785,39 @@ config SUNRPC_BIND34
 	  querying rpcbind servers via versions 3 and 4 of the rpcbind
 	  protocol.  The kernel automatically falls back to version 2
 	  if a remote rpcbind service does not support versions 3 or 4.
+
 	  By themselves, these new versions do not provide support for
 	  RPC over IPv6, but the new protocol versions are necessary to
-	  support it.
+	  support it.  Enabling this option is required to support
+	  mounting NFS servers over IPv6 networks.
 
 	  If unsure, say N to get traditional behavior (version 2 rpcbind
 	  requests only).
 
+config SUNRPC_REGISTER_V4
+	bool "Register local RPC services via rpcbind v4 (EXPERIMENTAL)"
+	depends on SUNRPC && EXPERIMENTAL
+	default n
+	help 
+	  RPC requests over IPv6 networks require support for larger
+	  addresses when performing an RPC bind.  Sun added support for
+	  registering RPC services at an IPv6 address by creating two
+	  new versions of the rpcbind protocol (RFC 1833).
+
+	  This option enables support in the kernel RPC server for
+	  registering local RPC services via version 4 of the rpcbind
+	  protocol.  If you enable this option, you must run a user
+	  space portmapper daemon capable of understanding rpcbind
+	  protocol version 4.
+
+	  If unsure, say N to get traditional behavior (register local
+	  services using only rpcbind version 2).
+
+	  Enabling this option and using a portmapper capable of
+	  responding to rpcbind version 4 requests is required to support
+	  serving NFS requests over IPv6 networks.  Distributions using
+	  the legacy Linux portmapper daemon must say N here.
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL

