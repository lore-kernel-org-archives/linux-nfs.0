From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] SUNRPC: Update help Kconfig text
Date: Thu, 14 Feb 2008 15:58:18 -0500
Message-ID: <20080214205818.11765.39259.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:16504 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbYBNU6V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:58:21 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKwJWS010232
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:58:20 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKwIj3011805
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: refresh the help text for Kconfig items related to the sunrpc
module.  Remove obsolete URLs, and make the language consistent among
the options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |   46 +++++++++++++++++++++++++++++++---------------
 1 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 4d8260c..90a2caa 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1764,17 +1764,31 @@ config SUNRPC_XPRT_RDMA
 	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
 	default m
 	help
-	  Adds a client RPC transport for supporting kernel NFS over RDMA
-	  mounts, including Infiniband and iWARP. Experimental.
+	  This option enables an RPC client transport capability that
+	  allows the NFS client to mount servers via an RDMA-enabled
+	  transport.
+
+	  To compile RPC client RDMA transport support as a module,
+	  choose M here: the module will be called xprtrdma.
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
@@ -1788,12 +1802,13 @@ config RPCSEC_GSS_KRB5
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
 
@@ -1807,11 +1822,12 @@ config RPCSEC_GSS_SPKM3
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
 

