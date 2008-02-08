From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/11] SUNRPC: Update help Kconfig text
Date: Fri, 08 Feb 2008 12:52:01 -0500
Message-ID: <20080208175201.16261.74366.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:8488 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758664AbYBHRwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:05 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refresh the help text for Kconfig items related to the sunrpc
module.  Remove obsolete URLs, and make the language consistent among
the options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |   44 +++++++++++++++++++++++++++++---------------
 1 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 53e21eb..9ad62a9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1766,17 +1766,29 @@ config SUNRPC_XPRT_RDMA
 	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
 	default m
 	help
-	  Adds a client RPC transport for supporting kernel NFS over RDMA
-	  mounts, including Infiniband and iWARP. Experimental.
+	  This option enables the RPC client transport capability that
+	  supports NFS over RDMA in the kernel's NFS client.  To compile
+	  RPC client RDMA transport support as a module, choose M here:
+	  the module will be called xprtrdma.
+
+	  If unsure, say N.
 
 config SUNRPC_BIND34
 	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
 	help
-	  Provides kernel support for querying rpcbind servers via versions 3
-	  and 4 of the rpcbind protocol.  The kernel automatically falls back
-	  to version 2 if a remote rpcbind service does not support versions
-	  3 or 4.
+	  RPC requests over IPv6 networks require support for larger
+	  addresses when performing an RPC bind.  Sun added support for
+	  IPv6 addressing by creating two new versions of the rpcbind
+	  protocol (RFC 1833).
+
+	  This option enables support in the kernel RPC client for
+	  querying rpcbind servers via versions 3 and 4 of the rpcbind
+	  protocol.  The kernel automatically falls back to version 2
+	  if a remote rpcbind service does not support versions 3 or 4.
+	  By themselves, these new versions do not provide support for
+	  RPC over IPv6, but the new protocol versions are necessary to
+	  support it.
 
 	  If unsure, say N to get traditional behavior (version 2 rpcbind
 	  requests only).
@@ -1790,12 +1802,13 @@ config RPCSEC_GSS_KRB5
 	select CRYPTO_DES
 	select CRYPTO_CBC
 	help
-	  Provides for secure RPC calls by means of a gss-api
-	  mechanism based on Kerberos V5. This is required for
-	  NFSv4.
+	  Choose Y here to enable Secure RPC using the Kerberos version 5
+	  GSS-API mechanism (RFC 1964).
 
-	  Note: Requires an auxiliary userspace daemon which may be found on
-		http://www.citi.umich.edu/projects/nfsv4/
+	  Secure RPC calls with Kerberos require an auxiliary user-space
+	  daemon which may be found in the Linux nfs-utils package
+	  available from http://linux-nfs.org/.  In addition, user-space
+	  Kerberos support should be installed.
 
 	  If unsure, say N.
 
@@ -1809,11 +1822,12 @@ config RPCSEC_GSS_SPKM3
 	select CRYPTO_CAST5
 	select CRYPTO_CBC
 	help
-	  Provides for secure RPC calls by means of a gss-api
-	  mechanism based on the SPKM3 public-key mechanism.
+	  Choose Y here to enable Secure RPC using the SPKM3 public key
+	  GSS-API mechansim (RFC 2025).
 
-	  Note: Requires an auxiliary userspace daemon which may be found on
-	  	http://www.citi.umich.edu/projects/nfsv4/
+	  Secure RPC calls with SPKM3 require an auxiliary userspace
+	  daemon which may be found in the Linux nfs-utils package
+	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
 

