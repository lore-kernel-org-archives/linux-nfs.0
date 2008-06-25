From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] SUNRPC: Use only rpcbind v2 for AF_INET requests
Date: Wed, 25 Jun 2008 17:24:54 -0400
Message-ID: <20080625212454.3171.65856.stgit@ellison.1015granger.net>
References: <20080625212101.3171.86703.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62997 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbYFYV0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2008 17:26:39 -0400
In-Reply-To: <20080625212101.3171.86703.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some server vendors support the higher versions of rpcbind only for
AF_INET6.  The kernel doesn't need to use v3 or v4 for AF_INET anyway,
so change the kernel's rpcbind client to query AF_INET servers over
rpcbind v2 only.

This has a few interesting benefits:

1. If the rpcbind request is going over TCP, and the server doesn't
   support rpcbind versions 3 or 4, the client reduces by two the number
   of ephemeral ports left in TIME_WAIT for each rpcbind request.  This
   will help during NFS mount storms.

2. The rpcbind interaction with servers that don't support rpcbind
   versions 3 or 4 will use less network traffic.  Also helpful
   during mount storms.

3. We can eliminate the kernel build option that controls whether the
   kernel's rpcbind client uses rpcbind version 3 and 4 for AF_INET
   servers.  Less complicated kernel configuration...

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig             |   21 ---------------------
 net/sunrpc/rpcb_clnt.c |   12 ------------
 2 files changed, 0 insertions(+), 33 deletions(-)


diff --git a/fs/Kconfig b/fs/Kconfig
index 07a61f5..8cf8ee2 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1799,27 +1799,6 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
-config SUNRPC_BIND34
-	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
-	default n
-	help
-	  RPC requests over IPv6 networks require support for larger
-	  addresses when performing an RPC bind.  Sun added support for
-	  IPv6 addressing by creating two new versions of the rpcbind
-	  protocol (RFC 1833).
-
-	  This option enables support in the kernel RPC client for
-	  querying rpcbind servers via versions 3 and 4 of the rpcbind
-	  protocol.  The kernel automatically falls back to version 2
-	  if a remote rpcbind service does not support versions 3 or 4.
-	  By themselves, these new versions do not provide support for
-	  RPC over IPv6, but the new protocol versions are necessary to
-	  support it.
-
-	  If unsure, say N to get traditional behavior (version 2 rpcbind
-	  requests only).
-
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 59b1d51..2b3a013 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -593,16 +593,6 @@ static struct rpc_procinfo rpcb_procedures4[] = {
 };
 
 static struct rpcb_info rpcb_next_version[] = {
-#ifdef CONFIG_SUNRPC_BIND34
-	{
-		.rpc_vers	= RPCBVERS_4,
-		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETADDR],
-	},
-	{
-		.rpc_vers	= RPCBVERS_3,
-		.rpc_proc	= &rpcb_procedures3[RPCBPROC_GETADDR],
-	},
-#endif
 	{
 		.rpc_vers	= RPCBVERS_2,
 		.rpc_proc	= &rpcb_procedures2[RPCBPROC_GETPORT],
@@ -613,7 +603,6 @@ static struct rpcb_info rpcb_next_version[] = {
 };
 
 static struct rpcb_info rpcb_next_version6[] = {
-#ifdef CONFIG_SUNRPC_BIND34
 	{
 		.rpc_vers	= RPCBVERS_4,
 		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETADDR],
@@ -622,7 +611,6 @@ static struct rpcb_info rpcb_next_version6[] = {
 		.rpc_vers	= RPCBVERS_3,
 		.rpc_proc	= &rpcb_procedures3[RPCBPROC_GETADDR],
 	},
-#endif
 	{
 		.rpc_proc	= NULL,
 	},

